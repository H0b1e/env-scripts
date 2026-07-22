`timescale 1ns/1ps

`include "sys_define.vh"

`ifndef XDMA_PCIE_LANES
`define XDMA_PCIE_LANES 4
`endif

module fpga_top_debug
(
`ifndef UVHS_UVW_AXI4_TO_DDR4
   input                 clk7_p, // ddr 80MHz
   input                 clk7_n,
`endif
   input                 clk6_p, // system 200MHz
`ifndef UVHS_NO_XILINX_CLK_PRIMS
   input                 clk6_n,
`endif
   input                 rstn_sw6,
   input                 rstn_sw5,
   input                 rstn_sw4,
   // uart
`ifdef XS_UART
   output                uart0_sout,
   input                 uart0_sin,
`endif
   //PCIE
`ifdef XS_XDMA_EP
   input    [`XDMA_PCIE_LANES-1:0] pci_ep_rxn,
   input    [`XDMA_PCIE_LANES-1:0] pci_ep_rxp,
   output   [`XDMA_PCIE_LANES-1:0] pci_ep_txn,
   output   [`XDMA_PCIE_LANES-1:0] pci_ep_txp,
   input                 pcie_ep_gt_ref_clk_n,
   input                 pcie_ep_gt_ref_clk_p,
   output                pcie_ep_lnk_up,
   input                 pcie_ep_perstn
`endif 
   //DDR
`ifndef UVHS_UVW_AXI4_TO_DDR4
   output    [0:0]       DDR0_CK_T,
   output    [0:0]       DDR0_CK_C,
   output    [0:0]       DDR0_CKE,
   output    [0:0]       DDR0_CS_N,
   output    [0:0]       DDR0_ODT,
   output                DDR0_ACT_N,
   output    [1:0]       DDR0_BG,
   output    [1:0]       DDR0_BA,
   output    [16:0]      DDR0_A,
   output                DDR0_RESET_N,
   inout     [7:0]       DDR0_DM,
   inout     [63:0]      DDR0_DQ,
   inout     [7:0]       DDR0_DQS_T,
   inout     [7:0]       DDR0_DQS_C,
`endif
   
`ifdef XS_GMAC
   input                RGMII_RXCLK,
   input                RGMII_RXDV,
   input                RGMII_RXD0,
   input                RGMII_RXD1,
   input                RGMII_RXD2,
   input                RGMII_RXD3,
   output               RGMII_TXCLK,
   output               RGMII_TXEN,
   output               RGMII_TXD0,
   output               RGMII_TXD1,
   output               RGMII_TXD2,
   output               RGMII_TXD3,
   output               MDC,
   inout                MDIO,
   output               PHY_RESET_B,
`endif
);

wire sys_rstn;
wire cpu_setn_buf;
wire sys_clk_i, dev_clk_i;
wire cpu_rstn_to_core;
wire rstn_sw4_to_core;
wire rstn_sw5_ctrl;
wire rstn_sw6_ctrl;
wire rstn_sw4_ctrl;

IBUF sys_rstn_ibuf (.O(sys_rstn), .I(rstn_sw6));
IBUF cpu_rstn_ibuf (.O(cpu_setn_buf), .I(rstn_sw5));

// The staged UVHS DDR profile uses the physical reset controls directly.
assign rstn_sw6_ctrl = sys_rstn;
assign rstn_sw5_ctrl = cpu_setn_buf;
assign rstn_sw4_ctrl = rstn_sw4;
assign cpu_rstn_to_core = rstn_sw5_ctrl;
assign rstn_sw4_to_core = rstn_sw4_ctrl;

// Suppose PHY_RESET_B active high.
// Although 88E1116R pin10 resetn is active low.
// But this pin is on connector, which might not have current by default?
assign PHY_RESET_B = cpu_rstn_to_core;

wire   cqetmclk_buf;

`ifdef UVHS_NO_XILINX_CLK_PRIMS
assign cqetmclk_buf   = clk6_p;
`else
wire    cqetmclk;
IBUFGDS ibufgds_tmclk_200MHz
(
	.I              (clk6_p),
	.IB             (clk6_n),
	.O              (cqetmclk)
);

BUFG bufg_cqetmclk
(
    .I              (cqetmclk),
    .O              (cqetmclk_buf)
);
`endif

