`timescale 1ns/1ps

`include "sys_define.vh"

module core_def (
      input                                      ddr_clk_p,
      input                                      ddr_clk_n,
      input                                      tmclk,
      input                                      cqetmclk,
      output                                     init_calib_complete,
      output                                     cpu_rd_qspi_valid,
      output                                     cpu_wr_ddr_valid,
      input                                      sys_clk_i,
      input                                      dev_clk_i,
      input                                      sys_rstn,
      input                                      cpu_rstn,
      input                                      rstn_sw4,
`ifdef  XS_XDMA_EP
      input       [`XDMA_PCIE_LANES-1:0]         pci_ep_rxn,
      input       [`XDMA_PCIE_LANES-1:0]         pci_ep_rxp,
      output      [`XDMA_PCIE_LANES-1:0]         pci_ep_txn,
      output      [`XDMA_PCIE_LANES-1:0]         pci_ep_txp,
      input                                      pcie_ep_gt_ref_clk_n,
      input                                      pcie_ep_gt_ref_clk_p,
      output                                     pcie_ep_lnk_up,
      input                                      pcie_ep_perstn,
`endif
`ifdef  XS_UART
      input                                      uart0_sin,
      input                                      uart1_sin,
      input                                      uart2_sin,
      output                                     uart0_sout,
      output                                     uart1_sout,
      output                                     uart2_sout,
`endif
      output                                     sd_card_clk_out,
      output                                     sd_cmd_out,
      output                                     sd_cmd_out_oe,
      output          [3:0]                      sd_dat_out,
      output          [3:0]                      sd_dat_out_oe,
      input                                      sd_cmd_in,
      input           [3:0]                      sd_dat_in,
      input                                      sd_card_det_in,
      input                                      sd_card_wp_in,
      output      [2:0]                          sd_vdd1_sel,
      output                                     sd_vdd1_on,
      output      [1:0]                          uhs1_drv_sth,
      output                                     uhs1_swvolt_en,
      output                                     sd_led_control,
`ifndef UVHS_UVW_AXI4_TO_DDR4
      output      [`CONFIG_RANK_WIDTH-1:0]       DDR_CK_T,
      output      [`CONFIG_RANK_WIDTH-1:0]       DDR_CK_C,
      output      [`CONFIG_RANK_WIDTH-1:0]       DDR_CKE,
      output      [`CONFIG_RANK_WIDTH-1:0]       DDR_CS_N,
      output      [`CONFIG_RANK_WIDTH-1:0]       DDR_ODT,
      output                                     DDR_ACT_N,
      output      [1:0]                          DDR_BG,
      output      [1:0]                          DDR_BA,
      output      [16:0]                         DDR_A,
      output                                     DDR_RESET_N,
      inout           [7:0]                      DDR_DM_N,
      inout           [63:0]                     DDR_DQ,
      inout           [7:0]                      DDR_DQS_T,
      inout           [7:0]                      DDR_DQS_C,
`endif
      input           io_systemjtag_jtag_TCK,
      input           io_systemjtag_jtag_TMS,
      input           io_systemjtag_jtag_TDI,
      output          io_systemjtag_jtag_TDO_data,
      output          io_systemjtag_jtag_TDO_driven,
      input           io_systemjtag_reset,
`ifdef  XS_GMAC
      output                                     io_gmac_mdo_oe,
      output                                     io_gmac_mdo,
      output                                     io_gmac_mck_out,
      input                                      io_gmac_mdi,
      output                                     io_gmac_tx_clk,
      output                                     io_gmac_txd_en,
      input                                      io_gmac_rx_clk,
      input                                      io_gmac_rxd_vld,
      input             [3:0]                    io_gmac_rxd,
      output            [3:0]                    io_gmac_txd,
