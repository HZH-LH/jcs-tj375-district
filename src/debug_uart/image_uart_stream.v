module image_uart_stream #(
    parameter integer CLK_FREQ_HZ = 70000000,
    parameter integer BAUD_RATE   = 1000000,
    parameter integer OUT_W       = 160,
    parameter integer OUT_H       = 90,
    parameter integer H_STEP      = 12,
    parameter integer V_STEP      = 12
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        i_enable,
    input  wire        i_vs,
    input  wire        i_de,
    input  wire        i_valid,
    input  wire [47:0] i_grb_datax2,
    output wire        o_uart_txd,
    output wire        o_busy
);

localparam integer PIXELS     = OUT_W * OUT_H;
localparam integer DATA_BYTES = PIXELS * 2;
localparam integer ADDR_W     = 14;
localparam integer MEM_DEPTH  = 16384;

localparam [2:0] ST_WAIT    = 3'd0;
localparam [2:0] ST_CAP     = 3'd1;
localparam [2:0] ST_HEADER  = 3'd2;
localparam [2:0] ST_RD_WORD = 3'd3;
localparam [2:0] ST_DATA_HI = 3'd4;
localparam [2:0] ST_DATA_LO = 3'd5;

reg [2:0] state;
reg       vs_d;
reg       de_d;
reg [5:0] h_phase;
reg [5:0] v_phase;
reg [7:0] sample_col;
reg [ADDR_W-1:0] wr_addr;
reg [ADDR_W-1:0] rd_addr;
(* ram_style = "block" *) (* syn_ramstyle = "block_ram" *) reg [15:0] frame_mem [0:MEM_DEPTH-1];
reg [15:0] rd_word;
reg [7:0] seq;
reg [7:0] checksum;
reg [7:0] checksum_latched;

reg [3:0]  header_idx;
reg [15:0] data_byte_idx;
reg        tx_valid;
reg [7:0]  tx_data;
wire       tx_busy;
reg        tx_busy_d;

wire frame_start = i_vs & ~vs_d;
wire de_rise = i_de & ~de_d;
wire de_fall = ~i_de & de_d;
wire tx_done = tx_busy_d & ~tx_busy;
wire sample_now = (state == ST_CAP) && i_valid && i_de &&
                  (v_phase == 4'd0) && (h_phase == 4'd0) &&
                  (sample_col < OUT_W) && (wr_addr < PIXELS);

wire [7:0] pix0_g = i_grb_datax2[23:16];
wire [7:0] pix0_r = i_grb_datax2[15:8];
wire [7:0] pix0_b = i_grb_datax2[7:0];
wire [15:0] pix0_rgb565 = {pix0_r[7:3], pix0_g[7:2], pix0_b[7:3]};

assign o_busy = (state != ST_WAIT);

function [7:0] header_byte;
    input [3:0] idx;
    begin
        case (idx)
            4'd0:  header_byte = 8'hA5;
            4'd1:  header_byte = 8'h5A;
            4'd2:  header_byte = 8'h01;               // packet version
            4'd3:  header_byte = seq;
            4'd4:  header_byte = (OUT_W >> 8);
            4'd5:  header_byte = OUT_W;
            4'd6:  header_byte = (OUT_H >> 8);
            4'd7:  header_byte = OUT_H;
            4'd8:  header_byte = 8'h00;               // 0 = RGB565 big endian
            4'd9:  header_byte = (DATA_BYTES >> 8);
            4'd10: header_byte = DATA_BYTES;
            4'd11: header_byte = checksum_latched;    // sum of payload bytes
            default: header_byte = 8'h00;
        endcase
    end
