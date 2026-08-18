// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1.1 (lin64) Build 6233196 Thu Sep 11 21:27:11 MDT 2025
// Date        : Mon Aug 17 17:34:16 2026
// Host        : open03.kxhcluster.com running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -mode synth_stub uvw_axi4_to_ddr4_stub.v -force
// Design      : uvw_axi4_to_ddr4
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvp1902-vsva6865-2MP-e-S
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* RDI_HAS_ANNOTATION = "1" *) (* p_ecc_en = "0" *) (* p_user_addr_width = "34" *) 
(* p_user_data_width = "256" *) (* p_user_id_width = "14" *) 
(* uv_axi2ddr = "ADDR_WIDTH:34,DATA_WIDTH:256" *)
(* UV_HW_IP = "type:<DCMEM>,ADDR_WIDTH:<34>,DATA_WIDTH:<256>,toSysbus:<uvw_generalHBD>,toFPGA:<UV_APCP_DDR4>" *)
module uvw_axi4_to_ddr4(ddr4ip_dut_axi_aclk, 
  ddr4ip_dut_axi_aresetn, ddr4ip_dut_axi_awaddr, ddr4ip_dut_axi_awburst, 
  ddr4ip_dut_axi_awcache, ddr4ip_dut_axi_awid, ddr4ip_dut_axi_awlen, 
  ddr4ip_dut_axi_awlock, ddr4ip_dut_axi_awprot, ddr4ip_dut_axi_awqos, 
  ddr4ip_dut_axi_awready, ddr4ip_dut_axi_awregion, ddr4ip_dut_axi_awsize, 
  ddr4ip_dut_axi_awvalid, ddr4ip_dut_axi_wdata, ddr4ip_dut_axi_wlast, 
  ddr4ip_dut_axi_wready, ddr4ip_dut_axi_wstrb, ddr4ip_dut_axi_wvalid, ddr4ip_dut_axi_bid, 
  ddr4ip_dut_axi_bready, ddr4ip_dut_axi_bresp, ddr4ip_dut_axi_bvalid, 
  ddr4ip_dut_axi_araddr, ddr4ip_dut_axi_arburst, ddr4ip_dut_axi_arcache, 
  ddr4ip_dut_axi_arid, ddr4ip_dut_axi_arlen, ddr4ip_dut_axi_arlock, 
  ddr4ip_dut_axi_arprot, ddr4ip_dut_axi_arqos, ddr4ip_dut_axi_arready, 
  ddr4ip_dut_axi_arregion, ddr4ip_dut_axi_arsize, ddr4ip_dut_axi_arvalid, 
  ddr4ip_dut_axi_rdata, ddr4ip_dut_axi_rid, ddr4ip_dut_axi_rlast, ddr4ip_dut_axi_rready, 
  ddr4ip_dut_axi_rresp, ddr4ip_dut_axi_rvalid, ddr4ip_dut_axi_aclk_en, sysbus_ghbd_i, 
  sysbus_ghbd_o, FP_CLK_200M_P, FP_CLK_200M_N, DDR4_DIMM_ACT_N, DDR4_DIMM_A, DDR4_DIMM_BA, 
  DDR4_DIMM_BG, DDR4_DIMM_CK_N, DDR4_DIMM_CK_P, DDR4_DIMM_CKE, DDR4_DIMM_CS_N, DDR4_DIMM_ODT, 
  DDR4_DIMM_RST_B, DDR4_DIMM_DM, DDR4_DIMM_DQ, DDR4_DIMM_DQS_N, DDR4_DIMM_DQS_P)