assign sys_clk_i = cqetmclk_buf;
assign dev_clk_i = cqetmclk_buf;

//------------led test------------------

wire                sdmmc_cclk_card;
wire                sdmmc_card_detect_n;
wire                sdmmc_card_write_prot;
wire                sdmmc_sd_cmd_in;
wire   [3:0]        sdmmc_sd_dat_in;
wire                sdmmc_sd_cmd_out;
wire                sdmmc_sd_cmd_out_en;
wire   [3:0]        sdmmc_sd_dat_out;
wire   [3:0]        sdmmc_sd_dat_out_en;
wire   [1:0]        sdmmc_uhs1_drv_sth;
wire                sdmmc_uhs1_swvolt_en;
wire                sdmmc_sd_vdd1_on;
wire   [2:0]        sdmmc_sd_vdd1_sel;
wire                gmac_gmii_mdi_i;
wire                gmac_gmii_mdc_o;
wire                gmac_gmii_mdo_o;
wire                gmac_gmii_mdo_o_e;
wire                gmac_clk_rx_i;
wire   [3:0]        gmac_phy_rxd;
wire                gmac_phy_rxdv;
wire                gmac_clk_tx_o;
wire   [3:0]        gmac_phy_txd;
wire                gmac_phy_txen;

wire DDR0_ZQ = 'h0;

// qspi-io
//assign QSPI_CLK = qspi_sclk_out;
//assign QSPI_CS = qspi_n_ss_out;

//assign QSPI_DAT_3 = !qspi_n_mo_en[3] ? qspi_mo3 : 1'bz;
//assign QSPI_DAT_2 = !qspi_n_mo_en[2] ? qspi_mo2 : 1'bz;
//assign QSPI_DAT_1 = !qspi_n_mo_en[1] ? qspi_mo1 : 1'bz;
//assign QSPI_DAT_0 = !qspi_n_mo_en[0] ? qspi_mo0 : 1'bz;

//assign qspi_mi3 = QSPI_DAT_3;
//assign qspi_mi2 = QSPI_DAT_2;
//assign qspi_mi1 = QSPI_DAT_1;
//assign qspi_mi0 = QSPI_DAT_0;

// sd-io is removed from the staged top-level interface.
// Core SD ports remain present and are tied off below.

// gmac wiring
`ifdef XS_GMAC
wire       io_gmac_mdo_oe;
wire       io_gmac_mdo;
wire       io_gmac_mck_out;
wire       io_gmac_mdi;
wire       io_gmac_tx_clk;
wire       io_gmac_txd_en;
wire       io_gmac_rx_clk;
wire       io_gmac_rxd_vld;
wire [3:0] io_gmac_rxd;
wire [3:0] io_gmac_txd;

assign MDC = io_gmac_mck_out;
assign io_gmac_mdi = MDIO;
assign MDIO = io_gmac_mdo_oe ? io_gmac_mdo : 1'bz;


assign io_gmac_rx_clk = RGMII_RXCLK;
assign io_gmac_rxd_vld = RGMII_RXDV;
assign io_gmac_rxd[0] = RGMII_RXD0;
assign io_gmac_rxd[1] = RGMII_RXD1;
assign io_gmac_rxd[2] = RGMII_RXD2;
assign io_gmac_rxd[3] = RGMII_RXD3;

assign RGMII_TXCLK = io_gmac_tx_clk;
assign RGMII_TXEN = io_gmac_txd_en;
assign RGMII_TXD0 = io_gmac_txd[0];
assign RGMII_TXD1 = io_gmac_txd[1];
assign RGMII_TXD2 = io_gmac_txd[2];
assign RGMII_TXD3 = io_gmac_txd[3];
`endif

// External JTAG is removed from the staged top-level interface.
// Keep the core JTAG inputs inactive and discard its debug output.
wire      io_systemjtag_jtag_TDO_data;
wire      io_systemjtag_jtag_TDO_driven;

