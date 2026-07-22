`timescale 1ns/1ps

`ifndef UVHS_NATIVE_BLACKBOX_STUBS_V
`define UVHS_NATIVE_BLACKBOX_STUBS_V

module IBUF(output O, input I);
  assign O = I;
endmodule

module OBUF(output O, input I);
  assign O = I;
endmodule

module BUFG(output O, input I);
  assign O = I;
endmodule

module IBUFGDS(output O, input I, input IB);
  assign O = I;
endmodule

(* black_box, syn_black_box *)
module vio_0 (
  clk, probe_out0, probe_out1, probe_out2
);
input clk;
output probe_out0, probe_out1, probe_out2;
`ifdef UVHS_VIO_STUB
assign probe_out0 = 1'b1;
assign probe_out1 = 1'b1;
assign probe_out2 = 1'b0;
`endif
endmodule

`ifndef UVHS_EXTERNAL_UVW_AXI4_TO_DDR4
(* black_box, syn_black_box *)
module uvw_axi4_to_ddr4 (
  input         ddr4ip_dut_axi_aclk,
  input         ddr4ip_dut_axi_aresetn,
  input  [33:0] ddr4ip_dut_axi_awaddr,
  input  [1:0]  ddr4ip_dut_axi_awburst,
  input  [3:0]  ddr4ip_dut_axi_awcache,
  input  [13:0] ddr4ip_dut_axi_awid,
  input  [7:0]  ddr4ip_dut_axi_awlen,
  input  [0:0]  ddr4ip_dut_axi_awlock,
  input  [2:0]  ddr4ip_dut_axi_awprot,
  input  [3:0]  ddr4ip_dut_axi_awqos,
  output        ddr4ip_dut_axi_awready,
  input  [3:0]  ddr4ip_dut_axi_awregion,
  input  [2:0]  ddr4ip_dut_axi_awsize,
  input         ddr4ip_dut_axi_awvalid,
  input  [255:0] ddr4ip_dut_axi_wdata,
  input         ddr4ip_dut_axi_wlast,
  output        ddr4ip_dut_axi_wready,
  input  [31:0] ddr4ip_dut_axi_wstrb,
  input         ddr4ip_dut_axi_wvalid,
  output [13:0] ddr4ip_dut_axi_bid,
  input         ddr4ip_dut_axi_bready,
  output [1:0]  ddr4ip_dut_axi_bresp,
  output        ddr4ip_dut_axi_bvalid,
  input  [33:0] ddr4ip_dut_axi_araddr,
  input  [1:0]  ddr4ip_dut_axi_arburst,
  input  [3:0]  ddr4ip_dut_axi_arcache,
  input  [13:0] ddr4ip_dut_axi_arid,
  input  [7:0]  ddr4ip_dut_axi_arlen,
  input  [0:0]  ddr4ip_dut_axi_arlock,
  input  [2:0]  ddr4ip_dut_axi_arprot,
  input  [3:0]  ddr4ip_dut_axi_arqos,
  output        ddr4ip_dut_axi_arready,
  input  [3:0]  ddr4ip_dut_axi_arregion,
  input  [2:0]  ddr4ip_dut_axi_arsize,
  input         ddr4ip_dut_axi_arvalid,
  output [255:0] ddr4ip_dut_axi_rdata,
  output [13:0] ddr4ip_dut_axi_rid,
  output        ddr4ip_dut_axi_rlast,
  input         ddr4ip_dut_axi_rready,
  output [1:0]  ddr4ip_dut_axi_rresp,
  output        ddr4ip_dut_axi_rvalid,
  input         ddr4ip_dut_axi_aclk_en,
  output        ddr4ip_ddr4_user_clk,
  output        ddr4ip_ddr4_user_rst,
  input  [255:0] sysbus_ghbd_i,
  output [255:0] sysbus_ghbd_o,
  output        FP_CLK_200M_P,
  output        FP_CLK_200M_N,
  output        DDR4_DIMM_ACT_N,
  output [16:0] DDR4_DIMM_A,
  output [1:0]  DDR4_DIMM_BA,
  output [1:0]  DDR4_DIMM_BG,
  output [0:0]  DDR4_DIMM_CK_N,
  output [0:0]  DDR4_DIMM_CK_P,
  output [0:0]  DDR4_DIMM_CKE,
  output [0:0]  DDR4_DIMM_CS_N,
  output [0:0]  DDR4_DIMM_ODT,
  output        DDR4_DIMM_RST_B,
  inout  [7:0]  DDR4_DIMM_DM,
  inout  [63:0] DDR4_DIMM_DQ,
  inout  [7:0]  DDR4_DIMM_DQS_N,
  inout  [7:0]  DDR4_DIMM_DQS_P
);
endmodule
`endif

`endif
