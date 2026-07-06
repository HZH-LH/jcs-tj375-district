
`define BRAM_VIDEO_PATH
// `define FRAME_BUFFER
// `define CONTRAST_BRIGHT_EN
// `define UVC_EN 
module top #(
parameter AXI_DATA_WIDTH = 512,

parameter AXI_MUX_EN = 1'b1,
parameter I_VID_WIDTH    = 32,
parameter O_VID_WIDTH    = 16,
parameter AXI_ADDR_WIDTH = 33,
parameter WR_FIFO_DEPTH	 = 256,    
parameter RD_FIFO_DEPTH  = 256,
parameter MAX_VID_WIDTH	 = 1920 ,//video width 
parameter MAX_VID_HIGHT	 = 1080 ,//wideo height
parameter START_ADDR     = 33'h000000000,
parameter FB_NUM		 = 3,//2 buffer ,3 buffer   
parameter BURST_LEN      = 63,
parameter   AXI_ID_WIDTH    = 8,
parameter   S_COUNT 					= 3,                          
parameter   M_COUNT 					= 1,  
// parameter HACT		     = 13'd3840,
parameter PACK_BIT          = 40,
parameter	HACT		    = 12'd1920,
parameter	VACT		    = 12'd1080,
parameter	HSP				= 8'd4,
parameter	HBP				= 8'd88,
parameter	HFP				= 8'd120,
parameter	VSP				= 6'd2,
parameter	VBP				= 6'd20,
parameter	VFP				= 6'd20


)(
  (* syn_peri_port = 0 *) input mipi_clk,
  (* syn_peri_port = 0 *) input clk_74p25m,
  (* syn_peri_port = 0 *) input ddr_clk_ref,
  (* syn_peri_port = 0 *) input [2:0] i_sw,
  (* syn_peri_port = 0 *) input sys_pll_lock,
  (* syn_peri_port = 0 *) input ddr_pll_lock,
  (* syn_peri_port = 0 *) input MIPI_TX_PLL_LOCKED,
  (* syn_peri_port = 0 *) input pll_byteclk_locked,
  (* syn_peri_port = 0 *) input CLK_5M,
  (* syn_peri_port = 0 *) input i_sysclk_div2,
  (* syn_peri_port = 0 *) input io_peripheralClk,
  (* syn_peri_port = 0 *) input io_peripheralReset,
  (* syn_peri_port = 0 *) input io_systemReset,
  (* syn_peri_port = 0 *) input pll_peripheral_locked,
  (* syn_peri_port = 0 *) input pll_inst1_CLKOUT0,
  (* syn_peri_port = 0 *) input mipi0_ref_clk,
  (* syn_peri_port = 0 *) input pll_inst2_CLKOUT0,
  (* syn_peri_port = 0 *) input axi0_ACLK,
  (* syn_peri_port = 0 *) input mipi_rx_ck0_CLKOUT,
  (* syn_peri_port = 0 *) input mipi_rx_ck1_CLKOUT,
  (* syn_peri_port = 0 *) input mipi_dphy_tx_FASTCLK_C,
  (* syn_peri_port = 0 *) input mipi_dphy_tx_FASTCLK_D,
  (* syn_peri_port = 0 *) input gpio_clk_50m,
  (* syn_peri_port = 0 *) input mipi_dphy_tx_SLOWCLK,
  (* syn_peri_port = 0 *) input i_fb_clk,
  (* syn_peri_port = 0 *) input jtag_inst1_CAPTURE,
  (* syn_peri_port = 0 *) input jtag_inst1_DRCK,
  (* syn_peri_port = 0 *) input jtag_inst1_RESET,
  (* syn_peri_port = 0 *) input jtag_inst1_RUNTEST,
  (* syn_peri_port = 0 *) input jtag_inst1_SEL,
  (* syn_peri_port = 0 *) input jtag_inst1_SHIFT,
  (* syn_peri_port = 0 *) input jtag_inst1_TCK,
  (* syn_peri_port = 0 *) input jtag_inst1_TDI,
  (* syn_peri_port = 0 *) input jtag_inst1_TMS,
  (* syn_peri_port = 0 *) input jtag_inst1_UPDATE,
  (* syn_peri_port = 0 *) input ut_jtagCtrl_capture,
  (* syn_peri_port = 0 *) input ut_jtagCtrl_reset,
  (* syn_peri_port = 0 *) input ut_jtagCtrl_enable,
  (* syn_peri_port = 0 *) input ut_jtagCtrl_shift,
  (* syn_peri_port = 0 *) input jtagCtrl_tck,
  (* syn_peri_port = 0 *) input ut_jtagCtrl_tdi,
  (* syn_peri_port = 0 *) input ut_jtagCtrl_update,
  (* syn_peri_port = 0 *) input jtagCtrl_tdo,
  (* syn_peri_port = 0 *) input system_uart_0_io_rxd,
  (* syn_peri_port = 0 *) input [31:0] axiA_araddr,
  (* syn_peri_port = 0 *) input [1:0] axiA_arburst,
  (* syn_peri_port = 0 *) input [3:0] axiA_arcache,
  (* syn_peri_port = 0 *) input [7:0] axiA_arlen,
  (* syn_peri_port = 0 *) input axiA_arlock,
  (* syn_peri_port = 0 *) input [2:0] axiA_arprot,
  (* syn_peri_port = 0 *) input [3:0] axiA_arqos,
  (* syn_peri_port = 0 *) input [3:0] axiA_arregion,
  (* syn_peri_port = 0 *) input [2:0] axiA_arsize,
  (* syn_peri_port = 0 *) input axiA_arvalid,
  (* syn_peri_port = 0 *) input [31:0] axiA_awaddr,
  (* syn_peri_port = 0 *) input [1:0] axiA_awburst,
  (* syn_peri_port = 0 *) input [3:0] axiA_awcache,
  (* syn_peri_port = 0 *) input [7:0] axiA_awlen,
  (* syn_peri_port = 0 *) input axiA_awlock,
  (* syn_peri_port = 0 *) input [2:0] axiA_awprot,
  (* syn_peri_port = 0 *) input [3:0] axiA_awqos,
  (* syn_peri_port = 0 *) input [3:0] axiA_awregion,
  (* syn_peri_port = 0 *) input [2:0] axiA_awsize,
  (* syn_peri_port = 0 *) input axiA_awvalid,
  (* syn_peri_port = 0 *) input axiA_bready,
  (* syn_peri_port = 0 *) input axiA_rready,
  (* syn_peri_port = 0 *) input [31:0] axiA_wdata,
  (* syn_peri_port = 0 *) input axiA_wlast,
  (* syn_peri_port = 0 *) input [3:0] axiA_wstrb,
  (* syn_peri_port = 0 *) input axiA_wvalid,
  (* syn_peri_port = 0 *) input axi0_ARREADY,
  (* syn_peri_port = 0 *) input axi0_AWREADY,
  (* syn_peri_port = 0 *) input [5:0] axi0_BID,
  (* syn_peri_port = 0 *) input [1:0] axi0_BRESP,
  (* syn_peri_port = 0 *) input axi0_BVALID,
  (* syn_peri_port = 0 *) input ddr_inst_CFG_DONE,
  (* syn_peri_port = 0 *) input [511:0] axi0_RDATA,
  (* syn_peri_port = 0 *) input [5:0] axi0_RID,
  (* syn_peri_port = 0 *) input axi0_RLAST,
  (* syn_peri_port = 0 *) input [1:0] axi0_RRESP,
  (* syn_peri_port = 0 *) input axi0_RVALID,
  (* syn_peri_port = 0 *) input axi0_WREADY,
  (* syn_peri_port = 0 *) input S0_io_cam_scl_IN,
  (* syn_peri_port = 0 *) input S0_io_cam_sda_IN,
  (* syn_peri_port = 0 *) input S1_io_cam_scl_IN,
  (* syn_peri_port = 0 *) input S1_io_cam_sda_IN,
  (* syn_peri_port = 0 *) input clk_25m,
 
  (* syn_peri_port = 0 *) output sys_pll_rstn,
  (* syn_peri_port = 0 *) output ddr_pll_rstn,
  (* syn_peri_port = 0 *) output MIPI_TX_PLL_RSTN,
  (* syn_peri_port = 0 *) output pll_byteclk_rstn,
  (* syn_peri_port = 0 *) output jtag_inst1_TDO,
  (* syn_peri_port = 0 *) output io_asyncReset,
  (* syn_peri_port = 0 *) output ut_jtagCtrl_tdo,
  (* syn_peri_port = 0 *) output jtagCtrl_capture,
  (* syn_peri_port = 0 *) output jtagCtrl_enable,
  (* syn_peri_port = 0 *) output jtagCtrl_reset,
  (* syn_peri_port = 0 *) output jtagCtrl_shift,
  (* syn_peri_port = 0 *) output jtagCtrl_tdi,
  (* syn_peri_port = 0 *) output jtagCtrl_update,
  (* syn_peri_port = 0 *) output system_uart_0_io_txd,
  (* syn_peri_port = 0 *) output axiAInterrupt,
  (* syn_peri_port = 0 *) output userInterruptA,
  (* syn_peri_port = 0 *) output userInterruptB,
  (* syn_peri_port = 0 *) output axiA_arready,
  (* syn_peri_port = 0 *) output axiA_awready,
  (* syn_peri_port = 0 *) output [1:0] axiA_bresp,
  (* syn_peri_port = 0 *) output axiA_bvalid,
  (* syn_peri_port = 0 *) output [31:0] axiA_rdata,
  (* syn_peri_port = 0 *) output axiA_rlast,
  (* syn_peri_port = 0 *) output [1:0] axiA_rresp,
  (* syn_peri_port = 0 *) output axiA_rvalid,
  (* syn_peri_port = 0 *) output axiA_wready,
  (* syn_peri_port = 0 *) output [32:0] axi0_ARADDR,
  (* syn_peri_port = 0 *) output axi0_ARAPCMD,
  (* syn_peri_port = 0 *) output [1:0] axi0_ARBURST,
  (* syn_peri_port = 0 *) output [5:0] axi0_ARID,
  (* syn_peri_port = 0 *) output [7:0] axi0_ARLEN,
  (* syn_peri_port = 0 *) output axi0_ARLOCK,
  (* syn_peri_port = 0 *) output axi0_ARQOS,
  (* syn_peri_port = 0 *) output [2:0] axi0_ARSIZE,
  (* syn_peri_port = 0 *) output axi0_ARESETn,
  (* syn_peri_port = 0 *) output axi0_ARVALID,
  (* syn_peri_port = 0 *) output [32:0] axi0_AWADDR,
  (* syn_peri_port = 0 *) output axi0_AWALLSTRB,
  (* syn_peri_port = 0 *) output axi0_AWAPCMD,
  (* syn_peri_port = 0 *) output [1:0] axi0_AWBURST,
  (* syn_peri_port = 0 *) output [3:0] axi0_AWCACHE,
  (* syn_peri_port = 0 *) output axi0_AWCOBUF,
  (* syn_peri_port = 0 *) output [5:0] axi0_AWID,
  (* syn_peri_port = 0 *) output [7:0] axi0_AWLEN,
  (* syn_peri_port = 0 *) output axi0_AWLOCK,
  (* syn_peri_port = 0 *) output axi0_AWQOS,
  (* syn_peri_port = 0 *) output [2:0] axi0_AWSIZE,
  (* syn_peri_port = 0 *) output axi0_AWVALID,
  (* syn_peri_port = 0 *) output axi0_BREADY,
  (* syn_peri_port = 0 *) output ddr_inst_CFG_RST,
  (* syn_peri_port = 0 *) output ddr_inst_CFG_SEL,
  (* syn_peri_port = 0 *) output ddr_inst_CFG_START,
  (* syn_peri_port = 0 *) output axi0_RREADY,
  (* syn_peri_port = 0 *) output [511:0] axi0_WDATA,
  (* syn_peri_port = 0 *) output axi0_WLAST,
  (* syn_peri_port = 0 *) output [63:0] axi0_WSTRB,
  (* syn_peri_port = 0 *) output axi0_WVALID,
  (* syn_peri_port = 0 *) output P0_lcd_power_en,
  (* syn_peri_port = 0 *) output P0_lcd_rstp,
  (* syn_peri_port = 0 *) output P1_lcd_power_en,
  (* syn_peri_port = 0 *) output P1_o_lcd_rstn,
  (* syn_peri_port = 0 *) output S0_io_cam_scl_OUT,
  (* syn_peri_port = 0 *) output S0_io_cam_scl_OE,
  (* syn_peri_port = 0 *) output S0_io_cam_sda_OUT,
  (* syn_peri_port = 0 *) output S0_io_cam_sda_OE,
  (* syn_peri_port = 0 *) output S0_o_cam_rst_p,
  (* syn_peri_port = 0 *) output S1_io_cam_scl_OUT,
  (* syn_peri_port = 0 *) output S1_io_cam_scl_OE,
  (* syn_peri_port = 0 *) output S1_io_cam_sda_OUT,
  (* syn_peri_port = 0 *) output S1_io_cam_sda_OE,
  (* syn_peri_port = 0 *) output S1_o_cam_rst_p,
  (* syn_peri_port = 0 *) output [19:0] led,  // 扩展到20个LED (LED12,13,16-33)
  // UART双串口
  (* syn_peri_port = 0 *) input  uart1_rxd,   // UART1 RX (从PC接收)
  (* syn_peri_port = 0 *) output uart1_txd,   // UART1 TX (发送到PC)
  (* syn_peri_port = 0 *) input  uart2_rxd,   // UART2 RX (从外设接收)
  (* syn_peri_port = 0 *) output uart2_txd,   // UART2 TX (发送到外设)
  //mipi rx
  (* syn_peri_port = 0 *) output mipi_rx_ck0_HS_ENA,
  (* syn_peri_port = 0 *) output mipi_rx_dp00_HS_ENA,
  (* syn_peri_port = 0 *) output mipi_rx_dp01_HS_ENA,
  (* syn_peri_port = 0 *) output mipi_rx_dp02_HS_ENA,
  (* syn_peri_port = 0 *) output mipi_rx_dp03_HS_ENA,

  (* syn_peri_port = 0 *) output mipi_rx_ck0_HS_TERM,
  (* syn_peri_port = 0 *) output mipi_rx_dp00_HS_TERM,
  (* syn_peri_port = 0 *) output mipi_rx_dp01_HS_TERM,
  (* syn_peri_port = 0 *) output mipi_rx_dp02_HS_TERM,
  (* syn_peri_port = 0 *) output mipi_rx_dp03_HS_TERM,
  
  
  (* syn_peri_port = 0 *) output mipi_rx_dp00_RST,
  (* syn_peri_port = 0 *) output mipi_rx_dp01_RST,
  (* syn_peri_port = 0 *) output mipi_rx_dp02_RST,
  (* syn_peri_port = 0 *) output mipi_rx_dp03_RST,


  (* syn_peri_port = 0 *) output mipi_rx_ck1_HS_ENA,
  (* syn_peri_port = 0 *) output mipi_rx_dp10_HS_ENA,
  (* syn_peri_port = 0 *) output mipi_rx_dp11_HS_ENA,
  (* syn_peri_port = 0 *) output mipi_rx_dp12_HS_ENA,
  (* syn_peri_port = 0 *) output mipi_rx_dp13_HS_ENA,

  (* syn_peri_port = 0 *) output mipi_rx_ck1_HS_TERM,
  (* syn_peri_port = 0 *) output mipi_rx_dp10_HS_TERM,
  (* syn_peri_port = 0 *) output mipi_rx_dp11_HS_TERM,
  (* syn_peri_port = 0 *) output mipi_rx_dp12_HS_TERM,
  (* syn_peri_port = 0 *) output mipi_rx_dp13_HS_TERM,
  
  
  (* syn_peri_port = 0 *) output mipi_rx_dp10_RST,
  (* syn_peri_port = 0 *) output mipi_rx_dp11_RST,
  (* syn_peri_port = 0 *) output mipi_rx_dp12_RST,
  (* syn_peri_port = 0 *) output mipi_rx_dp13_RST,

  (* syn_peri_port = 0 *) input mipi_rx_ck0_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_ck0_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp00_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp00_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp01_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp01_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp02_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp02_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp03_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp03_LP_P_IN,

  (* syn_peri_port = 0 *) input [7:0] mipi_rx_dp00_HS_IN,
  (* syn_peri_port = 0 *) input [7:0] mipi_rx_dp01_HS_IN,
  (* syn_peri_port = 0 *) input [7:0] mipi_rx_dp02_HS_IN,
  (* syn_peri_port = 0 *) input [7:0] mipi_rx_dp03_HS_IN,

  (* syn_peri_port = 0 *) output mipi_rx_dp00_FIFO_RD,
  (* syn_peri_port = 0 *) output mipi_rx_dp01_FIFO_RD,
  (* syn_peri_port = 0 *) output mipi_rx_dp02_FIFO_RD,
  (* syn_peri_port = 0 *) output mipi_rx_dp03_FIFO_RD,
  (* syn_peri_port = 0 *) input mipi_rx_dp00_FIFO_EMPTY,
  (* syn_peri_port = 0 *) input mipi_rx_dp01_FIFO_EMPTY,
  (* syn_peri_port = 0 *) input mipi_rx_dp02_FIFO_EMPTY,
  (* syn_peri_port = 0 *) input mipi_rx_dp03_FIFO_EMPTY,

    (* syn_peri_port = 0 *) input [7:0] mipi_rx_dp10_HS_IN,
  (* syn_peri_port = 0 *) input [7:0] mipi_rx_dp11_HS_IN,
  (* syn_peri_port = 0 *) input [7:0] mipi_rx_dp12_HS_IN,
  (* syn_peri_port = 0 *) input [7:0] mipi_rx_dp13_HS_IN,

  (* syn_peri_port = 0 *) input mipi_rx_ck1_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_ck1_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp10_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp10_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp11_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp11_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp12_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp12_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp13_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_rx_dp13_LP_P_IN,



  (* syn_peri_port = 0 *) output mipi_rx_dp10_FIFO_RD,
  (* syn_peri_port = 0 *) output mipi_rx_dp11_FIFO_RD,
  (* syn_peri_port = 0 *) output mipi_rx_dp12_FIFO_RD,
  (* syn_peri_port = 0 *) output mipi_rx_dp13_FIFO_RD,
  (* syn_peri_port = 0 *) input mipi_rx_dp10_FIFO_EMPTY,
  (* syn_peri_port = 0 *) input mipi_rx_dp11_FIFO_EMPTY,
  (* syn_peri_port = 0 *) input mipi_rx_dp12_FIFO_EMPTY,
  (* syn_peri_port = 0 *) input mipi_rx_dp13_FIFO_EMPTY,


  (* syn_peri_port = 0 *) output mipi_tx_ck0_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_ck0_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_ck0_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_ck0_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_ck0_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_ck0_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_ck0_RST,
  (* syn_peri_port = 0 *) output mipi_tx_dp00_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_dp00_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp00_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp00_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp00_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp00_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp00_RST,
  (* syn_peri_port = 0 *) output mipi_tx_dp01_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_dp01_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp01_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp01_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp01_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp01_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp01_RST,
  (* syn_peri_port = 0 *) output mipi_tx_dp02_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_dp02_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp02_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp02_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp02_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp02_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp02_RST,
  (* syn_peri_port = 0 *) output mipi_tx_dp03_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_dp03_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp03_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp03_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp03_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp03_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp03_RST,
  (* syn_peri_port = 0 *) output mipi_tx_ck1_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_ck1_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_ck1_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_ck1_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_ck1_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_ck1_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_ck1_RST,
  (* syn_peri_port = 0 *) output mipi_tx_dp10_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_dp10_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp10_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp10_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp10_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp10_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp10_RST,
  (* syn_peri_port = 0 *) output mipi_tx_dp11_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_dp11_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp11_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp11_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp11_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp11_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp11_RST,
  (* syn_peri_port = 0 *) output mipi_tx_dp12_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_dp12_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp12_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp12_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp12_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp12_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp12_RST,
  (* syn_peri_port = 0 *) output mipi_tx_dp13_HS_OE,
  (* syn_peri_port = 0 *) output [7:0] mipi_tx_dp13_HS_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp13_LP_N_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp13_LP_N_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp13_LP_P_OE,
  (* syn_peri_port = 0 *) output mipi_tx_dp13_LP_P_OUT,
  (* syn_peri_port = 0 *) output mipi_tx_dp13_RST,
  (* syn_peri_port = 0 *) input mipi_tx_dp00_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_tx_dp00_LP_P_IN,
  (* syn_peri_port = 0 *) input mipi_tx_dp10_LP_N_IN,
  (* syn_peri_port = 0 *) input mipi_tx_dp10_LP_P_IN

);



