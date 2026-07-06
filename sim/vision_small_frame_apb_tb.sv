`timescale 1ns/1ps

module vision_small_frame_apb_tb;

reg video_clk = 1'b0;
reg apb_clk = 1'b0;
reg video_rst_n = 1'b0;
reg apb_reset = 1'b1;
reg video_vs = 1'b0;
reg video_de = 1'b0;
reg [47:0] video_rgb2 = 48'd0;
reg [31:0] apb_paddr = 32'd0;
reg apb_psel = 1'b0;
reg apb_penable = 1'b0;
reg apb_pwrite = 1'b0;
reg [31:0] apb_pwdata = 32'd0;
wire [31:0] apb_prdata;
wire apb_pready;
wire apb_pslverror;

always #7 video_clk = ~video_clk;
always #2 apb_clk = ~apb_clk;

vision_small_frame_apb #(
    .INPUT_WORDS_PER_LINE(12),
    .INPUT_LINES(24),
    .OUTPUT_WIDTH(2),
    .OUTPUT_HEIGHT(2),
    .FRAME_PIXELS(4),
    .FRAME_WORDS(2)
) dut (
    .video_clk(video_clk),
    .video_rst_n(video_rst_n),
    .video_vs(video_vs),
    .video_de(video_de),
    .video_rgb2(video_rgb2),
    .apb_clk(apb_clk),
    .apb_reset(apb_reset),
    .apb_paddr(apb_paddr),
    .apb_psel(apb_psel),
    .apb_penable(apb_penable),
    .apb_pwrite(apb_pwrite),
    .apb_pwdata(apb_pwdata),
    .apb_prdata(apb_prdata),
    .apb_pready(apb_pready),
    .apb_pslverror(apb_pslverror)
);

task video_frame;
    integer y;
    integer x;
    begin
        @(negedge video_clk);
        video_vs = 1'b1;
        @(negedge video_clk);
        video_vs = 1'b0;
        for (y = 0; y < 24; y = y + 1) begin
            for (x = 0; x < 12; x = x + 1) begin
                video_de = 1'b1;
                video_rgb2[23:0] = {8'h20 + x[7:0], 8'h40 + y[7:0], 8'h60 + x[7:0]};
                @(negedge video_clk);
            end
            video_de = 1'b0;
            @(negedge video_clk);
        end
    end
endtask

task apb_read;
    input [15:0] address;
    output [31:0] data;
    begin
        @(negedge apb_clk);
        apb_paddr = {16'd0, address};
        apb_pwrite = 1'b0;
        apb_psel = 1'b1;
        apb_penable = 1'b0;
        @(negedge apb_clk);
        apb_penable = 1'b1;
        @(negedge apb_clk);
        data = apb_prdata;
        apb_psel = 1'b0;
        apb_penable = 1'b0;
    end
endtask

task apb_write;
    input [15:0] address;
    input [31:0] data;
    begin
        @(negedge apb_clk);
        apb_paddr = {16'd0, address};
        apb_pwdata = data;
        apb_pwrite = 1'b1;
        apb_psel = 1'b1;
        apb_penable = 1'b0;
        @(negedge apb_clk);
        apb_penable = 1'b1;
        @(negedge apb_clk);
        apb_psel = 1'b0;
        apb_penable = 1'b0;
        apb_pwrite = 1'b0;
    end
endtask

reg [31:0] data;
initial begin
    repeat (4) @(negedge apb_clk);
    apb_reset = 1'b0;
    video_rst_n = 1'b1;

    video_frame();
    video_frame();
    repeat (8) @(negedge apb_clk);

    apb_read(16'h0000, data);
    if (data !== 32'h5649534e) $fatal(1, "bad magic: %h", data);
    apb_read(16'h0008, data);
    if (data !== 32'h00020002) $fatal(1, "bad dimensions: %h", data);
    apb_read(16'h0010, data);
    if (data !== 32'd1) $fatal(1, "bad sequence: %h", data);
    apb_read(16'h1000, data);
    if (data === 32'd0) $fatal(1, "buffer word is zero");

    apb_write(16'h0030, 32'h00000001);
    apb_read(16'h0018, data);
    if (!data[2]) $fatal(1, "claim did not assert");
    apb_write(16'h0030, 32'h00000002);
    apb_read(16'h0018, data);
    if (data[2]) $fatal(1, "claim did not release");

    $display("PASS vision_small_frame_apb_tb");
    $finish;
end

endmodule
