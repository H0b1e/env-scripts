// =================================================================================================
// File Name        : uvw_axi4_to_ddr4
// Module           : uvw_axi4_to_ddr4
// Function         : uvw_axi4_to_ddr4
// Type             : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date                 Coded by         Contents
// 0.1.0      2022/1/24            wang.dw
// 0.2.0      2022/5/20            Jin Liu          update for u2 interface
// 0.3.0      2023/7/9             Kai Zhang        update for sysbus3.0 interface
// 0.3.0      2024/6/18            Kai Zhang        add ecc enable option
// 0.4.0      2025/1/13            Bin Gu           update for sysbus4.0 interface/V1 platform
// =================================================================================================
// End Revision
// =================================================================================================
`define AXI4_ID_WIDTH 8
`define AXI4_ADDR_WIDTH 35
`define AXI4_DATA_WIDTH 512
`define DDR_ECC_EN 1

// =================================================================================================
// RTL Header
// =================================================================================================
module uvw_axi4_to_ddr4#(
    parameter                           p_user_id_width     = `AXI4_ID_WIDTH    , // user logic id size
    parameter                           p_user_addr_width   = `AXI4_ADDR_WIDTH  , // user logic addr size
    parameter                           p_user_data_width   = `AXI4_DATA_WIDTH  , // user logic data size
    parameter                           p_ecc_en            = `DDR_ECC_EN         // 1 => ecc enable,0 => ecc disable      
    ) (     
    // User logic
    ddr4ip_dut_axi_aclk                 , // (i)
    ddr4ip_dut_axi_aresetn              , // (i)
    ddr4ip_dut_axi_awaddr               , // (i)
    ddr4ip_dut_axi_awburst              , // (i)
    ddr4ip_dut_axi_awcache              , // (i)
    ddr4ip_dut_axi_awid                 , // (i)
    ddr4ip_dut_axi_awlen                , // (i)
    ddr4ip_dut_axi_awlock               , // (i)
    ddr4ip_dut_axi_awprot               , // (i)
    ddr4ip_dut_axi_awqos                , // (i)
    ddr4ip_dut_axi_awready              , // (o)
    ddr4ip_dut_axi_awregion             , // (i)
    ddr4ip_dut_axi_awsize               , // (i)
    ddr4ip_dut_axi_awvalid              , // (i)
    ddr4ip_dut_axi_wdata                , // (i)
    ddr4ip_dut_axi_wlast                , // (i)
    ddr4ip_dut_axi_wready               , // (o)
    ddr4ip_dut_axi_wstrb                , // (i)
    ddr4ip_dut_axi_wvalid               , // (i)
    ddr4ip_dut_axi_bid                  , // (o)
    ddr4ip_dut_axi_bready               , // (i)
    ddr4ip_dut_axi_bresp                , // (o)
    ddr4ip_dut_axi_bvalid               , // (o)
    ddr4ip_dut_axi_araddr               , // (i)
    ddr4ip_dut_axi_arburst              , // (i)
    ddr4ip_dut_axi_arcache              , // (i)
    ddr4ip_dut_axi_arid                 , // (i)
    ddr4ip_dut_axi_arlen                , // (i)
    ddr4ip_dut_axi_arlock               , // (i)
    ddr4ip_dut_axi_arprot               , // (i)
    ddr4ip_dut_axi_arqos                , // (i)
    ddr4ip_dut_axi_arready              , // (o)
    ddr4ip_dut_axi_arregion             , // (i)
    ddr4ip_dut_axi_arsize               , // (i)
    ddr4ip_dut_axi_arvalid              , // (i)
    ddr4ip_dut_axi_rdata                , // (o)
    ddr4ip_dut_axi_rid                  , // (o)
    ddr4ip_dut_axi_rlast                , // (o)
    ddr4ip_dut_axi_rready               , // (i)
    ddr4ip_dut_axi_rresp                , // (o)
    ddr4ip_dut_axi_rvalid               , // (o)
    ddr4ip_dut_axi_aclk_en              , // (i)
    // System bus
    sysbus_ghbd_i                       , // (i)
    sysbus_ghbd_o                       , // (o)
     // DDR4 mig
    FP_CLK_200M_P                       , // (i)
    FP_CLK_200M_N                       , // (i)
    DDR4_DIMM_ACT_N                     , // (o)
    DDR4_DIMM_A                         , // (o)
    DDR4_DIMM_BA                        , // (o)
    DDR4_DIMM_BG                        , // (o)
    DDR4_DIMM_CK_N                      , // (o)
    DDR4_DIMM_CK_P                      , // (o)
    DDR4_DIMM_CKE                       , // (o)
    DDR4_DIMM_CS_N                      , // (o)
    DDR4_DIMM_ODT                       , // (o)
    DDR4_DIMM_RST_B                     , // (o)
    DDR4_DIMM_DM                        , // (io)
    DDR4_DIMM_DQ                        , // (io)
    DDR4_DIMM_DQS_N                     , // (io)
    DDR4_DIMM_DQS_P                       // (io)
) ;
    // User logic
    input                               ddr4ip_dut_axi_aclk                     ; // (i)
    input                               ddr4ip_dut_axi_aresetn                  ; // (i)
    input   [p_user_addr_width-1:0]     ddr4ip_dut_axi_awaddr                   ; // (i)
    input   [  1:0]                     ddr4ip_dut_axi_awburst                  ; // (i)
    input   [  3:0]                     ddr4ip_dut_axi_awcache                  ; // (i)
    input   [p_user_id_width-1:0]       ddr4ip_dut_axi_awid                     ; // (i)
    input   [  7:0]                     ddr4ip_dut_axi_awlen                    ; // (i)
    input   [  0:0]                     ddr4ip_dut_axi_awlock                   ; // (i)
    input   [  2:0]                     ddr4ip_dut_axi_awprot                   ; // (i)
    input   [  3:0]                     ddr4ip_dut_axi_awqos                    ; // (i)
    output                              ddr4ip_dut_axi_awready                  ; // (o)
    input   [  3:0]                     ddr4ip_dut_axi_awregion                 ; // (i)
    input   [  2:0]                     ddr4ip_dut_axi_awsize                   ; // (i)
    input                               ddr4ip_dut_axi_awvalid                  ; // (i)
    input   [p_user_data_width-1:0]     ddr4ip_dut_axi_wdata                    ; // (i)
    input                               ddr4ip_dut_axi_wlast                    ; // (i)
    output                              ddr4ip_dut_axi_wready                   ; // (o)
    input   [p_user_data_width/8-1:0]   ddr4ip_dut_axi_wstrb                    ; // (i)
    input                               ddr4ip_dut_axi_wvalid                   ; // (i)
    output  [p_user_id_width-1:0]       ddr4ip_dut_axi_bid                      ; // (o)
    input                               ddr4ip_dut_axi_bready                   ; // (i)
    output  [  1:0]                     ddr4ip_dut_axi_bresp                    ; // (o)
    output                              ddr4ip_dut_axi_bvalid                   ; // (o)
    input   [p_user_addr_width-1:0]     ddr4ip_dut_axi_araddr                   ; // (i)
    input   [  1:0]                     ddr4ip_dut_axi_arburst                  ; // (i)
    input   [  3:0]                     ddr4ip_dut_axi_arcache                  ; // (i)
    input   [p_user_id_width-1:0]       ddr4ip_dut_axi_arid                     ; // (i)
    input   [  7:0]                     ddr4ip_dut_axi_arlen                    ; // (i)
    input   [  0:0]                     ddr4ip_dut_axi_arlock                   ; // (i)
    input   [  2:0]                     ddr4ip_dut_axi_arprot                   ; // (i)
    input   [  3:0]                     ddr4ip_dut_axi_arqos                    ; // (i)
    output                              ddr4ip_dut_axi_arready                  ; // (o)
    input   [  3:0]                     ddr4ip_dut_axi_arregion                 ; // (i)
    input   [  2:0]                     ddr4ip_dut_axi_arsize                   ; // (i)
    input                               ddr4ip_dut_axi_arvalid                  ; // (i)
    output  [p_user_data_width-1:0]     ddr4ip_dut_axi_rdata                    ; // (o)
    output  [p_user_id_width-1:0]       ddr4ip_dut_axi_rid                      ; // (o)
    output                              ddr4ip_dut_axi_rlast                    ; // (o)
    input                               ddr4ip_dut_axi_rready                   ; // (i)
    output  [  1:0]                     ddr4ip_dut_axi_rresp                    ; // (o)
    output                              ddr4ip_dut_axi_rvalid                   ; // (o)
    input                               ddr4ip_dut_axi_aclk_en                  ; // (i)

    // System bus
    output  [255:0]                     sysbus_ghbd_o                           ; // (o)
    input   [255:0]                     sysbus_ghbd_i                           ; // (i)

    // DDR4 mig
    input                               FP_CLK_200M_P                          ; // (i)
    input                               FP_CLK_200M_N                          ; // (i)
    output                              DDR4_DIMM_ACT_N                         ; // (o)
    output  [16:0]                      DDR4_DIMM_A                             ; // (o)
    output  [ 1:0]                      DDR4_DIMM_BA                            ; // (o)
    output  [ 1:0]                      DDR4_DIMM_BG                            ; // (o)
    output  [ 1:0]                      DDR4_DIMM_CK_N                          ; // (o)
    output  [ 1:0]                      DDR4_DIMM_CK_P                          ; // (o)
    output  [ 1:0]                      DDR4_DIMM_CKE                           ; // (o)
    output  [ 1:0]                      DDR4_DIMM_CS_N                          ; // (o)
    output  [ 1:0]                      DDR4_DIMM_ODT                           ; // (o)
    output                              DDR4_DIMM_RST_B                         ; // (o)
    inout   [ 8:0]                      DDR4_DIMM_DM                            ; // (io)
    inout   [71:0]                      DDR4_DIMM_DQ                            ; // (io)
    inout   [ 8:0]                      DDR4_DIMM_DQS_N                         ; // (io)
    inout   [ 8:0]                      DDR4_DIMM_DQS_P                         ; // (io)