/////////////////////////////////////////////////////////////////////////////
//ddr4 config
localparam [1:0]    IDLE        = 2'b00,
                    CFG_START   = 2'b01,
                    CFG_DONE    = 2'b11;

reg [1:0]   cfg_st, cfg_next;
reg [7:0]   cfg_count;
//Reset and PLL
wire        arst_n;
wire ddr_cfg_ok;


// Slave Interface Write Address Ports
wire [AXI_ID_WIDTH-1:0]           s_axi_awid;
wire [AXI_ADDR_WIDTH-1:0]         s_axi_awaddr;
wire [7:0]                        s_axi_awlen;
wire [2:0]                        s_axi_awsize;
wire [1:0]                        s_axi_awburst;
wire [0:0]                        s_axi_awlock;
wire [3:0]                        s_axi_awcache;
wire [2:0]                        s_axi_awprot;
wire                              s_axi_awvalid;
wire                              s_axi_awready;
// Slave Interface Write Data Ports
wire [AXI_DATA_WIDTH-1:0]         s_axi_wdata;
wire [(AXI_DATA_WIDTH/8)-1:0]     s_axi_wstrb;
wire                              s_axi_wlast;
wire                              s_axi_wvalid;
wire                              s_axi_wready;
// Slave Interface Write Response Ports
wire                              s_axi_bready;
wire [AXI_ID_WIDTH-1:0]           s_axi_bid;
wire [1:0]                        s_axi_bresp;
wire                              s_axi_bvalid;
// Slave Interface Read Address Ports
wire [AXI_ID_WIDTH-1:0]           s_axi_arid;
wire [AXI_ADDR_WIDTH-1:0]         s_axi_araddr;
wire [7:0]                        s_axi_arlen;
wire [2:0]                        s_axi_arsize;
wire [1:0]                        s_axi_arburst;
wire [0:0]                        s_axi_arlock;
wire [3:0]                        s_axi_arcache;
wire [2:0]                        s_axi_arprot;
wire                              s_axi_arvalid;
wire                              s_axi_arready;
// Slave Interface Read Data Ports
wire                              s_axi_rready;
wire [AXI_ID_WIDTH-1:0]           s_axi_rid;
wire [AXI_DATA_WIDTH-1:0]         s_axi_rdata;
wire [1:0]                        s_axi_rresp;
wire                              s_axi_rlast;
wire                              s_axi_rvalid;

wire  [AXI_ID_WIDTH-1:0]   		m0_axi_awid      ; 
  wire  [AXI_ADDR_WIDTH-1:0]   	m0_axi_awaddr    ; 
  wire  [    7:0]   			m0_axi_awlen     ; 
  wire  [    2:0]   			m0_axi_awsize    ; 
  wire  [    1:0]   			m0_axi_awburst   ; 
  wire  [    1:0]   			m0_axi_awlock    ; 
  wire              			m0_axi_awvalid   ; 
  wire              			m0_axi_awready   ; 
  wire  [AXI_ID_WIDTH-1:0]   	m0_axi_arid      ; 
  wire  [   AXI_ADDR_WIDTH-1:0]   m0_axi_araddr    ; 
  wire  [    7:0]   			m0_axi_arlen     ; 
  wire  [    2:0]   			m0_axi_arsize    ; 
  wire  [    1:0]   			m0_axi_arburst   ; 
  wire  [    1:0]   			m0_axi_arlock    ; 
  wire              			m0_axi_arvalid   ; 
  wire              			m0_axi_arready   ; 
  wire  [AXI_ID_WIDTH-1:0]   	m0_axi_wid       ; 
  wire  [(AXI_DATA_WIDTH/8)-1:0]   m0_axi_wstrb     ; 
  wire              			m0_axi_wlast     ; 
  wire              			m0_axi_wvalid    ; 
  wire  [AXI_DATA_WIDTH-1:0]   	m0_axi_wdata     ; 
  wire              			m0_axi_wready    ; 
  wire  [AXI_ID_WIDTH-1:0]   	m0_axi_bid       ; 
  wire              			m0_axi_bvalid    ; 
  wire              			m0_axi_bready    ; 
  wire              			m0_axi_rready    ; 
  wire  [AXI_ID_WIDTH-1:0]   	m0_axi_rid       ; 
  wire  [    1:0]   			m0_axi_rresp     ; 
  wire              			m0_axi_rlast     ; 
  wire              			m0_axi_rvalid    ; 
  wire  [AXI_DATA_WIDTH-1:0]   	m0_axi_rdata     ; 
  ///////////// AXI MASTER 1   
  wire  [AXI_ID_WIDTH-1:0]   	m1_axi_awid      ; 
  wire  [   AXI_ADDR_WIDTH-1:0]   m1_axi_awaddr    ; 
  wire  [    7:0]   			m1_axi_awlen     ; 
  wire  [    2:0]   			m1_axi_awsize    ; 
  wire  [    1:0]   			m1_axi_awburst   ; 
  wire  [    1:0]   			m1_axi_awlock    ; 
  wire              			m1_axi_awvalid   ; 
  wire              			m1_axi_awready   ; 
  wire  [AXI_ID_WIDTH-1:0]   	m1_axi_arid      ; 
  wire  [   AXI_ADDR_WIDTH-1:0]   m1_axi_araddr    ; 
  wire  [    7:0]   			m1_axi_arlen     ; 
  wire  [    2:0]   			m1_axi_arsize    ; 
  wire  [    1:0]   			m1_axi_arburst   ; 
  wire  [    1:0]   			m1_axi_arlock    ; 
  wire              			m1_axi_arvalid   ; 
  wire              			m1_axi_arready   ; 
  wire  [AXI_ID_WIDTH-1:0]   	m1_axi_wid       ; 
  wire  [(AXI_DATA_WIDTH/8)-1:0]   m1_axi_wstrb     ; 
  wire              			m1_axi_wlast     ; 
  wire              			m1_axi_wvalid    ; 
  wire  [AXI_DATA_WIDTH-1:0]   	m1_axi_wdata     ; 
  wire              			m1_axi_wready    ; 
  wire  [AXI_ID_WIDTH-1:0]   	m1_axi_bid       ; 
  wire              			m1_axi_bvalid    ; 
  wire              			m1_axi_bready    ;  
  wire              			m1_axi_rready    ; 
  wire  [AXI_ID_WIDTH-1:0]   	m1_axi_rid       ; 
  wire  [    1:0]   			m1_axi_rresp     ; 
  wire              			m1_axi_rlast     ; 
  wire              			m1_axi_rvalid    ; 
  wire  [AXI_DATA_WIDTH-1:0]   	m1_axi_rdata     ;   

  ///////////// AXI MASTER 2   
  wire  [AXI_ID_WIDTH-1:0]   	m2_axi_awid      ; 
  wire  [   AXI_ADDR_WIDTH-1:0] m2_axi_awaddr    ; 
  wire  [    7:0]   			m2_axi_awlen     ; 
  wire  [    2:0]   			m2_axi_awsize    ; 
  wire  [    1:0]   			m2_axi_awburst   ; 
  wire  [    1:0]   			m2_axi_awlock    ; 
  wire              			m2_axi_awvalid   ; 
  wire              			m2_axi_awready   ; 
  wire  [AXI_ID_WIDTH-1:0]   	m2_axi_arid      ; 
  wire  [   AXI_ADDR_WIDTH-1:0] m2_axi_araddr    ; 
  wire  [    7:0]   			m2_axi_arlen     ; 
  wire  [    2:0]   			m2_axi_arsize    ; 
  wire  [    1:0]   			m2_axi_arburst   ; 
  wire  [    1:0]   			m2_axi_arlock    ; 
  wire              			m2_axi_arvalid   ; 
  wire              			m2_axi_arready   ; 
  wire  [AXI_ID_WIDTH-1:0]   	m2_axi_wid       ; 
  wire  [(AXI_DATA_WIDTH/8)-1:0]m2_axi_wstrb     ; 
  wire              			m2_axi_wlast     ; 
  wire              			m2_axi_wvalid    ; 
  wire  [AXI_DATA_WIDTH-1:0]   	m2_axi_wdata     ; 
  wire              			m2_axi_wready    ; 
  wire  [AXI_ID_WIDTH-1:0]   	m2_axi_bid       ; 
  wire              			m2_axi_bvalid    ; 
  wire              			m2_axi_bready    ;  
  wire              			m2_axi_rready    ; 
  wire  [AXI_ID_WIDTH-1:0]   	m2_axi_rid       ; 
  wire  [    1:0]   			m2_axi_rresp     ; 
  wire              			m2_axi_rlast     ; 
  wire              			m2_axi_rvalid    ; 
  wire  [AXI_DATA_WIDTH-1:0]   	m2_axi_rdata     ; 

  ///////////// AXI MASTER 3   
  wire  [AXI_ID_WIDTH-1:0]   	m3_axi_awid      ; 
  wire  [   AXI_ADDR_WIDTH-1:0] m3_axi_awaddr    ; 
  wire  [    7:0]   			m3_axi_awlen     ; 
  wire  [    2:0]   			m3_axi_awsize    ; 
  wire  [    1:0]   			m3_axi_awburst   ; 
  wire  [    1:0]   			m3_axi_awlock    ; 
  wire              			m3_axi_awvalid   ; 
  wire              			m3_axi_awready   ; 
  wire  [AXI_ID_WIDTH-1:0]   	m3_axi_arid      ; 
  wire  [   AXI_ADDR_WIDTH-1:0] m3_axi_araddr    ; 
  wire  [    7:0]   			m3_axi_arlen     ; 
  wire  [    2:0]   			m3_axi_arsize    ; 
  wire  [    1:0]   			m3_axi_arburst   ; 
  wire  [    1:0]   			m3_axi_arlock    ; 
  wire              			m3_axi_arvalid   ; 
  wire              			m3_axi_arready   ; 
  wire  [AXI_ID_WIDTH-1:0]   	m3_axi_wid       ; 
  wire  [(AXI_DATA_WIDTH/8)-1:0]m3_axi_wstrb     ; 
  wire              			m3_axi_wlast     ; 
  wire              			m3_axi_wvalid    ; 
  wire  [AXI_DATA_WIDTH-1:0]   	m3_axi_wdata     ; 
  wire              			m3_axi_wready    ; 
  wire  [AXI_ID_WIDTH-1:0]   	m3_axi_bid       ; 
  wire              			m3_axi_bvalid    ; 
  wire              			m3_axi_bready    ;  
  wire              			m3_axi_rready    ; 
  wire  [AXI_ID_WIDTH-1:0]   	m3_axi_rid       ; 
  wire  [    1:0]   			m3_axi_rresp     ; 
  wire              			m3_axi_rlast     ; 
  wire              			m3_axi_rvalid    ; 
  wire  [AXI_DATA_WIDTH-1:0]   	m3_axi_rdata     ; 


  wire    [S_COUNT*AXI_ID_WIDTH-1:0]  axi_m_awid;        //
  wire    [S_COUNT*AXI_ADDR_WIDTH-1:0]axi_m_awaddr;
  wire    [S_COUNT*8-1:0]         		axi_m_awlen;
  wire    [S_COUNT*3-1:0]         		axi_m_awsize;
  wire    [S_COUNT*2-1:0]         		axi_m_awburst;
  wire    [S_COUNT-1:0]           		axi_m_awlock;
  wire    [S_COUNT*4-1:0]         		axi_m_awcache;
  wire    [S_COUNT*3-1:0]         		axi_m_awprot;
  wire    [S_COUNT-1:0]           		axi_m_awvalid;
  wire    [S_COUNT-1:0]           		axi_m_awready;
  wire		[S_COUNT*AXI_ID_WIDTH-1:0]	axi_m_wid;
  wire    [S_COUNT*AXI_DATA_WIDTH-1:0]  axi_m_wdata;
  wire    [S_COUNT*(AXI_DATA_WIDTH/8)-1:0]  axi_m_wstrb;
  wire    [S_COUNT-1:0]           		axi_m_wlast;
  wire    [S_COUNT-1:0]           		axi_m_wvalid;
  wire    [S_COUNT-1:0]           		axi_m_wready;
  wire    [S_COUNT*AXI_ID_WIDTH-1:0]  axi_m_bid;
  wire    [S_COUNT*2-1:0]         		axi_m_bresp;
  wire    [S_COUNT-1:0]           		axi_m_bvalid;
  wire    [S_COUNT-1:0]           		axi_m_bready;
  wire    [S_COUNT*AXI_ID_WIDTH-1:0]  axi_m_arid;
  wire    [S_COUNT*AXI_ADDR_WIDTH-1:0]axi_m_araddr;
  wire    [S_COUNT*8-1:0]         		axi_m_arlen;
  wire    [S_COUNT*3-1:0]         		axi_m_arsize;
  wire    [S_COUNT*2-1:0]         		axi_m_arburst;
  wire    [S_COUNT-1:0]           		axi_m_arlock;
  wire    [S_COUNT-1:0]           		axi_m_arvalid;
  wire    [S_COUNT-1:0]           		axi_m_arready;
  wire    [S_COUNT*AXI_ID_WIDTH-1:0]  axi_m_rid;
  wire    [S_COUNT*AXI_DATA_WIDTH-1:0]axi_m_rdata;
  wire    [S_COUNT*2-1:0]         		axi_m_rresp;
  wire    [S_COUNT-1:0]           		axi_m_rlast;
  wire    [S_COUNT-1:0]           		axi_m_rvalid;
  wire    [S_COUNT-1:0]          			axi_m_rready;// 
  reg [5:0] vs_cnt ;
  reg  out_sync;
//=========================================================================
//signal define
//=========================================================================

/////////////////////////////////////////////////////////////////////////////
//Reset and PLL
assign sys_pll_rstn     = i_sw[0];
assign ddr_pll_rstn     = i_sw[0];
assign MIPI_TX_PLL_RSTN = i_sw[0];
assign pll_byteclk_rstn = i_sw[0];

// LED跑马灯控制 - 所有20个LED都跑马灯
wire [19:0] led_runner_out;  // 20个LED的跑马灯输出

// 拨杆开关控制：i_sw[2]=0时运行，i_sw[2]=1时停止（按下停止）
led_runner #(
    .LED_NUM(20),
    .CLK_FREQ(50_000_000),  // 使用50MHz时钟
    .SPEED_MS(100)          // 100ms切换一次
) u_led_runner (
    .clk(gpio_clk_50m),     // 使用50MHz GPIO时钟
    .rst_n(arst_n),         // 使用PLL锁定信号作为复位
    .enable(~i_sw[2]),      // 拨杆开关按下(i_sw[2]=1)时停止，松开(i_sw[2]=0)时运行
    .led_out(led_runner_out)
);

// LED输出：混合极性处理
// LED12-17 (TR1/TR2, 3.3V): 共阳极，不取反
// LED18-33 (BANK4C/4D, 1.8V): 共阴极，需要取反
assign led[3:0] = led_runner_out[3:0];      // LED12-17: 不取反（共阳极）
assign led[19:4] = ~led_runner_out[19:4];   // LED18-33: 取反（共阴极）

//============================================================
// 双向串口转发 (115200, 8N1)
//    UART1(PC) <-> FIFO1 <-> UART2(外设)
//    UART2(外设) <-> FIFO2 <-> UART1(PC)
//============================================================

// UART1 信号
wire [7:0] uart1_rx_data;
wire uart1_rx_valid;
wire uart1_tx_busy;
reg uart1_tx_start;
reg [7:0] uart1_tx_data;

// UART2 信号
wire [7:0] uart2_rx_data;
wire uart2_rx_valid;
wire uart2_tx_busy;
reg uart2_tx_start;
reg [7:0] uart2_tx_data;
reg diag_uart2_tx_start;
reg [7:0] diag_uart2_tx_data;
reg [7:0] diag_uart_por = 8'h00;
wire diag_uart_rst_n = diag_uart_por[7];
wire uart1_unused_txd;
wire uart2_unused_txd;
reg diag_uart2_txd_reg = 1'b1;
assign uart1_txd = diag_uart2_txd_reg;
assign uart2_txd = diag_uart2_txd_reg;

