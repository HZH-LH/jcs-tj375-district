`timescale 1ns/1ps

// Converts CSI bursts of four RAW8 pixels into a two-pixel stream. Frame and
// line markers travel through the FIFO so the Debayer still sees a VS pulse
// and a DE gap at every line boundary.
module raw_burst_serializer #(
    parameter FIFO_DEPTH_WORDS = 8192,
    parameter INPUT_WORDS_PER_LINE = 480,
    parameter COUNT_WIDTH = $clog2(FIFO_DEPTH_WORDS) + 1
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_vs,
    input  wire        in_de,
    input  wire [31:0] in_raw4,
    output reg         out_vs = 1'b0,
    output reg         out_hs = 1'b0,
    output reg         out_de = 1'b0,
    output reg  [15:0] out_raw2 = 16'd0,
    output wire [COUNT_WIDTH-1:0] fifo_level,
    output reg         active = 1'b0,
    output reg         overflow_sticky = 1'b0,
    output reg  [15:0] overflow_count = 16'd0,
    output reg  [15:0] input_frame_count = 16'd0,
    output reg  [15:0] output_frame_count = 16'd0,
    output reg  [15:0] output_line_count = 16'd0
);

localparam FIFO_ADDR_WIDTH = $clog2(FIFO_DEPTH_WORDS);
localparam ST_IDLE = 3'd0;
localparam ST_WAIT = 3'd1;
localparam ST_LOAD = 3'd2;
localparam ST_GAP  = 3'd3;
localparam ST_LOW  = 3'd4;
localparam ST_HIGH = 3'd5;
localparam ST_LINE_WAIT = 3'd6;

reg in_vs_d = 1'b0;
reg frame_pending = 1'b0;
reg [8:0] input_word_x = 9'd0;
reg [2:0] state = ST_IDLE;
reg fifo_read = 1'b0;
reg next_requested = 1'b0;
reg [33:0] current_word = 34'd0;

wire in_vs_rise = in_vs & ~in_vs_d;
wire line_start = in_de && (input_word_x == 9'd0);
wire frame_start = line_start & (frame_pending | in_vs_rise);
wire fifo_full;
wire fifo_empty;
wire [FIFO_ADDR_WIDTH:0] fifo_write_level;
wire [FIFO_ADDR_WIDTH:0] fifo_read_level;
wire [33:0] fifo_read_data;
wire fifo_write = in_de & !fifo_full;

assign fifo_level = fifo_read_level[COUNT_WIDTH-1:0];

DC_FIFO #(
    .FIFO_MODE("Normal"),
    .DATA_WIDTH(34),
    .FIFO_DEPTH(FIFO_DEPTH_WORDS)
) u_raw_fifo (
    .Reset(!rst_n),
    .WrClk(clk),
    .WrEn(fifo_write),
    .WrDNum(fifo_write_level),
    .WrFull(fifo_full),
    .WrData({frame_start, line_start, in_raw4}),
    .RdClk(clk),
    .RdEn(fifo_read),
    .RdDNum(fifo_read_level),
    .RdEmpty(fifo_empty),
    .DataVal(),
    .RdData(fifo_read_data)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_vs_d <= 1'b0;
        frame_pending <= 1'b0;
        input_word_x <= 9'd0;
        input_frame_count <= 16'd0;
        overflow_sticky <= 1'b0;
        overflow_count <= 16'd0;
    end else begin
        in_vs_d <= in_vs;

        if (in_vs_rise) begin
            frame_pending <= 1'b1;
            input_word_x <= 9'd0;
            input_frame_count <= input_frame_count + 1'b1;
        end
        if (frame_start)
            frame_pending <= 1'b0;

        if (in_de) begin
            if (input_word_x == INPUT_WORDS_PER_LINE - 1)
                input_word_x <= 9'd0;
            else
                input_word_x <= input_word_x + 1'b1;
        end

        if (in_de && fifo_full) begin
            overflow_sticky <= 1'b1;
            if (overflow_count != 16'hffff)
                overflow_count <= overflow_count + 1'b1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= ST_IDLE;
        fifo_read <= 1'b0;
        next_requested <= 1'b0;
        current_word <= 34'd0;
        out_vs <= 1'b0;
        out_hs <= 1'b0;
        out_de <= 1'b0;
        out_raw2 <= 16'd0;
        active <= 1'b0;
        output_frame_count <= 16'd0;
        output_line_count <= 16'd0;
    end else begin
        fifo_read <= 1'b0;
        out_vs <= 1'b0;
        out_hs <= 1'b0;
        out_de <= 1'b0;
        out_raw2 <= 16'd0;

        case (state)
            ST_IDLE: begin
                active <= 1'b0;
                // Do not chase the bursty CSI producer. Buffer one complete
                // RAW4 line before starting its continuous RAW2 output.
                if (fifo_read_level >= INPUT_WORDS_PER_LINE) begin
                    fifo_read <= 1'b1;
                    state <= ST_WAIT;
                end
            end

            ST_WAIT: begin
                state <= ST_LOAD;
            end

            ST_LOAD: begin
                current_word <= fifo_read_data;
                active <= 1'b1;
                if (!fifo_empty) begin
                    fifo_read <= 1'b1;
                    next_requested <= 1'b1;
                end else begin
                    next_requested <= 1'b0;
                end
                state <= fifo_read_data[32] ? ST_GAP : ST_LOW;
            end

            ST_GAP: begin
                out_vs <= current_word[33];
                out_hs <= 1'b1;
                if (current_word[33])
                    output_frame_count <= output_frame_count + 1'b1;
                output_line_count <= output_line_count + 1'b1;
                state <= ST_LOW;
            end

            ST_LOW: begin
                out_de <= 1'b1;
                out_raw2 <= current_word[15:0];
                state <= ST_HIGH;
            end

            ST_HIGH: begin
                out_de <= 1'b1;
                out_raw2 <= current_word[31:16];
                if (next_requested) begin
                    current_word <= fifo_read_data;
                    if (fifo_read_data[32]) begin
                        // The first word of the next line is now held locally.
                        // Wait until the remaining 479 words are buffered.
                        next_requested <= 1'b0;
                        state <= ST_LINE_WAIT;
                    end else if (!fifo_empty) begin
                        fifo_read <= 1'b1;
                        next_requested <= 1'b1;
                        state <= ST_LOW;
                    end else begin
                        next_requested <= 1'b0;
                        state <= ST_IDLE;
                    end
                end else begin
                    state <= ST_IDLE;
                end
            end

            ST_LINE_WAIT: begin
                active <= 1'b1;
                if (fifo_read_level >= INPUT_WORDS_PER_LINE - 1) begin
                    fifo_read <= 1'b1;
                    next_requested <= 1'b1;
                    state <= ST_GAP;
                end
            end

            default: state <= ST_IDLE;
        endcase
    end
end

endmodule
