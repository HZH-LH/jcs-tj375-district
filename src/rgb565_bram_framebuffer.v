`timescale 1ns/1ps

// Stores alternate 960x540 RGB565 frames in two BRAM banks. The display port
// reads one source pixel for every two horizontal and two vertical output
// pixels, producing a stable 1920x1080 stream without external DDR.
module rgb565_bram_framebuffer #(
    parameter SRC_WIDTH = 960,
    parameter SRC_HEIGHT = 540,
    parameter FRAME_PIXELS = SRC_WIDTH * SRC_HEIGHT,
    parameter ADDR_WIDTH = $clog2(FRAME_PIXELS)
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_vs,
    input  wire        in_de,
    input  wire [47:0] in_rgb2,
    input  wire        test_pattern_enable,
    input  wire        timing_vs,
    input  wire        timing_hs,
    input  wire        timing_de,
    output reg         out_vs = 1'b0,
    output reg         out_hs = 1'b0,
    output reg         out_de = 1'b0,
    output reg  [47:0] out_rgb2 = 48'd0,
    output reg         display_valid = 1'b0,
    output reg         pending_valid = 1'b0,
    output reg  [15:0] captured_frame_count = 16'd0,
    output reg  [15:0] displayed_frame_count = 16'd0,
    output reg  [15:0] swap_count = 16'd0,
    output reg  [15:0] dropped_frame_count = 16'd0,
    output reg         capture_error_sticky = 1'b0,
    output reg  [15:0] measured_frame_lines = 16'd0,
    output reg  [15:0] measured_line_de_min = 16'd0,
    output reg  [15:0] measured_line_de_max = 16'd0,
    output reg  [19:0] measured_frame_de_total = 20'd0
);

reg in_vs_d = 1'b0;
reg in_de_d = 1'b0;
reg timing_vs_d = 1'b0;
reg test_pattern_enable_d = 1'b0;
reg capture_active = 1'b0;
reg write_bank = 1'b1;
reg pending_bank = 1'b0;
reg display_bank = 1'b0;
reg [10:0] input_line = 11'd0;
reg [10:0] input_x_pair = 11'd0;
reg [ADDR_WIDTH-1:0] write_addr = {ADDR_WIDTH{1'b0}};
reg test_fill_active = 1'b0;
reg test_bank = 1'b1;
reg [10:0] test_x = 11'd0;
reg [10:0] test_y = 11'd0;
reg [ADDR_WIDTH-1:0] test_write_addr = {ADDR_WIDTH{1'b0}};
reg [15:0] geometry_line_de_count = 16'd0;
reg [15:0] geometry_frame_line_count = 16'd0;
reg [15:0] geometry_line_de_min = 16'hffff;
reg [15:0] geometry_line_de_max = 16'd0;
reg [19:0] geometry_frame_de_total = 20'd0;

reg [10:0] output_line = 11'd0;
reg [10:0] output_x = 11'd0;
reg [ADDR_WIDTH-1:0] read_line_base = {ADDR_WIDTH{1'b0}};
reg [ADDR_WIDTH-1:0] read_addr = {ADDR_WIDTH{1'b0}};
reg timing_vs_d1 = 1'b0;
reg timing_hs_d1 = 1'b0;
reg timing_de_d1 = 1'b0;
reg timing_vs_d2 = 1'b0;
reg timing_hs_d2 = 1'b0;
reg timing_de_d2 = 1'b0;

wire in_vs_rise = in_vs & ~in_vs_d;
wire in_de_fall = ~in_de & in_de_d;
wire timing_vs_rise = timing_vs & ~timing_vs_d;
wire test_pattern_rise = test_pattern_enable & ~test_pattern_enable_d;
wire [7:0] pixel0_r = in_rgb2[23:16];
wire [7:0] pixel0_g = in_rgb2[15:8];
wire [7:0] pixel0_b = in_rgb2[7:0];
wire [15:0] pixel0_rgb565 = {pixel0_r[7:3], pixel0_g[7:2], pixel0_b[7:3]};
wire [15:0] test_rgb565 = (test_x < 11'd320) ?
                          (test_y[5] ? 16'hf800 : 16'h7800) :
                          (test_x < 11'd640) ?
                          (test_y[5] ? 16'h07e0 : 16'h03e0) :
                          (test_y[5] ? 16'h001f : 16'h000f);

wire [15:0] bank0_read_data;
wire [15:0] bank1_read_data;
wire [15:0] read_data = display_bank ? bank1_read_data : bank0_read_data;
wire camera_frame_write = capture_active && in_de && !input_line[0] &&
                          (input_x_pair < SRC_WIDTH);
wire frame_write = test_fill_active || camera_frame_write;
wire frame_write_bank = test_fill_active ? test_bank : write_bank;
wire [ADDR_WIDTH-1:0] frame_write_addr = test_fill_active ? test_write_addr : write_addr;
wire [15:0] frame_write_data = test_fill_active ? test_rgb565 : pixel0_rgb565;

wire [7:0] read_r8 = {read_data[15:11], read_data[15:13]};
wire [7:0] read_g8 = {read_data[10:5], read_data[10:9]};
wire [7:0] read_b8 = {read_data[4:0], read_data[4:2]};
wire [23:0] read_rgb888 = {read_r8, read_g8, read_b8};

bram_chunked_frame_bank #(
    .DATA_WIDTH(16),
    .ADDR_WIDTH(ADDR_WIDTH),
    .CHUNK_ADDR_WIDTH(13)
) u_frame_bank0 (
    .clk(clk),
    .write_en(frame_write && !frame_write_bank),
    .write_addr(frame_write_addr),
    .write_data(frame_write_data),
    .read_en(timing_de && display_valid && !display_bank),
    .read_addr(read_addr),
    .read_data(bank0_read_data)
);

bram_chunked_frame_bank #(
    .DATA_WIDTH(16),
    .ADDR_WIDTH(ADDR_WIDTH),
    .CHUNK_ADDR_WIDTH(13)
) u_frame_bank1 (
    .clk(clk),
    .write_en(frame_write && frame_write_bank),
    .write_addr(frame_write_addr),
    .write_data(frame_write_data),
    .read_en(timing_de && display_valid && display_bank),
    .read_addr(read_addr),
    .read_data(bank1_read_data)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_vs_d <= 1'b0;
        in_de_d <= 1'b0;
        test_pattern_enable_d <= 1'b0;
        capture_active <= 1'b0;
        write_bank <= 1'b1;
        pending_bank <= 1'b0;
        pending_valid <= 1'b0;
        display_bank <= 1'b0;
        display_valid <= 1'b0;
        input_line <= 11'd0;
        input_x_pair <= 11'd0;
        write_addr <= {ADDR_WIDTH{1'b0}};
        test_fill_active <= 1'b0;
        test_bank <= 1'b1;
        test_x <= 11'd0;
        test_y <= 11'd0;
        test_write_addr <= {ADDR_WIDTH{1'b0}};
        captured_frame_count <= 16'd0;
        swap_count <= 16'd0;
        dropped_frame_count <= 16'd0;
        capture_error_sticky <= 1'b0;
    end else begin
        in_vs_d <= in_vs;
        in_de_d <= in_de;
        test_pattern_enable_d <= test_pattern_enable;

        if (test_pattern_rise) begin
            capture_active <= 1'b0;
            pending_valid <= 1'b0;
            test_fill_active <= 1'b1;
            test_bank <= ~display_bank;
            test_x <= 11'd0;
            test_y <= 11'd0;
            test_write_addr <= {ADDR_WIDTH{1'b0}};
        end else if (test_fill_active) begin
            if (test_write_addr == FRAME_PIXELS - 1) begin
                test_fill_active <= 1'b0;
                pending_bank <= test_bank;
                pending_valid <= 1'b1;
                captured_frame_count <= captured_frame_count + 1'b1;
            end else begin
                test_write_addr <= test_write_addr + 1'b1;
                if (test_x == SRC_WIDTH - 1) begin
                    test_x <= 11'd0;
                    test_y <= test_y + 1'b1;
                end else begin
                    test_x <= test_x + 1'b1;
                end
            end
        end else if (!test_pattern_enable && in_vs_rise) begin
            input_line <= 11'd0;
            input_x_pair <= 11'd0;
            write_addr <= {ADDR_WIDTH{1'b0}};
            if (!pending_valid && (write_bank != display_bank)) begin
                capture_active <= 1'b1;
            end else begin
                capture_active <= 1'b0;
                capture_error_sticky <= 1'b1;
                if (dropped_frame_count != 16'hffff)
                    dropped_frame_count <= dropped_frame_count + 1'b1;
            end
        end

        if (!test_pattern_enable && capture_active && in_de) begin
            if (!input_line[0]) begin
                if (write_addr == FRAME_PIXELS - 1) begin
                    pending_bank <= write_bank;
                    pending_valid <= 1'b1;
                    capture_active <= 1'b0;
                    captured_frame_count <= captured_frame_count + 1'b1;
                end else begin
                    write_addr <= write_addr + 1'b1;
                end
            end

            // rgb_de can contain short gaps inside a physical line. Derive the
            // logical line boundary from the known 960 valid two-pixel words.
            if (input_x_pair == SRC_WIDTH - 1) begin
                input_x_pair <= 11'd0;
                input_line <= input_line + 1'b1;
            end else begin
                input_x_pair <= input_x_pair + 1'b1;
            end
        end

        if (timing_vs_rise && pending_valid) begin
            display_bank <= pending_bank;
            write_bank <= ~pending_bank;
            pending_valid <= 1'b0;
            display_valid <= 1'b1;
            swap_count <= swap_count + 1'b1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timing_vs_d <= 1'b0;
        timing_vs_d1 <= 1'b0;
        timing_hs_d1 <= 1'b0;
        timing_de_d1 <= 1'b0;
        timing_vs_d2 <= 1'b0;
        timing_hs_d2 <= 1'b0;
        timing_de_d2 <= 1'b0;
        output_line <= 11'd0;
        output_x <= 11'd0;
        read_line_base <= {ADDR_WIDTH{1'b0}};
        read_addr <= {ADDR_WIDTH{1'b0}};
        out_vs <= 1'b0;
        out_hs <= 1'b0;
        out_de <= 1'b0;
        out_rgb2 <= 48'd0;
        displayed_frame_count <= 16'd0;
    end else begin
        timing_vs_d <= timing_vs;
        timing_vs_d1 <= timing_vs;
        timing_hs_d1 <= timing_hs;
        timing_de_d1 <= timing_de;
        timing_vs_d2 <= timing_vs_d1;
        timing_hs_d2 <= timing_hs_d1;
        timing_de_d2 <= timing_de_d1;

        out_vs <= timing_vs_d1;
        out_hs <= timing_hs_d1;
        out_de <= timing_de_d1;
        out_rgb2 <= display_valid ? {read_rgb888, read_rgb888} : 48'd0;

        if (timing_vs_rise) begin
            output_line <= 11'd0;
            output_x <= 11'd0;
            read_line_base <= {ADDR_WIDTH{1'b0}};
            read_addr <= {ADDR_WIDTH{1'b0}};
            displayed_frame_count <= displayed_frame_count + 1'b1;
        end else if (timing_de) begin
            if (output_x == SRC_WIDTH - 1) begin
                output_x <= 11'd0;
                output_line <= output_line + 1'b1;
                if (output_line[0])
                    read_line_base <= read_line_base + SRC_WIDTH;
                read_addr <= output_line[0] ? read_line_base + SRC_WIDTH : read_line_base;
            end else begin
                output_x <= output_x + 1'b1;
                read_addr <= read_addr + 1'b1;
            end
        end
    end
end

// Measure the stream presented to the BRAM writer without influencing it.
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        geometry_line_de_count <= 16'd0;
        geometry_frame_line_count <= 16'd0;
        geometry_line_de_min <= 16'hffff;
        geometry_line_de_max <= 16'd0;
        geometry_frame_de_total <= 20'd0;
        measured_frame_lines <= 16'd0;
        measured_line_de_min <= 16'd0;
        measured_line_de_max <= 16'd0;
        measured_frame_de_total <= 20'd0;
    end else begin
        if (in_de) begin
            geometry_line_de_count <= geometry_line_de_count + 1'b1;
            geometry_frame_de_total <= geometry_frame_de_total + 1'b1;
        end

        if (in_de_fall) begin
            geometry_frame_line_count <= geometry_frame_line_count + 1'b1;
            if (geometry_line_de_count < geometry_line_de_min)
                geometry_line_de_min <= geometry_line_de_count;
            if (geometry_line_de_count > geometry_line_de_max)
                geometry_line_de_max <= geometry_line_de_count;
            geometry_line_de_count <= 16'd0;
        end

        if (in_vs_rise) begin
            measured_frame_lines <= geometry_frame_line_count;
            measured_line_de_min <= (geometry_line_de_min == 16'hffff) ? 16'd0 : geometry_line_de_min;
            measured_line_de_max <= geometry_line_de_max;
            measured_frame_de_total <= geometry_frame_de_total;
            geometry_frame_line_count <= 16'd0;
            geometry_line_de_min <= 16'hffff;
            geometry_line_de_max <= 16'd0;
            geometry_frame_de_total <= 20'd0;
        end
    end
end

endmodule

// Splitting the frame into moderate-depth memories avoids Efinity expanding a
// single 518400-entry Verilog array in the top-level mapper. Each chunk is
// independently inferred as cascaded RAM10 blocks.
module bram_chunked_frame_bank #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 19,
    parameter CHUNK_ADDR_WIDTH = 13,
    parameter CHUNK_COUNT = 1 << (ADDR_WIDTH - CHUNK_ADDR_WIDTH)
) (
    input  wire                  clk,
    input  wire                  write_en,
    input  wire [ADDR_WIDTH-1:0] write_addr,
    input  wire [DATA_WIDTH-1:0] write_data,
    input  wire                  read_en,
    input  wire [ADDR_WIDTH-1:0] read_addr,
    output wire [DATA_WIDTH-1:0] read_data
);

localparam CHUNK_SELECT_WIDTH = ADDR_WIDTH - CHUNK_ADDR_WIDTH;
localparam CHUNK_DEPTH = 1 << CHUNK_ADDR_WIDTH;

wire [CHUNK_SELECT_WIDTH-1:0] write_chunk = write_addr[ADDR_WIDTH-1:CHUNK_ADDR_WIDTH];
wire [CHUNK_SELECT_WIDTH-1:0] read_chunk = read_addr[ADDR_WIDTH-1:CHUNK_ADDR_WIDTH];
reg  [CHUNK_SELECT_WIDTH-1:0] read_chunk_d = {CHUNK_SELECT_WIDTH{1'b0}};
wire [CHUNK_COUNT*DATA_WIDTH-1:0] chunk_read_data;

always @(posedge clk) begin
    if (read_en)
        read_chunk_d <= read_chunk;
end

genvar chunk_index;
generate
    for (chunk_index = 0; chunk_index < CHUNK_COUNT; chunk_index = chunk_index + 1) begin : g_chunk
        (* syn_ramstyle = "block_ram" *) reg [DATA_WIDTH-1:0] memory [0:CHUNK_DEPTH-1];
        reg [DATA_WIDTH-1:0] read_data_reg = {DATA_WIDTH{1'b0}};

        always @(posedge clk) begin
            if (write_en && (write_chunk == chunk_index))
                memory[write_addr[CHUNK_ADDR_WIDTH-1:0]] <= write_data;
            if (read_en && (read_chunk == chunk_index))
                read_data_reg <= memory[read_addr[CHUNK_ADDR_WIDTH-1:0]];
        end

        assign chunk_read_data[chunk_index*DATA_WIDTH +: DATA_WIDTH] = read_data_reg;
    end
endgenerate

assign read_data = chunk_read_data[read_chunk_d*DATA_WIDTH +: DATA_WIDTH];

endmodule