always @(posedge CLK_5M) begin
  diag_uart_por <= {diag_uart_por[6:0], 1'b1};
end

// FIFO1: UART1接收 -> UART2发送
reg [7:0] fifo1 [0:3];
reg [1:0] fifo1_wr_ptr;
reg [1:0] fifo1_rd_ptr;
reg [2:0] fifo1_count;
wire fifo1_empty = (fifo1_count == 0);
wire fifo1_full = (fifo1_count == 4);

// FIFO2: UART2接收 -> UART1发送
reg [7:0] fifo2 [0:3];
reg [1:0] fifo2_wr_ptr;
reg [1:0] fifo2_rd_ptr;
reg [2:0] fifo2_count;
wire fifo2_empty = (fifo2_count == 0);
wire fifo2_full = (fifo2_count == 4);

// FIFO1写入（UART1接收 -> 写入FIFO1）
always @(posedge CLK_5M or negedge arst_n) begin
  if (!arst_n) begin
    fifo1_wr_ptr <= 0;
  end else begin
    if (uart1_rx_valid && !fifo1_full) begin
      fifo1[fifo1_wr_ptr] <= uart1_rx_data;
      fifo1_wr_ptr <= fifo1_wr_ptr + 1;
    end
  end
end

// FIFO1读取（读取FIFO1 -> UART2发送）
always @(posedge CLK_5M or negedge arst_n) begin
  if (!arst_n) begin
    fifo1_rd_ptr <= 0;
    uart2_tx_start <= 0;
    uart2_tx_data <= 0;
  end else begin
    if (!fifo1_empty && !uart2_tx_busy && !uart2_tx_start) begin
      uart2_tx_data <= fifo1[fifo1_rd_ptr];
      uart2_tx_start <= 1;
      fifo1_rd_ptr <= fifo1_rd_ptr + 1;
    end else begin
      uart2_tx_start <= 0;
    end
  end
end

// FIFO1计数器
always @(posedge CLK_5M or negedge arst_n) begin
  if (!arst_n) begin
    fifo1_count <= 0;
  end else begin
    case ({uart1_rx_valid && !fifo1_full, uart2_tx_start})
      2'b10: fifo1_count <= fifo1_count + 1;
      2'b01: fifo1_count <= fifo1_count - 1;
      default: fifo1_count <= fifo1_count;
    endcase
  end
end

// FIFO2写入（UART2接收 -> 写入FIFO2）
always @(posedge CLK_5M or negedge arst_n) begin
  if (!arst_n) begin
    fifo2_wr_ptr <= 0;
  end else begin
    if (uart2_rx_valid && !fifo2_full) begin
      fifo2[fifo2_wr_ptr] <= uart2_rx_data;
      fifo2_wr_ptr <= fifo2_wr_ptr + 1;
    end
  end
end

// FIFO2读取（读取FIFO2 -> UART1发送）
always @(posedge CLK_5M or negedge arst_n) begin
  if (!arst_n) begin
    fifo2_rd_ptr <= 0;
    uart1_tx_start <= 0;
    uart1_tx_data <= 0;
  end else begin
    if (!fifo2_empty && !uart1_tx_busy && !uart1_tx_start) begin
      uart1_tx_data <= fifo2[fifo2_rd_ptr];
      uart1_tx_start <= 1;
      fifo2_rd_ptr <= fifo2_rd_ptr + 1;
    end else begin
      uart1_tx_start <= 0;
    end
  end
end

// FIFO2计数器
always @(posedge CLK_5M or negedge arst_n) begin
  if (!arst_n) begin
    fifo2_count <= 0;
  end else begin
    case ({uart2_rx_valid && !fifo2_full, uart1_tx_start})
      2'b10: fifo2_count <= fifo2_count + 1;
      2'b01: fifo2_count <= fifo2_count - 1;
      default: fifo2_count <= fifo2_count;
    endcase
  end
end

// UART1 实例（与PC通信）
simple_uart #(
  .CLK_FREQ(5000000),
  .BAUD_RATE(1000000)
) u_uart1 (
  .clk(CLK_5M),
  .rst_n(arst_n),
  .rx(uart1_rxd),
  .tx(uart1_unused_txd),
  .rx_data(uart1_rx_data),
  .rx_valid(uart1_rx_valid),
  .tx_data(uart1_tx_data),
  .tx_start(uart1_tx_start),
  .tx_busy(uart1_tx_busy)
);

// UART2 实例（与外设通信）
simple_uart #(
  .CLK_FREQ(5000000),
  .BAUD_RATE(1000000)
) u_uart2 (
  .clk(CLK_5M),
  .rst_n(diag_uart_rst_n),
  .rx(uart2_rxd),
  .tx(uart2_unused_txd),
  .rx_data(uart2_rx_data),
  .rx_valid(uart2_rx_valid),
  .tx_data(diag_uart2_tx_data),
  .tx_start(diag_uart2_tx_start),
  .tx_busy(uart2_tx_busy)
);

wire pll_all_lock_n = sys_pll_lock & ddr_pll_lock & pll_byteclk_locked & MIPI_TX_PLL_LOCKED;
wire dsi_rst_n = MIPI_TX_PLL_LOCKED & pll_byteclk_locked;
wire csi_rst_n = dsi_rst_n;
assign arst_n = pll_all_lock_n;
reg [20:0] rst_cnt = 'd0;
always@( posedge i_fb_clk or negedge arst_n )
begin
    if( !arst_n )
        rst_cnt <= 'd0;
    else 
        rst_cnt <= rst_cnt[20] ? rst_cnt : rst_cnt + 1'b1;
end 
wire rst_n = rst_cnt[20];
//ddr4 config
always@(posedge i_fb_clk or negedge rst_n)
begin
   
    if(!rst_n)
    begin
        cfg_st <= IDLE;
        cfg_count <= 'h0;
    end 
    else
    begin
        cfg_st <= cfg_next;

        if (cfg_st == IDLE)
            cfg_count <= cfg_count + 1'b1;
        else 
            cfg_count <= 'h0;
    end 
        
end