endfunction

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        vs_d <= 1'b0;
        de_d <= 1'b0;
    end else begin
        vs_d <= i_vs;
        de_d <= i_de;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= ST_WAIT;
        h_phase <= 6'd0;
        v_phase <= 6'd0;
        sample_col <= 8'd0;
        wr_addr <= {ADDR_W{1'b0}};
        rd_addr <= {ADDR_W{1'b0}};
        rd_word <= 16'd0;
        seq <= 8'd0;
        checksum <= 8'd0;
        checksum_latched <= 8'd0;
        header_idx <= 4'd0;
        data_byte_idx <= 16'd0;
        tx_valid <= 1'b0;
        tx_data <= 8'hFF;
        tx_busy_d <= 1'b0;
    end else begin
        tx_busy_d <= tx_busy;
        tx_valid <= 1'b0;

        case (state)
            ST_WAIT: begin
                h_phase <= 6'd0;
                sample_col <= 8'd0;
                if (!i_enable) begin
                    v_phase <= 6'd0;
                    wr_addr <= {ADDR_W{1'b0}};
                    checksum <= 8'd0;
                end else if (frame_start) begin
                    v_phase <= 6'd0;
                    h_phase <= 6'd0;
                    sample_col <= 8'd0;
                    wr_addr <= {ADDR_W{1'b0}};
                    checksum <= 8'd0;
                    state <= ST_CAP;
                end
            end

            ST_CAP: begin
                if (de_rise) begin
                    h_phase <= 6'd0;
                    sample_col <= 8'd0;
                end else if (i_valid && i_de) begin
                    if (h_phase == H_STEP - 2) begin
                        h_phase <= 6'd0;
                    end else begin
                        h_phase <= h_phase + 6'd2;
                    end
                end

                if (sample_now) begin
                    frame_mem[wr_addr] <= pix0_rgb565;
                    wr_addr <= wr_addr + {{(ADDR_W-1){1'b0}}, 1'b1};
                    sample_col <= sample_col + 8'd1;
                    checksum <= checksum + pix0_rgb565[15:8] + pix0_rgb565[7:0];
                    if (wr_addr == PIXELS - 1) begin
                        checksum_latched <= checksum + pix0_rgb565[15:8] + pix0_rgb565[7:0];
                        rd_addr <= {ADDR_W{1'b0}};
                        header_idx <= 4'd0;
                        data_byte_idx <= 16'd0;
                        tx_data <= 8'hA5;
                        tx_valid <= 1'b1;
                        state <= ST_HEADER;
                    end
                end

                if (de_fall) begin
                    if (v_phase == V_STEP - 1) begin
                        v_phase <= 6'd0;
                    end else begin
                        v_phase <= v_phase + 6'd1;
                    end
                end
            end

            ST_HEADER: begin
                if (tx_done) begin
                    if (header_idx < 4'd11) begin
                        header_idx <= header_idx + 4'd1;
                        tx_data <= header_byte(header_idx + 4'd1);
                        tx_valid <= 1'b1;
                    end else begin
                        rd_addr <= {ADDR_W{1'b0}};
                        data_byte_idx <= 16'd0;
                        state <= ST_RD_WORD;
                    end
                end
            end

            ST_RD_WORD: begin
                rd_word <= frame_mem[rd_addr];
                state <= ST_DATA_HI;
            end

            ST_DATA_HI: begin
                if (!tx_busy) begin
                    tx_data <= rd_word[15:8];
                    tx_valid <= 1'b1;
                    data_byte_idx <= data_byte_idx + 16'd1;
                    state <= ST_DATA_LO;
                end
            end

            ST_DATA_LO: begin
                if (tx_done) begin
                    tx_data <= rd_word[7:0];
                    tx_valid <= 1'b1;
                    data_byte_idx <= data_byte_idx + 16'd1;
                    if (data_byte_idx == DATA_BYTES - 1) begin
                        seq <= seq + 8'd1;
                        state <= ST_WAIT;
                    end else begin
                        rd_addr <= rd_addr + {{(ADDR_W-1){1'b0}}, 1'b1};
                        state <= ST_RD_WORD;
                    end
                end
            end

            default: begin
                state <= ST_WAIT;
            end
        endcase
    end
end

uart_tx #(
    .CLK_FREQ_HZ(CLK_FREQ_HZ),
    .BAUD_RATE  (BAUD_RATE)
) u_image_uart_tx (
    .clk    (clk),
    .rst_n  (rst_n),
    .i_valid(tx_valid),
    .i_data (tx_data),
    .o_txd  (o_uart_txd),
    .o_busy (tx_busy)
);

endmodule
