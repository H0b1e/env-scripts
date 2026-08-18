// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1.1 (lin64) Build 6233196 Thu Sep 11 21:27:11 MDT 2025
// Date        : Mon Aug 17 21:12:57 2026
// Host        : open01.kxhcluster.com running 64-bit Ubuntu 26.04 LTS
// Command     : write_verilog -mode synth_stub -force /nfs/home/lufeifan/tools/xdma_ep_1902_out/xdma_ep_Stub.v
// Design      : xdma_ep_wrapper
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvp1902-vsva6865-2MP-e-S
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module xdma_ep_wrapper(M00_AXIS_0_tdata, M00_AXIS_0_tkeep, 
  M00_AXIS_0_tlast, M00_AXIS_0_tready, M00_AXIS_0_tvalid, S00_AXIS_0_tdata, 
  S00_AXIS_0_tkeep, S00_AXIS_0_tlast, S00_AXIS_0_tready, S00_AXIS_0_tvalid, 
  TO_DIFFTEST_PCIE_CLK, XDMA_AXI_LITE_araddr, XDMA_AXI_LITE_arprot, 
  XDMA_AXI_LITE_arready, XDMA_AXI_LITE_arvalid, XDMA_AXI_LITE_awaddr, 
  XDMA_AXI_LITE_awprot, XDMA_AXI_LITE_awready, XDMA_AXI_LITE_awvalid, 
  XDMA_AXI_LITE_bready, XDMA_AXI_LITE_bresp, XDMA_AXI_LITE_bvalid, XDMA_AXI_LITE_rdata, 
  XDMA_AXI_LITE_rready, XDMA_AXI_LITE_rresp, XDMA_AXI_LITE_rvalid, XDMA_AXI_LITE_wdata, 
  XDMA_AXI_LITE_wready, XDMA_AXI_LITE_wstrb, XDMA_AXI_LITE_wvalid, cpu_clk, 
  pcie_ep_gt_ref_clk_n, pcie_ep_gt_ref_clk_p, pcie_ep_lnk_up, pcie_ep_perstn, 
  pcie_mgt_grx_n, pcie_mgt_grx_p, pcie_mgt_gtx_n, pcie_mgt_gtx_p)
/* synthesis syn_black_box black_box_pad_pin="M00_AXIS_0_tdata[255:0],M00_AXIS_0_tkeep[31:0],M00_AXIS_0_tlast,M00_AXIS_0_tready,M00_AXIS_0_tvalid,S00_AXIS_0_tdata[255:0],S00_AXIS_0_tkeep[31:0],S00_AXIS_0_tlast,S00_AXIS_0_tready,S00_AXIS_0_tvalid,TO_DIFFTEST_PCIE_CLK,XDMA_AXI_LITE_araddr[31:0],XDMA_AXI_LITE_arprot[2:0],XDMA_AXI_LITE_arready,XDMA_AXI_LITE_arvalid,XDMA_AXI_LITE_awaddr[31:0],XDMA_AXI_LITE_awprot[2:0],XDMA_AXI_LITE_awready,XDMA_AXI_LITE_awvalid,XDMA_AXI_LITE_bready,XDMA_AXI_LITE_bresp[1:0],XDMA_AXI_LITE_bvalid,XDMA_AXI_LITE_rdata[31:0],XDMA_AXI_LITE_rready,XDMA_AXI_LITE_rresp[1:0],XDMA_AXI_LITE_rvalid,XDMA_AXI_LITE_wdata[31:0],XDMA_AXI_LITE_wready,XDMA_AXI_LITE_wstrb[3:0],XDMA_AXI_LITE_wvalid,cpu_clk,pcie_ep_gt_ref_clk_n[0:0],pcie_ep_gt_ref_clk_p[0:0],pcie_ep_lnk_up,pcie_ep_perstn,pcie_mgt_grx_n[3:0],pcie_mgt_grx_p[3:0],pcie_mgt_gtx_n[3:0],pcie_mgt_gtx_p[3:0]" */;
  output [255:0]M00_AXIS_0_tdata;
  output [31:0]M00_AXIS_0_tkeep;
  output M00_AXIS_0_tlast;
  input M00_AXIS_0_tready;
  output M00_AXIS_0_tvalid;
  input [255:0]S00_AXIS_0_tdata;
  input [31:0]S00_AXIS_0_tkeep;
  input S00_AXIS_0_tlast;
  output S00_AXIS_0_tready;
  input S00_AXIS_0_tvalid;
  output TO_DIFFTEST_PCIE_CLK;
  output [31:0]XDMA_AXI_LITE_araddr;
  output [2:0]XDMA_AXI_LITE_arprot;
  input XDMA_AXI_LITE_arready;
  output XDMA_AXI_LITE_arvalid;
  output [31:0]XDMA_AXI_LITE_awaddr;
  output [2:0]XDMA_AXI_LITE_awprot;
  input XDMA_AXI_LITE_awready;
  output XDMA_AXI_LITE_awvalid;
  output XDMA_AXI_LITE_bready;
  input [1:0]XDMA_AXI_LITE_bresp;
  input XDMA_AXI_LITE_bvalid;
  input [31:0]XDMA_AXI_LITE_rdata;
  output XDMA_AXI_LITE_rready;
  input [1:0]XDMA_AXI_LITE_rresp;
  input XDMA_AXI_LITE_rvalid;
  output [31:0]XDMA_AXI_LITE_wdata;
  input XDMA_AXI_LITE_wready;
  output [3:0]XDMA_AXI_LITE_wstrb;
  output XDMA_AXI_LITE_wvalid;
  input cpu_clk;
  input [0:0]pcie_ep_gt_ref_clk_n;
  input [0:0]pcie_ep_gt_ref_clk_p;
  output pcie_ep_lnk_up;
  input pcie_ep_perstn;
  input [3:0]pcie_mgt_grx_n;
  input [3:0]pcie_mgt_grx_p;
  output [3:0]pcie_mgt_gtx_n;
  output [3:0]pcie_mgt_gtx_p;
endmodule