/* synthesis syn_black_box black_box_pad_pin="ddr4ip_dut_axi_aresetn,ddr4ip_dut_axi_awaddr[33:0],ddr4ip_dut_axi_awburst[1:0],ddr4ip_dut_axi_awcache[3:0],ddr4ip_dut_axi_awid[13:0],ddr4ip_dut_axi_awlen[7:0],ddr4ip_dut_axi_awlock[0:0],ddr4ip_dut_axi_awprot[2:0],ddr4ip_dut_axi_awqos[3:0],ddr4ip_dut_axi_awready,ddr4ip_dut_axi_awregion[3:0],ddr4ip_dut_axi_awsize[2:0],ddr4ip_dut_axi_awvalid,ddr4ip_dut_axi_wdata[255:0],ddr4ip_dut_axi_wlast,ddr4ip_dut_axi_wready,ddr4ip_dut_axi_wstrb[31:0],ddr4ip_dut_axi_wvalid,ddr4ip_dut_axi_bid[13:0],ddr4ip_dut_axi_bready,ddr4ip_dut_axi_bresp[1:0],ddr4ip_dut_axi_bvalid,ddr4ip_dut_axi_araddr[33:0],ddr4ip_dut_axi_arburst[1:0],ddr4ip_dut_axi_arcache[3:0],ddr4ip_dut_axi_arid[13:0],ddr4ip_dut_axi_arlen[7:0],ddr4ip_dut_axi_arlock[0:0],ddr4ip_dut_axi_arprot[2:0],ddr4ip_dut_axi_arqos[3:0],ddr4ip_dut_axi_arready,ddr4ip_dut_axi_arregion[3:0],ddr4ip_dut_axi_arsize[2:0],ddr4ip_dut_axi_arvalid,ddr4ip_dut_axi_rdata[255:0],ddr4ip_dut_axi_rid[13:0],ddr4ip_dut_axi_rlast,ddr4ip_dut_axi_rready,ddr4ip_dut_axi_rresp[1:0],ddr4ip_dut_axi_rvalid,ddr4ip_dut_axi_aclk_en,sysbus_ghbd_i[255:0],sysbus_ghbd_o[255:0],FP_CLK_200M_P,FP_CLK_200M_N,DDR4_DIMM_ACT_N,DDR4_DIMM_A[16:0],DDR4_DIMM_BA[1:0],DDR4_DIMM_BG[1:0],DDR4_DIMM_CK_N[1:0],DDR4_DIMM_CK_P[1:0],DDR4_DIMM_CKE[1:0],DDR4_DIMM_CS_N[1:0],DDR4_DIMM_ODT[1:0],DDR4_DIMM_RST_B,DDR4_DIMM_DM[8:0],DDR4_DIMM_DQ[71:0],DDR4_DIMM_DQS_N[8:0],DDR4_DIMM_DQS_P[8:0]" */
/* synthesis syn_force_seq_prim="ddr4ip_dut_axi_aclk" */;
  input ddr4ip_dut_axi_aclk /* synthesis syn_isclock = 1 */;
  input ddr4ip_dut_axi_aresetn;
  input [33:0]ddr4ip_dut_axi_awaddr;
  input [1:0]ddr4ip_dut_axi_awburst;
  input [3:0]ddr4ip_dut_axi_awcache;
  input [13:0]ddr4ip_dut_axi_awid;
  input [7:0]ddr4ip_dut_axi_awlen;
  input [0:0]ddr4ip_dut_axi_awlock;
  input [2:0]ddr4ip_dut_axi_awprot;
  input [3:0]ddr4ip_dut_axi_awqos;
  output ddr4ip_dut_axi_awready;
  input [3:0]ddr4ip_dut_axi_awregion;
  input [2:0]ddr4ip_dut_axi_awsize;
  input ddr4ip_dut_axi_awvalid;
  input [255:0]ddr4ip_dut_axi_wdata;
  input ddr4ip_dut_axi_wlast;
  output ddr4ip_dut_axi_wready;
  input [31:0]ddr4ip_dut_axi_wstrb;
  input ddr4ip_dut_axi_wvalid;
  output [13:0]ddr4ip_dut_axi_bid;
  input ddr4ip_dut_axi_bready;
  output [1:0]ddr4ip_dut_axi_bresp;
  output ddr4ip_dut_axi_bvalid;
  input [33:0]ddr4ip_dut_axi_araddr;
  input [1:0]ddr4ip_dut_axi_arburst;
  input [3:0]ddr4ip_dut_axi_arcache;
  input [13:0]ddr4ip_dut_axi_arid;
  input [7:0]ddr4ip_dut_axi_arlen;
  input [0:0]ddr4ip_dut_axi_arlock;
  input [2:0]ddr4ip_dut_axi_arprot;
  input [3:0]ddr4ip_dut_axi_arqos;
  output ddr4ip_dut_axi_arready;
  input [3:0]ddr4ip_dut_axi_arregion;
  input [2:0]ddr4ip_dut_axi_arsize;
  input ddr4ip_dut_axi_arvalid;
  output [255:0]ddr4ip_dut_axi_rdata;
  output [13:0]ddr4ip_dut_axi_rid;
  output ddr4ip_dut_axi_rlast;
  input ddr4ip_dut_axi_rready;
  output [1:0]ddr4ip_dut_axi_rresp;
  output ddr4ip_dut_axi_rvalid;
  input ddr4ip_dut_axi_aclk_en;
  input [255:0]sysbus_ghbd_i;
  output [255:0]sysbus_ghbd_o;
  input FP_CLK_200M_P;
  input FP_CLK_200M_N;
  output DDR4_DIMM_ACT_N;
  output [16:0]DDR4_DIMM_A;
  output [1:0]DDR4_DIMM_BA;
  output [1:0]DDR4_DIMM_BG;
  output [1:0]DDR4_DIMM_CK_N;
  output [1:0]DDR4_DIMM_CK_P;
  output [1:0]DDR4_DIMM_CKE;
  output [1:0]DDR4_DIMM_CS_N;
  output [1:0]DDR4_DIMM_ODT;
  output DDR4_DIMM_RST_B;
  inout [8:0]DDR4_DIMM_DM;
  inout [71:0]DDR4_DIMM_DQ;
  inout [8:0]DDR4_DIMM_DQS_N;
  inout [8:0]DDR4_DIMM_DQS_P;


