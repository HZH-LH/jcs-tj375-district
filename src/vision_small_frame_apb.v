`timescale 1ns/1ps

// Non-blocking camera tap with an APB3 read window for the hardened RISC-V.
// The video side writes complete 160x90 RGB565 frames into alternating banks.
// APB software can claim the latest bank to prevent overwrite while reading it.
module vision_small_frame_apb #(
    parameter INPUT_WORDS_PER_LINE = 960,
    parameter INPUT_LINES = 1080,
    parameter OUTPUT_WIDTH = 160,
    parameter OUTPUT_HEIGHT = 90,
    parameter H_STEP = 12,
    parameter V_STEP = 12,
    parameter FRAME_PIXELS = OUTPUT_WIDTH * OUTPUT_HEIGHT,
    parameter FRAME_WORDS = FRAME_PIXELS / 2
) (
    input  wire        video_clk,
    input  wire        video_rst_n,
    input  wire        video_vs,
    input  wire        video_de,
    input  wire        video_valid,
    input  wire [47:0] video_grb2,

    input  wire        apb_clk,
    input  wire        apb_reset,
    input  wire [31:0] apb_paddr,
    input  wire        apb_psel,
    input  wire        apb_penable,
    input  wire        apb_pwrite,
    input  wire [31:0] apb_pwdata,
    output wire [31:0] apb_prdata,
    output wire        apb_pready,
    output wire        apb_pslverror
);

localparam [15:0] REG_MAGIC        = 16'h0000;
localparam [15:0] REG_VERSION      = 16'h0004;
localparam [15:0] REG_DIMENSIONS   = 16'h0008;
localparam [15:0] REG_FORMAT       = 16'h000c;
localparam [15:0] REG_FRAME_SEQ    = 16'h0010;
localparam [15:0] REG_LATEST_BANK  = 16'h0014;
localparam [15:0] REG_STATUS       = 16'h0018;
localparam [15:0] REG_BUFFER0      = 16'h001c;
localparam [15:0] REG_BUFFER1      = 16'h0020;
localparam [15:0] REG_BUFFER_BYTES = 16'h0024;
localparam [15:0] REG_DROP_COUNT   = 16'h0028;
localparam [15:0] REG_FRAME_COUNT  = 16'h002c;
localparam [15:0] REG_CONTROL      = 16'h0030;
localparam [15:0] REG_CLAIM_BANK   = 16'h0034;
localparam [15:0] REG_CLAIM_SEQ    = 16'h0038;

localparam [15:0] BUFFER0_OFFSET = 16'h1000;
localparam [15:0] BUFFER1_OFFSET = 16'h8100;
localparam [15:0] BUFFER_BYTES = 16'h7080;

wire [7:0] pix0_g = video_grb2[23:16];
wire [7:0] pix0_r = video_grb2[15:8];
wire [7:0] pix0_b = video_grb2[7:0];
wire [15:0] pix0_rgb565 = {pix0_r[7:3], pix0_g[7:2], pix0_b[7:3]};

reg video_vs_d = 1'b0;
reg video_de_d = 1'b0;
reg [5:0] h_phase = 6'd0;
reg [5:0] v_phase = 6'd0;
reg [7:0] sample_col = 8'd0;
reg capture_active = 1'b0;
reg write_bank = 1'b0;
reg half_pending = 1'b0;
reg [15:0] low_pixel = 16'd0;
reg [13:0] sampled_pixel_count = 14'd0;
reg [12:0] write_word_addr = 13'd0;
reg published_valid = 1'b0;
reg published_bank = 1'b0;
reg [31:0] published_seq = 32'd0;
reg [31:0] completed_frame_count = 32'd0;
reg [31:0] dropped_frame_count = 32'd0;
reg capture_error_sticky = 1'b0;
reg publish_toggle = 1'b0;

reg hold_active_meta = 1'b0;
reg hold_active_video = 1'b0;
reg hold_bank_meta = 1'b0;
reg hold_bank_video = 1'b0;
reg hold_active_apb = 1'b0;
reg hold_bank_apb = 1'b0;
reg [31:0] hold_seq_apb = 32'd0;

wire video_vs_rise = video_vs & ~video_vs_d;
wire video_de_rise = video_de & ~video_de_d;
wire video_de_fall = ~video_de & video_de_d;
wire frame_complete = (sampled_pixel_count == FRAME_PIXELS) && !half_pending;
wire next_write_bank = frame_complete ? ~write_bank : write_bank;
wire next_bank_blocked = hold_active_video && (hold_bank_video == next_write_bank);
wire take_sample = capture_active && video_valid && video_de &&
                   (h_phase == 6'd0) && (v_phase == 6'd0) &&
                   (sample_col < OUTPUT_WIDTH) &&
                   (sampled_pixel_count < FRAME_PIXELS);
wire frame_word_write = take_sample && half_pending;
wire [31:0] frame_word_data = {pix0_rgb565, low_pixel};
wire [31:0] apb_bank0_read_data;
wire [31:0] apb_bank1_read_data;
wire apb_bank0_read;
wire apb_bank1_read;
wire [12:0] apb_buffer0_word_addr;
wire [12:0] apb_buffer1_word_addr;

vision_frame_bank_dc u_small_frame_bank0 (
    .wclk(video_clk),
    .we(frame_word_write && !write_bank),
    .waddr(write_word_addr),
    .din(frame_word_data),
    .rclk(apb_clk),
    .re(apb_bank0_read),
    .raddr(apb_buffer0_word_addr),
    .dout(apb_bank0_read_data)
);

vision_frame_bank_dc u_small_frame_bank1 (
    .wclk(video_clk),
    .we(frame_word_write && write_bank),
    .waddr(write_word_addr),
    .din(frame_word_data),
    .rclk(apb_clk),
    .re(apb_bank1_read),
    .raddr(apb_buffer1_word_addr),
    .dout(apb_bank1_read_data)
);

always @(posedge video_clk or negedge video_rst_n) begin
    if (!video_rst_n) begin
        hold_active_meta <= 1'b0;
        hold_active_video <= 1'b0;
        hold_bank_meta <= 1'b0;
        hold_bank_video <= 1'b0;
    end else begin
        hold_active_meta <= hold_active_apb;
        hold_active_video <= hold_active_meta;
        hold_bank_meta <= hold_bank_apb;
        hold_bank_video <= hold_bank_meta;
    end
end

always @(posedge video_clk or negedge video_rst_n) begin
    if (!video_rst_n) begin
        video_vs_d <= 1'b0;
        video_de_d <= 1'b0;
        h_phase <= 6'd0;
        v_phase <= 6'd0;
        sample_col <= 8'd0;
        capture_active <= 1'b0;
        write_bank <= 1'b0;
        half_pending <= 1'b0;
        low_pixel <= 16'd0;
        sampled_pixel_count <= 14'd0;
        write_word_addr <= 13'd0;
        published_valid <= 1'b0;
        published_bank <= 1'b0;
        published_seq <= 32'd0;
        completed_frame_count <= 32'd0;
        dropped_frame_count <= 32'd0;
        capture_error_sticky <= 1'b0;
        publish_toggle <= 1'b0;
    end else begin
        video_vs_d <= video_vs;
        video_de_d <= video_de;

        if (video_vs_rise) begin
            if (capture_active) begin
                if (frame_complete) begin
                    published_valid <= 1'b1;
                    published_bank <= write_bank;
                    published_seq <= published_seq + 1'b1;
                    completed_frame_count <= completed_frame_count + 1'b1;
                    publish_toggle <= ~publish_toggle;
                end else begin
                    capture_error_sticky <= 1'b1;
                    dropped_frame_count <= dropped_frame_count + 1'b1;
                end
            end

            write_bank <= next_write_bank;
            capture_active <= !next_bank_blocked;
            if (next_bank_blocked)
                dropped_frame_count <= dropped_frame_count + 1'b1;

            h_phase <= 6'd0;
            v_phase <= 6'd0;
            sample_col <= 8'd0;
            half_pending <= 1'b0;
            sampled_pixel_count <= 14'd0;
            write_word_addr <= 13'd0;
        end else if (video_de) begin
            if (video_de_rise) begin
                h_phase <= 6'd0;
                sample_col <= 8'd0;
            end else if (video_valid) begin
                if (h_phase == H_STEP - 2)
                    h_phase <= 6'd0;
                else
                    h_phase <= h_phase + 6'd2;
            end

            if (take_sample) begin
                sampled_pixel_count <= sampled_pixel_count + 1'b1;
                sample_col <= sample_col + 1'b1;
                if (!half_pending) begin
                    low_pixel <= pix0_rgb565;
                    half_pending <= 1'b1;
                end else begin
                    write_word_addr <= write_word_addr + 1'b1;
                    half_pending <= 1'b0;
                end
            end
        end

        if (video_de_fall) begin
            if (v_phase == V_STEP - 1)
                v_phase <= 6'd0;
            else
                v_phase <= v_phase + 1'b1;
        end
    end
end

reg publish_toggle_meta = 1'b0;
reg publish_toggle_apb = 1'b0;
reg publish_toggle_seen = 1'b0;
reg [31:0] apb_frame_seq = 32'd0;
reg apb_latest_bank = 1'b0;
reg apb_frame_valid = 1'b0;
reg [31:0] apb_frame_count = 32'd0;
reg [31:0] apb_drop_count = 32'd0;
reg apb_capture_error = 1'b0;
reg [15:0] apb_addr_latched = 16'd0;
reg apb_read_bank = 1'b0;

wire apb_setup_read = apb_psel && !apb_penable && !apb_pwrite;
wire buffer0_selected = (apb_paddr[15:0] >= BUFFER0_OFFSET) &&
                        (apb_paddr[15:0] < BUFFER0_OFFSET + BUFFER_BYTES);
wire buffer1_selected = (apb_paddr[15:0] >= BUFFER1_OFFSET) &&
                        (apb_paddr[15:0] < BUFFER1_OFFSET + BUFFER_BYTES);
assign apb_buffer0_word_addr = (apb_paddr[15:0] - BUFFER0_OFFSET) >> 2;
assign apb_buffer1_word_addr = (apb_paddr[15:0] - BUFFER1_OFFSET) >> 2;
assign apb_bank0_read = apb_setup_read && buffer0_selected;
assign apb_bank1_read = apb_setup_read && buffer1_selected;

always @(posedge apb_clk) begin
    if (apb_reset) begin
        publish_toggle_meta <= 1'b0;
        publish_toggle_apb <= 1'b0;
        publish_toggle_seen <= 1'b0;
        apb_frame_seq <= 32'd0;
        apb_latest_bank <= 1'b0;
        apb_frame_valid <= 1'b0;
        apb_frame_count <= 32'd0;
        apb_drop_count <= 32'd0;
        apb_capture_error <= 1'b0;
        hold_active_apb <= 1'b0;
        hold_bank_apb <= 1'b0;
        hold_seq_apb <= 32'd0;
        apb_addr_latched <= 16'd0;
        apb_read_bank <= 1'b0;
    end else begin
        publish_toggle_meta <= publish_toggle;
        publish_toggle_apb <= publish_toggle_meta;
        if (publish_toggle_apb != publish_toggle_seen) begin
            publish_toggle_seen <= publish_toggle_apb;
            apb_frame_seq <= published_seq;
            apb_latest_bank <= published_bank;
            apb_frame_valid <= published_valid;
            apb_frame_count <= completed_frame_count;
            apb_drop_count <= dropped_frame_count;
            apb_capture_error <= capture_error_sticky;
        end

        if (apb_setup_read) begin
            apb_addr_latched <= apb_paddr[15:0];
            if (buffer0_selected)
                apb_read_bank <= 1'b0;
            else if (buffer1_selected)
                apb_read_bank <= 1'b1;
        end

        if (apb_psel && apb_penable && apb_pwrite &&
            (apb_paddr[15:0] == REG_CONTROL)) begin
            if (apb_pwdata[0]) begin
                hold_active_apb <= 1'b1;
                hold_bank_apb <= apb_latest_bank;
                hold_seq_apb <= apb_frame_seq;
            end
            if (apb_pwdata[1])
                hold_active_apb <= 1'b0;
        end
    end
end

reg [31:0] apb_register_read_data;
always @(*) begin
    case (apb_addr_latched)
        REG_MAGIC:        apb_register_read_data = 32'h5649534e; // "VISN"
        REG_VERSION:      apb_register_read_data = 32'h00010000;
        REG_DIMENSIONS:   apb_register_read_data = {OUTPUT_HEIGHT[15:0], OUTPUT_WIDTH[15:0]};
        REG_FORMAT:       apb_register_read_data = 32'h00000001; // RGB565, two pixels per word
        REG_FRAME_SEQ:    apb_register_read_data = apb_frame_seq;
        REG_LATEST_BANK:  apb_register_read_data = {31'd0, apb_latest_bank};
        REG_STATUS:       apb_register_read_data = {
            28'd0, apb_capture_error, hold_active_apb, apb_frame_valid, 1'b1
        };
        REG_BUFFER0:      apb_register_read_data = {16'd0, BUFFER0_OFFSET};
        REG_BUFFER1:      apb_register_read_data = {16'd0, BUFFER1_OFFSET};
        REG_BUFFER_BYTES: apb_register_read_data = {16'd0, BUFFER_BYTES};
        REG_DROP_COUNT:   apb_register_read_data = apb_drop_count;
        REG_FRAME_COUNT:  apb_register_read_data = apb_frame_count;
        REG_CONTROL:      apb_register_read_data = {30'd0, 1'b0, hold_active_apb};
        REG_CLAIM_BANK:   apb_register_read_data = {31'd0, hold_bank_apb};
        REG_CLAIM_SEQ:    apb_register_read_data = hold_seq_apb;
        default:          apb_register_read_data = 32'd0;
    endcase
end

wire latched_buffer0 = (apb_addr_latched >= BUFFER0_OFFSET) &&
                       (apb_addr_latched < BUFFER0_OFFSET + BUFFER_BYTES);
wire latched_buffer1 = (apb_addr_latched >= BUFFER1_OFFSET) &&
                       (apb_addr_latched < BUFFER1_OFFSET + BUFFER_BYTES);

assign apb_prdata = (latched_buffer0 || latched_buffer1) ?
                    (apb_read_bank ? apb_bank1_read_data : apb_bank0_read_data) :
                    apb_register_read_data;
assign apb_pready = 1'b1;
assign apb_pslverror = 1'b0;

endmodule

// Keep the dual-clock RAM in a strict inference template. Efinity otherwise
// expands a shared read mux into hundreds of thousands of logic-memory loads.
module vision_frame_bank_dc #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 13,
    parameter DEPTH = 1 << ADDR_WIDTH
) (
    input  wire                  wclk,
    input  wire                  we,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire                  rclk,
    input  wire                  re,
    input  wire [ADDR_WIDTH-1:0] raddr,
    output wire [DATA_WIDTH-1:0] dout
);

(* syn_ramstyle = "block_ram" *) reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
reg [DATA_WIDTH-1:0] dout_r = {DATA_WIDTH{1'b0}};

always @(posedge wclk) begin
    if (we)
        mem[waddr] <= din;
end

always @(posedge rclk) begin
    if (re)
        dout_r <= mem[raddr];
end

assign dout = dout_r;

endmodule