// core
core_def core_def
(
`ifdef UVHS_UVW_AXI4_TO_DDR4
  .ddr_clk_p            (1'b0),
  .ddr_clk_n            (1'b0),
`else
  .ddr_clk_p            (clk7_p),
  .ddr_clk_n            (clk7_n),
`endif
  .tmclk                (1'b0),
  .cqetmclk             (cqetmclk_buf),
  .init_calib_complete  (),
  .cpu_rd_qspi_valid    (),
  .cpu_wr_ddr_valid     (),
  .sys_clk_i            (sys_clk_i),
  .dev_clk_i            (dev_clk_i),
  .sys_rstn             (rstn_sw6_ctrl),
  .cpu_rstn             (cpu_rstn_to_core),
  .rstn_sw4             (rstn_sw4_to_core),
  .dft_lgc_rst_n        (1'b1),
  .dft_se               (1'b0),
  .chip_mode_i          (2'b00), // normal mode
  .dft_crg_rst_n        (1'b1),
  // pcie
`ifdef XS_XDMA_EP
  .pci_ep_rxn           (pci_ep_rxn),
  .pci_ep_rxp           (pci_ep_rxp),
  .pci_ep_txn           (pci_ep_txn),
  .pci_ep_txp           (pci_ep_txp),
  .pcie_ep_gt_ref_clk_n (pcie_ep_gt_ref_clk_n),
  .pcie_ep_gt_ref_clk_p (pcie_ep_gt_ref_clk_p),
  .pcie_ep_lnk_up       (pcie_ep_lnk_up),
  .pcie_ep_perstn       (pcie_ep_perstn),
`endif
`ifdef XS_UART
  // uart
  .uart0_sout           (uart0_sout),
  .uart1_sout           (),
  .uart2_sout           (),
  .uart0_sin            (uart0_sin),
  .uart1_sin            (1'b1),
  .uart2_sin            (1'b1),
`endif  
  // JTAG
  .io_systemjtag_jtag_TCK         (1'b0),
  .io_systemjtag_jtag_TMS         (1'b1),
  .io_systemjtag_jtag_TDI         (1'b0),
  .io_systemjtag_jtag_TDO_data    (io_systemjtag_jtag_TDO_data ),
  .io_systemjtag_jtag_TDO_driven  (io_systemjtag_jtag_TDO_driven ),
  .io_systemjtag_reset            (1'b1),

  // qspi
//  .qspi_mo0(qspi_mo0),
//  .qspi_mo1(qspi_mo1),
//  .qspi_mo2(qspi_mo2),
//  .qspi_mo3(qspi_mo3),
//  .qspi_mo_oe_n(qspi_n_mo_en),
//  .qspi_cs_out_n(qspi_n_ss_out),
//  .qspi_sclk_out(qspi_sclk_out),
//  .qspi_mi0(qspi_mi0),
//  .qspi_mi1(qspi_mi1),
//  .qspi_mi2(qspi_mi2),
//  .qspi_mi3(qspi_mi3),

   // sdmmc
  .sd_card_clk_out      (),
  .sd_cmd_out           (),
  .sd_cmd_out_oe        (),
  .sd_dat_out           (),
  .sd_dat_out_oe        (),
  .uhs1_drv_sth         (),
  .uhs1_swvolt_en       (),
  .sd_vdd1_on           (),
  .sd_vdd1_sel          (),
  .sd_card_det_in       (1'b1),
  .sd_card_wp_in        (1'b0),
  .sd_cmd_in            (1'b1),
  .sd_dat_in            (4'b1111),
  .sd_led_control       (          )
`ifdef XS_GMAC
  ,
`else
`ifndef UVHS_UVW_AXI4_TO_DDR4
  ,
`endif
`endif
  
  `ifdef XS_GMAC
  // gmac
  .io_gmac_mdo_oe  ( io_gmac_mdo_oe  ),
  .io_gmac_mdo     ( io_gmac_mdo     ),
  .io_gmac_mck_out ( io_gmac_mck_out ),
  .io_gmac_mdi     ( io_gmac_mdi     ),
  .io_gmac_tx_clk  ( io_gmac_tx_clk  ),
  .io_gmac_txd_en  ( io_gmac_txd_en  ),
  .io_gmac_rx_clk  ( io_gmac_rx_clk  ),
  .io_gmac_rxd_vld ( io_gmac_rxd_vld ),
  .io_gmac_rxd     ( io_gmac_rxd     ),
  .io_gmac_txd     ( io_gmac_txd     )
`ifndef UVHS_UVW_AXI4_TO_DDR4
  ,
`endif
  `endif

  // ddr
`ifndef UVHS_UVW_AXI4_TO_DDR4
  .DDR_CK_T             (DDR0_CK_T        ),   
  .DDR_CK_C             (DDR0_CK_C        ),   
  .DDR_CKE              (DDR0_CKE         ),    
  .DDR_CS_N             (DDR0_CS_N        ),   
  .DDR_ODT              (DDR0_ODT         ),    
  .DDR_ACT_N            (DDR0_ACT_N       ),  
  .DDR_BG               (DDR0_BG          ),     
  .DDR_BA               (DDR0_BA          ),     
  .DDR_A                (DDR0_A           ),      
  .DDR_RESET_N          (DDR0_RESET_N     ), 
  .DDR_DM_N             (DDR0_DM          ),     
  .DDR_DQ               (DDR0_DQ          ),     
  .DDR_DQS_T            (DDR0_DQS_T       ),  
  .DDR_DQS_C            (DDR0_DQS_C       )
  /*
  .DDR_ZQ               (DDR0_ZQ),
  .gmac_gmii_mdc_o(gmac_gmii_mdc_o),
  .gmac_gmii_mdo_o(gmac_gmii_mdo_o),
  .gmac_gmii_mdo_o_e(gmac_gmii_mdo_o_e),
  .gmac_clk_tx_o(gmac_clk_tx_o),
  .gmac_phy_txd(gmac_phy_txd),
  .gmac_phy_txen(gmac_phy_txen),
  .gmac_gmii_mdi_i(gmac_gmii_mdi_i),
  .gmac_clk_rx_i(gmac_clk_rx_i),
  .gmac_phy_rxd(gmac_phy_rxd),
  .gmac_phy_rxdv(gmac_phy_rxdv),
  
  .gpio_porta_ddr(gpio_porta_ddr),
  .gpio_porta_dr(gpio_porta_dr),
  .gpio_ext_porta(gpio_ext_porta),
  
  .jtag_tck(jtag_tck), 
  .jtag_tdi(jtag_tdi), 
  .jtag_tms(jtag_tms), 
  .jtag_trstn(jtag_trstn),
  .jtag_tdo(jtag_tdo), 
  
  */
`endif

);

//---
/*
wire                gmac_gmii_mdi_i;
wire                gmac_gmii_mdc_o;
wire                gmac_gmii_mdo_o;
wire                gmac_gmii_mdo_o_e;

wire                gmac_clk_rx_i;
wire                gmac_phy_rxdv;
wire   [3:0]        gmac_phy_rxd;

wire                gmac_clk_tx_o;
wire                gmac_phy_txen;
wire   [3:0]        gmac_phy_txd;


assign MDC = gmac_gmii_mdc_o;
assign gmac_gmii_mdi_i = MDIO;
assign MDIO = gmac_gmii_mdo_o_e ? gmac_gmii_mdo_o : 1'bz;

assign gmac_clk_rx_i = RGMII_RXCLK;
assign gmac_phy_rxdv = RGMII_RXDV;
assign gmac_phy_rxd[0] = RGMII_RXD0;
assign gmac_phy_rxd[1] = RGMII_RXD1;
assign gmac_phy_rxd[2] = RGMII_RXD2;
assign gmac_phy_rxd[3] = RGMII_RXD3;

assign RGMII_TXCLK = gmac_clk_tx_o;
assign RGMII_TXEN = gmac_phy_txen;
assign RGMII_TXD0 = gmac_phy_txd[0];
assign RGMII_TXD1 = gmac_phy_txd[1];
assign RGMII_TXD2 = gmac_phy_txd[2];
assign RGMII_TXD3 = gmac_phy_txd[3];


assign gpio_ext_porta = 32'h0;
assign GPIO_O0 = |gpio_porta_ddr;
assign GPIO_O1 = |gpio_porta_dr;
*/

endmodule