`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Univista"
`pragma protect encrypt_agent_info = "univista-isg uv_enc 2023.08.25-0fea5ec"
`pragma protect data_method = "aes128-cbc"

`pragma protect key_keyowner = "Univista"
`pragma protect key_keyname = "UV-ENC-RSA-1"
`pragma protect key_method = "RSA"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
PfZSMlwY0/PT3AyeTNox03PSWcea5/WgEsyNRml83jLvaspFB9v9Yodf0Z8JKjr/nYlADIvtFITi
6WSzs6bSl3kgfhX0tI+vW14fjdrDVKFHeM8kwehtgCu67hffov3csGs9EsRcINS2nbNMjAyJ4RpT
i/IQVy7bDAHPD73RJtbq3kqa452l5mONxLKtGdaqFsw40qrO3VbgXziCdSFwrssEZlNyLjnzgvVI
i93ZUX+5PJugPz9p1Jt8/yVZQJ1ntVG6dqhOdqwSSz5M9K9QB2Qki13w3rsNFjJN+qq3YujCq+gu
jLzPA7rNMUo3/tMyImRCCqyHb8qixF05hu815A==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 528)
`pragma protect data_block
P7q6jql6BIwxKLiHFn+umf6ugxDz8HUZ1P6bpeb+GgmeZU0koHdcoMWIMV5z9SG+45SFf4iOFX0r
Kgrp9fCrrmYkZ6KjXRE2sbyGzXE12CE6SDstvxYEglktrf910SNa4OMjVRivO2xHGDIqUUJxVxnN
XeziDez9IidwJbfkcyGcjQm4/C01E9xPyH29bw/vNl4INF7CSWEbnfSV/Z99vIgNg7VFGlik3nPh
bGxPgjtPAlx41t/H2fdbBx58WII22I4U8qangPiG4SjfyX8Ss7iNIqx4x2mQzZQvOAHZMD5KFhVh
IzVJkF+Y1hBHxsHabWLsPyYS0PcjQry2pe8NGiedwHKj5q/IcJM9liB4ekheLACNHNDVOLNPhM5w
r3ZOM4boWDaoYfEUPlUX761aR6h/dbFe95Ev9bidPB03egw+8E9WYT8WKhNfsMIs8D8L1KSJtItg
mn+11whWEr0hvbvdwUEbx7ANB/5uDxHjh4nrLuBlWOx9PkymoOHvV4NzJzYwaG4idXV9rTrE9FSd
nnGnViD6YE+pZe4B5ajAYo+D/TP1GMP02vZzzCiEVIrkJiE3KHt34DAnLRfU6wWZuc1gHiRTZFeQ
0eQWPYheJzNzgpsscaPKAuOhs8y1t+W56Pp/bTmqfXgy3x+wNYXBrdCPPTeMtVgS8GgrIu/Mf14A
+ErDLMkeIDqUhQ4Ojpb67DTpQk6taVD95uH5sMEgwA==

`pragma protect end_protected

endmodule