always@(*)
begin
    cfg_next = cfg_st;
    case(cfg_st)
    IDLE:
    begin
        if(cfg_count == 'hff)
            cfg_next = CFG_START;
        else
            cfg_next = IDLE;
    end
    CFG_START:
    begin
        if(ddr_inst_CFG_DONE)
            cfg_next = CFG_DONE;
        else
            cfg_next = CFG_START;
    end
    CFG_DONE:
        cfg_next = CFG_DONE;
    default:
        cfg_next = IDLE;
    endcase
end

assign ddr_inst_CFG_START    = (cfg_st != IDLE);
assign ddr_cfg_ok   = (cfg_st == CFG_DONE);
assign ddr_inst_CFG_RST    = (cfg_st == IDLE);
assign ddr_inst_CFG_SEL      = 1'b0;

assign axi0_ARESETn = ddr_cfg_ok;
wire sys_rst_n = ddr_cfg_ok;
`ifdef BRAM_VIDEO_PATH
wire video_run_n = dsi_rst_n;
`else
wire video_run_n = dsi_rst_n & ddr_cfg_ok;
`endif
wire pixel_data_en;     // DSI TX 0 使能信号
wire pixel_data_en1;    // DSI TX 1 使能信号

localparam [30:0] RISCV_RELEASE_DELAY_CYCLES = 31'd1250000000; // 5 s at 250 MHz.
wire riscv_release_ready = ddr_cfg_ok & pixel_data_en & pixel_data_en1;
reg [30:0] riscv_release_cnt = 31'd0;
reg riscv_reset_n = 1'b0;

always @(posedge io_peripheralClk) begin
    if (!riscv_release_ready) begin
        riscv_release_cnt <= 31'd0;
        riscv_reset_n <= 1'b0;
    end else if (!riscv_reset_n) begin
        if (riscv_release_cnt == RISCV_RELEASE_DELAY_CYCLES - 1'b1) begin
            riscv_reset_n <= 1'b1;
        end else begin
            riscv_release_cnt <= riscv_release_cnt + 1'b1;
        end
    end
end

assign jtag_inst1_TDO = 1'b0;

wire        riscv_unused_cfg_start;
wire        riscv_unused_cfg_sel;
wire        riscv_unused_cfg_reset;
wire        riscv_unused_spi0_data_0_write;
wire        riscv_unused_spi0_data_0_writeEnable;
wire        riscv_unused_spi0_data_1_write;
wire        riscv_unused_spi0_data_1_writeEnable;
wire        riscv_unused_spi0_data_2_write;
wire        riscv_unused_spi0_data_2_writeEnable;
wire        riscv_unused_spi0_data_3_write;
wire        riscv_unused_spi0_data_3_writeEnable;
wire        riscv_unused_spi0_sclk_write;
wire [3:0]  riscv_unused_spi0_ss;
wire [31:0] riscv_apb_paddr;
wire        riscv_apb_penable;
wire        riscv_apb_pready;
wire        riscv_apb_psel;
wire        riscv_apb_pslverror;
wire [31:0] riscv_apb_pwdata;
wire        riscv_apb_pwrite;
wire [31:0] riscv_apb_prdata;

(* syn_preserve = "true" *) EfxSapphireHpSoc_slb u_riscv_sapphire_soc (
    .io_peripheralClk        (io_peripheralClk),
    .io_peripheralReset      (io_peripheralReset),
    .io_asyncReset           (io_asyncReset),
    .io_gpio_sw_n            (riscv_reset_n),
    .pll_peripheral_locked   (pll_peripheral_locked),
    .pll_system_locked       (ddr_pll_lock),
    .jtagCtrl_capture        (jtagCtrl_capture),
    .jtagCtrl_enable         (jtagCtrl_enable),
    .jtagCtrl_reset          (jtagCtrl_reset),
    .jtagCtrl_shift          (jtagCtrl_shift),
    .jtagCtrl_tdi            (jtagCtrl_tdi),
    .jtagCtrl_tdo            (jtagCtrl_tdo),
    .jtagCtrl_update         (jtagCtrl_update),
    .ut_jtagCtrl_capture     (ut_jtagCtrl_capture),
    .ut_jtagCtrl_enable      (ut_jtagCtrl_enable),
    .ut_jtagCtrl_reset       (ut_jtagCtrl_reset),
    .ut_jtagCtrl_shift       (ut_jtagCtrl_shift),
    .ut_jtagCtrl_tdi         (ut_jtagCtrl_tdi),
    .ut_jtagCtrl_tdo         (ut_jtagCtrl_tdo),
    .ut_jtagCtrl_update      (ut_jtagCtrl_update),
    .system_spi_0_io_data_0_read        (1'b0),
    .system_spi_0_io_data_0_write       (riscv_unused_spi0_data_0_write),
    .system_spi_0_io_data_0_writeEnable (riscv_unused_spi0_data_0_writeEnable),
    .system_spi_0_io_data_1_read        (1'b0),
    .system_spi_0_io_data_1_write       (riscv_unused_spi0_data_1_write),
    .system_spi_0_io_data_1_writeEnable (riscv_unused_spi0_data_1_writeEnable),
    .system_spi_0_io_data_2_read        (1'b0),
    .system_spi_0_io_data_2_write       (riscv_unused_spi0_data_2_write),
    .system_spi_0_io_data_2_writeEnable (riscv_unused_spi0_data_2_writeEnable),
    .system_spi_0_io_data_3_read        (1'b0),
    .system_spi_0_io_data_3_write       (riscv_unused_spi0_data_3_write),
    .system_spi_0_io_data_3_writeEnable (riscv_unused_spi0_data_3_writeEnable),
    .system_spi_0_io_sclk_write         (riscv_unused_spi0_sclk_write),
    .system_spi_0_io_ss                 (riscv_unused_spi0_ss),
    .system_uart_0_io_rxd    (system_uart_0_io_rxd),
    .system_uart_0_io_txd    (system_uart_0_io_txd),
    .cfg_done                (ddr_inst_CFG_DONE),
    .cfg_start               (riscv_unused_cfg_start),
    .cfg_sel                 (riscv_unused_cfg_sel),
    .cfg_reset               (riscv_unused_cfg_reset),
    .axiAInterrupt           (axiAInterrupt),
    .axiA_awaddr             (axiA_awaddr),
    .axiA_awlen              (axiA_awlen),
    .axiA_awsize             (axiA_awsize),
    .axiA_awburst            (axiA_awburst),
    .axiA_awlock             (axiA_awlock),
    .axiA_awcache            (axiA_awcache),
    .axiA_awprot             (axiA_awprot),
    .axiA_awqos              (axiA_awqos),
    .axiA_awregion           (axiA_awregion),
    .axiA_awvalid            (axiA_awvalid),
    .axiA_awready            (axiA_awready),
    .axiA_wdata              (axiA_wdata),
    .axiA_wstrb              (axiA_wstrb),
    .axiA_wvalid             (axiA_wvalid),
    .axiA_wlast              (axiA_wlast),
    .axiA_wready             (axiA_wready),
    .axiA_bresp              (axiA_bresp),
    .axiA_bvalid             (axiA_bvalid),
    .axiA_bready             (axiA_bready),
    .axiA_araddr             (axiA_araddr),
    .axiA_arlen              (axiA_arlen),
    .axiA_arsize             (axiA_arsize),
    .axiA_arburst            (axiA_arburst),
    .axiA_arlock             (axiA_arlock),
    .axiA_arcache            (axiA_arcache),
    .axiA_arprot             (axiA_arprot),
    .axiA_arqos              (axiA_arqos),
    .axiA_arregion           (axiA_arregion),
    .axiA_arvalid            (axiA_arvalid),
    .axiA_arready            (axiA_arready),
    .axiA_rdata              (axiA_rdata),
    .axiA_rresp              (axiA_rresp),
    .axiA_rlast              (axiA_rlast),
    .axiA_rvalid             (axiA_rvalid),
    .axiA_rready             (axiA_rready),
    .userInterruptA          (userInterruptA),
    .userInterruptB          (userInterruptB),
    .io_apbSlave_0_PADDR     (riscv_apb_paddr),
    .io_apbSlave_0_PENABLE   (riscv_apb_penable),
    .io_apbSlave_0_PRDATA    (riscv_apb_prdata),
    .io_apbSlave_0_PREADY    (riscv_apb_pready),
    .io_apbSlave_0_PSEL      (riscv_apb_psel),
    .io_apbSlave_0_PSLVERROR (riscv_apb_pslverror),
    .io_apbSlave_0_PWDATA    (riscv_apb_pwdata),
    .io_apbSlave_0_PWRITE    (riscv_apb_pwrite)
);
//============================================================================================ 
//
//============================================================================================





// wire        hs;
// wire        vs;
// wire        de;
// wire [ 7:0] r_data;
// wire [ 7:0] g_data;
// wire [ 7:0] b_data;
// wire [12:0] hact;
// wire [12:0] vact;
    //     color_bar_rgb #(
	// 		.HS_POLORY 		(1'b0	    ),
	// 		.VS_POLORY 		(1'b0	    ),
            
    //         .TEST_MODE 		(2'b00		)
	// )u_color_bar_rgb(
	// /*i*/.clk	(i_sys_clk),
	// /*i*/.rst_n	(pixel_data_en),//(sys_rst_n ),
    //      .H_VALID 		(HACT/2	    ),
    //     .V_VALID 		(VACT	    ),
    //     .H_FRONT_PORCH 	(HFP/2	    ),
    //     .H_SYNC 		(HSP	    ),
    //     .H_BACK_PORCH 	(HBP/2	    ),
    //     .V_FRONT_PORCH 	(VFP		),
    //     .V_SYNC 		(VSP		),
    //     .V_BACK_PORCH 	(VBP		),
   
	// /*o*/.hs	(hs),
	// /*o*/.vs	(vs),
	// /*o*/.de	(de),
	// /*O*/.h_cnt (h_cnt),
	// /*O*/.v_cnt (v_cnt),
	// /*o*/.rgb_r	(r_data),    //像素数据、红色分量
	// /*o*/.rgb_g	(g_data),    //像素数据、绿色分量
	// /*o*/.rgb_b (b_data)    //像素数据、蓝色分量
	
	// );

//========================================================================== 
// csi 
//========================================================================== 
    wire		       w_mipi_rx_vs1;
    wire		       w_mipi_rx_hs1;
    wire	         w_mipi_rx_de1;
    wire	[63:0]	 w_mipi_rx_data1	;
    reg rx_out_vs_r;

    
    
    always @( posedge i_sysclk_div2 )
    begin 
        rx_out_vs_r <= rx_out_vs;
        if( {rx_out_vs_r,rx_out_vs} == 2'b01)
            vs_cnt <= vs_cnt + 1'b1;
    end 

wire rx_out_de;
wire rx_out_hs;
wire rx_out_vs;
wire [PACK_BIT-1:0] rx_out_data;

wire rx_out_de1;
wire rx_out_hs1;
wire rx_out_vs1;
wire [PACK_BIT-1:0] rx_out_data1;

wire [7:0] ch0_r;
wire [7:0] ch0_g;
wire [7:0] ch0_b;
wire ch0_vs;
wire ch0_hs;
wire ch0_de;
wire [7:0] ch1_r;
wire [7:0] ch1_g;
wire [7:0] ch1_b;
wire ch1_vs;
wire ch1_hs;
wire ch1_de;

wire [13:0] bram_fifo_level;
wire bram_stream_active;
wire bram_overflow_sticky;
wire bram_underflow_sticky;
wire [15:0] bram_overflow_count;
wire [15:0] bram_underflow_count;
wire [15:0] bram_input_frame_count;
wire [15:0] bram_output_frame_count;
wire [15:0] bram_resync_count;
wire raw_serializer_active;
wire [15:0] raw_input_frame_count;
wire [15:0] raw_serialized_frame_count;
wire bram_display_valid;
wire bram_frame_pending;
wire [15:0] bram_captured_frame_count;
wire [15:0] bram_displayed_frame_count;
wire [15:0] bram_swap_count;
wire [15:0] bram_dropped_frame_count;
wire [15:0] bram_measured_frame_lines;
wire [15:0] bram_measured_line_de_min;
wire [15:0] bram_measured_line_de_max;
wire [19:0] bram_measured_frame_de_total;
wire bram_capture_error_sticky;


  soft_mipi_rx_top # (
    .PACK_BIT(PACK_BIT)
  )
  soft_mipi_rx_top_inst (
    .mipi_clk                   (   mipi_clk                   ),
    .CLK_5M                     (   CLK_5M                     ),
    .i_sysclk_div2              (   i_sysclk_div2              ),
    .arst_n                     (   csi_rst_n                  ),
    .mipi_rx_ck0_CLKOUT         (   mipi_rx_ck0_CLKOUT         ),
    .io_cam_scl_IN              (   S0_io_cam_scl_IN           ),
    .io_cam_sda_IN              (   S0_io_cam_sda_IN           ),
    .io_cam_scl_OUT             (   S0_io_cam_scl_OUT          ),
    .io_cam_scl_OE              (   S0_io_cam_scl_OE           ),
    .io_cam_sda_OUT             (   S0_io_cam_sda_OUT          ),
    .io_cam_sda_OE              (   S0_io_cam_sda_OE           ),
    .o_cam_rst_p                (   S0_o_cam_rst_p             ),
    .mipi_rx_ck0_HS_ENA         (   mipi_rx_ck0_HS_ENA         ),
    .mipi_rx_dp00_HS_ENA        (   mipi_rx_dp00_HS_ENA        ),
    .mipi_rx_dp01_HS_ENA        (   mipi_rx_dp01_HS_ENA        ),
    .mipi_rx_dp02_HS_ENA        (   mipi_rx_dp02_HS_ENA        ),
    .mipi_rx_dp03_HS_ENA        (   mipi_rx_dp03_HS_ENA        ),
    .mipi_rx_ck0_HS_TERM        (   mipi_rx_ck0_HS_TERM        ),
    .mipi_rx_dp00_HS_TERM       (   mipi_rx_dp00_HS_TERM       ),
    .mipi_rx_dp01_HS_TERM       (   mipi_rx_dp01_HS_TERM       ),
    .mipi_rx_dp02_HS_TERM       (   mipi_rx_dp02_HS_TERM       ),
    .mipi_rx_dp03_HS_TERM       (   mipi_rx_dp03_HS_TERM       ),
    .mipi_rx_dp00_RST           (   mipi_rx_dp00_RST           ),
    .mipi_rx_dp01_RST           (   mipi_rx_dp01_RST           ),
    .mipi_rx_dp02_RST           (   mipi_rx_dp02_RST           ),
    .mipi_rx_dp03_RST           (   mipi_rx_dp03_RST           ),
    .mipi_rx_ck0_LP_N_IN        (   mipi_rx_ck0_LP_N_IN        ),
    .mipi_rx_ck0_LP_P_IN        (   mipi_rx_ck0_LP_P_IN        ),
    .mipi_rx_dp00_LP_N_IN       (   mipi_rx_dp00_LP_N_IN       ),
    .mipi_rx_dp00_LP_P_IN       (   mipi_rx_dp00_LP_P_IN       ),
    .mipi_rx_dp01_LP_N_IN       (   mipi_rx_dp01_LP_N_IN       ),
    .mipi_rx_dp01_LP_P_IN       (   mipi_rx_dp01_LP_P_IN       ),
    .mipi_rx_dp02_LP_N_IN       (   mipi_rx_dp02_LP_N_IN       ),
    .mipi_rx_dp02_LP_P_IN       (   mipi_rx_dp02_LP_P_IN       ),
    .mipi_rx_dp03_LP_N_IN       (   mipi_rx_dp03_LP_N_IN       ),
    .mipi_rx_dp03_LP_P_IN       (   mipi_rx_dp03_LP_P_IN       ),
    .mipi_rx_dp00_HS_IN         (   mipi_rx_dp00_HS_IN         ),
    .mipi_rx_dp01_HS_IN         (   mipi_rx_dp01_HS_IN         ),
    .mipi_rx_dp02_HS_IN         (   mipi_rx_dp02_HS_IN         ),
    .mipi_rx_dp03_HS_IN         (   mipi_rx_dp03_HS_IN         ),
    .mipi_rx_dp00_FIFO_RD       (   mipi_rx_dp00_FIFO_RD       ),
    .mipi_rx_dp01_FIFO_RD       (   mipi_rx_dp01_FIFO_RD       ),
    .mipi_rx_dp02_FIFO_RD       (   mipi_rx_dp02_FIFO_RD       ),
    .mipi_rx_dp03_FIFO_RD       (   mipi_rx_dp03_FIFO_RD       ),
    .mipi_rx_dp00_FIFO_EMPTY    (   mipi_rx_dp00_FIFO_EMPTY    ),
    .mipi_rx_dp01_FIFO_EMPTY    (   mipi_rx_dp01_FIFO_EMPTY    ),
    .mipi_rx_dp02_FIFO_EMPTY    (   mipi_rx_dp02_FIFO_EMPTY    ),
    .mipi_rx_dp03_FIFO_EMPTY    (   mipi_rx_dp03_FIFO_EMPTY    ),
    .rx_out_de                  (   rx_out_de                  ),
    .rx_out_hs                  (   rx_out_hs                  ),
    .rx_out_vs                  (   rx_out_vs                  ),
    .rx_out_data                (   rx_out_data                )
  );


  soft_mipi_rx_top # (
    .PACK_BIT(PACK_BIT)
  )
  soft_mipi_rx_top_inst1 (
    .mipi_clk                   (   mipi_clk                   ),
    .CLK_5M                     (   CLK_5M                     ),
    .i_sysclk_div2              (   i_sysclk_div2              ),
    .arst_n                     (   csi_rst_n                  ),
    
    .io_cam_scl_IN              (   S1_io_cam_scl_IN           ),
    .io_cam_sda_IN              (   S1_io_cam_sda_IN           ),
    .io_cam_scl_OUT             (   S1_io_cam_scl_OUT          ),
    .io_cam_scl_OE              (   S1_io_cam_scl_OE           ),
    .io_cam_sda_OUT             (   S1_io_cam_sda_OUT          ),
    .io_cam_sda_OE              (   S1_io_cam_sda_OE           ),
    .o_cam_rst_p                (   S1_o_cam_rst_p             ),

    .mipi_rx_ck0_CLKOUT         (   mipi_rx_ck1_CLKOUT         ),
    .mipi_rx_ck0_HS_ENA         (   mipi_rx_ck1_HS_ENA         ),
    .mipi_rx_ck0_HS_TERM        (   mipi_rx_ck1_HS_TERM        ),
    .mipi_rx_ck0_LP_N_IN        (   mipi_rx_ck1_LP_N_IN        ),
    .mipi_rx_ck0_LP_P_IN        (   mipi_rx_ck1_LP_P_IN        ),

    .mipi_rx_dp00_HS_ENA        (   mipi_rx_dp10_HS_ENA        ),
    .mipi_rx_dp01_HS_ENA        (   mipi_rx_dp11_HS_ENA        ),
    .mipi_rx_dp02_HS_ENA        (   mipi_rx_dp12_HS_ENA        ),
    .mipi_rx_dp03_HS_ENA        (   mipi_rx_dp13_HS_ENA        ),
    
    .mipi_rx_dp00_HS_TERM       (   mipi_rx_dp10_HS_TERM       ),
    .mipi_rx_dp01_HS_TERM       (   mipi_rx_dp11_HS_TERM       ),
    .mipi_rx_dp02_HS_TERM       (   mipi_rx_dp12_HS_TERM       ),
    .mipi_rx_dp03_HS_TERM       (   mipi_rx_dp13_HS_TERM       ),
    .mipi_rx_dp00_RST           (   mipi_rx_dp10_RST           ),
    .mipi_rx_dp01_RST           (   mipi_rx_dp11_RST           ),
    .mipi_rx_dp02_RST           (   mipi_rx_dp12_RST           ),
    .mipi_rx_dp03_RST           (   mipi_rx_dp13_RST           ),
    .mipi_rx_dp00_LP_N_IN       (   mipi_rx_dp10_LP_N_IN       ),
    .mipi_rx_dp00_LP_P_IN       (   mipi_rx_dp10_LP_P_IN       ),
    .mipi_rx_dp01_LP_N_IN       (   mipi_rx_dp11_LP_N_IN       ),
    .mipi_rx_dp01_LP_P_IN       (   mipi_rx_dp11_LP_P_IN       ),
    .mipi_rx_dp02_LP_N_IN       (   mipi_rx_dp12_LP_N_IN       ),
    .mipi_rx_dp02_LP_P_IN       (   mipi_rx_dp12_LP_P_IN       ),
    .mipi_rx_dp03_LP_N_IN       (   mipi_rx_dp13_LP_N_IN       ),
    .mipi_rx_dp03_LP_P_IN       (   mipi_rx_dp13_LP_P_IN       ),
    .mipi_rx_dp00_HS_IN         (   mipi_rx_dp10_HS_IN         ),
    .mipi_rx_dp01_HS_IN         (   mipi_rx_dp11_HS_IN         ),
    .mipi_rx_dp02_HS_IN         (   mipi_rx_dp12_HS_IN         ),
    .mipi_rx_dp03_HS_IN         (   mipi_rx_dp13_HS_IN         ),
    .mipi_rx_dp00_FIFO_RD       (   mipi_rx_dp10_FIFO_RD       ),
    .mipi_rx_dp01_FIFO_RD       (   mipi_rx_dp11_FIFO_RD       ),
    .mipi_rx_dp02_FIFO_RD       (   mipi_rx_dp12_FIFO_RD       ),
    .mipi_rx_dp03_FIFO_RD       (   mipi_rx_dp13_FIFO_RD       ),
    .mipi_rx_dp00_FIFO_EMPTY    (   mipi_rx_dp10_FIFO_EMPTY    ),
    .mipi_rx_dp01_FIFO_EMPTY    (   mipi_rx_dp11_FIFO_EMPTY    ),
    .mipi_rx_dp02_FIFO_EMPTY    (   mipi_rx_dp12_FIFO_EMPTY    ),
    .mipi_rx_dp03_FIFO_EMPTY    (   mipi_rx_dp13_FIFO_EMPTY    ),
    .rx_out_de                  (   rx_out_de1                  ),
    .rx_out_hs                  (   rx_out_hs1                  ),
    .rx_out_vs                  (   rx_out_vs1                  ),
    .rx_out_data                (   rx_out_data1                )
  );
`ifdef  FRAME_BUFFER

//============================================================================================ 
//frame_buffer 0 
//============================================================================================	
  
frame_buffer #(
.AXI_DATA_WIDTH ( AXI_DATA_WIDTH	),
.I_VID_WIDTH    ( I_VID_WIDTH       ),
.O_VID_WIDTH    ( O_VID_WIDTH       ),
.FB_NUM         ( FB_NUM            ),
.BURST_LEN      ( BURST_LEN         ),
.MAX_VID_WIDTH 	( MAX_VID_WIDTH     ),
.MAX_VID_HIGHT 	( MAX_VID_HIGHT     ),
.AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH	),
.WR_FIFO_DEPTH	( WR_FIFO_DEPTH		),    
.RD_FIFO_DEPTH 	( RD_FIFO_DEPTH 	),
.START_ADDR		(	START_ADDR		)
)u_frame_buffer(
    .axi_clk(axi0_ACLK),
    .rst_n(pixel_data_en | pixel_data_en1),
    // .i_clk  (i_sys_clk) ,
    // .i_vs   (vs) , 
    // .i_de   (de) , 
    // .vin   ({r_data,g_data,b_data}) ,// ({24'habcdef}),//

/*i*/.i_clk			(i_sysclk_div2      ),
/*i*/.i_vs			(rx_out_vs	),
/*i*/.i_de			(rx_out_de 	),
/*i*/.vin 			({rx_out_data[39:32],rx_out_data[29:22],rx_out_data[19:12],rx_out_data[9:2]}	),

    .o_clk  (i_sysclk_div2) ,
    // .o_hs   (fb_ch0_hs) ,
    // .o_vs   (fb_ch0_vs) ,
    // .o_de   (fb_ch0_de) ,
    // .vout   ({fb_ch0_dout}) ,

    /*i*/.o_hs    		(ch0_hs		),			
/*i*/.o_vs    		(ch0_vs		),			
/*i*/.o_de    		(ch0_de		),			
/*i*/.vout    		({ch0_g,ch0_b}	),//ch0_r,

    .H_FRONT_PORCH 	(HFP/2	    ),
    .H_SYNC 		(HSP/2	    ),	
    .H_VALID 		(HACT/2	    ),
    .H_BACK_PORCH 	(HBP/2	    ),
    .V_FRONT_PORCH 	(VFP		),
    .V_SYNC 		(VSP		),	
    .V_VALID 		(VACT	    ),
    .V_BACK_PORCH 	(VBP		),
    .out_sync         (out_sync),
    .awid   (axi_m_awid		  [1*AXI_ID_WIDTH-1   : 0]		),//(m0_axi_awid      ),//(AXI_MUX_EN ? : axi0_AWID     ),
.awaddr     (axi_m_awaddr	  [1*AXI_ADDR_WIDTH-1 : 0]		),//(m0_axi_awaddr    ),//(AXI_MUX_EN ? : axi0_AWADDR   ),
.awlen      (axi_m_awlen		[1*8-1      : 0]			),//(m0_axi_awlen     ),//(AXI_MUX_EN ? : axi0_AWLEN    ),
.awsize     (axi_m_awsize	  [1*3-1			 :0]		),//(m0_axi_awsize    ),//(AXI_MUX_EN ? : axi0_AWSIZE   ),
.awburst    (axi_m_awburst	[1*2-1      : 0]				),//(m0_axi_awburst   ),//(AXI_MUX_EN ? : axi0_AWBURST  ),
.awcache    (),//(m0_axi_awcache   ),//(AXI_MUX_EN ? : axi0_AWCACHE  ),
.awlock     (axi_m_awlock 	[1*1-1      : 0]				),//(m0_axi_awlock    ),//(AXI_MUX_EN ? : axi0_AWLOCK   ),
.awvalid    (axi_m_awvalid	[1*1-1      : 0]				),//(m0_axi_awvalid   ),//(AXI_MUX_EN ? : axi0_AWVALID  ),
.awcobuf    (),//(axi_m_wid			[1*AXI_ID_WIDTH-1:0]		),//(m0_axi_awcobuf   ),//(AXI_MUX_EN ? : axi0_AWCOBUF  ),
.awapcmd    (),//(m0_axi_awapcmd   ),//(AXI_MUX_EN ? : axi0_AWAPCMD  ),
.awallstrb  (),//(m0_axi_awallstrb ),//(AXI_MUX_EN ? : axi0_AWALLSTRB),
.awready    (axi_m_awready	[1*1-1      : 0]				),//(m0_axi_awready   ),//(AXI_MUX_EN ? : axi0_AWREADY  ),
.awqos      (),//(axi_m_bresp		[1*2-1      : 0]			),//(m0_axi_awqos     ),//(AXI_MUX_EN ? : axi0_AWQOS    ),
.arid       (axi_m_arid		  [1*AXI_ID_WIDTH-1   : 0]		),//(m0_axi_arid      ),//(AXI_MUX_EN ? : axi0_ARID     ),
.araddr     (axi_m_araddr	  [1*AXI_ADDR_WIDTH-1 : 0]		),//(m0_axi_araddr    ),//(AXI_MUX_EN ? : axi0_ARADDR   ),
.arlen      (axi_m_arlen		[1*8-1      : 0]   			),//(m0_axi_arlen     ),//(AXI_MUX_EN ? : axi0_ARLEN    ),
.arsize     (axi_m_arsize 	[1*3-1      : 0]   				),//(m0_axi_arsize    ),//(AXI_MUX_EN ? : axi0_ARSIZE   ),
.arburst    (axi_m_arburst	[1*2-1      : 0]   				),//(m0_axi_arburst   ),//(AXI_MUX_EN ? : axi0_ARBURST  ),
.arlock     (axi_m_arlock	  [1*1-1      : 0]   			),//(m0_axi_arlock    ),//(AXI_MUX_EN ? : axi0_ARLOCK   ),
.arvalid    (axi_m_arvalid	[1*1-1      : 0]				),//(m0_axi_arvalid   ),//(AXI_MUX_EN ? : axi0_ARVALID  ),
.arapcmd    (),//(m0_axi_arapcmd   ),//(AXI_MUX_EN ? : axi0_ARAPCMD  ),
.arready    (axi_m_arready	[1*1-1      : 0]				),//(m0_axi_arready   ),//(AXI_MUX_EN ? : axi0_ARREADY  ),
.arqos      (),//(m0_axi_arqos     ),//(AXI_MUX_EN ? : axi0_ARQOS    ),
.wdata      (axi_m_wdata		[1*AXI_DATA_WIDTH-1 : 0]	),//(m0_axi_wdata     ),//(AXI_MUX_EN ? : axi0_WDATA    ),
.wstrb      (axi_m_wstrb		[1*(AXI_DATA_WIDTH/8)-1 : 0]			),//(m0_axi_wstrb     ),//(AXI_MUX_EN ? : axi0_WSTRB    ),
.wlast      (axi_m_wlast		[1*1-1      : 0]			),//(m0_axi_wlast     ),//(AXI_MUX_EN ? : axi0_WLAST    ),
.wvalid     (axi_m_wvalid	  [1*1-1      : 0]				),//(m0_axi_wvalid    ),//(AXI_MUX_EN ? : axi0_WVALID   ),
.wready     (axi_m_wready	  [1*1-1      : 0]				),//(m0_axi_wready    ),//(AXI_MUX_EN ? : axi0_WREADY   ),
.rid        (axi_m_rid			[1*8-1      : 0]   			),//(m0_axi_rid       ),//(AXI_MUX_EN ? : axi0_RID      ),
.rdata      (axi_m_rdata		[1*AXI_DATA_WIDTH-1 : 0]	),//(m0_axi_rdata     ),//(AXI_MUX_EN ? : axi0_RDATA    ),
.rlast      (axi_m_rlast		[1*1-1      : 0]   			),//(m0_axi_rlast     ),//(AXI_MUX_EN ? : axi0_RLAST    ),
.rvalid     (axi_m_rvalid	  [1*1-1      : 0]   			),//(m0_axi_rvalid    ),//(AXI_MUX_EN ? : axi0_RVALID   ),
.rready     (axi_m_rready	  [1*1-1      : 0]   			),//(m0_axi_rready    ),//(AXI_MUX_EN ? : axi0_RREADY   ),
.rresp      (axi_m_rresp		[1*2-1      : 0]   			),//(m0_axi_rresp     ),//(AXI_MUX_EN ? : axi0_RRESP    ),
.bid        (axi_m_bid			[1*8-1      : 0]			),//(m0_axi_bid       ),//(AXI_MUX_EN ? : axi0_BID      ),
.bvalid     (axi_m_bvalid	  [1*1-1      : 0]				),//(m0_axi_bvalid    ),//(AXI_MUX_EN ? : axi0_BVALID   ),
.bready     (axi_m_bready	  [1*1-1      : 0]				)//(m0_axi_bready    ) //(AXI_MUX_EN ? : axi0_BREADY   )
);



// color_bar_checker  #(
//     .DATA_WIDTH (O_VID_WIDTH)
// )u_color_bar_checker (
//     .clk(i_sysclk_div2),
//     .rst_n(sys_rst_n),
//     .i_hs(fb_ch0_hs),
//     .i_vs(fb_ch0_vs),
//     .i_de(fb_ch0_de),
//     .vin(fb_ch0_dout),
//     .check_fail(check_fail)
//   );

//============================================================================================ 
//framebuffer 1
//============================================================================================	
// wire fb_ch1_hs;
// wire fb_ch1_vs;
// wire fb_ch1_de;
// wire [48-1:0] fb_ch1_dout;
wire        hs1;
wire        vs1;
wire        de1;
wire [ 7:0] r_data1;
wire [ 7:0] g_data1;
wire [ 7:0] b_data1;
wire [12:0] hact1;
wire [12:0] vact1;
   

    
// 	color_bar_rgb # (
//     .DYN_EN(1'b0),
//     .HS_POLORY(1'b0),
//     .VS_POLORY(1'b0),
//     .SYMBOL_WIDTH(8),
//     .SYMBOL_NUM(3),
//     .PAR_PIXEL_NUM(1),
//     .HFP(HFP),
//     .HST(HSP),
//     .HACT(3840),
//     .HBP(HBP),
//     .VFP(VFP),
//     .VST(VSP),
//     .VACT(2160),
//     .VBP(VBP),
//     .TEST_MODE(2'd1)
//   )
//   color_bar_rgb_inst (
//     .clk(clk_54m),
//     .rst_n(1'b1),
//     .i_cfg_vid(i_cfg_vid),
//     .h_cnt(h_cnt1),
//     .v_cnt(v_cnt1),
//     .hs(hs1),
//     .vs(vs1),
//     .de(de1),
//     .o_vid_data({r_data1,g_data1,b_data1})
//   );
	

