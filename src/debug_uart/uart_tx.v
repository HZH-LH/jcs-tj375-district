module uart_tx #(
    parameter integer CLK_FREQ_HZ = 70000000,
    parameter integer BAUD_RATE   = 115200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       i_valid,
    input  wire [7:0] i_data,
    output reg        o_txd,
    output wire       o_busy
);

localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;

localparam [1:0] ST_IDLE  = 2'd0;
localparam [1:0] ST_START = 2'd1;
localparam [1:0] ST_DATA  = 2'd2;
localparam [1:0] ST_STOP  = 2'd3;

reg [1:0]  state;
reg [15:0] baud_cnt;
reg [2:0]  bit_idx;
reg [7:0]  data_latch;

assign o_busy = (state != ST_IDLE);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= ST_IDLE;
        baud_cnt <= 16'd0;
        bit_idx <= 3'd0;
        data_latch <= 8'd0;
        o_txd <= 1'b1;
    end else begin
        case (state)
            ST_IDLE: begin
                o_txd <= 1'b1;
                baud_cnt <= 16'd0;
                bit_idx <= 3'd0;
                if (i_valid) begin
                    data_latch <= i_data;
                    state <= ST_START;
                    o_txd <= 1'b0;
                end
            end

            ST_START: begin
                if (baud_cnt == CLKS_PER_BIT - 1) begin
                    baud_cnt <= 16'd0;
                    state <= ST_DATA;
                    o_txd <= data_latch[0];
                end else begin
                    baud_cnt <= baud_cnt + 16'd1;
                end
            end

            ST_DATA: begin
                if (baud_cnt == CLKS_PER_BIT - 1) begin
                    baud_cnt <= 16'd0;
                    if (bit_idx == 3'd7) begin
                        bit_idx <= 3'd0;
                        state <= ST_STOP;
                        o_txd <= 1'b1;
                    end else begin
                        bit_idx <= bit_idx + 3'd1;
                        o_txd <= data_latch[bit_idx + 3'd1];
                    end
                end else begin
                    baud_cnt <= baud_cnt + 16'd1;
                end
            end

            ST_STOP: begin
                if (baud_cnt == CLKS_PER_BIT - 1) begin
                    baud_cnt <= 16'd0;
                    state <= ST_IDLE;
                    o_txd <= 1'b1;
                end else begin
                    baud_cnt <= baud_cnt + 16'd1;
                end
            end

            default: begin
                state <= ST_IDLE;
                o_txd <= 1'b1;
            end
        endcase
    end
end

endmodule