uvw_axi4_to_ddr4_secondary_top #(
    .p_user_id_width                    (p_user_id_width                        ), // user logic id size
    .p_user_addr_width                  (p_user_addr_width                      ), // user logic addr size
    .p_user_data_width                  (p_user_data_width                      ), // user logic data size
    .p_ecc_en                           (p_ecc_en                               )) 
u_uvw_axi4_to_ddr4_secondary_top(
    // User logic
    .ddr4ip_dut_axi_aclk                (ddr4ip_dut_axi_aclk                    ), // (i)
    .ddr4ip_dut_axi_aresetn             (ddr4ip_dut_axi_aresetn                 ), // (i)
    .ddr4ip_dut_axi_awaddr              (ddr4ip_dut_axi_awaddr                  ), // (i)
    .ddr4ip_dut_axi_awburst             (ddr4ip_dut_axi_awburst                 ), // (i)
    .ddr4ip_dut_axi_awcache             (ddr4ip_dut_axi_awcache                 ), // (i)
    .ddr4ip_dut_axi_awid                (ddr4ip_dut_axi_awid                    ), // (i)
    .ddr4ip_dut_axi_awlen               (ddr4ip_dut_axi_awlen                   ), // (i)
    .ddr4ip_dut_axi_awlock              (ddr4ip_dut_axi_awlock                  ), // (i)
    .ddr4ip_dut_axi_awprot              (ddr4ip_dut_axi_awprot                  ), // (i)
    .ddr4ip_dut_axi_awqos               (ddr4ip_dut_axi_awqos                   ), // (i)
    .ddr4ip_dut_axi_awready             (ddr4ip_dut_axi_awready                 ), // (o)
    .ddr4ip_dut_axi_awregion            (ddr4ip_dut_axi_awregion                ), // (i)
    .ddr4ip_dut_axi_awsize              (ddr4ip_dut_axi_awsize                  ), // (i)
    .ddr4ip_dut_axi_awvalid             (ddr4ip_dut_axi_awvalid                 ), // (i)
    .ddr4ip_dut_axi_wdata               (ddr4ip_dut_axi_wdata                   ), // (i)
    .ddr4ip_dut_axi_wlast               (ddr4ip_dut_axi_wlast                   ), // (i)
    .ddr4ip_dut_axi_wready              (ddr4ip_dut_axi_wready                  ), // (o)
    .ddr4ip_dut_axi_wstrb               (ddr4ip_dut_axi_wstrb                   ), // (i)
    .ddr4ip_dut_axi_wvalid              (ddr4ip_dut_axi_wvalid                  ), // (i)
    .ddr4ip_dut_axi_bid                 (ddr4ip_dut_axi_bid                     ), // (o)
    .ddr4ip_dut_axi_bready              (ddr4ip_dut_axi_bready                  ), // (i)
    .ddr4ip_dut_axi_bresp               (ddr4ip_dut_axi_bresp                   ), // (o)
    .ddr4ip_dut_axi_bvalid              (ddr4ip_dut_axi_bvalid                  ), // (o)
    .ddr4ip_dut_axi_araddr              (ddr4ip_dut_axi_araddr                  ), // (i)
    .ddr4ip_dut_axi_arburst             (ddr4ip_dut_axi_arburst                 ), // (i)
    .ddr4ip_dut_axi_arcache             (ddr4ip_dut_axi_arcache                 ), // (i)
    .ddr4ip_dut_axi_arid                (ddr4ip_dut_axi_arid                    ), // (i)
    .ddr4ip_dut_axi_arlen               (ddr4ip_dut_axi_arlen                   ), // (i)
    .ddr4ip_dut_axi_arlock              (ddr4ip_dut_axi_arlock                  ), // (i)
    .ddr4ip_dut_axi_arprot              (ddr4ip_dut_axi_arprot                  ), // (i)
    .ddr4ip_dut_axi_arqos               (ddr4ip_dut_axi_arqos                   ), // (i)
    .ddr4ip_dut_axi_arready             (ddr4ip_dut_axi_arready                 ), // (o)
    .ddr4ip_dut_axi_arregion            (ddr4ip_dut_axi_arregion                ), // (i)
    .ddr4ip_dut_axi_arsize              (ddr4ip_dut_axi_arsize                  ), // (i)
    .ddr4ip_dut_axi_arvalid             (ddr4ip_dut_axi_arvalid                 ), // (i)
    .ddr4ip_dut_axi_rdata               (ddr4ip_dut_axi_rdata                   ), // (o)
    .ddr4ip_dut_axi_rid                 (ddr4ip_dut_axi_rid                     ), // (o)
    .ddr4ip_dut_axi_rlast               (ddr4ip_dut_axi_rlast                   ), // (o)
    .ddr4ip_dut_axi_rready              (ddr4ip_dut_axi_rready                  ), // (i)
    .ddr4ip_dut_axi_rresp               (ddr4ip_dut_axi_rresp                   ), // (o)
    .ddr4ip_dut_axi_rvalid              (ddr4ip_dut_axi_rvalid                  ), // (o)
    .ddr4ip_dut_axi_aclk_en             (ddr4ip_dut_axi_aclk_en                 ), // (i)

    // System bus
    .sysbus_ghbd_i                      (sysbus_ghbd_i                          ), // (i)
    .sysbus_ghbd_o                      (sysbus_ghbd_o                          ), // (o)

    .FP_CLK_200M_P                      (FP_CLK_200M_P                          ),                  
    .FP_CLK_200M_N                      (FP_CLK_200M_N                          ),
    .DDR4_DIMM_ACT_N                    (DDR4_DIMM_ACT_N                        ),
    .DDR4_DIMM_A                        (DDR4_DIMM_A                            ),
    .DDR4_DIMM_BA                       (DDR4_DIMM_BA                           ),
    .DDR4_DIMM_BG                       (DDR4_DIMM_BG                           ),
    .DDR4_DIMM_CK_N                     (DDR4_DIMM_CK_N                         ),
    .DDR4_DIMM_CK_P                     (DDR4_DIMM_CK_P                         ),
    .DDR4_DIMM_CKE                      (DDR4_DIMM_CKE                          ),
    .DDR4_DIMM_CS_N                     (DDR4_DIMM_CS_N                         ),
    .DDR4_DIMM_ODT                      (DDR4_DIMM_ODT                          ),
    .DDR4_DIMM_RST_B                    (DDR4_DIMM_RST_B                        ),
    .DDR4_DIMM_DM                       (DDR4_DIMM_DM                           ),
    .DDR4_DIMM_DQ                       (DDR4_DIMM_DQ                           ),
    .DDR4_DIMM_DQS_N                    (DDR4_DIMM_DQS_N                        ),
    .DDR4_DIMM_DQS_P                    (DDR4_DIMM_DQS_P                        )   
);


endmodule