frame_buffer #(
.AXI_DATA_WIDTH ( AXI_DATA_WIDTH	),
.I_VID_WIDTH    ( I_VID_WIDTH       ),
.O_VID_WIDTH    ( O_VID_WIDTH       ),
.FB_NUM         ( FB_NUM            ),
.BURST_LEN      ( BURST_LEN         ),
.MAX_VID_WIDTH 	( 1920     ),
.MAX_VID_HIGHT 	( 1080     ),
.AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH	),
.WR_FIFO_DEPTH	( WR_FIFO_DEPTH		),    
.RD_FIFO_DEPTH 	( RD_FIFO_DEPTH 	),
.START_ADDR		( 32'h0180_0000		)
)u_frame_buffer1(
  .axi_clk(axi0_ACLK),
  .rst_n(pixel_data_en | pixel_data_en1),
//   .i_clk  (i_sysclk_div2) ,
//   .i_vs   (vs1) , 
//   .i_de   (de1) , 
//   .vin   ({24'd0,r_data1,g_data1,b_data1}) ,// ({24'habcdef}),//

/*i*/.i_clk			(i_sysclk_div2      ),
/*i*/.i_vs			(rx_out_vs1	),
/*i*/.i_de			(rx_out_de1 	),
/*i*/.vin 			({rx_out_data1[39:32],rx_out_data1[29:22],rx_out_data1[19:12],rx_out_data1[9:2]}	),

/*i*/.o_clk       (i_sysclk_div2  ) ,
/*i*/.o_hs    		(ch1_hs	    ),			
/*i*/.o_vs    		(ch1_vs	    ),			
/*i*/.o_de    		(ch1_de	    ),			
/*i*/.vout    		({ch1_g,ch1_b}	),//ch0_r,

   .H_FRONT_PORCH 	(HFP/2	    ),
    .H_SYNC 		(HSP/2	    ),	
    .H_VALID 		(HACT/2	    ),
    .H_BACK_PORCH 	(HBP/2	    ),
    .V_FRONT_PORCH 	(VFP		),
    .V_SYNC 		(VSP		),	
    .V_VALID 		(VACT	    ),
    .V_BACK_PORCH 	(VBP		),
  .out_sync         (out_sync       ),
.awid       (axi_m_awid		 [2*AXI_ID_WIDTH-1   : 1*AXI_ID_WIDTH]		    ),//(m0_axi_awid      ),//(AXI_MUX_EN ? : axi0_AWID     ),
.awaddr     (axi_m_awaddr	 [2*AXI_ADDR_WIDTH-1 : 1*AXI_ADDR_WIDTH]		),//(m0_axi_awaddr    ),//(AXI_MUX_EN ? : axi0_AWADDR   ),
.awlen      (axi_m_awlen	 [2*8-1      : 1*8]			    ),//(m0_axi_awlen     ),//(AXI_MUX_EN ? : axi0_AWLEN    ),
.awsize     (axi_m_awsize	 [2*3-1		 : 1*3]		        ),//(m0_axi_awsize    ),//(AXI_MUX_EN ? : axi0_AWSIZE   ),
.awburst    (axi_m_awburst	 [2*2-1      : 1*2]				),//(m0_axi_awburst   ),//(AXI_MUX_EN ? : axi0_AWBURST  ),
.awlock     (axi_m_awlock 	 [2*1-1      : 1*1]				),//(m0_axi_awlock    ),//(AXI_MUX_EN ? : axi0_AWLOCK   ),
.awvalid    (axi_m_awvalid	 [2*1-1      : 1*1]				),//(m0_axi_awvalid   ),//(AXI_MUX_EN ? : axi0_AWVALID  ),
.awready    (axi_m_awready	 [2*1-1      : 1*1]				),//(m0_axi_awready   ),//(AXI_MUX_EN ? : axi0_AWREADY  ),
.arid       (axi_m_arid		 [2*AXI_ID_WIDTH-1   : 1*AXI_ID_WIDTH]		    ),//(m0_axi_arid      ),//(AXI_MUX_EN ? : axi0_ARID     ),
.araddr     (axi_m_araddr	 [2*AXI_ADDR_WIDTH-1 : 1*AXI_ADDR_WIDTH]		),//(m0_axi_araddr    ),//(AXI_MUX_EN ? : axi0_ARADDR   ),
.arlen      (axi_m_arlen	 [2*8-1      : 1*8]   			),//(m0_axi_arlen     ),//(AXI_MUX_EN ? : axi0_ARLEN    ),
.arsize     (axi_m_arsize 	 [2*3-1      : 1*3]   			),//(m0_axi_arsize    ),//(AXI_MUX_EN ? : axi0_ARSIZE   ),
.arburst    (axi_m_arburst	 [2*2-1      : 1*2]   			),//(m0_axi_arburst   ),//(AXI_MUX_EN ? : axi0_ARBURST  ),
.arlock     (axi_m_arlock	 [2*1-1      : 1*1]   			),//(m0_axi_arlock    ),//(AXI_MUX_EN ? : axi0_ARLOCK   ),
.arvalid    (axi_m_arvalid	 [2*1-1      : 1*1]				),//(m0_axi_arvalid   ),//(AXI_MUX_EN ? : axi0_ARVALID  ),
.arready    (axi_m_arready	 [2*1-1      : 1*1]				),//(m0_axi_arready   ),//(AXI_MUX_EN ? : axi0_ARREADY  ),
.wdata      (axi_m_wdata	 [2*AXI_DATA_WIDTH-1 : 1*AXI_DATA_WIDTH]	        ),//(m0_axi_wdata     ),//(AXI_MUX_EN ? : axi0_WDATA    ),
.wstrb      (axi_m_wstrb	 [2*(AXI_DATA_WIDTH/8)-1 : 1*(AXI_DATA_WIDTH/8)]	),//(m0_axi_wstrb     ),//(AXI_MUX_EN ? : axi0_WSTRB    ),
.wlast      (axi_m_wlast	 [2*1-1      : 1*1]			    ),//(m0_axi_wlast     ),//(AXI_MUX_EN ? : axi0_WLAST    ),
.wvalid     (axi_m_wvalid	 [2*1-1      : 1*1]				),//(m0_axi_wvalid    ),//(AXI_MUX_EN ? : axi0_WVALID   ),
.wready     (axi_m_wready	 [2*1-1      : 1*1]				),//(m0_axi_wready    ),//(AXI_MUX_EN ? : axi0_WREADY   ),
.rid        (axi_m_rid		 [2*8-1      : 1*8]   			),//(m0_axi_rid       ),//(AXI_MUX_EN ? : axi0_RID      ),
.rdata      (axi_m_rdata	 [2*AXI_DATA_WIDTH-1 : 1*AXI_DATA_WIDTH]	        ),//(m0_axi_rdata     ),//(AXI_MUX_EN ? : axi0_RDATA    ),
.rlast      (axi_m_rlast	 [2*1-1      : 1*1]   			),//(m0_axi_rlast     ),//(AXI_MUX_EN ? : axi0_RLAST    ),
.rvalid     (axi_m_rvalid	 [2*1-1      : 1*1]   			),//(m0_axi_rvalid    ),//(AXI_MUX_EN ? : axi0_RVALID   ),
.rready     (axi_m_rready	 [2*1-1      : 1*1]   			),//(m0_axi_rready    ),//(AXI_MUX_EN ? : axi0_RREADY   ),
.rresp      (axi_m_rresp	 [2*2-1      : 1*2]   			),//(m0_axi_rresp     ),//(AXI_MUX_EN ? : axi0_RRESP    ),
.bid        (axi_m_bid		 [2*8-1      : 1*8]			    ),//(m0_axi_bid       ),//(AXI_MUX_EN ? : axi0_BID      ),
.bvalid     (axi_m_bvalid	 [2*1-1      : 1*1]				),//(m0_axi_bvalid    ),//(AXI_MUX_EN ? : axi0_BVALID   ),
.bready     (axi_m_bready	 [2*1-1      : 1*1]				)//(m0_axi_bready    ) //(AXI_MUX_EN ? : axi0_BREADY   )

);



// color_bar_checker  #(
//     .DATA_WIDTH (48)
// )u_color_bar_checker (
//     .clk(i_sysclk_div2),
//     .rst_n(sys_rst_n),
//     .i_hs(fb_ch1_hs),
//     .i_vs(fb_ch1_vs),
//     .i_de(fb_ch1_de),
//     .vin(fb_ch1_dout),
//     .check_fail(check_fail)
//   );

//======================================================================================================== 
// axi_interconnect
//======================================================================================================== 
axi_interconnect #
(
    .S_COUNT                            (S_COUNT                            ),
    .M_COUNT                            (M_COUNT                            ),
    .DATA_WIDTH                         (AXI_DATA_WIDTH                     ),
    .ADDR_WIDTH                         (AXI_ADDR_WIDTH                     ),
    .ID_WIDTH                           (AXI_ID_WIDTH                       )
)
uw_axi_interconnect
(
    .clk                                (axi0_ACLK                            ),
    .rst                                (~pixel_data_en                         ),
//AXI slave interfaces
    .s_axi_awid                         (axi_m_awid	  [S_COUNT*AXI_ID_WIDTH-1   : 0]    ),// 
    .s_axi_awaddr                       (axi_m_awaddr [S_COUNT*AXI_ADDR_WIDTH-1 : 0]   	), 
    .s_axi_awlen                        (axi_m_awlen  [S_COUNT*8-1      : 0]   			), 
    .s_axi_awsize                       (axi_m_awsize [S_COUNT*3-1		: 0]	 		), 
    .s_axi_awburst                      (axi_m_awburst[S_COUNT*2-1      : 0]   			), 
    .s_axi_awlock                       (axi_m_awlock [S_COUNT*1-1      : 0]   			), 
    .s_axi_awcache                      (axi_m_awcache[S_COUNT*4-1      : 0]   			), 
    .s_axi_awprot                       (axi_m_awprot [S_COUNT*3-1      : 0]   			), 
    .s_axi_awvalid                      (axi_m_awvalid[S_COUNT*1-1      : 0]   			), 
    .s_axi_awready                      (axi_m_awready[S_COUNT*1-1      : 0]   			),

    .s_axi_wdata                        (axi_m_wdata  [S_COUNT*AXI_DATA_WIDTH-1 : 0]   	), 
    .s_axi_wstrb                        (axi_m_wstrb  [S_COUNT*(AXI_DATA_WIDTH/8)-1 : 0]), 
    .s_axi_wlast                        (axi_m_wlast  [S_COUNT*1-1      : 0]   			), 
    .s_axi_wvalid                       (axi_m_wvalid [S_COUNT*1-1      : 0]   			), 
    .s_axi_wready                       (axi_m_wready [S_COUNT*1-1      : 0]   			),
    .s_axi_bid                          (axi_m_bid    [S_COUNT*8-1      : 0]   			),
    .s_axi_bresp                        (axi_m_bresp  [S_COUNT*2-1      : 0]   			), 
    .s_axi_bvalid                       (axi_m_bvalid [S_COUNT*1-1      : 0]   			), 
    .s_axi_bready                       (axi_m_bready [S_COUNT*1-1      : 0]   			),
//AXI master interfaces
    .m_axi_awid                         (axi0_AWID       ), //(axi_m1_awid      ),
    .m_axi_awaddr                       (axi0_AWADDR     ), //(axi_m1_awaddr   	), 
    .m_axi_awlen                        (axi0_AWLEN      ), //(axi_m1_awlen     ), 
    .m_axi_awsize                       (axi0_AWSIZE     ), //(axi_m1_awsize    ), 
    .m_axi_awburst                      (axi0_AWBURST    ), //(axi_m1_awburst   ), 
    .m_axi_awlock                       (axi0_AWLOCK     ), //(axi_m1_awlock    ), 
    .m_axi_awcache                      (),//(axi_m1_awcache   ), 
    .m_axi_awprot                       (),//(axi0_WID        ), //(axi_m1_awprot    ), 
    .m_axi_awvalid                      (axi0_AWVALID    ), //(axi_m1_awvalid   ), 
    .m_axi_awready                      (axi0_AWREADY    ), //(axi_m1_awready   ), 
    .m_axi_wdata                        (axi0_WDATA      ), //(axi_m1_wdata     ), 
    .m_axi_wstrb                        (axi0_WSTRB      ), //(axi_m1_wstrb     ), 
    .m_axi_wlast                        (axi0_WLAST      ), //(axi_m1_wlast     ), 
    .m_axi_wvalid                       (axi0_WVALID     ), //(axi_m1_wvalid    ), 
    .m_axi_wready                       (axi0_WREADY     ), //(axi_m1_wready    ),
    .m_axi_bid                          (axi0_BID        ), //(axi_m1_bid       ),
    .m_axi_bresp                        (),//(axi_m1_bresp     ), 
    .m_axi_bvalid                       (axi0_BVALID     ), //(axi_m1_bvalid    ), 
    .m_axi_bready                       (axi0_BREADY     )//, //(axi_m1_bready    ),
);

axi_interconnect #
(
    .S_COUNT                            (S_COUNT                            ),
    .M_COUNT                            (M_COUNT                            ),
    .DATA_WIDTH                         (AXI_DATA_WIDTH                     ),
    .ADDR_WIDTH                         (AXI_ADDR_WIDTH                     ),
    .ID_WIDTH                           (AXI_ID_WIDTH                       )
)
ur_axi_interconnect
(
    .clk                                (axi0_ACLK                            ),
    .rst                                (~pixel_data_en                         ),
//AXI slave interfaces
    
    .s_axi_arid                         (axi_m_arid   [S_COUNT*AXI_ID_WIDTH-1   : 0]   	),
    .s_axi_araddr                       (axi_m_araddr [S_COUNT*AXI_ADDR_WIDTH-1 : 0]   	), 
    .s_axi_arlen                        (axi_m_arlen  [S_COUNT*8-1      : 0]   			), 
    .s_axi_arsize                       (axi_m_arsize [S_COUNT*3-1      : 0]   			), 
    .s_axi_arburst                      (axi_m_arburst[S_COUNT*2-1      : 0]   			), 
    .s_axi_arlock                       (axi_m_arlock [S_COUNT*1-1      : 0]   			), 
    .s_axi_arvalid                      (axi_m_arvalid[S_COUNT*1-1      : 0]   			), 
    .s_axi_arready                      (axi_m_arready[S_COUNT*1-1      : 0]   			),
    .s_axi_rid                          (axi_m_rid    [S_COUNT*8-1      : 0]   			),
    .s_axi_rdata                        (axi_m_rdata  [S_COUNT*AXI_DATA_WIDTH-1 : 0]   	), 
    .s_axi_rresp                        (axi_m_rresp  [S_COUNT*2-1      : 0]   			), 
    .s_axi_rlast                        (axi_m_rlast  [S_COUNT*1-1      : 0]   			), 
    .s_axi_rvalid                       (axi_m_rvalid [S_COUNT*1-1      : 0]   			), 
    .s_axi_rready                       (axi_m_rready [S_COUNT*1-1      : 0]   			),
//AXI master interfaces
   
    .m_axi_arid                         (axi0_ARID       ), //(axi_m1_arid      ),
    .m_axi_araddr                       (axi0_ARADDR     ), //(axi_m1_araddr    ), 
    .m_axi_arlen                        (axi0_ARLEN      ),  //(axi_m1_arlen     ), 
    .m_axi_arsize                       (axi0_ARSIZE     ), //(axi_m1_arsize    ), 
    .m_axi_arburst                      (axi0_ARBURST    ), //(axi_m1_arburst   ), 
    .m_axi_arlock                       (axi0_ARLOCK     ), //(axi_m1_arlock    ), 
    .m_axi_arcache                      (),//(axi_m1_arcache   ), 
    .m_axi_arprot                       (),//(axi_m1_arprot    ), 
    .m_axi_arvalid                      (axi0_ARVALID    ), //(axi_m1_arvalid   ), 
    .m_axi_arready                      (axi0_ARREADY    ), //(axi_m1_arready   ),
    .m_axi_rid                          (axi0_RID        ), //(axi_m1_rid       ),
    .m_axi_rdata                        (axi0_RDATA      ), //(axi_m1_rdata     ), 
    .m_axi_rresp                        (axi0_RRESP      ), //(axi_m1_rresp     ), 
    .m_axi_rlast                        (axi0_RLAST      ), //(axi_m1_rlast     ), 
    .m_axi_rvalid                       (axi0_RVALID     ), //(axi_m1_rvalid    ), 
    .m_axi_rready                       (axi0_RREADY     )  //(axi_m1_rready    )
);
assign bram_fifo_level = 14'd0;
assign bram_stream_active = 1'b0;
assign bram_overflow_sticky = 1'b0;
assign bram_underflow_sticky = 1'b0;
assign bram_overflow_count = 16'd0;
assign bram_underflow_count = 16'd0;
assign bram_input_frame_count = 16'd0;
assign bram_output_frame_count = 16'd0;
assign bram_resync_count = 16'd0;
`else
raw_burst_serializer #(
    .FIFO_DEPTH_WORDS(8192)
) u_raw_burst_serializer (
    .clk(i_sysclk_div2),
    .rst_n(pixel_data_en | pixel_data_en1),
    .in_vs(rx_out_vs),
    .in_de(rx_out_de),
    .in_raw4({rx_out_data[39:32], rx_out_data[29:22],
              rx_out_data[19:12], rx_out_data[9:2]}),
    .out_vs(ch0_vs),
    .out_hs(ch0_hs),
    .out_de(ch0_de),
    // Match video_primary: framebuffer vout was {ch0_g,ch0_b}, then the
    // Debayer consumed {ch0_b,ch0_g}. Preserve that intentional RAW pair flip.
    .out_raw2({ch0_g, ch0_b}),
    .fifo_level(bram_fifo_level),
    .active(raw_serializer_active),
    .overflow_sticky(bram_overflow_sticky),
    .overflow_count(bram_overflow_count),
    .input_frame_count(raw_input_frame_count),
    .output_frame_count(raw_serialized_frame_count),
    .output_line_count()
);

assign bram_stream_active = bram_display_valid;
assign bram_underflow_sticky = bram_capture_error_sticky;
assign bram_underflow_count = bram_dropped_frame_count;
assign bram_input_frame_count = bram_captured_frame_count;
assign bram_output_frame_count = bram_displayed_frame_count;
assign bram_resync_count = bram_swap_count;

assign ch0_r = 8'd0;
assign ch1_r = 8'd0;
assign ch1_g = 8'd0;
assign ch1_b = 8'd0;
assign ch1_vs = 1'b0;
assign ch1_hs = 1'b0;
assign ch1_de = 1'b0;

// FPGA video does not own DDR AXI0 in BRAM mode. DDR remains available to
// the Hard SoC through its dedicated fixed interface.
assign axi0_ARADDR = 33'd0;
assign axi0_ARAPCMD = 1'b0;
assign axi0_ARBURST = 2'b01;
assign axi0_ARID = 6'd0;
assign axi0_ARLEN = 8'd0;
assign axi0_ARLOCK = 1'b0;
assign axi0_ARQOS = 1'b0;
assign axi0_ARSIZE = 3'd6;
assign axi0_ARVALID = 1'b0;
assign axi0_AWADDR = 33'd0;
assign axi0_AWALLSTRB = 1'b0;
assign axi0_AWAPCMD = 1'b0;
assign axi0_AWBURST = 2'b01;
assign axi0_AWCACHE = 4'd0;
assign axi0_AWCOBUF = 1'b0;
assign axi0_AWID = 6'd0;
assign axi0_AWLEN = 8'd0;
assign axi0_AWLOCK = 1'b0;
assign axi0_AWQOS = 1'b0;
assign axi0_AWSIZE = 3'd6;
assign axi0_AWVALID = 1'b0;
assign axi0_BREADY = 1'b0;
assign axi0_RREADY = 1'b0;
assign axi0_WDATA = 512'd0;
assign axi0_WLAST = 1'b0;
assign axi0_WSTRB = 64'd0;
assign axi0_WVALID = 1'b0;
`endif 


//***************************************************************************
// debayer
//***************************************************************************