`endif
      input                                      dft_lgc_rst_n,
      input                                      dft_se,
      input           [1:0]                      chip_mode_i,
      input                                      dft_crg_rst_n
);

`ifdef XS_XDMA_EP
assign pci_ep_txn = '0;
assign pci_ep_txp = '0;
assign pcie_ep_lnk_up = 1'b0;
`endif

`ifdef XS_UART
assign uart0_sout = 1'b1;
assign uart1_sout = 1'b1;
assign uart2_sout = 1'b1;
`endif

assign sd_card_clk_out = 1'b0;
assign sd_cmd_out      = 1'b0;
assign sd_cmd_out_oe   = 1'b0;
assign sd_dat_out      = 4'b0;
assign sd_dat_out_oe   = 4'b0;
assign sd_vdd1_sel     = 3'b0;
assign sd_vdd1_on      = 1'b0;
assign uhs1_drv_sth    = 2'b0;
assign uhs1_swvolt_en  = 1'b0;
assign sd_led_control  = 1'b0;

assign io_systemjtag_jtag_TDO_data = 1'b0;
assign io_systemjtag_jtag_TDO_driven = 1'b0;

`ifdef XS_GMAC
assign io_gmac_mdo_oe  = 1'b0;
assign io_gmac_mdo     = 1'b0;
assign io_gmac_mck_out = 1'b0;
assign io_gmac_tx_clk  = 1'b0;
assign io_gmac_txd_en  = 1'b0;
assign io_gmac_txd     = 4'b0;
`endif

`ifndef UVHS_UVW_AXI4_TO_DDR4
assign DDR_CK_T    = '0;
assign DDR_CK_C    = '0;
assign DDR_CKE     = '0;
assign DDR_CS_N    = '1;
assign DDR_ODT     = '0;
assign DDR_ACT_N   = 1'b1;
assign DDR_BG      = 2'b0;
assign DDR_BA      = 2'b0;
assign DDR_A       = 17'b0;
assign DDR_RESET_N = 1'b0;
assign DDR_DM_N    = 8'hzz;
assign DDR_DQ      = 64'hzzzz_zzzz_zzzz_zzzz;
assign DDR_DQS_T   = 8'hzz;
assign DDR_DQS_C   = 8'hzz;
`endif

NutShellUVHSNativeTop U_NUTSHELL_UVHS_NATIVE_TOP (
  .clk                    (sys_clk_i),
  .sys_rstn               (sys_rstn),
  .cpu_rstn               (cpu_rstn),
  .ddr_rstn               (rstn_sw4),
  .init_calib_complete    (init_calib_complete),
  .cpu_rd_qspi_valid      (cpu_rd_qspi_valid),
  .cpu_wr_ddr_valid       (cpu_wr_ddr_valid)
);

endmodule

module NutShellUVHSNativeTop (
  input  wire clk,
  input  wire sys_rstn,
  input  wire cpu_rstn,
  input  wire ddr_rstn,
  output wire init_calib_complete,
  output wire cpu_rd_qspi_valid,
  output wire cpu_wr_ddr_valid
);

  wire         mem_awready;
  wire         mem_awvalid;
  wire [31:0]  mem_awaddr;
  wire [2:0]   mem_awprot;
  wire         mem_awid;
  wire         mem_awuser;
  wire [7:0]   mem_awlen;
  wire [2:0]   mem_awsize;
  wire [1:0]   mem_awburst;
  wire         mem_awlock;
  wire [3:0]   mem_awcache;
  wire [3:0]   mem_awqos;
  wire         mem_wready;
  wire         mem_wvalid;
  wire [63:0]  mem_wdata;
  wire [7:0]   mem_wstrb;
  wire         mem_wlast;
  wire         mem_bready;
  wire         mem_bvalid;
  wire [1:0]   mem_bresp;
  wire         mem_bid;
  wire         mem_buser;
  wire         mem_arready;
  wire         mem_arvalid;
  wire [31:0]  mem_araddr;
  wire [2:0]   mem_arprot;
  wire         mem_arid;
  wire         mem_aruser;
  wire [7:0]   mem_arlen;
  wire [2:0]   mem_arsize;
  wire [1:0]   mem_arburst;
  wire         mem_arlock;
  wire [3:0]   mem_arcache;
  wire [3:0]   mem_arqos;
  wire         mem_rready;
  wire         mem_rvalid;
  wire [1:0]   mem_rresp;
  wire [63:0]  mem_rdata;
  wire         mem_rlast;
  wire         mem_rid;
  wire         mem_ruser;

  wire         mmio_awready;
  wire         mmio_awvalid;
  wire [31:0]  mmio_awaddr;
  wire [2:0]   mmio_awprot;
  wire         mmio_awid;
  wire         mmio_awuser;
  wire [7:0]   mmio_awlen;
  wire [2:0]   mmio_awsize;
  wire [1:0]   mmio_awburst;
  wire         mmio_awlock;
  wire [3:0]   mmio_awcache;
  wire [3:0]   mmio_awqos;
  wire         mmio_wready;
  wire         mmio_wvalid;
  wire [63:0]  mmio_wdata;
  wire [7:0]   mmio_wstrb;
  wire         mmio_wlast;
  wire         mmio_bready;
  wire         mmio_bvalid;
  wire [1:0]   mmio_bresp;
  wire         mmio_bid;
  wire         mmio_buser;
  wire         mmio_arready;
  wire         mmio_arvalid;
  wire [31:0]  mmio_araddr;
  wire [2:0]   mmio_arprot;
  wire         mmio_arid;
  wire         mmio_aruser;
  wire [7:0]   mmio_arlen;
  wire [2:0]   mmio_arsize;
  wire [1:0]   mmio_arburst;
  wire         mmio_arlock;
  wire [3:0]   mmio_arcache;
  wire [3:0]   mmio_arqos;
  wire         mmio_rready;
  wire         mmio_rvalid;
  wire [1:0]   mmio_rresp;
  wire [63:0]  mmio_rdata;
  wire         mmio_rlast;
  wire         mmio_rid;
  wire         mmio_ruser;

  wire [38:0]  ila_wbu_pc;
  wire         ila_wbu_valid;
  wire         ila_wbu_rf_wen;
  wire [4:0]   ila_wbu_rf_dest;
  wire [63:0]  ila_wbu_rf_data;
  wire [63:0]  ila_instr_cnt;
  wire         uart_tx_fire;

  wire [13:0]  uvhs_ddr_awid;
  wire [33:0]  uvhs_ddr_awaddr;
  wire [7:0]   uvhs_ddr_awlen;
  wire [2:0]   uvhs_ddr_awsize;
  wire [1:0]   uvhs_ddr_awburst;
  wire [0:0]   uvhs_ddr_awlock;
  wire [3:0]   uvhs_ddr_awcache;
  wire [2:0]   uvhs_ddr_awprot;
  wire [3:0]   uvhs_ddr_awqos;
  wire [3:0]   uvhs_ddr_awregion;
  wire         uvhs_ddr_awvalid;
  wire         uvhs_ddr_awready;
  wire [255:0] uvhs_ddr_wdata;
  wire [31:0]  uvhs_ddr_wstrb;
  wire         uvhs_ddr_wlast;
  wire         uvhs_ddr_wvalid;
  wire         uvhs_ddr_wready;
  wire [13:0]  uvhs_ddr_bid;
  wire [1:0]   uvhs_ddr_bresp;
  wire         uvhs_ddr_bvalid;
  wire         uvhs_ddr_bready;
  wire [13:0]  uvhs_ddr_arid;
  wire [33:0]  uvhs_ddr_araddr;
  wire [7:0]   uvhs_ddr_arlen;
  wire [2:0]   uvhs_ddr_arsize;
  wire [1:0]   uvhs_ddr_arburst;
  wire [0:0]   uvhs_ddr_arlock;
  wire [3:0]   uvhs_ddr_arcache;
  wire [2:0]   uvhs_ddr_arprot;
  wire [3:0]   uvhs_ddr_arqos;
  wire [3:0]   uvhs_ddr_arregion;
  wire         uvhs_ddr_arvalid;
  wire         uvhs_ddr_arready;
  wire [255:0] uvhs_ddr_rdata;
  wire [13:0]  uvhs_ddr_rid;
  wire [1:0]   uvhs_ddr_rresp;
  wire         uvhs_ddr_rlast;
  wire         uvhs_ddr_rvalid;
  wire         uvhs_ddr_rready;
  wire         uvhs_ddr_user_clk;
  wire         uvhs_ddr_user_rst;
  wire [255:0] uvhs_ddr_sysbus_i;
  wire [255:0] uvhs_ddr_sysbus_o;

  wire uvhs_ddr_user_rstn = ~uvhs_ddr_user_rst;
  (* ASYNC_REG = "TRUE" *) reg [1:0] sys_rstn_sync = 2'b00;
  (* ASYNC_REG = "TRUE" *) reg [1:0] cpu_rstn_sync = 2'b00;
  (* ASYNC_REG = "TRUE" *) reg [1:0] ddr_rstn_sync = 2'b00;
  (* ASYNC_REG = "TRUE" *) reg [1:0] uvhs_ddr_user_rstn_sync = 2'b00;
  always @(posedge clk) begin
    sys_rstn_sync           <= {sys_rstn_sync[0], sys_rstn};
    cpu_rstn_sync           <= {cpu_rstn_sync[0], cpu_rstn};
    ddr_rstn_sync           <= {ddr_rstn_sync[0], ddr_rstn};
    uvhs_ddr_user_rstn_sync <= {uvhs_ddr_user_rstn_sync[0], uvhs_ddr_user_rstn};
  end
  wire native_rstn = sys_rstn_sync[1] & cpu_rstn_sync[1] &
                     ddr_rstn_sync[1] & uvhs_ddr_user_rstn_sync[1];
  wire [31:0] mem_awaddr_rebased = mem_awaddr - 32'h8000_0000;
  wire [31:0] mem_araddr_rebased = mem_araddr - 32'h8000_0000;

  assign uvhs_ddr_sysbus_i = 256'b0;
  assign init_calib_complete = ddr_rstn_sync[1] & uvhs_ddr_user_rstn_sync[1];

  NutShell U_NUTSHELL (
    .clock                  (clk),
    .reset                  (~native_rstn),
    .io_mem_awready         (mem_awready),
    .io_mem_awvalid         (mem_awvalid),
    .io_mem_awaddr          (mem_awaddr),
    .io_mem_awprot          (mem_awprot),
    .io_mem_awid            (mem_awid),
    .io_mem_awuser          (mem_awuser),
    .io_mem_awlen           (mem_awlen),
    .io_mem_awsize          (mem_awsize),
    .io_mem_awburst         (mem_awburst),
    .io_mem_awlock          (mem_awlock),
    .io_mem_awcache         (mem_awcache),
    .io_mem_awqos           (mem_awqos),
    .io_mem_wready          (mem_wready),
    .io_mem_wvalid          (mem_wvalid),
    .io_mem_wdata           (mem_wdata),
    .io_mem_wstrb           (mem_wstrb),
    .io_mem_wlast           (mem_wlast),
    .io_mem_bready          (mem_bready),
    .io_mem_bvalid          (mem_bvalid),
    .io_mem_bresp           (mem_bresp),
    .io_mem_bid             (mem_bid),
    .io_mem_buser           (mem_buser),
    .io_mem_arready         (mem_arready),
    .io_mem_arvalid         (mem_arvalid),
    .io_mem_araddr          (mem_araddr),
    .io_mem_arprot          (mem_arprot),
    .io_mem_arid            (mem_arid),
    .io_mem_aruser          (mem_aruser),
    .io_mem_arlen           (mem_arlen),
    .io_mem_arsize          (mem_arsize),
    .io_mem_arburst         (mem_arburst),
    .io_mem_arlock          (mem_arlock),
    .io_mem_arcache         (mem_arcache),
    .io_mem_arqos           (mem_arqos),
    .io_mem_rready          (mem_rready),
    .io_mem_rvalid          (mem_rvalid),
    .io_mem_rresp           (mem_rresp),
    .io_mem_rdata           (mem_rdata),
    .io_mem_rlast           (mem_rlast),
    .io_mem_rid             (mem_rid),
    .io_mem_ruser           (mem_ruser),
    .io_mmio_awready        (mmio_awready),
    .io_mmio_awvalid        (mmio_awvalid),
    .io_mmio_awaddr         (mmio_awaddr),
    .io_mmio_awprot         (mmio_awprot),
    .io_mmio_awid           (mmio_awid),
    .io_mmio_awuser         (mmio_awuser),
    .io_mmio_awlen          (mmio_awlen),
    .io_mmio_awsize         (mmio_awsize),
    .io_mmio_awburst        (mmio_awburst),
    .io_mmio_awlock         (mmio_awlock),
    .io_mmio_awcache        (mmio_awcache),
    .io_mmio_awqos          (mmio_awqos),
    .io_mmio_wready         (mmio_wready),
    .io_mmio_wvalid         (mmio_wvalid),
    .io_mmio_wdata          (mmio_wdata),
    .io_mmio_wstrb          (mmio_wstrb),
    .io_mmio_wlast          (mmio_wlast),
    .io_mmio_bready         (mmio_bready),
    .io_mmio_bvalid         (mmio_bvalid),
    .io_mmio_bresp          (mmio_bresp),
    .io_mmio_bid            (mmio_bid),
    .io_mmio_buser          (mmio_buser),
    .io_mmio_arready        (mmio_arready),
    .io_mmio_arvalid        (mmio_arvalid),
    .io_mmio_araddr         (mmio_araddr),
    .io_mmio_arprot         (mmio_arprot),
    .io_mmio_arid           (mmio_arid),
    .io_mmio_aruser         (mmio_aruser),
    .io_mmio_arlen          (mmio_arlen),
    .io_mmio_arsize         (mmio_arsize),
    .io_mmio_arburst        (mmio_arburst),
    .io_mmio_arlock         (mmio_arlock),
    .io_mmio_arcache        (mmio_arcache),
    .io_mmio_arqos          (mmio_arqos),
    .io_mmio_rready         (mmio_rready),
    .io_mmio_rvalid         (mmio_rvalid),
    .io_mmio_rresp          (mmio_rresp),
    .io_mmio_rdata          (mmio_rdata),
    .io_mmio_rlast          (mmio_rlast),
    .io_mmio_rid            (mmio_rid),
    .io_mmio_ruser          (mmio_ruser),
    .io_frontend_awready    (),
    .io_frontend_awvalid    (1'b0),
    .io_frontend_awaddr     (32'b0),
    .io_frontend_awprot     (3'b0),
    .io_frontend_awid       (1'b0),
    .io_frontend_awuser     (1'b0),
    .io_frontend_awlen      (8'b0),
    .io_frontend_awsize     (3'b0),
    .io_frontend_awburst    (2'b0),
    .io_frontend_awlock     (1'b0),
    .io_frontend_awcache    (4'b0),
    .io_frontend_awqos      (4'b0),
    .io_frontend_wready     (),
    .io_frontend_wvalid     (1'b0),
    .io_frontend_wdata      (64'b0),
    .io_frontend_wstrb      (8'b0),
    .io_frontend_wlast      (1'b0),
    .io_frontend_bready     (1'b1),
    .io_frontend_bvalid     (),
    .io_frontend_bresp      (),
    .io_frontend_bid        (),
    .io_frontend_buser      (),
    .io_frontend_arready    (),
    .io_frontend_arvalid    (1'b0),
    .io_frontend_araddr     (32'b0),
    .io_frontend_arprot     (3'b0),
    .io_frontend_arid       (1'b0),
    .io_frontend_aruser     (1'b0),
    .io_frontend_arlen      (8'b0),
    .io_frontend_arsize     (3'b0),
    .io_frontend_arburst    (2'b0),
    .io_frontend_arlock     (1'b0),
    .io_frontend_arcache    (4'b0),
    .io_frontend_arqos      (4'b0),
    .io_frontend_rready     (1'b1),
    .io_frontend_rvalid     (),
    .io_frontend_rresp      (),
    .io_frontend_rdata      (),
    .io_frontend_rlast      (),
    .io_frontend_rid        (),
    .io_frontend_ruser      (),
    .io_meip                (5'b0),
    .io_ila_WBUpc           (ila_wbu_pc),
    .io_ila_WBUvalid        (ila_wbu_valid),
    .io_ila_WBUrfWen        (ila_wbu_rf_wen),
    .io_ila_WBUrfDest       (ila_wbu_rf_dest),
    .io_ila_WBUrfData       (ila_wbu_rf_data),
    .io_ila_InstrCnt        (ila_instr_cnt)
  );

  uvhs_axi64_to_axi256 u_uvhs_axi64_to_axi256 (
    .clk                   (clk),
    .rstn                  (native_rstn),
    .s_axi_awid            ({13'b0, mem_awid}),
    .s_axi_awaddr          ({8'b0, mem_awaddr_rebased}),
    .s_axi_awlen           (mem_awlen),
    .s_axi_awsize          (mem_awsize),
    .s_axi_awburst         (mem_awburst),
    .s_axi_awlock          (mem_awlock),
    .s_axi_awcache         (mem_awcache),
    .s_axi_awprot          (mem_awprot),
    .s_axi_awqos           (mem_awqos),
    .s_axi_awvalid         (mem_awvalid),
    .s_axi_awready         (mem_awready),
    .s_axi_wdata           (mem_wdata),
    .s_axi_wstrb           (mem_wstrb),
    .s_axi_wlast           (mem_wlast),
    .s_axi_wvalid          (mem_wvalid),
    .s_axi_wready          (mem_wready),
    .s_axi_bid             (),
    .s_axi_bresp           (mem_bresp),
    .s_axi_bvalid          (mem_bvalid),
    .s_axi_bready          (mem_bready),
    .s_axi_arid            ({13'b0, mem_arid}),
    .s_axi_araddr          ({8'b0, mem_araddr_rebased}),
    .s_axi_arlen           (mem_arlen),
    .s_axi_arsize          (mem_arsize),
    .s_axi_arburst         (mem_arburst),
    .s_axi_arlock          (mem_arlock),
    .s_axi_arcache         (mem_arcache),
    .s_axi_arprot          (mem_arprot),
    .s_axi_arqos           (mem_arqos),
    .s_axi_arvalid         (mem_arvalid),
    .s_axi_arready         (mem_arready),
    .s_axi_rid             (),
    .s_axi_rdata           (mem_rdata),
    .s_axi_rresp           (mem_rresp),
    .s_axi_rlast           (mem_rlast),
    .s_axi_rvalid          (mem_rvalid),
    .s_axi_rready          (mem_rready),
    .m_axi_awid            (uvhs_ddr_awid),
    .m_axi_awaddr          (uvhs_ddr_awaddr),
    .m_axi_awlen           (uvhs_ddr_awlen),
    .m_axi_awsize          (uvhs_ddr_awsize),
    .m_axi_awburst         (uvhs_ddr_awburst),
    .m_axi_awlock          (uvhs_ddr_awlock),
    .m_axi_awcache         (uvhs_ddr_awcache),
    .m_axi_awprot          (uvhs_ddr_awprot),
    .m_axi_awqos           (uvhs_ddr_awqos),
    .m_axi_awregion        (uvhs_ddr_awregion),
    .m_axi_awvalid         (uvhs_ddr_awvalid),
    .m_axi_awready         (uvhs_ddr_awready),
    .m_axi_wdata           (uvhs_ddr_wdata),
    .m_axi_wstrb           (uvhs_ddr_wstrb),
    .m_axi_wlast           (uvhs_ddr_wlast),
    .m_axi_wvalid          (uvhs_ddr_wvalid),
    .m_axi_wready          (uvhs_ddr_wready),
    .m_axi_bid             (uvhs_ddr_bid),
    .m_axi_bresp           (uvhs_ddr_bresp),
    .m_axi_bvalid          (uvhs_ddr_bvalid),
    .m_axi_bready          (uvhs_ddr_bready),
    .m_axi_arid            (uvhs_ddr_arid),
    .m_axi_araddr          (uvhs_ddr_araddr),
    .m_axi_arlen           (uvhs_ddr_arlen),
    .m_axi_arsize          (uvhs_ddr_arsize),
    .m_axi_arburst         (uvhs_ddr_arburst),
    .m_axi_arlock          (uvhs_ddr_arlock),
    .m_axi_arcache         (uvhs_ddr_arcache),
    .m_axi_arprot          (uvhs_ddr_arprot),
    .m_axi_arqos           (uvhs_ddr_arqos),
    .m_axi_arregion        (uvhs_ddr_arregion),
    .m_axi_arvalid         (uvhs_ddr_arvalid),
    .m_axi_arready         (uvhs_ddr_arready),
    .m_axi_rid             (uvhs_ddr_rid),
    .m_axi_rdata           (uvhs_ddr_rdata),
    .m_axi_rresp           (uvhs_ddr_rresp),
    .m_axi_rlast           (uvhs_ddr_rlast),
    .m_axi_rvalid          (uvhs_ddr_rvalid),
    .m_axi_rready          (uvhs_ddr_rready)
  );

  assign mem_bid = 1'b0;
  assign mem_buser = 1'b0;
  assign mem_rid = 1'b0;
  assign mem_ruser = 1'b0;

  uvhs_native_mmio_slave U_NATIVE_MMIO (
    .clk          (clk),
    .rstn         (native_rstn),
    .awvalid      (mmio_awvalid),
    .awaddr       (mmio_awaddr),
    .awid         (mmio_awid),
    .awready      (mmio_awready),
    .wvalid       (mmio_wvalid),
    .wdata        (mmio_wdata),
    .wstrb        (mmio_wstrb),
    .wready       (mmio_wready),
    .bready       (mmio_bready),
    .bvalid       (mmio_bvalid),
    .bresp        (mmio_bresp),
    .bid          (mmio_bid),
    .arvalid      (mmio_arvalid),
    .araddr       (mmio_araddr),
    .arid         (mmio_arid),
    .arready      (mmio_arready),
    .rready       (mmio_rready),
    .rvalid       (mmio_rvalid),
    .rresp        (mmio_rresp),
    .rdata        (mmio_rdata),
    .rlast        (mmio_rlast),
    .rid          (mmio_rid),
    .uart_tx_fire (uart_tx_fire)
  );

  assign mmio_buser = 1'b0;
  assign mmio_ruser = 1'b0;

  uvw_axi4_to_ddr4 U_UVHS_UVW_AXI4_TO_DDR4 (
    .ddr4ip_dut_axi_aclk     (clk),
    .ddr4ip_dut_axi_aresetn  (ddr_rstn_sync[1]),
    .ddr4ip_dut_axi_awaddr   (uvhs_ddr_awaddr),
    .ddr4ip_dut_axi_awburst  (uvhs_ddr_awburst),
    .ddr4ip_dut_axi_awcache  (uvhs_ddr_awcache),
    .ddr4ip_dut_axi_awid     (uvhs_ddr_awid),
    .ddr4ip_dut_axi_awlen    (uvhs_ddr_awlen),
    .ddr4ip_dut_axi_awlock   (uvhs_ddr_awlock),
    .ddr4ip_dut_axi_awprot   (uvhs_ddr_awprot),
    .ddr4ip_dut_axi_awqos    (uvhs_ddr_awqos),
    .ddr4ip_dut_axi_awready  (uvhs_ddr_awready),
    .ddr4ip_dut_axi_awregion (uvhs_ddr_awregion),
    .ddr4ip_dut_axi_awsize   (uvhs_ddr_awsize),
    .ddr4ip_dut_axi_awvalid  (uvhs_ddr_awvalid),
    .ddr4ip_dut_axi_wdata    (uvhs_ddr_wdata),
    .ddr4ip_dut_axi_wlast    (uvhs_ddr_wlast),
    .ddr4ip_dut_axi_wready   (uvhs_ddr_wready),
    .ddr4ip_dut_axi_wstrb    (uvhs_ddr_wstrb),
    .ddr4ip_dut_axi_wvalid   (uvhs_ddr_wvalid),
    .ddr4ip_dut_axi_bid      (uvhs_ddr_bid),
    .ddr4ip_dut_axi_bready   (uvhs_ddr_bready),
    .ddr4ip_dut_axi_bresp    (uvhs_ddr_bresp),
    .ddr4ip_dut_axi_bvalid   (uvhs_ddr_bvalid),
    .ddr4ip_dut_axi_araddr   (uvhs_ddr_araddr),
    .ddr4ip_dut_axi_arburst  (uvhs_ddr_arburst),
    .ddr4ip_dut_axi_arcache  (uvhs_ddr_arcache),
    .ddr4ip_dut_axi_arid     (uvhs_ddr_arid),
    .ddr4ip_dut_axi_arlen    (uvhs_ddr_arlen),
    .ddr4ip_dut_axi_arlock   (uvhs_ddr_arlock),
    .ddr4ip_dut_axi_arprot   (uvhs_ddr_arprot),
    .ddr4ip_dut_axi_arqos    (uvhs_ddr_arqos),
    .ddr4ip_dut_axi_arready  (uvhs_ddr_arready),
    .ddr4ip_dut_axi_arregion (uvhs_ddr_arregion),
    .ddr4ip_dut_axi_arsize   (uvhs_ddr_arsize),
    .ddr4ip_dut_axi_arvalid  (uvhs_ddr_arvalid),
    .ddr4ip_dut_axi_rdata    (uvhs_ddr_rdata),
    .ddr4ip_dut_axi_rid      (uvhs_ddr_rid),
    .ddr4ip_dut_axi_rlast    (uvhs_ddr_rlast),
    .ddr4ip_dut_axi_rready   (uvhs_ddr_rready),
    .ddr4ip_dut_axi_rresp    (uvhs_ddr_rresp),
    .ddr4ip_dut_axi_rvalid   (uvhs_ddr_rvalid),
    .ddr4ip_dut_axi_aclk_en  (1'b1),
    .ddr4ip_ddr4_user_clk    (uvhs_ddr_user_clk),
    .ddr4ip_ddr4_user_rst    (uvhs_ddr_user_rst),
    .sysbus_ghbd_i           (uvhs_ddr_sysbus_i),
    .sysbus_ghbd_o           (uvhs_ddr_sysbus_o),
    .FP_CLK_200M_P           (),
    .FP_CLK_200M_N           (),
    .DDR4_DIMM_ACT_N         (),
    .DDR4_DIMM_A             (),
    .DDR4_DIMM_BA            (),
    .DDR4_DIMM_BG            (),
    .DDR4_DIMM_CK_N          (),
    .DDR4_DIMM_CK_P          (),
    .DDR4_DIMM_CKE           (),
    .DDR4_DIMM_CS_N          (),
    .DDR4_DIMM_ODT           (),
    .DDR4_DIMM_RST_B         (),
    .DDR4_DIMM_DM            (),
    .DDR4_DIMM_DQ            (),
    .DDR4_DIMM_DQS_N         (),
    .DDR4_DIMM_DQS_P         ()
  );

  (* mark_debug = "true" *) reg mem_read_seen;
  (* mark_debug = "true" *) reg commit_seen;
  (* mark_debug = "true" *) reg uart_seen;
  (* mark_debug = "true" *) reg [38:0] last_commit_pc;
  wire mem_read_fire = mem_arvalid & mem_arready;
  always @(posedge clk) begin
    if (!native_rstn) begin
      mem_read_seen  <= 1'b0;
      commit_seen    <= 1'b0;
      uart_seen      <= 1'b0;
      last_commit_pc <= 39'b0;
    end else begin
      mem_read_seen <= mem_read_seen | mem_read_fire;
      commit_seen   <= commit_seen | ila_wbu_valid;
      uart_seen     <= uart_seen | uart_tx_fire;
      if (ila_wbu_valid) begin
        last_commit_pc <= ila_wbu_pc;
      end
    end
  end

  assign cpu_rd_qspi_valid = mem_read_seen;
  assign cpu_wr_ddr_valid = commit_seen | uart_seen;

endmodule

module uvhs_native_mmio_slave (
  input  wire        clk,
  input  wire        rstn,
  input  wire        awvalid,
  input  wire [31:0] awaddr,
  input  wire        awid,
  output wire        awready,
  input  wire        wvalid,
  input  wire [63:0] wdata,
  input  wire [7:0]  wstrb,
  output wire        wready,
  input  wire        bready,
  output reg         bvalid,
  output wire [1:0]  bresp,
  output reg         bid,
  input  wire        arvalid,
  input  wire [31:0] araddr,
  input  wire        arid,
  output wire        arready,
  input  wire        rready,
  output reg         rvalid,
  output wire [1:0]  rresp,
  output reg  [63:0] rdata,
  output wire        rlast,
  output reg         rid,
  output reg         uart_tx_fire
);
  localparam [31:0] UARTLITE_BASE = 32'h4060_0000;
  localparam [31:0] UART_TX_FIFO  = 32'h4060_0004;
  localparam [31:0] UART_STAT     = 32'h4060_0008;

  reg        aw_seen;
  reg [31:0] awaddr_q;
  reg        awid_q;

  assign awready = ~aw_seen & ~bvalid;
  assign wready  = aw_seen & ~bvalid;
  assign bresp   = 2'b00;
  assign arready = ~rvalid;
  assign rresp   = 2'b00;
  assign rlast   = 1'b1;

  always @(posedge clk) begin
    if (!rstn) begin
      aw_seen      <= 1'b0;
      awaddr_q     <= 32'b0;
      awid_q       <= 1'b0;
      bvalid       <= 1'b0;
      bid          <= 1'b0;
      rvalid       <= 1'b0;
      rid          <= 1'b0;
      rdata        <= 64'b0;
      uart_tx_fire <= 1'b0;
    end else begin
      uart_tx_fire <= 1'b0;

      if (awvalid && awready) begin
        aw_seen  <= 1'b1;
        awaddr_q <= awaddr;
        awid_q   <= awid;
      end

      if (wvalid && wready) begin
        aw_seen <= 1'b0;
        bvalid  <= 1'b1;
        bid     <= awid_q;
        if (awaddr_q == UART_TX_FIFO && |wstrb) begin
          uart_tx_fire <= 1'b1;
        end
      end

      if (bvalid && bready) begin
        bvalid <= 1'b0;
      end

      if (arvalid && arready) begin
        rvalid <= 1'b1;
        rid    <= arid;
        case (araddr)
          UART_STAT: rdata <= 64'b0;
          UARTLITE_BASE: rdata <= 64'b0;
          default: rdata <= 64'b0;
        endcase
      end else if (rvalid && rready) begin
        rvalid <= 1'b0;
      end
    end
  end
endmodule