reg [26:0] sw_cnt;
always @( posedge i_sysclk_div2)
begin
    sw_cnt <= sw_cnt + 1'b1;
    if( sw_cnt[25] )
        out_sync <= 1'b1;
end



  wire        rgb_vs;
  wire        rgb_hs;
  wire        rgb_de;
  wire        rgb_valid;
  wire [47:0] rgb_datax2;
  wire        rgb1_vs;
  wire        rgb1_hs;
  wire        rgb1_de;
  wire        rgb1_valid;
  wire [47:0] rgb1_datax2;
  
  debayer_top_2to1 debayer_top
  (
      .in_pclk		  (i_sysclk_div2),//(i_mipi_rx_pclk ),
      .in_rstn		  (pixel_data_en | pixel_data_en1),
      
      .raw_vs_i		  (ch0_vs		  ),//(ch1_vs	     ),//
      .raw_hs_i		  (ch0_hs		  ),//(ch1_hs	     ),//	 
      .raw_de_i		  (ch0_de		  ),//(ch1_de	     ),//	
      .raw_valid_i	  (ch0_de	      ),//(ch1_de	     ),//	
      .raw_datax4_i	  ({ch0_b,ch0_g}  ),//
      
      .rgb_vs_o		  (rgb_vs         ),
      .rgb_hs_o		  (rgb_hs         ),
      .rgb_de_o		  (rgb_de         ),
      .rgb_valid_o	  (rgb_valid      ),
      .rgb_datax2_o   (rgb_datax2     )//b,g,r,b,g,r
  );
  


  debayer_top_2to1 debayer_top1
  (
      .in_pclk		  (i_sysclk_div2),//(i_mipi_rx_pclk ),
      .in_rstn		  (pixel_data_en | pixel_data_en1),
      
      .raw_vs_i		  (ch1_vs		  ),//(ch1_vs	     ),//
      .raw_hs_i		  (ch1_hs		  ),//(ch1_hs	     ),//	 
      .raw_de_i		  (ch1_de		  ),//(ch1_de	     ),//	
      .raw_valid_i	  (ch1_de	      ),//(ch1_de	     ),//	
      .raw_datax4_i	  ({ch1_b,ch1_g}  ),//
      
      .rgb_vs_o		  (rgb1_vs         ),
      .rgb_hs_o		  (rgb1_hs         ),
      .rgb_de_o		  (rgb1_de         ),
      .rgb_valid_o	  (rgb1_valid      ),
      .rgb_datax2_o   (rgb1_datax2     )//b,g,r,b,g,r
  );

//=============================================================================
// Color correction and brightness enhancement
//=============================================================================
// rgb_datax2 layout: {R1,G1,B1,R0,G0,B0}.
// Processing follows 2ChMIPICSI_2ChMIPIDSI_Demo_Test exactly in the GRB domain.
wire [47:0] cam0_grb_datax2 = {
  rgb_datax2[39:32], rgb_datax2[47:40], rgb_datax2[31:24],
  rgb_datax2[15:8],  rgb_datax2[23:16], rgb_datax2[7:0]
};

wire [47:0] cam1_grb_datax2 = {
  rgb1_datax2[39:32], rgb1_datax2[47:40], rgb1_datax2[31:24],
  rgb1_datax2[15:8],  rgb1_datax2[23:16], rgb1_datax2[7:0]
};

function [7:0] grb_green_correct;
  input [7:0] g;
  begin
    grb_green_correct = g - (g >> 2) - (g >> 3); // 62.5% G
  end
endfunction

function [7:0] grb_brighten_sat;
  input [7:0] c;
  reg [8:0] c_gain;
  begin
    c_gain = {1'b0, c} + {1'b0, c}; // 200% brightness
    grb_brighten_sat = c_gain[8] ? 8'hff : c_gain[7:0];
  end
endfunction

wire [47:0] cam0_proc_grb_datax2 = {
  grb_brighten_sat(grb_green_correct(cam0_grb_datax2[47:40])),
  grb_brighten_sat(cam0_grb_datax2[39:32]),
  grb_brighten_sat(cam0_grb_datax2[31:24]),
  grb_brighten_sat(grb_green_correct(cam0_grb_datax2[23:16])),
  grb_brighten_sat(cam0_grb_datax2[15:8]),
  grb_brighten_sat(cam0_grb_datax2[7:0])
};

wire [47:0] cam1_proc_grb_datax2 = {
  grb_brighten_sat(grb_green_correct(cam1_grb_datax2[47:40])),
  grb_brighten_sat(cam1_grb_datax2[39:32]),
  grb_brighten_sat(cam1_grb_datax2[31:24]),
  grb_brighten_sat(grb_green_correct(cam1_grb_datax2[23:16])),
  grb_brighten_sat(cam1_grb_datax2[15:8]),
  grb_brighten_sat(cam1_grb_datax2[7:0])
};

wire [47:0] cam0_dsi_rgb_datax2 = {
  cam0_proc_grb_datax2[39:32], cam0_proc_grb_datax2[47:40], cam0_proc_grb_datax2[31:24],
  cam0_proc_grb_datax2[15:8],  cam0_proc_grb_datax2[23:16], cam0_proc_grb_datax2[7:0]
};

wire [47:0] cam1_dsi_rgb_datax2 = {
  cam1_proc_grb_datax2[39:32], cam1_proc_grb_datax2[47:40], cam1_proc_grb_datax2[31:24],
  cam1_proc_grb_datax2[15:8],  cam1_proc_grb_datax2[23:16], cam1_proc_grb_datax2[7:0]
};

//============================================================================= 
//mipi dsi
//=============================================================================
 
reset
#(
	.IN_RST_ACTIVE	("LOW"),
	.OUT_RST_ACTIVE	("LOW"),
	.CYCLE			(3)
)
inst_tx_byteclk_rst
(
	.i_arst	(arst_n),
	.i_clk	(mipi_dphy_tx_SLOWCLK),
	.o_srst	(mipi_dphy_tx_reset_byte_HS_n)
);



wire [47:0] dout;
wire o_de;
wire o_vs;
wire o_hs;
wire [15:0] h_cnt;
wire [15:0] v_cnt;

reg [2:0] diag_dsi_mode = 3'd0;
wire [7:0] diag_uart1_rx_data;
wire [7:0] diag_uart2_rx_data;
wire diag_uart1_rx_valid;
wire diag_uart2_rx_valid;

diag_uart_rx_1m u_diag_uart1_rx (
    .clk(i_sysclk_div2),
    .rst_n(diag_uart_rst_n),
    .rx(uart1_rxd),
    .data(diag_uart1_rx_data),
    .valid(diag_uart1_rx_valid)
);

diag_uart_rx_1m u_diag_uart2_rx (
    .clk(i_sysclk_div2),
    .rst_n(diag_uart_rst_n),
    .rx(uart2_rxd),
    .data(diag_uart2_rx_data),
    .valid(diag_uart2_rx_valid)
);

wire diag_cmd_valid = diag_uart2_rx_valid | diag_uart1_rx_valid;
wire [7:0] diag_cmd_data = diag_uart2_rx_valid ? diag_uart2_rx_data : diag_uart1_rx_data;

always @(posedge i_sysclk_div2 or negedge diag_uart_rst_n) begin
    if (!diag_uart_rst_n) begin
        diag_dsi_mode <= 3'd0;
    end else if (diag_cmd_valid) begin
        case (diag_cmd_data)
            "C", "c": diag_dsi_mode <= 3'd0;
            "B", "b": diag_dsi_mode <= 3'd1;
            "W", "w": diag_dsi_mode <= 3'd2;
            "D", "d": diag_dsi_mode <= 3'd3;
            "R", "r": diag_dsi_mode <= 3'd4;
            "F", "f": diag_dsi_mode <= 3'd5;
            "T", "t": diag_dsi_mode <= 3'd6;
            default: diag_dsi_mode <= diag_dsi_mode;
        endcase
    end
end

wire diag_dsi_vs = ((diag_dsi_mode == 3'd0) || (diag_dsi_mode == 3'd6)) ? bram_display_vs :
                   (diag_dsi_mode == 3'd4) ? rx_out_vs :
                   (diag_dsi_mode == 3'd5) ? ch0_vs : o_vs;
wire diag_dsi_hs = ((diag_dsi_mode == 3'd0) || (diag_dsi_mode == 3'd6)) ? bram_display_hs :
                   (diag_dsi_mode == 3'd4) ? rx_out_hs :
                   (diag_dsi_mode == 3'd5) ? ch0_hs : o_hs;
wire diag_dsi_de = ((diag_dsi_mode == 3'd0) || (diag_dsi_mode == 3'd6)) ? bram_display_de :
                   (diag_dsi_mode == 3'd4) ? rx_out_de :
                   (diag_dsi_mode == 3'd5) ? ch0_de : o_de;
wire [47:0] diag_dsi_white_data = 48'hffffff_ffffff;
wire [47:0] diag_dsi_rgb_de_data = rgb_de ? 48'hffffff_ffffff : 48'h000000_000000;
wire [31:0] diag_rx_raw_data = {rx_out_data[39:32], rx_out_data[29:22], rx_out_data[19:12], rx_out_data[9:2]};
wire [15:0] diag_fb_raw_data = {ch0_g, ch0_b};
wire [47:0] diag_rx_raw_view_data = {
    rx_out_data[39:32], rx_out_data[39:32], rx_out_data[39:32],
    rx_out_data[29:22], rx_out_data[29:22], rx_out_data[29:22]
};
wire [47:0] diag_fb_raw_view_data = {
    ch0_g, ch0_g, ch0_g,
    ch0_b, ch0_b, ch0_b
};
reg [63:0] diag_dsi_data;

always @(*) begin
    case (diag_dsi_mode)
        3'd0: diag_dsi_data = {16'd0, bram_display_rgb_datax2};
        3'd1: diag_dsi_data = {16'd0, dout};
        3'd2: diag_dsi_data = {16'd0, diag_dsi_white_data};
        3'd3: diag_dsi_data = {16'd0, diag_dsi_rgb_de_data};
        3'd4: diag_dsi_data = {16'd0, diag_rx_raw_view_data};
        3'd5: diag_dsi_data = {16'd0, diag_fb_raw_view_data};
        3'd6: diag_dsi_data = {16'd0, bram_display_rgb_datax2};
        default: diag_dsi_data = {16'd0, dout};
    endcase
end



color_bar_rgb # (
    .DYN_EN(1'b1),
    .HS_POLORY(1'b1),
    .VS_POLORY(1'b1),
    .SYMBOL_WIDTH(8),
    .SYMBOL_NUM(3),
    .PAR_PIXEL_NUM(2),
    .HFP(HFP),
    .HST(HSP),
    .HACT(HACT),
    .HBP(HBP),
    .VFP(VFP),
    .VST(VSP),
    .VACT(VACT),
    .VBP(VBP),
    .TEST_MODE(2'd1)
  )
  color_bar_rgb_inst (
    .clk(i_sysclk_div2),
    .rst_n(pixel_data_en | pixel_data_en1),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt),
    .hs(o_hs),
    .vs(o_vs),
    .de(o_de),
    .o_vid_data(dout)
  );



//=============================================================================
// DSI TX 0 - SENSOR1 (ch0) -> LCD1 (MIPI0_TX)
//=============================================================================
dsi_tx_top # (
    .HACT(HACT),
    .VACT(VACT),
    .HSP(HSP),
    .HBP(HBP),
    .HFP(HFP),
    .VSP(VSP),
    .VBP(VBP),
    .VFP(VFP)
  )
  dsi_tx_top_inst0 (
    .rst_n(arst_n),
    .i_mipi_clk(mipi_clk),
    .i_mipi_tx_pclk(mipi_dphy_tx_SLOWCLK),
    .i_sysclk_div_2(i_sysclk_div2),

    .pixel_vs_i  (diag_dsi_vs),
    .pixel_hs_i  (diag_dsi_hs),
    .pixel_de_i  (diag_dsi_de),
    .pixel_data_i(diag_dsi_data),
    .pixel_data_en(pixel_data_en),

    .LCD_POWER           (P0_lcd_power_en),
    .LCD_RST_P           (P0_lcd_rstp),
    .mipi_dp_clk_HS_OE   (mipi_tx_ck0_HS_OE),
    .mipi_dp_clk_HS_OUT  (mipi_tx_ck0_HS_OUT),
    .mipi_dp_clk_LP_N_OE (mipi_tx_ck0_LP_N_OE),
    .mipi_dp_clk_LP_N_OUT(mipi_tx_ck0_LP_N_OUT),
    .mipi_dp_clk_LP_P_OE (mipi_tx_ck0_LP_P_OE),
    .mipi_dp_clk_LP_P_OUT(mipi_tx_ck0_LP_P_OUT),
    .mipi_dp_clk_RST     (mipi_tx_ck0_RST),

    .mipi_dp_data0_LP_N_IN(mipi_tx_dp00_LP_N_IN),
    .mipi_dp_data0_LP_P_IN(mipi_tx_dp00_LP_P_IN),

    .mipi_dp_data0_HS_OE   (mipi_tx_dp00_HS_OE),
    .mipi_dp_data0_HS_OUT  (mipi_tx_dp00_HS_OUT),
    .mipi_dp_data0_LP_N_OE (mipi_tx_dp00_LP_N_OE),
    .mipi_dp_data0_LP_N_OUT(mipi_tx_dp00_LP_N_OUT),
    .mipi_dp_data0_LP_P_OE (mipi_tx_dp00_LP_P_OE),
    .mipi_dp_data0_LP_P_OUT(mipi_tx_dp00_LP_P_OUT),

    .mipi_dp_data1_HS_OE   (mipi_tx_dp01_HS_OE),
    .mipi_dp_data1_HS_OUT  (mipi_tx_dp01_HS_OUT),
    .mipi_dp_data1_LP_N_OE (mipi_tx_dp01_LP_N_OE),
    .mipi_dp_data1_LP_N_OUT(mipi_tx_dp01_LP_N_OUT),
    .mipi_dp_data1_LP_P_OE (mipi_tx_dp01_LP_P_OE),
    .mipi_dp_data1_LP_P_OUT(mipi_tx_dp01_LP_P_OUT),

    .mipi_dp_data2_HS_OE   (mipi_tx_dp02_HS_OE),
    .mipi_dp_data2_HS_OUT  (mipi_tx_dp02_HS_OUT),
    .mipi_dp_data2_LP_N_OE (mipi_tx_dp02_LP_N_OE),
    .mipi_dp_data2_LP_N_OUT(mipi_tx_dp02_LP_N_OUT),
    .mipi_dp_data2_LP_P_OE (mipi_tx_dp02_LP_P_OE),
    .mipi_dp_data2_LP_P_OUT(mipi_tx_dp02_LP_P_OUT),

    .mipi_dp_data3_HS_OE   (mipi_tx_dp03_HS_OE),
    .mipi_dp_data3_HS_OUT  (mipi_tx_dp03_HS_OUT),
    .mipi_dp_data3_LP_N_OE (mipi_tx_dp03_LP_N_OE),
    .mipi_dp_data3_LP_N_OUT(mipi_tx_dp03_LP_N_OUT),
    .mipi_dp_data3_LP_P_OE (mipi_tx_dp03_LP_P_OE),
    .mipi_dp_data3_LP_P_OUT(mipi_tx_dp03_LP_P_OUT),

    .mipi_dp_data0_RST   (mipi_tx_dp00_RST),
    .mipi_dp_data1_RST   (mipi_tx_dp01_RST),
    .mipi_dp_data2_RST   (mipi_tx_dp02_RST),
    .mipi_dp_data3_RST   (mipi_tx_dp03_RST)
  );

//=============================================================================
// DSI TX 1 - SENSOR2 (ch1) -> LCD2 (MIPI1_TX)
//=============================================================================
dsi_tx_top # (
    .HACT(HACT),
    .VACT(VACT),
    .HSP(HSP),
    .HBP(HBP),
    .HFP(HFP),
    .VSP(VSP),
    .VBP(VBP),
    .VFP(VFP)
  )
  dsi_tx_top_inst1 (
	.rst_n(arst_n),
    .i_mipi_clk(mipi_clk),
    .i_mipi_tx_pclk(mipi_dphy_tx_SLOWCLK),
    .i_sysclk_div_2(i_sysclk_div2),

   /*i*/.pixel_vs_i  (diag_dsi_vs				  ),// diagnostic mirror to both DSI outputs
   /*i*/.pixel_hs_i  (diag_dsi_hs				  ),
   /*i*/.pixel_de_i  (diag_dsi_de				  ),
   /*i*/.pixel_data_i(diag_dsi_data	          ),
   /*o*/.pixel_data_en(pixel_data_en1),  // DSI TX 1 使能输出

    .LCD_POWER           (P1_lcd_power_en),
    .LCD_RST_P           (P1_o_lcd_rstn),  // 修正: 使用正确的信号名
    .mipi_dp_clk_HS_OE   (mipi_tx_ck1_HS_OE),
    .mipi_dp_clk_HS_OUT  (mipi_tx_ck1_HS_OUT),
    .mipi_dp_clk_LP_N_OE (mipi_tx_ck1_LP_N_OE),
    .mipi_dp_clk_LP_N_OUT(mipi_tx_ck1_LP_N_OUT),
    .mipi_dp_clk_LP_P_OE (mipi_tx_ck1_LP_P_OE),
    .mipi_dp_clk_LP_P_OUT(mipi_tx_ck1_LP_P_OUT),
    .mipi_dp_clk_RST     (mipi_tx_ck1_RST),

    .mipi_dp_data0_LP_N_IN(mipi_tx_dp10_LP_N_IN),
    .mipi_dp_data0_LP_P_IN(mipi_tx_dp10_LP_P_IN),

    .mipi_dp_data0_HS_OE   (mipi_tx_dp10_HS_OE),
    .mipi_dp_data0_HS_OUT  (mipi_tx_dp10_HS_OUT),
    .mipi_dp_data0_LP_N_OE (mipi_tx_dp10_LP_N_OE),
    .mipi_dp_data0_LP_N_OUT(mipi_tx_dp10_LP_N_OUT),
    .mipi_dp_data0_LP_P_OE (mipi_tx_dp10_LP_P_OE),
    .mipi_dp_data0_LP_P_OUT(mipi_tx_dp10_LP_P_OUT),
    
    .mipi_dp_data1_HS_OE   (mipi_tx_dp11_HS_OE),
    .mipi_dp_data1_HS_OUT  (mipi_tx_dp11_HS_OUT),
    .mipi_dp_data1_LP_N_OE (mipi_tx_dp11_LP_N_OE),
    .mipi_dp_data1_LP_N_OUT(mipi_tx_dp11_LP_N_OUT),
    .mipi_dp_data1_LP_P_OE (mipi_tx_dp11_LP_P_OE),
    .mipi_dp_data1_LP_P_OUT(mipi_tx_dp11_LP_P_OUT),
    
    .mipi_dp_data2_HS_OE   (mipi_tx_dp12_HS_OE),
    .mipi_dp_data2_HS_OUT  (mipi_tx_dp12_HS_OUT),
    .mipi_dp_data2_LP_N_OE (mipi_tx_dp12_LP_N_OE),
    .mipi_dp_data2_LP_N_OUT(mipi_tx_dp12_LP_N_OUT),
    .mipi_dp_data2_LP_P_OE (mipi_tx_dp12_LP_P_OE),
    .mipi_dp_data2_LP_P_OUT(mipi_tx_dp12_LP_P_OUT),
    
    .mipi_dp_data3_HS_OE   (mipi_tx_dp13_HS_OE),
    .mipi_dp_data3_HS_OUT  (mipi_tx_dp13_HS_OUT),
    .mipi_dp_data3_LP_N_OE (mipi_tx_dp13_LP_N_OE),
    .mipi_dp_data3_LP_N_OUT(mipi_tx_dp13_LP_N_OUT),
    .mipi_dp_data3_LP_P_OE (mipi_tx_dp13_LP_P_OE),
    .mipi_dp_data3_LP_P_OUT(mipi_tx_dp13_LP_P_OUT),

	  .mipi_dp_data0_RST   (mipi_tx_dp10_RST),
	  .mipi_dp_data1_RST   (mipi_tx_dp11_RST),
	  .mipi_dp_data2_RST   (mipi_tx_dp12_RST),
    .mipi_dp_data3_RST     (mipi_tx_dp13_RST)
  );

wire bram_display_vs;
wire bram_display_hs;
wire bram_display_de;
wire [47:0] bram_display_rgb_datax2;

rgb565_bram_framebuffer #(
    .SRC_WIDTH(960),
    .SRC_HEIGHT(540)
) u_rgb565_bram_framebuffer (
    .clk(i_sysclk_div2),
    .rst_n(pixel_data_en | pixel_data_en1),
    .in_vs(rgb_vs),
    .in_de(rgb_de),
    .in_rgb2(cam0_dsi_rgb_datax2),
    .test_pattern_enable(diag_dsi_mode == 3'd6),
    .timing_vs(o_vs),
    .timing_hs(o_hs),
    .timing_de(o_de),
    .out_vs(bram_display_vs),
    .out_hs(bram_display_hs),
    .out_de(bram_display_de),
    .out_rgb2(bram_display_rgb_datax2),
    .display_valid(bram_display_valid),
    .pending_valid(bram_frame_pending),
    .captured_frame_count(bram_captured_frame_count),
    .displayed_frame_count(bram_displayed_frame_count),
    .swap_count(bram_swap_count),
    .dropped_frame_count(bram_dropped_frame_count),
    .capture_error_sticky(bram_capture_error_sticky),
    .measured_frame_lines(bram_measured_frame_lines),
    .measured_line_de_min(bram_measured_line_de_min),
    .measured_line_de_max(bram_measured_line_de_max),
    .measured_frame_de_total(bram_measured_frame_de_total)
);

// Independent 160x90 RGB565 tap for the hardened RISC-V. This path never
// applies backpressure to the display stream and does not access external DDR.
vision_small_frame_apb u_vision_small_frame_apb (
    .video_clk(i_sysclk_div2),
    .video_rst_n(pixel_data_en | pixel_data_en1),
    .video_vs(rgb_vs),
    .video_de(rgb_de),
    .video_rgb2(cam0_dsi_rgb_datax2),
    .apb_clk(io_peripheralClk),
    .apb_reset(io_peripheralReset),
    .apb_paddr(riscv_apb_paddr),
    .apb_psel(riscv_apb_psel),
    .apb_penable(riscv_apb_penable),
    .apb_pwrite(riscv_apb_pwrite),
    .apb_pwdata(riscv_apb_pwdata),
    .apb_prdata(riscv_apb_prdata),
    .apb_pready(riscv_apb_pready),
    .apb_pslverror(riscv_apb_pslverror)
);

//=============================================================================
// Diagnostic UART2 status stream
//=============================================================================
reg dbg_rx0_vs_seen  = 1'b0;
reg dbg_rx0_de_seen  = 1'b0;
reg dbg_rx1_vs_seen  = 1'b0;
reg dbg_rx1_de_seen  = 1'b0;
reg dbg_fb0_vs_seen  = 1'b0;
reg dbg_fb0_de_seen  = 1'b0;
reg dbg_fb1_vs_seen  = 1'b0;
reg dbg_fb1_de_seen  = 1'b0;
reg dbg_rgb0_vs_seen = 1'b0;
reg dbg_rgb0_de_seen = 1'b0;
reg dbg_rgb1_vs_seen = 1'b0;
reg dbg_rgb1_de_seen = 1'b0;
reg [9:0] dbg_dsi_hs_oe_seen = 10'd0;
reg [9:0] dbg_dsi_hs_toggle_seen = 10'd0;
reg [9:0] dbg_dsi_hs_sample_d = 10'd0;
reg dbg_rgb_data_nonzero_seen = 1'b0;
reg dbg_rgb_data_toggle_seen = 1'b0;
reg [47:0] dbg_rgb_data_d = 48'd0;
reg [15:0] dbg_rgb_data_sample = 16'd0;
reg dbg_rx_data_nonzero_seen = 1'b0;
reg dbg_rx_data_toggle_seen = 1'b0;
reg [31:0] dbg_rx_data_d = 32'd0;
reg [15:0] dbg_rx_data_sample = 16'd0;
reg dbg_fb_data_nonzero_seen = 1'b0;
reg dbg_fb_data_toggle_seen = 1'b0;
reg [15:0] dbg_fb_data_d = 16'd0;
reg [15:0] dbg_fb_data_sample = 16'd0;
reg dbg_axi_aw_seen = 1'b0;
reg dbg_axi_w_seen = 1'b0;
reg dbg_axi_b_seen = 1'b0;
reg dbg_axi_ar_seen = 1'b0;
reg dbg_axi_r_seen = 1'b0;
reg dbg_axi_bresp_error_seen = 1'b0;
reg dbg_axi_rresp_error_seen = 1'b0;
reg dbg_axi_rdata_nonzero_seen = 1'b0;

wire [9:0] dbg_dsi_hs_oe_now = {
  mipi_tx_ck0_HS_OE,
  mipi_tx_dp00_HS_OE,
  mipi_tx_dp01_HS_OE,
  mipi_tx_dp02_HS_OE,
  mipi_tx_dp03_HS_OE,
  mipi_tx_ck1_HS_OE,
  mipi_tx_dp10_HS_OE,
  mipi_tx_dp11_HS_OE,
  mipi_tx_dp12_HS_OE,
  mipi_tx_dp13_HS_OE
};

wire [9:0] dbg_dsi_rst_now = {
  mipi_tx_ck0_RST,
  mipi_tx_dp00_RST,
  mipi_tx_dp01_RST,
  mipi_tx_dp02_RST,
  mipi_tx_dp03_RST,
  mipi_tx_ck1_RST,
  mipi_tx_dp10_RST,
  mipi_tx_dp11_RST,
  mipi_tx_dp12_RST,
  mipi_tx_dp13_RST
};

wire [9:0] dbg_dsi_hs_sample_now = {
  mipi_tx_ck0_HS_OUT[0],
  mipi_tx_dp00_HS_OUT[0],
  mipi_tx_dp01_HS_OUT[0],
  mipi_tx_dp02_HS_OUT[0],
  mipi_tx_dp03_HS_OUT[0],
  mipi_tx_ck1_HS_OUT[0],
  mipi_tx_dp10_HS_OUT[0],
  mipi_tx_dp11_HS_OUT[0],
  mipi_tx_dp12_HS_OUT[0],
  mipi_tx_dp13_HS_OUT[0]
};

always @(posedge axi0_ACLK or negedge ddr_cfg_ok) begin
  if (!ddr_cfg_ok) begin
    dbg_axi_aw_seen <= 1'b0;
    dbg_axi_w_seen <= 1'b0;
    dbg_axi_b_seen <= 1'b0;
    dbg_axi_ar_seen <= 1'b0;
    dbg_axi_r_seen <= 1'b0;
    dbg_axi_bresp_error_seen <= 1'b0;
    dbg_axi_rresp_error_seen <= 1'b0;
    dbg_axi_rdata_nonzero_seen <= 1'b0;
  end else begin
    dbg_axi_aw_seen <= dbg_axi_aw_seen | (axi0_AWVALID & axi0_AWREADY);
    dbg_axi_w_seen <= dbg_axi_w_seen | (axi0_WVALID & axi0_WREADY);
    dbg_axi_b_seen <= dbg_axi_b_seen | (axi0_BVALID & axi0_BREADY);
    dbg_axi_ar_seen <= dbg_axi_ar_seen | (axi0_ARVALID & axi0_ARREADY);
    dbg_axi_r_seen <= dbg_axi_r_seen | (axi0_RVALID & axi0_RREADY);
    dbg_axi_bresp_error_seen <= dbg_axi_bresp_error_seen |
                                (axi0_BVALID & axi0_BREADY & (|axi0_BRESP));
    dbg_axi_rresp_error_seen <= dbg_axi_rresp_error_seen |
                                (axi0_RVALID & axi0_RREADY & (|axi0_RRESP));
    dbg_axi_rdata_nonzero_seen <= dbg_axi_rdata_nonzero_seen |
                                  (axi0_RVALID & axi0_RREADY & (|axi0_RDATA));
  end
end

always @(posedge i_sysclk_div2) begin
  if (rx_out_vs)
    dbg_rx0_vs_seen <= 1'b1;
  if (rx_out_de)
    dbg_rx0_de_seen <= 1'b1;
  if (rx_out_vs1)
    dbg_rx1_vs_seen <= 1'b1;
  if (rx_out_de1)
    dbg_rx1_de_seen <= 1'b1;
  if (ch0_vs)
    dbg_fb0_vs_seen <= 1'b1;
  if (ch0_de)
    dbg_fb0_de_seen <= 1'b1;
  if (ch1_vs)
    dbg_fb1_vs_seen <= 1'b1;
  if (ch1_de)
    dbg_fb1_de_seen <= 1'b1;
  if (rgb_vs)
    dbg_rgb0_vs_seen <= 1'b1;
  if (rgb_de)
    dbg_rgb0_de_seen <= 1'b1;
  if (rgb1_vs)
    dbg_rgb1_vs_seen <= 1'b1;
  if (rgb1_de)
    dbg_rgb1_de_seen <= 1'b1;

  dbg_dsi_hs_oe_seen <= dbg_dsi_hs_oe_seen | dbg_dsi_hs_oe_now;
  dbg_dsi_hs_toggle_seen <= dbg_dsi_hs_toggle_seen | (dbg_dsi_hs_sample_now ^ dbg_dsi_hs_sample_d);
  dbg_dsi_hs_sample_d <= dbg_dsi_hs_sample_now;

  if (rgb_de) begin
    dbg_rgb_data_nonzero_seen <= dbg_rgb_data_nonzero_seen | (|rgb_datax2);
    dbg_rgb_data_toggle_seen <= dbg_rgb_data_toggle_seen | (|(rgb_datax2 ^ dbg_rgb_data_d));
    dbg_rgb_data_d <= rgb_datax2;
    dbg_rgb_data_sample <= rgb_datax2[15:0];
  end
  if (rx_out_de) begin
    dbg_rx_data_nonzero_seen <= dbg_rx_data_nonzero_seen | (|diag_rx_raw_data);
    dbg_rx_data_toggle_seen <= dbg_rx_data_toggle_seen | (|(diag_rx_raw_data ^ dbg_rx_data_d));
    dbg_rx_data_d <= diag_rx_raw_data;
    dbg_rx_data_sample <= diag_rx_raw_data[15:0];
  end
  if (ch0_de) begin
    dbg_fb_data_nonzero_seen <= dbg_fb_data_nonzero_seen | (|diag_fb_raw_data);
    dbg_fb_data_toggle_seen <= dbg_fb_data_toggle_seen | (|(diag_fb_raw_data ^ dbg_fb_data_d));
    dbg_fb_data_d <= diag_fb_raw_data;
    dbg_fb_data_sample <= diag_fb_raw_data;
  end
end

function [7:0] dbg_bit_char;
  input value;
  begin
    dbg_bit_char = value ? 8'h31 : 8'h30;
end
endfunction

function [7:0] dbg_hex_char;
  input [3:0] value;
  begin
    dbg_hex_char = (value < 4'd10) ? (8'h30 + value) : (8'h41 + value - 4'd10);
  end
endfunction

localparam [8:0] DIAG_MSG_LEN = 9'd275;
localparam [6:0] DIAG_UART_CLKS_PER_BIT = 7'd70; // i_sysclk_div2 is 70 MHz, UART2 follows capture at 1 Mbps.
localparam [1:0] DIAG_TX_IDLE  = 2'd0;
localparam [1:0] DIAG_TX_START = 2'd1;
localparam [1:0] DIAG_TX_DATA  = 2'd2;
localparam [1:0] DIAG_TX_STOP  = 2'd3;

reg [26:0] diag_interval_cnt = 27'd0;
reg [8:0] diag_msg_idx = 9'd0;
reg [1:0] diag_tx_state = DIAG_TX_IDLE;
reg [6:0] diag_tx_clk_cnt = 7'd0;
reg [2:0] diag_tx_bit_idx = 3'd0;
reg [7:0] diag_tx_byte = 8'h00;

always @(*) begin
  case (diag_msg_idx)
        8'd0:  diag_uart2_tx_data <= "V";
        8'd1:  diag_uart2_tx_data <= " ";
        8'd2:  diag_uart2_tx_data <= "s";
        8'd3:  diag_uart2_tx_data <= "w";
        8'd4:  diag_uart2_tx_data <= "=";
        8'd5:  diag_uart2_tx_data <= dbg_bit_char(i_sw[0]);
        8'd6:  diag_uart2_tx_data <= " ";
        8'd7:  diag_uart2_tx_data <= "s";
        8'd8:  diag_uart2_tx_data <= "p";
        8'd9:  diag_uart2_tx_data <= "=";
        8'd10: diag_uart2_tx_data <= dbg_bit_char(sys_pll_lock);
        8'd11: diag_uart2_tx_data <= " ";
        8'd12: diag_uart2_tx_data <= "d";
        8'd13: diag_uart2_tx_data <= "p";
        8'd14: diag_uart2_tx_data <= "=";
        8'd15: diag_uart2_tx_data <= dbg_bit_char(ddr_pll_lock);
        8'd16: diag_uart2_tx_data <= " ";
        8'd17: diag_uart2_tx_data <= "m";
        8'd18: diag_uart2_tx_data <= "p";
        8'd19: diag_uart2_tx_data <= "=";
        8'd20: diag_uart2_tx_data <= dbg_bit_char(MIPI_TX_PLL_LOCKED);
        8'd21: diag_uart2_tx_data <= " ";
        8'd22: diag_uart2_tx_data <= "b";
        8'd23: diag_uart2_tx_data <= "p";
        8'd24: diag_uart2_tx_data <= "=";
        8'd25: diag_uart2_tx_data <= dbg_bit_char(pll_byteclk_locked);
        8'd26: diag_uart2_tx_data <= " ";
        8'd27: diag_uart2_tx_data <= "a";
        8'd28: diag_uart2_tx_data <= "l";
        8'd29: diag_uart2_tx_data <= "l";
        8'd30: diag_uart2_tx_data <= "=";
        8'd31: diag_uart2_tx_data <= dbg_bit_char(arst_n);
        8'd32: diag_uart2_tx_data <= " ";
        8'd33: diag_uart2_tx_data <= "d";
        8'd34: diag_uart2_tx_data <= "s";
        8'd35: diag_uart2_tx_data <= "i";
        8'd36: diag_uart2_tx_data <= "=";
        8'd37: diag_uart2_tx_data <= dbg_bit_char(dsi_rst_n);
        8'd38: diag_uart2_tx_data <= " ";
        8'd39: diag_uart2_tx_data <= "c";
        8'd40: diag_uart2_tx_data <= "f";
        8'd41: diag_uart2_tx_data <= "g";
        8'd42: diag_uart2_tx_data <= "=";
        8'd43: diag_uart2_tx_data <= dbg_bit_char(ddr_inst_CFG_DONE);
        8'd44: diag_uart2_tx_data <= "/";
        8'd45: diag_uart2_tx_data <= dbg_bit_char(ddr_cfg_ok);
        8'd46: diag_uart2_tx_data <= " ";
        8'd47: diag_uart2_tx_data <= "v";
        8'd48: diag_uart2_tx_data <= "r";
        8'd49: diag_uart2_tx_data <= "=";
        8'd50: diag_uart2_tx_data <= dbg_bit_char(video_run_n);
        8'd51: diag_uart2_tx_data <= " ";
        8'd52: diag_uart2_tx_data <= "r";
        8'd53: diag_uart2_tx_data <= "x";
        8'd54: diag_uart2_tx_data <= "=";
        8'd55: diag_uart2_tx_data <= dbg_bit_char(dbg_rx0_vs_seen);
        8'd56: diag_uart2_tx_data <= dbg_bit_char(dbg_rx0_de_seen);
        8'd57: diag_uart2_tx_data <= dbg_bit_char(dbg_rx1_vs_seen);
        8'd58: diag_uart2_tx_data <= dbg_bit_char(dbg_rx1_de_seen);
        8'd59: diag_uart2_tx_data <= " ";
        8'd60: diag_uart2_tx_data <= "f";
        8'd61: diag_uart2_tx_data <= "b";
        8'd62: diag_uart2_tx_data <= "=";
        8'd63: diag_uart2_tx_data <= dbg_bit_char(dbg_fb0_vs_seen);
        8'd64: diag_uart2_tx_data <= dbg_bit_char(dbg_fb0_de_seen);
        8'd65: diag_uart2_tx_data <= dbg_bit_char(dbg_fb1_vs_seen);
        8'd66: diag_uart2_tx_data <= dbg_bit_char(dbg_fb1_de_seen);
        8'd67: diag_uart2_tx_data <= " ";
        8'd68: diag_uart2_tx_data <= "r";
        8'd69: diag_uart2_tx_data <= "g";
        8'd70: diag_uart2_tx_data <= "b";
        8'd71: diag_uart2_tx_data <= "=";
        8'd72: diag_uart2_tx_data <= dbg_bit_char(dbg_rgb0_vs_seen);
        8'd73: diag_uart2_tx_data <= dbg_bit_char(dbg_rgb0_de_seen);
        8'd74: diag_uart2_tx_data <= dbg_bit_char(dbg_rgb1_vs_seen);
        8'd75: diag_uart2_tx_data <= dbg_bit_char(dbg_rgb1_de_seen);
        8'd76: diag_uart2_tx_data <= " ";
        8'd77: diag_uart2_tx_data <= "m";
        8'd78: diag_uart2_tx_data <= "d";
        8'd79: diag_uart2_tx_data <= "=";
        8'd80: begin
          case (diag_dsi_mode)
            3'd0: diag_uart2_tx_data <= "C";
            3'd1: diag_uart2_tx_data <= "B";
            3'd2: diag_uart2_tx_data <= "W";
            3'd3: diag_uart2_tx_data <= "D";
            3'd4: diag_uart2_tx_data <= "R";
            3'd5: diag_uart2_tx_data <= "F";
            3'd6: diag_uart2_tx_data <= "T";
            default: diag_uart2_tx_data <= "?";
          endcase
        end
        8'd81: diag_uart2_tx_data <= " ";
        8'd82: diag_uart2_tx_data <= "p";
        8'd83: diag_uart2_tx_data <= "e";
        8'd84: diag_uart2_tx_data <= "=";
        8'd85: diag_uart2_tx_data <= dbg_bit_char(pixel_data_en);
        8'd86: diag_uart2_tx_data <= dbg_bit_char(pixel_data_en1);
        8'd87: diag_uart2_tx_data <= " ";
        8'd88: diag_uart2_tx_data <= "l";
        8'd89: diag_uart2_tx_data <= "c";
        8'd90: diag_uart2_tx_data <= "d";
        8'd91: diag_uart2_tx_data <= "=";
        8'd92: diag_uart2_tx_data <= dbg_bit_char(P0_lcd_power_en);
        8'd93: diag_uart2_tx_data <= dbg_bit_char(P0_lcd_rstp);
        8'd94: diag_uart2_tx_data <= dbg_bit_char(P1_lcd_power_en);
        8'd95: diag_uart2_tx_data <= dbg_bit_char(P1_o_lcd_rstn);
        8'd96: diag_uart2_tx_data <= " ";
        8'd97: diag_uart2_tx_data <= "l";
        8'd98: diag_uart2_tx_data <= "r";
        8'd99: diag_uart2_tx_data <= "=";
        8'd100: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[9]);
        8'd101: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[8]);
        8'd102: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[7]);
        8'd103: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[6]);
        8'd104: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[5]);
        8'd105: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[4]);
        8'd106: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[3]);
        8'd107: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[2]);
        8'd108: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[1]);
        8'd109: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_rst_now[0]);
        8'd110: diag_uart2_tx_data <= " ";
        8'd111: diag_uart2_tx_data <= "o";
        8'd112: diag_uart2_tx_data <= "e";
        8'd113: diag_uart2_tx_data <= "=";
        8'd114: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[9]);
        8'd115: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[8]);
        8'd116: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[7]);
        8'd117: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[6]);
        8'd118: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[5]);
        8'd119: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[4]);
        8'd120: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[3]);
        8'd121: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[2]);
        8'd122: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[1]);
        8'd123: diag_uart2_tx_data <= dbg_bit_char(dbg_dsi_hs_oe_seen[0]);
        8'd124: diag_uart2_tx_data <= " ";
        8'd125: diag_uart2_tx_data <= "t";
        8'd126: diag_uart2_tx_data <= "g";
        8'd127: diag_uart2_tx_data <= "=";
        8'd128: diag_uart2_tx_data <= dbg_bit_char(|dbg_dsi_hs_toggle_seen[9:5]);
        8'd129: diag_uart2_tx_data <= dbg_bit_char(|dbg_dsi_hs_toggle_seen[4:0]);
        8'd130: diag_uart2_tx_data <= "/";
        8'd131: diag_uart2_tx_data <= dbg_bit_char(|dbg_dsi_hs_sample_now[9:5]);
        8'd132: diag_uart2_tx_data <= dbg_bit_char(|dbg_dsi_hs_sample_now[4:0]);
        8'd133: diag_uart2_tx_data <= " ";
        8'd134: diag_uart2_tx_data <= "r";
        8'd135: diag_uart2_tx_data <= "d";
        8'd136: diag_uart2_tx_data <= "=";
        8'd137: diag_uart2_tx_data <= dbg_bit_char(dbg_rgb_data_nonzero_seen);
        8'd138: diag_uart2_tx_data <= dbg_bit_char(dbg_rgb_data_toggle_seen);
        8'd139: diag_uart2_tx_data <= " ";
        8'd140: diag_uart2_tx_data <= "s";
        8'd141: diag_uart2_tx_data <= "=";
        8'd142: diag_uart2_tx_data <= dbg_hex_char(dbg_rgb_data_sample[15:12]);
        8'd143: diag_uart2_tx_data <= dbg_hex_char(dbg_rgb_data_sample[11:8]);
        8'd144: diag_uart2_tx_data <= dbg_hex_char(dbg_rgb_data_sample[7:4]);
        8'd145: diag_uart2_tx_data <= dbg_hex_char(dbg_rgb_data_sample[3:0]);
        8'd146: diag_uart2_tx_data <= " ";
        8'd147: diag_uart2_tx_data <= "x";
        8'd148: diag_uart2_tx_data <= "d";
        8'd149: diag_uart2_tx_data <= "=";
        8'd150: diag_uart2_tx_data <= dbg_bit_char(dbg_rx_data_nonzero_seen);
        8'd151: diag_uart2_tx_data <= dbg_bit_char(dbg_rx_data_toggle_seen);
        8'd152: diag_uart2_tx_data <= " ";
        8'd153: diag_uart2_tx_data <= "x";
        8'd154: diag_uart2_tx_data <= "s";
        8'd155: diag_uart2_tx_data <= "=";
        8'd156: diag_uart2_tx_data <= dbg_hex_char(dbg_rx_data_sample[15:12]);
        8'd157: diag_uart2_tx_data <= dbg_hex_char(dbg_rx_data_sample[11:8]);
        8'd158: diag_uart2_tx_data <= dbg_hex_char(dbg_rx_data_sample[7:4]);
        8'd159: diag_uart2_tx_data <= dbg_hex_char(dbg_rx_data_sample[3:0]);
        8'd160: diag_uart2_tx_data <= " ";
        8'd161: diag_uart2_tx_data <= "f";
        8'd162: diag_uart2_tx_data <= "d";
        8'd163: diag_uart2_tx_data <= "=";
        8'd164: diag_uart2_tx_data <= dbg_bit_char(dbg_fb_data_nonzero_seen);
        8'd165: diag_uart2_tx_data <= dbg_bit_char(dbg_fb_data_toggle_seen);
        8'd166: diag_uart2_tx_data <= " ";
        8'd167: diag_uart2_tx_data <= "f";
        8'd168: diag_uart2_tx_data <= "s";
        8'd169: diag_uart2_tx_data <= "=";
        8'd170: diag_uart2_tx_data <= dbg_hex_char(dbg_fb_data_sample[15:12]);
        8'd171: diag_uart2_tx_data <= dbg_hex_char(dbg_fb_data_sample[11:8]);
        8'd172: diag_uart2_tx_data <= dbg_hex_char(dbg_fb_data_sample[7:4]);
        8'd173: diag_uart2_tx_data <= dbg_hex_char(dbg_fb_data_sample[3:0]);
        8'd174: diag_uart2_tx_data <= " ";
        8'd175: diag_uart2_tx_data <= "q";
        8'd176: diag_uart2_tx_data <= "=";
        8'd177: diag_uart2_tx_data <= dbg_hex_char(bram_fifo_level[13:12]);
        8'd178: diag_uart2_tx_data <= dbg_hex_char(bram_fifo_level[11:8]);
        8'd179: diag_uart2_tx_data <= dbg_hex_char(bram_fifo_level[7:4]);
        8'd180: diag_uart2_tx_data <= dbg_hex_char(bram_fifo_level[3:0]);
        8'd181: diag_uart2_tx_data <= " ";
        8'd182: diag_uart2_tx_data <= "b";
        8'd183: diag_uart2_tx_data <= "a";
        8'd184: diag_uart2_tx_data <= "=";
        8'd185: diag_uart2_tx_data <= dbg_bit_char(bram_stream_active);
        8'd186: diag_uart2_tx_data <= " ";
        8'd187: diag_uart2_tx_data <= "b";
        8'd188: diag_uart2_tx_data <= "e";
        8'd189: diag_uart2_tx_data <= "=";
        8'd190: diag_uart2_tx_data <= dbg_bit_char(bram_overflow_sticky);
        8'd191: diag_uart2_tx_data <= dbg_bit_char(bram_underflow_sticky);
        8'd192: diag_uart2_tx_data <= " ";
        8'd193: diag_uart2_tx_data <= "o";
        8'd194: diag_uart2_tx_data <= "c";
        8'd195: diag_uart2_tx_data <= "=";
        8'd196: diag_uart2_tx_data <= dbg_hex_char(bram_overflow_count[15:12]);
        8'd197: diag_uart2_tx_data <= dbg_hex_char(bram_overflow_count[11:8]);
        8'd198: diag_uart2_tx_data <= dbg_hex_char(bram_overflow_count[7:4]);
        8'd199: diag_uart2_tx_data <= dbg_hex_char(bram_overflow_count[3:0]);
        8'd200: diag_uart2_tx_data <= " ";
        8'd201: diag_uart2_tx_data <= "u";
        8'd202: diag_uart2_tx_data <= "c";
        8'd203: diag_uart2_tx_data <= "=";
        8'd204: diag_uart2_tx_data <= dbg_hex_char(bram_underflow_count[15:12]);
        8'd205: diag_uart2_tx_data <= dbg_hex_char(bram_underflow_count[11:8]);
        8'd206: diag_uart2_tx_data <= dbg_hex_char(bram_underflow_count[7:4]);
        8'd207: diag_uart2_tx_data <= dbg_hex_char(bram_underflow_count[3:0]);
        8'd208: diag_uart2_tx_data <= " ";
        8'd209: diag_uart2_tx_data <= "r";
        8'd210: diag_uart2_tx_data <= "c";
        8'd211: diag_uart2_tx_data <= "=";
        8'd212: diag_uart2_tx_data <= dbg_hex_char(bram_resync_count[15:12]);
        8'd213: diag_uart2_tx_data <= dbg_hex_char(bram_resync_count[11:8]);
        8'd214: diag_uart2_tx_data <= dbg_hex_char(bram_resync_count[7:4]);
        8'd215: diag_uart2_tx_data <= dbg_hex_char(bram_resync_count[3:0]);
        8'd216: diag_uart2_tx_data <= " ";
        8'd217: diag_uart2_tx_data <= "f";
        8'd218: diag_uart2_tx_data <= "i";
        8'd219: diag_uart2_tx_data <= "=";
        8'd220: diag_uart2_tx_data <= dbg_hex_char(bram_input_frame_count[15:12]);
        8'd221: diag_uart2_tx_data <= dbg_hex_char(bram_input_frame_count[11:8]);
        8'd222: diag_uart2_tx_data <= dbg_hex_char(bram_input_frame_count[7:4]);
        8'd223: diag_uart2_tx_data <= dbg_hex_char(bram_input_frame_count[3:0]);
        8'd224: diag_uart2_tx_data <= " ";
        8'd225: diag_uart2_tx_data <= "f";
        8'd226: diag_uart2_tx_data <= "o";
        8'd227: diag_uart2_tx_data <= "=";
        8'd228: diag_uart2_tx_data <= dbg_hex_char(bram_output_frame_count[15:12]);
        8'd229: diag_uart2_tx_data <= dbg_hex_char(bram_output_frame_count[11:8]);
        8'd230: diag_uart2_tx_data <= dbg_hex_char(bram_output_frame_count[7:4]);
        8'd231: diag_uart2_tx_data <= dbg_hex_char(bram_output_frame_count[3:0]);
        8'd232: diag_uart2_tx_data <= " ";
        8'd233: diag_uart2_tx_data <= "a";
        8'd234: diag_uart2_tx_data <= "x";
        8'd235: diag_uart2_tx_data <= "=";
        8'd236: diag_uart2_tx_data <= dbg_bit_char(dbg_axi_aw_seen);
        8'd237: diag_uart2_tx_data <= dbg_bit_char(dbg_axi_w_seen);
        8'd238: diag_uart2_tx_data <= dbg_bit_char(dbg_axi_b_seen);
        8'd239: diag_uart2_tx_data <= dbg_bit_char(dbg_axi_ar_seen);
        8'd240: diag_uart2_tx_data <= dbg_bit_char(dbg_axi_r_seen);
        8'd241: diag_uart2_tx_data <= " ";
        8'd242: diag_uart2_tx_data <= "r";
        8'd243: diag_uart2_tx_data <= "r";
        8'd244: diag_uart2_tx_data <= "=";
        8'd245: diag_uart2_tx_data <= dbg_bit_char(riscv_reset_n);
        9'd246: diag_uart2_tx_data <= " ";
        9'd247: diag_uart2_tx_data <= "g";
        9'd248: diag_uart2_tx_data <= "m";
        9'd249: diag_uart2_tx_data <= "=";
        9'd250: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_lines[15:12]);
        9'd251: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_lines[11:8]);
        9'd252: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_lines[7:4]);
        9'd253: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_lines[3:0]);
        9'd254: diag_uart2_tx_data <= "/";
        9'd255: diag_uart2_tx_data <= dbg_hex_char(bram_measured_line_de_min[15:12]);
        9'd256: diag_uart2_tx_data <= dbg_hex_char(bram_measured_line_de_min[11:8]);
        9'd257: diag_uart2_tx_data <= dbg_hex_char(bram_measured_line_de_min[7:4]);
        9'd258: diag_uart2_tx_data <= dbg_hex_char(bram_measured_line_de_min[3:0]);
        9'd259: diag_uart2_tx_data <= "/";
        9'd260: diag_uart2_tx_data <= dbg_hex_char(bram_measured_line_de_max[15:12]);
        9'd261: diag_uart2_tx_data <= dbg_hex_char(bram_measured_line_de_max[11:8]);
        9'd262: diag_uart2_tx_data <= dbg_hex_char(bram_measured_line_de_max[7:4]);
        9'd263: diag_uart2_tx_data <= dbg_hex_char(bram_measured_line_de_max[3:0]);
        9'd264: diag_uart2_tx_data <= "/";
        9'd265: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_de_total[19:16]);
        9'd266: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_de_total[15:12]);
        9'd267: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_de_total[11:8]);
        9'd268: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_de_total[7:4]);
        9'd269: diag_uart2_tx_data <= dbg_hex_char(bram_measured_frame_de_total[3:0]);
        9'd270: diag_uart2_tx_data <= " ";
        9'd271: diag_uart2_tx_data <= "v";
        9'd272: diag_uart2_tx_data <= "G";
        9'd273: diag_uart2_tx_data <= 8'h0d;
        9'd274: diag_uart2_tx_data <= 8'h0a;
        default: diag_uart2_tx_data <= 8'h0a;
  endcase
end

always @(posedge i_sysclk_div2 or negedge i_sw[0]) begin
  if (!i_sw[0]) begin
    diag_interval_cnt <= 27'd0;
    diag_msg_idx <= 9'd0;
    diag_uart2_tx_start <= 1'b0;
    diag_tx_state <= DIAG_TX_IDLE;
    diag_tx_clk_cnt <= 7'd0;
    diag_tx_bit_idx <= 3'd0;
    diag_tx_byte <= 8'h00;
    diag_uart2_txd_reg <= 1'b1;
  end else begin
    diag_uart2_tx_start <= 1'b0;

    case (diag_tx_state)
      DIAG_TX_IDLE: begin
        diag_uart2_txd_reg <= 1'b1;
        diag_tx_clk_cnt <= 7'd0;
        diag_tx_bit_idx <= 3'd0;

        if (diag_interval_cnt < 27'd70000000) begin
          diag_interval_cnt <= diag_interval_cnt + 1'b1;
          diag_msg_idx <= 9'd0;
        end else begin
          diag_tx_byte <= diag_uart2_tx_data;
          diag_uart2_tx_start <= 1'b1;
          diag_tx_state <= DIAG_TX_START;
        end
      end

      DIAG_TX_START: begin
        diag_uart2_txd_reg <= 1'b0;
        if (diag_tx_clk_cnt == DIAG_UART_CLKS_PER_BIT - 1'b1) begin
          diag_tx_clk_cnt <= 7'd0;
          diag_tx_state <= DIAG_TX_DATA;
        end else begin
          diag_tx_clk_cnt <= diag_tx_clk_cnt + 1'b1;
        end
      end

      DIAG_TX_DATA: begin
        diag_uart2_txd_reg <= diag_tx_byte[diag_tx_bit_idx];
        if (diag_tx_clk_cnt == DIAG_UART_CLKS_PER_BIT - 1'b1) begin
          diag_tx_clk_cnt <= 7'd0;
          if (diag_tx_bit_idx == 3'd7) begin
            diag_tx_bit_idx <= 3'd0;
            diag_tx_state <= DIAG_TX_STOP;
          end else begin
            diag_tx_bit_idx <= diag_tx_bit_idx + 1'b1;
          end
        end else begin
          diag_tx_clk_cnt <= diag_tx_clk_cnt + 1'b1;
        end
      end

      DIAG_TX_STOP: begin
        diag_uart2_txd_reg <= 1'b1;
        if (diag_tx_clk_cnt == DIAG_UART_CLKS_PER_BIT - 1'b1) begin
          diag_tx_clk_cnt <= 7'd0;
          if (diag_msg_idx == DIAG_MSG_LEN - 1'b1) begin
            diag_msg_idx <= 9'd0;
            diag_interval_cnt <= 27'd0;
          end else begin
            diag_msg_idx <= diag_msg_idx + 1'b1;
          end
          diag_tx_state <= DIAG_TX_IDLE;
        end else begin
          diag_tx_clk_cnt <= diag_tx_clk_cnt + 1'b1;
        end
      end

      default: begin
        diag_tx_state <= DIAG_TX_IDLE;
        diag_uart2_txd_reg <= 1'b1;
      end
    endcase
  end
end
endmodule

// Robust 1 Mbps, 8-N-1 receiver for the 70 MHz diagnostic clock domain.
// Both physical debug UART RX pins use this receiver so the active connector
// can be selected without rebuilding the bitstream.
module diag_uart_rx_1m (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg  [7:0] data = 8'd0,
    output reg        valid = 1'b0
);

localparam CLKS_PER_BIT = 70;
localparam HALF_BIT = 35;
localparam RX_IDLE  = 2'd0;
localparam RX_START = 2'd1;
localparam RX_DATA  = 2'd2;
localparam RX_STOP  = 2'd3;

reg [1:0] state = RX_IDLE;
reg [6:0] clk_count = 7'd0;
reg [2:0] bit_index = 3'd0;
reg [7:0] shift_data = 8'd0;
reg [2:0] rx_sync = 3'b111;
wire rx_sample = rx_sync[2];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= RX_IDLE;
        clk_count <= 7'd0;
        bit_index <= 3'd0;
        shift_data <= 8'd0;
        data <= 8'd0;
        valid <= 1'b0;
        rx_sync <= 3'b111;
    end else begin
        rx_sync <= {rx_sync[1:0], rx};
        valid <= 1'b0;

        case (state)
            RX_IDLE: begin
                clk_count <= 7'd0;
                bit_index <= 3'd0;
                if (!rx_sample)
                    state <= RX_START;
            end

            RX_START: begin
                if (clk_count == HALF_BIT - 1) begin
                    clk_count <= 7'd0;
                    state <= rx_sample ? RX_IDLE : RX_DATA;
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            RX_DATA: begin
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 7'd0;
                    shift_data[bit_index] <= rx_sample;
                    if (bit_index == 3'd7) begin
                        bit_index <= 3'd0;
                        state <= RX_STOP;
                    end else begin
                        bit_index <= bit_index + 1'b1;
                    end
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            RX_STOP: begin
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 7'd0;
                    if (rx_sample) begin
                        data <= shift_data;
                        valid <= 1'b1;
                    end
                    state <= RX_IDLE;
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end

            default: state <= RX_IDLE;
        endcase
    end
end

endmodule
