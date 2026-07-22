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
// =================================================================================================
// End Revision
// =================================================================================================
//`define AXI4_ID_WIDTH 8
//`define AXI4_ADDR_WIDTH 32
//`define AXI4_DATA_WIDTH 256
//`define DDR_ECC_EN 0

// =================================================================================================
// RTL Header
// =================================================================================================
module uvw_axi4_to_ddr4_secondary_top #(
    parameter                           p_user_id_width     = 8    , // user logic id size
    parameter                           p_user_addr_width   = 32   , // user logic addr size
    parameter                           p_user_data_width   = 256  , // user logic data size
    parameter                           p_ecc_en            = 0      // 1 => ecc enable,0 => ecc disable

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
    ddr4ip_ddr4_user_clk                , // (o)
    ddr4ip_ddr4_user_rst                , // (o)

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
    input                               ddr4ip_dut_axi_aclk_en                  ; // (o)
    output                              ddr4ip_ddr4_user_clk                    ; // (o)
    output                              ddr4ip_ddr4_user_rst                    ; // (o)

    // System bus
    output  [255:0]                     sysbus_ghbd_o                           ; // (o)
    input   [255:0]                     sysbus_ghbd_i                           ; // (i)

    // DDR4 mig
    input                               FP_CLK_200M_P                           ; // (i)
    input                               FP_CLK_200M_N                           ; // (i)
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

    //---------------------------------------------------------------------
    // defination of parameters
    //---------------------------------------------------------------------

    //---------------------------------------------------------------------
    // defination of internal signals
    //---------------------------------------------------------------------

    reg                                                     ddr4ip_dut_axi_aresetn_0ff      ;
    reg                                                     ddr4ip_dut_axi_aresetn_1ff      ;
(* dont_touch="true" *)    reg                              ddr4ip_dut_axi_aresetn_2ff      ;
    reg                                                     ddr4ip_dut_axi_aresetn_3ff      ;

    reg                                                     r_dut_wa_buf_wren               ;
    reg     [p_user_id_width+p_user_addr_width+29-1:0]      r_dut_wa_buf_wdat               ;
    wire                                                    s_dut_wa_buf_rden               ;
    wire    [p_user_id_width+p_user_addr_width+29-1:0]      s_dut_wa_buf_rdat               ;
    wire    [  4:0]                                         s_dut_wa_buf_dcnt               ;
    reg                                                     r_dut_wa_buf_full               ;

    reg                                                     r_dut_wd_buf_wren               ;
    reg     [p_user_data_width+p_user_data_width/8+1-1:0]   r_dut_wd_buf_wdat               ;
    wire                                                    s_dut_wd_buf_rden               ;
    wire    [p_user_data_width+p_user_data_width/8+1-1:0]   s_dut_wd_buf_rdat               ;
    wire    [ 10:0]                                         s_dut_wd_buf_dcnt               ;
    reg                                                     r_dut_wd_buf_full               ;

    reg                                                     r_dut_wb_buf_wren               ;
    reg     [p_user_id_width+2-1:0]                         r_dut_wb_buf_wdat               ;
    wire                                                    s_dut_wb_buf_rden               ;
    wire    [p_user_id_width+2-1:0]                         s_dut_wb_buf_rdat               ;
    wire    [  4:0]                                         s_dut_wb_buf_dcnt               ;
    reg                                                     r_dut_wb_buf_full               ;

    reg                                                     r_dut_ra_buf_wren               ;
    reg     [p_user_id_width+p_user_addr_width+29-1:0]      r_dut_ra_buf_wdat               ;
    wire                                                    s_dut_ra_buf_rden               ;
    wire    [p_user_id_width+p_user_addr_width+29-1:0]      s_dut_ra_buf_rdat               ;
    wire    [  4:0]                                         s_dut_ra_buf_dcnt               ;
    reg                                                     r_dut_ra_buf_full               ;

    reg                                                     r_dut_rd_buf_wren               ;
    reg     [p_user_id_width+p_user_data_width+3-1:0]       r_dut_rd_buf_wdat               ;
    wire                                                    s_dut_rd_buf_rden               ;
    wire    [p_user_id_width+p_user_data_width+3-1:0]       s_dut_rd_buf_rdat               ;
    wire    [ 10:0]                                         s_dut_rd_buf_dcnt               ;
    reg                                                     r_dut_rd_buf_full               ;

    wire    [p_user_addr_width-1:0]     s_dut_axi_awaddr                        ;
    wire    [  1:0]                     s_dut_axi_awburst                       ;
    wire    [  3:0]                     s_dut_axi_awcache                       ;
    wire    [p_user_id_width-1:0]       s_dut_axi_awid                          ;
    wire    [  7:0]                     s_dut_axi_awlen                         ;
    wire    [  0:0]                     s_dut_axi_awlock                        ;
    wire    [  2:0]                     s_dut_axi_awprot                        ;
    wire    [  3:0]                     s_dut_axi_awqos                         ;
    wire                                s_dut_axi_awready                       ;
    wire    [  3:0]                     s_dut_axi_awregion                      ;
    wire    [  2:0]                     s_dut_axi_awsize                        ;
    wire                                s_dut_axi_awvalid                       ;
    wire    [p_user_data_width-1:0]     s_dut_axi_wdata                         ;
    wire                                s_dut_axi_wlast                         ;
    wire                                s_dut_axi_wready                        ;
    wire    [p_user_data_width/8-1:0]   s_dut_axi_wstrb                         ;
    wire                                s_dut_axi_wvalid                        ;
    wire    [p_user_id_width-1:0]       s_dut_axi_bid                           ;
    wire                                s_dut_axi_bready                        ;
    wire    [  1:0]                     s_dut_axi_bresp                         ;
    wire                                s_dut_axi_bvalid                        ;
    wire    [p_user_addr_width-1:0]     s_dut_axi_araddr                        ;
    wire    [  1:0]                     s_dut_axi_arburst                       ;
    wire    [  3:0]                     s_dut_axi_arcache                       ;
    wire    [p_user_id_width-1:0]       s_dut_axi_arid                          ;
    wire    [  7:0]                     s_dut_axi_arlen                         ;
    wire    [  0:0]                     s_dut_axi_arlock                        ;
    wire    [  2:0]                     s_dut_axi_arprot                        ;
    wire    [  3:0]                     s_dut_axi_arqos                         ;
    wire                                s_dut_axi_arready                       ;
    wire    [  3:0]                     s_dut_axi_arregion                      ;
    wire    [  2:0]                     s_dut_axi_arsize                        ;
    wire                                s_dut_axi_arvalid                       ;
    wire    [p_user_data_width-1:0]     s_dut_axi_rdata                         ;
    wire    [p_user_id_width-1:0]       s_dut_axi_rid                           ;
    wire                                s_dut_axi_rlast                         ;
    wire                                s_dut_axi_rready                        ;
    wire    [  1:0]                     s_dut_axi_rresp                         ;
    wire                                s_dut_axi_rvalid                        ;

    wire                                s_ddr4_user_clk                         ;
    wire                                s_ddr4_user_rst                         ;
    wire                                s_ddr4_user_clk_oddr                    ;

    // For U2
    // system bus interface decode
    // input direction
    wire                                s_ip_clk                                ;
    wire                                s_ip_rst                                ;
    wire                                s_reg_wr_en                             ;
    wire                                s_reg_rd_en                             ;
    wire    [ 15:0]                     s_reg_addr                              ;
    wire    [ 31:0]                     s_reg_wr_data                           ; 
    wire                                s_sbus2ip_tvalid                        ;
    wire                                s_sbus2ip_tlast                         ;
    wire    [  7:0]                     s_sbus2ip_tkeep                         ;
    wire    [ 63:0]                     s_sbus2ip_tdata                         ;
    wire                                s_ip2sbus_tready                        ;
    // output direction
    wire                                s_reg_clk                               ;
    wire                                s_reg_rst                               ;
    wire                                s_ip2sbus_clk                           ;
    wire                                s_ip2sbus_rst                           ;
    wire                                s_intr                                  ;
    wire                                s_reg_wr_resp                           ;
    wire                                s_reg_rd_resp                           ;
    wire    [ 31:0]                     s_reg_rd_data                           ;
    wire                                s_reg_wr_valid                          ;
    wire                                s_reg_rd_valid                          ;
    wire                                s_sbus2ip_tready                        ;
    wire                                s_ip2sbus_tvalid                        ;
    wire                                s_ip2sbus_tlast                         ;
    wire    [  7:0]                     s_ip2sbus_tkeep                         ;
    wire    [ 63:0]                     s_ip2sbus_tdata                         ;


    wire                                s_regm_clk                              ;
    wire                                s_regm_rst                              ;
    wire                                s_stream_clk                            ;
(* MARK_DEBUG="true" *)    wire                                s_stream_rst                            ;

    wire                                s_bus_clear                             ; 
    wire    [ 63:0]                     s_ddr4_start_addr                       ; 
    wire    [ 63:0]                     s_ddr4_size                             ;
    wire                                s_ddr4_wcmd                             ; 
    wire                                s_ddr4_rcmd                             ; 
(* MARK_DEBUG="true" *)    wire                                s_ddr4_rst                              ; 
    wire                                s_ddr4_busy                             ; 
    wire                                s_ddr4_calib_done                       ; 

    wire    [ 63:0]                     s_axi_araddr                            ; 
    wire    [  7:0]                     s_axi_arlen                             ; 
    wire                                s_axi_arvalid                           ;
    wire    [ 63:0]                     s_axi_awaddr                            ;
    wire    [  7:0]                     s_axi_awlen                             ;
    wire                                s_axi_awvalid                           ;
    wire                                s_axi_bready                            ;
    wire                                s_axi_rready                            ;
    wire    [ 63:0]                     s_axi_wdata                             ;
    wire                                s_axi_wlast                             ;
    wire    [  7:0]                     s_axi_wstrb                             ;
    wire                                s_axi_wvalid                            ;
    wire                                s_axi_arready                           ;
    wire                                s_axi_awready                           ;
    wire    [  1:0]                     s_axi_bresp                             ;
    wire                                s_axi_bvalid                            ;
    wire    [ 63:0]                     s_axi_rdata                             ;
    wire                                s_axi_rlast                             ;
    wire    [  1:0]                     s_axi_rresp                             ;
    wire                                s_axi_rvalid                            ;
    wire                                s_axi_wready                            ;
(* MARK_DEBUG="true" *)    wire                                s_axi_resetn                            ;

// add sysbus3.0
    wire    [255:0]                     sysbus_ghbd_i_int                       ;   // From u_sbus_bridge_2 of uvw_sysbus_3p0_2p1_bridge.v
    wire    [255:0]                     sysbus_ghbd_o_int                       ;   // From u_systemif of uvw_sram_systembus_if.v

// =================================================================================================
// rtl body
// =================================================================================================

    assign ddr4ip_ddr4_user_clk = s_ddr4_user_clk   ;
    assign ddr4ip_ddr4_user_rst = s_ddr4_user_rst   ;

    //---------------------------------------------------------------------
    // rstn sync to dut clk
    //---------------------------------------------------------------------
    always @( posedge ddr4ip_dut_axi_aclk ) begin
        if (ddr4ip_dut_axi_aclk_en) begin
            ddr4ip_dut_axi_aresetn_0ff <= ddr4ip_dut_axi_aresetn    ;
            ddr4ip_dut_axi_aresetn_1ff <= ddr4ip_dut_axi_aresetn_0ff;
            ddr4ip_dut_axi_aresetn_2ff <= ddr4ip_dut_axi_aresetn_1ff;
            ddr4ip_dut_axi_aresetn_3ff <= ddr4ip_dut_axi_aresetn_2ff;
        end
    end

    //---------------------------------------------------------------------
    // wa_buf
    //---------------------------------------------------------------------
    assign ddr4ip_dut_axi_awready   = ~r_dut_wa_buf_full ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_wa_buf_wren   <= 1'b0 ;
            r_dut_wa_buf_wdat   <= {p_user_id_width+p_user_addr_width+29{1'b0}} ;
        end else begin
            if ( ddr4ip_dut_axi_aclk_en == 1'b1 ) begin
                r_dut_wa_buf_wren   <= ddr4ip_dut_axi_awvalid & ~r_dut_wa_buf_full ;
                r_dut_wa_buf_wdat   <= {    ddr4ip_dut_axi_awid     ,
                                            ddr4ip_dut_axi_awaddr   ,
                                            ddr4ip_dut_axi_awburst  ,
                                            ddr4ip_dut_axi_awcache  ,
                                            ddr4ip_dut_axi_awlen    ,
                                            ddr4ip_dut_axi_awlock   ,
                                            ddr4ip_dut_axi_awprot   ,
                                            ddr4ip_dut_axi_awqos    ,
                                            ddr4ip_dut_axi_awregion ,
                                            ddr4ip_dut_axi_awsize   } ;
            end else begin
                r_dut_wa_buf_wren   <= 1'b0 ;
                r_dut_wa_buf_wdat   <= r_dut_wa_buf_wdat;
            end


        end
    end

    uvw_axi4_to_ddr4_buf_fwft #(
        .p_data_width           ( p_user_id_width + p_user_addr_width + 29      ) ,
        .p_addr_width           ( 4                                             )
        )
    u_wa_buf (
        .clk                    ( ddr4ip_dut_axi_aclk                           ) , // (i)
        .rst                    ( ~ddr4ip_dut_axi_aresetn_3ff                   ) , // (i)
        .wren                   ( r_dut_wa_buf_wren                             ) , // (i)
        .wdat                   ( r_dut_wa_buf_wdat                             ) , // (i)
        .rden                   ( s_dut_wa_buf_rden                             ) , // (i)
        .rdat                   ( s_dut_wa_buf_rdat                             ) , // (o)
        .dcnt                   ( s_dut_wa_buf_dcnt                             ) , // (o)
        .full                   (                                               ) , // (o)
        .empt                   ( s_dut_wa_buf_empt                             )   // (o)
    ) ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_wa_buf_full   <= 1'b0 ;
        end else begin
            if ( s_dut_wa_buf_dcnt > 5'd10 ) begin
                r_dut_wa_buf_full   <= 1'b1 ;
            end else begin
                r_dut_wa_buf_full   <= 1'b0 ;
            end
        end
    end

    assign s_dut_wa_buf_rden    = ( s_dut_axi_awvalid == 1'b1 && s_dut_axi_awready == 1'b1 ) ? 1'b1 : 1'b0 ;

    assign s_dut_axi_awvalid    = ( s_dut_wa_buf_empt == 1'b0 ) ? 1'b1 : 1'b0 ;
    assign s_dut_axi_awid       = s_dut_wa_buf_rdat[29+p_user_addr_width+p_user_id_width    - 1 :29+p_user_addr_width   ]   ;
    assign s_dut_axi_awaddr     = s_dut_wa_buf_rdat[29+p_user_addr_width                    - 1 :29                     ]   ;
    assign s_dut_axi_awburst    = s_dut_wa_buf_rdat[29                                      - 1 :27                     ]   ;
    assign s_dut_axi_awcache    = s_dut_wa_buf_rdat[27                                      - 1 :23                     ]   ;
    assign s_dut_axi_awlen      = s_dut_wa_buf_rdat[23                                      - 1 :15                     ]   ;
    assign s_dut_axi_awlock     = s_dut_wa_buf_rdat[15                                      - 1 :14                     ]   ;
    assign s_dut_axi_awprot     = s_dut_wa_buf_rdat[14                                      - 1 :11                     ]   ;
    assign s_dut_axi_awqos      = s_dut_wa_buf_rdat[11                                      - 1 : 7                     ]   ;
    assign s_dut_axi_awregion   = s_dut_wa_buf_rdat[ 7                                      - 1 : 3                     ]   ;
    assign s_dut_axi_awsize     = s_dut_wa_buf_rdat[ 3                                      - 1 : 0                     ]   ;

    //---------------------------------------------------------------------
    // wd_buf
    //---------------------------------------------------------------------
    assign ddr4ip_dut_axi_wready    = ~r_dut_wd_buf_full ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_wd_buf_wren   <= 1'b0 ;
            r_dut_wd_buf_wdat   <= 'b0 ;
        end else begin
            if ( ddr4ip_dut_axi_aclk_en == 1'b1 ) begin
                r_dut_wd_buf_wren   <= ddr4ip_dut_axi_wvalid & ~r_dut_wd_buf_full ;
                r_dut_wd_buf_wdat   <= {    ddr4ip_dut_axi_wstrb    ,
                                            ddr4ip_dut_axi_wdata    ,
                                            ddr4ip_dut_axi_wlast    } ;
            end else begin
                r_dut_wd_buf_wren   <= 1'b0 ;
                r_dut_wd_buf_wdat   <= r_dut_wd_buf_wdat;
            end


        end
    end

    uvw_axi4_to_ddr4_buf_fwft #(
        .p_data_width           ( p_user_data_width + p_user_data_width/8 + 1   ) ,
        .p_addr_width           ( 10                                            )
        )
    u_wd_buf (
        .clk                    ( ddr4ip_dut_axi_aclk                           ) , // (i)
        .rst                    ( ~ddr4ip_dut_axi_aresetn_3ff                   ) , // (i)
        .wren                   ( r_dut_wd_buf_wren                             ) , // (i)
        .wdat                   ( r_dut_wd_buf_wdat                             ) , // (i)
        .rden                   ( s_dut_wd_buf_rden                             ) , // (i)
        .rdat                   ( s_dut_wd_buf_rdat                             ) , // (o)
        .dcnt                   ( s_dut_wd_buf_dcnt                             ) , // (o)
        .full                   (                                               ) , // (o)
        .empt                   ( s_dut_wd_buf_empt                             )   // (o)
    ) ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_wd_buf_full   <= 1'b0 ;
        end else begin
            if ( s_dut_wd_buf_dcnt > 11'd1000 ) begin
                r_dut_wd_buf_full   <= 1'b1 ;
            end else begin
                r_dut_wd_buf_full   <= 1'b0 ;
            end
        end
    end

    assign s_dut_wd_buf_rden    = ( s_dut_axi_wvalid == 1'b1 && s_dut_axi_wready == 1'b1 ) ? 1'b1 : 1'b0 ;

    assign s_dut_axi_wvalid     = ( s_dut_wd_buf_empt == 1'b0 ) ? 1'b1 : 1'b0 ;
    assign s_dut_axi_wstrb      = s_dut_wd_buf_rdat[1+p_user_data_width+(p_user_data_width/8)-1 : 1+p_user_data_width    ]   ;
    assign s_dut_axi_wdata      = s_dut_wd_buf_rdat[1+p_user_data_width                     - 1 : 1                      ]   ;
    assign s_dut_axi_wlast      = s_dut_wd_buf_rdat[0]   ;

    //---------------------------------------------------------------------
    // wb_buf
    //---------------------------------------------------------------------
    assign s_dut_axi_bready     = ~r_dut_wb_buf_full ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_wb_buf_wren   <= 1'b0 ;
            r_dut_wb_buf_wdat   <= 'b0 ;
        end else begin
            r_dut_wb_buf_wren  <= s_dut_axi_bvalid & ~r_dut_wb_buf_full ;
            r_dut_wb_buf_wdat   <= {    s_dut_axi_bid       ,
                                        s_dut_axi_bresp     } ;
        end
    end

    uvw_axi4_to_ddr4_buf_fwft #(
        .p_data_width           ( p_user_id_width + 2           ) ,
        .p_addr_width           ( 4                             )
        )
    u_wb_buf (
        .clk                    ( ddr4ip_dut_axi_aclk           ) , // (i)
        .rst                    ( ~ddr4ip_dut_axi_aresetn_3ff   ) , // (i)
        .wren                   ( r_dut_wb_buf_wren             ) , // (i)
        .wdat                   ( r_dut_wb_buf_wdat             ) , // (i)
        .rden                   ( s_dut_wb_buf_rden             ) , // (i)
        .rdat                   ( s_dut_wb_buf_rdat             ) , // (o)
        .dcnt                   ( s_dut_wb_buf_dcnt             ) , // (o)
        .full                   (                               ) , // (o)
        .empt                   ( s_dut_wb_buf_empt             )   // (o)
    ) ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_wb_buf_full   <= 1'b0 ;
        end else begin
            if ( s_dut_wb_buf_dcnt > 5'd10 ) begin
                r_dut_wb_buf_full   <= 1'b1 ;
            end else begin
                r_dut_wb_buf_full   <= 1'b0 ;
            end
        end
    end

    assign s_dut_wb_buf_rden        = ( s_dut_wb_buf_empt == 1'b0 && ddr4ip_dut_axi_bready == 1'b1 && ddr4ip_dut_axi_aclk_en == 1'b1 ) ? 1'b1 : 1'b0 ;

    assign ddr4ip_dut_axi_bvalid    = ( s_dut_wb_buf_empt == 1'b0 ) ? 1'b1 : 1'b0 ;
    assign ddr4ip_dut_axi_bid       = s_dut_wb_buf_rdat[2+p_user_id_width   - 1 : 2 ]   ;
    assign ddr4ip_dut_axi_bresp     = s_dut_wb_buf_rdat[2                   - 1 : 0 ]   ;

    //---------------------------------------------------------------------
    // ra_buf
    //---------------------------------------------------------------------
    assign ddr4ip_dut_axi_arready   = ~r_dut_ra_buf_full ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_ra_buf_wren   <= 1'b0 ;
            r_dut_ra_buf_wdat   <= 'b0 ;
        end else begin
            if ( ddr4ip_dut_axi_aclk_en == 1'b1 ) begin
                r_dut_ra_buf_wren   <= ddr4ip_dut_axi_arvalid & ~r_dut_ra_buf_full ;
                r_dut_ra_buf_wdat   <= {    ddr4ip_dut_axi_arid     ,
                                            ddr4ip_dut_axi_araddr   ,
                                            ddr4ip_dut_axi_arburst  ,
                                            ddr4ip_dut_axi_arcache  ,
                                            ddr4ip_dut_axi_arlen    ,
                                            ddr4ip_dut_axi_arlock   ,
                                            ddr4ip_dut_axi_arprot   ,
                                            ddr4ip_dut_axi_arqos    ,
                                            ddr4ip_dut_axi_arregion ,
                                            ddr4ip_dut_axi_arsize   } ;
            end else begin
                r_dut_ra_buf_wren   <= 1'b0 ;
                r_dut_ra_buf_wdat   <= r_dut_ra_buf_wdat;
            end
        end
    end

    uvw_axi4_to_ddr4_buf_fwft #(
        .p_data_width           ( p_user_id_width + p_user_addr_width + 29      ) ,
        .p_addr_width           ( 4                                             )
        )
    u_ra_buf (
        .clk                    ( ddr4ip_dut_axi_aclk                           ) , // (i)
        .rst                    ( ~ddr4ip_dut_axi_aresetn_3ff                   ) , // (i)
        .wren                   ( r_dut_ra_buf_wren                             ) , // (i)
        .wdat                   ( r_dut_ra_buf_wdat                             ) , // (i)
        .rden                   ( s_dut_ra_buf_rden                             ) , // (i)
        .rdat                   ( s_dut_ra_buf_rdat                             ) , // (o)
        .dcnt                   ( s_dut_ra_buf_dcnt                             ) , // (o)
        .full                   (                                               ) , // (o)
        .empt                   ( s_dut_ra_buf_empt                             )   // (o)
    ) ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_ra_buf_full   <= 1'b0 ;
        end else begin
            if ( s_dut_ra_buf_dcnt > 5'd10 ) begin
                r_dut_ra_buf_full   <= 1'b1 ;
            end else begin
                r_dut_ra_buf_full   <= 1'b0 ;
            end
        end
    end

    assign s_dut_ra_buf_rden    = ( s_dut_axi_arvalid == 1'b1 && s_dut_axi_arready == 1'b1 ) ? 1'b1 : 1'b0 ;

    assign s_dut_axi_arvalid    = ( s_dut_ra_buf_empt == 1'b0 ) ? 1'b1 : 1'b0 ;
    assign s_dut_axi_arid       = s_dut_ra_buf_rdat[29+p_user_addr_width+p_user_id_width    - 1 :29+p_user_addr_width   ]   ;
    assign s_dut_axi_araddr     = s_dut_ra_buf_rdat[29+p_user_addr_width                    - 1 :29                     ]   ;
    assign s_dut_axi_arburst    = s_dut_ra_buf_rdat[29                                      - 1 :27                     ]   ;
    assign s_dut_axi_arcache    = s_dut_ra_buf_rdat[27                                      - 1 :23                     ]   ;
    assign s_dut_axi_arlen      = s_dut_ra_buf_rdat[23                                      - 1 :15                     ]   ;
    assign s_dut_axi_arlock     = s_dut_ra_buf_rdat[15                                      - 1 :14                     ]   ;
    assign s_dut_axi_arprot     = s_dut_ra_buf_rdat[14                                      - 1 :11                     ]   ;
    assign s_dut_axi_arqos      = s_dut_ra_buf_rdat[11                                      - 1 : 7                     ]   ;
    assign s_dut_axi_arregion   = s_dut_ra_buf_rdat[ 7                                      - 1 : 3                     ]   ;
    assign s_dut_axi_arsize     = s_dut_ra_buf_rdat[ 3                                      - 1 : 0                     ]   ;

    //---------------------------------------------------------------------
    // rd_buf
    //---------------------------------------------------------------------
    assign s_dut_axi_rready     = ~r_dut_rd_buf_full ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_rd_buf_wren   <= 1'b0 ;
            r_dut_rd_buf_wdat   <= 'b0 ;
        end else begin
            r_dut_rd_buf_wren  <= s_dut_axi_rvalid & ~r_dut_rd_buf_full ;
            r_dut_rd_buf_wdat   <= {    s_dut_axi_rid       ,
                                        s_dut_axi_rdata     ,
                                        s_dut_axi_rlast     ,
                                        s_dut_axi_rresp     } ;
        end
    end

    uvw_axi4_to_ddr4_buf_fwft #(
        .p_data_width           ( p_user_id_width + p_user_data_width + 3       ) ,
        .p_addr_width           ( 10                                            )
        )
    u_rd_buf (
        .clk                    ( ddr4ip_dut_axi_aclk                           ) , // (i)
        .rst                    ( ~ddr4ip_dut_axi_aresetn_3ff                   ) , // (i)
        .wren                   ( r_dut_rd_buf_wren                             ) , // (i)
        .wdat                   ( r_dut_rd_buf_wdat                             ) , // (i)
        .rden                   ( s_dut_rd_buf_rden                             ) , // (i)
        .rdat                   ( s_dut_rd_buf_rdat                             ) , // (o)
        .dcnt                   ( s_dut_rd_buf_dcnt                             ) , // (o)
        .full                   (                                               ) , // (o)
        .empt                   ( s_dut_rd_buf_empt                             )   // (o)
    ) ;

    always @( posedge ddr4ip_dut_axi_aclk or negedge ddr4ip_dut_axi_aresetn_3ff ) begin
        if ( ddr4ip_dut_axi_aresetn_3ff == 1'b0 ) begin
            r_dut_rd_buf_full   <= 1'b0 ;
        end else begin
            if ( s_dut_rd_buf_dcnt > 11'd1000 ) begin
                r_dut_rd_buf_full   <= 1'b1 ;
            end else begin
                r_dut_rd_buf_full   <= 1'b0 ;
            end
        end
    end

    assign s_dut_rd_buf_rden        = ( s_dut_rd_buf_empt == 1'b0 && ddr4ip_dut_axi_rready == 1'b1 && ddr4ip_dut_axi_aclk_en == 1'b1 ) ? 1'b1 : 1'b0 ;

    assign ddr4ip_dut_axi_rvalid    = ( s_dut_rd_buf_empt == 1'b0 ) ? 1'b1 : 1'b0 ;
    assign ddr4ip_dut_axi_rid       = s_dut_rd_buf_rdat[3+p_user_id_width+p_user_data_width - 1 : 3+p_user_data_width       ]   ;
    assign ddr4ip_dut_axi_rdata     = s_dut_rd_buf_rdat[3+p_user_data_width                 - 1 : 3                         ]   ;
    assign ddr4ip_dut_axi_rlast     = s_dut_rd_buf_rdat[3                                   - 1 : 2                         ]   ;
    assign ddr4ip_dut_axi_rresp     = s_dut_rd_buf_rdat[2                                   - 1 : 0                         ]   ;

    //---------------------------------------------------------------------
    // block design
    //---------------------------------------------------------------------
    // dummy dimm clock for DDR4_DIMM_CK_P/N[1]
    ODDRE1 #(
        .IS_C_INVERTED                      (1'b0                           ), // Optional inversion for C
        .IS_D1_INVERTED                     (1'b0                           ), // Unsupported, do not use
        .IS_D2_INVERTED                     (1'b0                           ), // Unsupported, do not use
        .SIM_DEVICE                         ("ULTRASCALE_PLUS"              ), // Set the device version for simulation functionality (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
        .SRVAL                              (1'b0                           )  // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
    )
    u_oddre1_dimm_ck1 (
        .Q                                  (s_ddr4_user_clk_oddr           ), // 1-bit output: Data output to IOB
        .C                                  (s_ddr4_user_clk                ), // 1-bit input: High-speed clock input
        .D1                                 (1'b1                           ), // 1-bit input: Parallel data input 1
        .D2                                 (1'b0                           ), // 1-bit input: Parallel data input 2
        .SR                                 (1'b0                           )  // 1-bit input: Active-High Async Reset
    );

    OBUFDS #(
        .IOSTANDARD                         ("DEFAULT"                      ), // Specify the output I/O standard
        .SLEW                               ("SLOW"                         )  // Specify the output slew rate
    ) 
    u_obufds_dimm_ck1 (
        .O                                  (DDR4_DIMM_CK_P[1]              ), // Diff_p output (connect directly to top-level port)
        .OB                                 (DDR4_DIMM_CK_N[1]              ), // Diff_n output (connect directly to top-level port)
        .I                                  (s_ddr4_user_clk_oddr           )  // Buffer input
    );

//    assign DDR4_DIMM_CK_N    [1]    = 1'b0 ;
//    assign DDR4_DIMM_CK_P    [1]    = 1'b0 ;
    assign DDR4_DIMM_CKE     [1]    = 1'b0 ;
    assign DDR4_DIMM_CS_N    [1]    = 1'b0 ;
    assign DDR4_DIMM_ODT     [1]    = 1'b0 ;
generate
    if (p_ecc_en == 1'b1) begin
    design_1_wrapper u_uvw_axi4_to_ddr4_design_1_wrapper_987cukl(
        .C0_SYS_CLK_0_clk_p                 ( FP_CLK_200M_P                 ) , // input
        .C0_SYS_CLK_0_clk_n                 ( FP_CLK_200M_N                 ) , // input
        .C0_DDR4_0_act_n                    ( DDR4_DIMM_ACT_N               ) , // output   [ 0:0]  1
        .C0_DDR4_0_adr                      ( DDR4_DIMM_A                   ) , // output   [16:0]  17
        .C0_DDR4_0_ba                       ( DDR4_DIMM_BA                  ) , // output   [ 1:0]  2
        .C0_DDR4_0_bg                       ( DDR4_DIMM_BG                  ) , // output   [ 1:0]  2
        .C0_DDR4_0_ck_c                     ( DDR4_DIMM_CK_N    [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_ck_t                     ( DDR4_DIMM_CK_P    [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_cke                      ( DDR4_DIMM_CKE     [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_cs_n                     ( DDR4_DIMM_CS_N    [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_odt                      ( DDR4_DIMM_ODT     [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_reset_n                  ( DDR4_DIMM_RST_B               ) , // output   [ 0:0]  1
        .C0_DDR4_0_dm_n                     ( DDR4_DIMM_DM                  ) , // inout    [ 8:0]  9
        .C0_DDR4_0_dq                       ( DDR4_DIMM_DQ                  ) , // inout    [71:0]  72
        .C0_DDR4_0_dqs_c                    ( DDR4_DIMM_DQS_N               ) , // inout    [ 8:0]  9
        .C0_DDR4_0_dqs_t                    ( DDR4_DIMM_DQS_P               ) , // inout    [ 8:0]  9

        .C0_DDR4_S_AXI_CTRL_0_araddr        ( 14'b0                         ) , // input   [31:0]
        .C0_DDR4_S_AXI_CTRL_0_arready       (                               ) , // output
        .C0_DDR4_S_AXI_CTRL_0_arvalid       (  1'b0                         ) , // input
        .C0_DDR4_S_AXI_CTRL_0_awaddr        ( 32'b0                         ) , // input   [31:0]
        .C0_DDR4_S_AXI_CTRL_0_awready       (                               ) , // output
        .C0_DDR4_S_AXI_CTRL_0_awvalid       (  1'b0                         ) , // input
        .C0_DDR4_S_AXI_CTRL_0_bready        (  1'b0                         ) , // input
        .C0_DDR4_S_AXI_CTRL_0_bresp         (                               ) , // output  [ 1:0]
        .C0_DDR4_S_AXI_CTRL_0_bvalid        (                               ) , // output
        .C0_DDR4_S_AXI_CTRL_0_rdata         (                               ) , // output  [31:0]
        .C0_DDR4_S_AXI_CTRL_0_rready        (  1'b0                         ) , // input
        .C0_DDR4_S_AXI_CTRL_0_rresp         (                               ) , // output  [ 1:0]
        .C0_DDR4_S_AXI_CTRL_0_rvalid        (                               ) , // output
        .C0_DDR4_S_AXI_CTRL_0_wdata         ( 32'b0                         ) , // input   [31:0]
        .C0_DDR4_S_AXI_CTRL_0_wready        (                               ) , // output
        .C0_DDR4_S_AXI_CTRL_0_wvalid        (  1'b0                         ) , // input

        .S00_AXI_0_aclk                     ( ddr4ip_dut_axi_aclk           ) , // input
        .S00_AXI_0_aresetn                  ( ddr4ip_dut_axi_aresetn_3ff    ) , // input
        .S00_AXI_0_araddr                   ( s_dut_axi_araddr              ) , // input   [63:0]
        .S00_AXI_0_arburst                  ( s_dut_axi_arburst             ) , // input   [ 1:0]
        .S00_AXI_0_arcache                  ( s_dut_axi_arcache             ) , // input   [ 3:0]
        .S00_AXI_0_arid                     ( s_dut_axi_arid                ) , // input   [31:0]
        .S00_AXI_0_arlen                    ( s_dut_axi_arlen               ) , // input   [ 7:0]
        .S00_AXI_0_arlock                   ( s_dut_axi_arlock              ) , // input   [ 0:0]
        .S00_AXI_0_arprot                   ( s_dut_axi_arprot              ) , // input   [ 2:0]
        .S00_AXI_0_arqos                    ( s_dut_axi_arqos               ) , // input   [ 3:0]
        .S00_AXI_0_arready                  ( s_dut_axi_arready             ) , // output
        .S00_AXI_0_arregion                 ( s_dut_axi_arregion            ) , // input   [ 3:0]
        .S00_AXI_0_arsize                   ( s_dut_axi_arsize              ) , // input   [ 2:0]
        .S00_AXI_0_arvalid                  ( s_dut_axi_arvalid             ) , // input
        .S00_AXI_0_awaddr                   ( s_dut_axi_awaddr              ) , // input   [63:0]
        .S00_AXI_0_awburst                  ( s_dut_axi_awburst             ) , // input   [ 1:0]
        .S00_AXI_0_awcache                  ( s_dut_axi_awcache             ) , // input   [ 3:0]
        .S00_AXI_0_awid                     ( s_dut_axi_awid                ) , // input   [31:0]
        .S00_AXI_0_awlen                    ( s_dut_axi_awlen               ) , // input   [ 7:0]
        .S00_AXI_0_awlock                   ( s_dut_axi_awlock              ) , // input   [ 0:0]
        .S00_AXI_0_awprot                   ( s_dut_axi_awprot              ) , // input   [ 2:0]
        .S00_AXI_0_awqos                    ( s_dut_axi_awqos               ) , // input   [ 3:0]
        .S00_AXI_0_awready                  ( s_dut_axi_awready             ) , // output
        .S00_AXI_0_awregion                 ( s_dut_axi_awregion            ) , // input   [ 3:0]
        .S00_AXI_0_awsize                   ( s_dut_axi_awsize              ) , // input   [ 2:0]
        .S00_AXI_0_awvalid                  ( s_dut_axi_awvalid             ) , // input
        .S00_AXI_0_bid                      ( s_dut_axi_bid                 ) , // output  [31:0]
        .S00_AXI_0_bready                   ( s_dut_axi_bready              ) , // input
        .S00_AXI_0_bresp                    ( s_dut_axi_bresp               ) , // output  [ 1:0]
        .S00_AXI_0_bvalid                   ( s_dut_axi_bvalid              ) , // output
        .S00_AXI_0_rdata                    ( s_dut_axi_rdata               ) , // output  [31:0]
        .S00_AXI_0_rid                      ( s_dut_axi_rid                 ) , // output  [31:0]
        .S00_AXI_0_rlast                    ( s_dut_axi_rlast               ) , // output
        .S00_AXI_0_rready                   ( s_dut_axi_rready              ) , // input
        .S00_AXI_0_rresp                    ( s_dut_axi_rresp               ) , // output  [ 1:0]
        .S00_AXI_0_rvalid                   ( s_dut_axi_rvalid              ) , // output
        .S00_AXI_0_wdata                    ( s_dut_axi_wdata               ) , // input   [31:0]
        .S00_AXI_0_wlast                    ( s_dut_axi_wlast               ) , // input
        .S00_AXI_0_wready                   ( s_dut_axi_wready              ) , // output
        .S00_AXI_0_wstrb                    ( s_dut_axi_wstrb               ) , // input   [ 3:0]
        .S00_AXI_0_wvalid                   ( s_dut_axi_wvalid              ) , // input

        .S01_AXI_0_aclk                     ( s_stream_clk                  ) , // input    [  0:0] 1
        .S01_AXI_0_aresetn                  ( s_axi_resetn                  ) , // input    [  0:0] 1
        .S01_AXI_0_araddr                   ( s_axi_araddr[35:0]            ) , // input    [ 63:0]  
        .S01_AXI_0_arburst                  ( 2'b01                         ) , // input    [  1:0] 2
        .S01_AXI_0_arcache                  ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_arid                     ( 24'h000000                    ) , // input    [ 23:0]  
        .S01_AXI_0_arlen                    ( s_axi_arlen                   ) , // input    [  7:0] 8
        .S01_AXI_0_arlock                   ( 1'b0                          ) , // input    [  0:0] 1
        .S01_AXI_0_arprot                   ( 3'b000                        ) , // input    [  2:0] 3
        .S01_AXI_0_arqos                    ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_arregion                 ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_arsize                   ( 3'b011                        ) , // input    [  2:0] 3
        .S01_AXI_0_arvalid                  ( s_axi_arvalid                 ) , // input    [  0:0] 1
        .S01_AXI_0_awaddr                   ( s_axi_awaddr[35:0]            ) , // input    [ 63:0]  
        .S01_AXI_0_awburst                  ( 2'b01                         ) , // input    [  1:0] 2
        .S01_AXI_0_awcache                  ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_awid                     ( 24'h000000                    ) , // input    [ 23:0]  
        .S01_AXI_0_awlen                    ( s_axi_awlen                   ) , // input    [  7:0] 8
        .S01_AXI_0_awlock                   ( 1'b0                          ) , // input    [  0:0] 1
        .S01_AXI_0_awprot                   ( 3'b000                        ) , // input    [  2:0] 3
        .S01_AXI_0_awqos                    ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_awregion                 ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_awsize                   ( 3'b011                        ) , // input    [  2:0] 3
        .S01_AXI_0_awvalid                  ( s_axi_awvalid                 ) , // input    [  0:0] 1
        .S01_AXI_0_bready                   ( s_axi_bready                  ) , // input    [  0:0] 1
        .S01_AXI_0_rready                   ( s_axi_rready                  ) , // input    [  0:0] 1
        .S01_AXI_0_wdata                    ( s_axi_wdata                   ) , // input    [ 63:0]  
        .S01_AXI_0_wlast                    ( s_axi_wlast                   ) , // input    [  0:0] 1
        .S01_AXI_0_wstrb                    ( s_axi_wstrb                   ) , // input    [  7:0] 
        .S01_AXI_0_wvalid                   ( s_axi_wvalid                  ) , // input    [  0:0] 1

        .S01_AXI_0_arready                  ( s_axi_arready                 ) , // output   [  0:0] 1
        .S01_AXI_0_awready                  ( s_axi_awready                 ) , // output   [  0:0] 1
        .S01_AXI_0_bid                      (                               ) , // output   [ 23:0]  
        .S01_AXI_0_bresp                    ( s_axi_bresp                   ) , // output   [  1:0] 2
        .S01_AXI_0_bvalid                   ( s_axi_bvalid                  ) , // output   [  0:0] 1
        .S01_AXI_0_rdata                    ( s_axi_rdata                   ) , // output   [ 63:0] 
        .S01_AXI_0_rid                      (                               ) , // output   [ 23:0]  
        .S01_AXI_0_rlast                    ( s_axi_rlast                   ) , // output   [  0:0] 1
        .S01_AXI_0_rresp                    ( s_axi_rresp                   ) , // output   [  1:0] 2
        .S01_AXI_0_rvalid                   ( s_axi_rvalid                  ) , // output   [  0:0] 1
        .S01_AXI_0_wready                   ( s_axi_wready                  ) , // output   [  0:0] 1
        .c0_init_calib_complete_0           ( s_ddr4_calib_done             ) , // output   [  0:0] 1

        .ddr4_ui_clk                        ( s_ddr4_user_clk               ) , // output
        .ddr4_ui_rst                        ( s_ddr4_user_rst               )   // output  [  0:0]
    ) ;
    end else begin
    design_1_wrapper u_uvw_axi4_to_ddr4_design_1_wrapper_987cukl(
        .C0_SYS_CLK_0_clk_p                 ( FP_CLK_200M_P                 ) , // input
        .C0_SYS_CLK_0_clk_n                 ( FP_CLK_200M_N                 ) , // input
        .C0_DDR4_0_act_n                    ( DDR4_DIMM_ACT_N               ) , // output   [ 0:0]  1
        .C0_DDR4_0_adr                      ( DDR4_DIMM_A                   ) , // output   [16:0]  17
        .C0_DDR4_0_ba                       ( DDR4_DIMM_BA                  ) , // output   [ 1:0]  2
        .C0_DDR4_0_bg                       ( DDR4_DIMM_BG                  ) , // output   [ 1:0]  2
        .C0_DDR4_0_ck_c                     ( DDR4_DIMM_CK_N    [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_ck_t                     ( DDR4_DIMM_CK_P    [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_cke                      ( DDR4_DIMM_CKE     [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_cs_n                     ( DDR4_DIMM_CS_N    [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_odt                      ( DDR4_DIMM_ODT     [0]         ) , // output   [ 0:0]  1
        .C0_DDR4_0_reset_n                  ( DDR4_DIMM_RST_B               ) , // output   [ 0:0]  1
        .C0_DDR4_0_dm_n                     ( DDR4_DIMM_DM      [7:0]       ) , // inout    [ 8:0]  9
        .C0_DDR4_0_dq                       ( DDR4_DIMM_DQ      [63:0]      ) , // inout    [71:0]  72
        .C0_DDR4_0_dqs_c                    ( DDR4_DIMM_DQS_N   [7:0]       ) , // inout    [ 8:0]  9
        .C0_DDR4_0_dqs_t                    ( DDR4_DIMM_DQS_P   [7:0]       ) , // inout    [ 8:0]  9

        .S00_AXI_0_aclk                     ( ddr4ip_dut_axi_aclk           ) , // input
        .S00_AXI_0_aresetn                  ( ddr4ip_dut_axi_aresetn_3ff    ) , // input
        .S00_AXI_0_araddr                   ( s_dut_axi_araddr              ) , // input   [63:0]
        .S00_AXI_0_arburst                  ( s_dut_axi_arburst             ) , // input   [ 1:0]
        .S00_AXI_0_arcache                  ( s_dut_axi_arcache             ) , // input   [ 3:0]
        .S00_AXI_0_arid                     ( s_dut_axi_arid                ) , // input   [31:0]
        .S00_AXI_0_arlen                    ( s_dut_axi_arlen               ) , // input   [ 7:0]
        .S00_AXI_0_arlock                   ( s_dut_axi_arlock              ) , // input   [ 0:0]
        .S00_AXI_0_arprot                   ( s_dut_axi_arprot              ) , // input   [ 2:0]
        .S00_AXI_0_arqos                    ( s_dut_axi_arqos               ) , // input   [ 3:0]
        .S00_AXI_0_arready                  ( s_dut_axi_arready             ) , // output
        .S00_AXI_0_arregion                 ( s_dut_axi_arregion            ) , // input   [ 3:0]
        .S00_AXI_0_arsize                   ( s_dut_axi_arsize              ) , // input   [ 2:0]
        .S00_AXI_0_arvalid                  ( s_dut_axi_arvalid             ) , // input
        .S00_AXI_0_awaddr                   ( s_dut_axi_awaddr              ) , // input   [63:0]
        .S00_AXI_0_awburst                  ( s_dut_axi_awburst             ) , // input   [ 1:0]
        .S00_AXI_0_awcache                  ( s_dut_axi_awcache             ) , // input   [ 3:0]
        .S00_AXI_0_awid                     ( s_dut_axi_awid                ) , // input   [31:0]
        .S00_AXI_0_awlen                    ( s_dut_axi_awlen               ) , // input   [ 7:0]
        .S00_AXI_0_awlock                   ( s_dut_axi_awlock              ) , // input   [ 0:0]
        .S00_AXI_0_awprot                   ( s_dut_axi_awprot              ) , // input   [ 2:0]
        .S00_AXI_0_awqos                    ( s_dut_axi_awqos               ) , // input   [ 3:0]
        .S00_AXI_0_awready                  ( s_dut_axi_awready             ) , // output
        .S00_AXI_0_awregion                 ( s_dut_axi_awregion            ) , // input   [ 3:0]
        .S00_AXI_0_awsize                   ( s_dut_axi_awsize              ) , // input   [ 2:0]
        .S00_AXI_0_awvalid                  ( s_dut_axi_awvalid             ) , // input
        .S00_AXI_0_bid                      ( s_dut_axi_bid                 ) , // output  [31:0]
        .S00_AXI_0_bready                   ( s_dut_axi_bready              ) , // input
        .S00_AXI_0_bresp                    ( s_dut_axi_bresp               ) , // output  [ 1:0]
        .S00_AXI_0_bvalid                   ( s_dut_axi_bvalid              ) , // output
        .S00_AXI_0_rdata                    ( s_dut_axi_rdata               ) , // output  [31:0]
        .S00_AXI_0_rid                      ( s_dut_axi_rid                 ) , // output  [31:0]
        .S00_AXI_0_rlast                    ( s_dut_axi_rlast               ) , // output
        .S00_AXI_0_rready                   ( s_dut_axi_rready              ) , // input
        .S00_AXI_0_rresp                    ( s_dut_axi_rresp               ) , // output  [ 1:0]
        .S00_AXI_0_rvalid                   ( s_dut_axi_rvalid              ) , // output
        .S00_AXI_0_wdata                    ( s_dut_axi_wdata               ) , // input   [31:0]
        .S00_AXI_0_wlast                    ( s_dut_axi_wlast               ) , // input
        .S00_AXI_0_wready                   ( s_dut_axi_wready              ) , // output
        .S00_AXI_0_wstrb                    ( s_dut_axi_wstrb               ) , // input   [ 3:0]
        .S00_AXI_0_wvalid                   ( s_dut_axi_wvalid              ) , // input

        .S01_AXI_0_aclk                     ( s_stream_clk                  ) , // input    [  0:0] 1
        .S01_AXI_0_aresetn                  ( s_axi_resetn                  ) , // input    [  0:0] 1
        .S01_AXI_0_araddr                   ( s_axi_araddr[35:0]            ) , // input    [ 63:0]  
        .S01_AXI_0_arburst                  ( 2'b01                         ) , // input    [  1:0] 2
        .S01_AXI_0_arcache                  ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_arid                     ( 24'h000000                    ) , // input    [ 23:0]  
        .S01_AXI_0_arlen                    ( s_axi_arlen                   ) , // input    [  7:0] 8
        .S01_AXI_0_arlock                   ( 1'b0                          ) , // input    [  0:0] 1
        .S01_AXI_0_arprot                   ( 3'b000                        ) , // input    [  2:0] 3
        .S01_AXI_0_arqos                    ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_arregion                 ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_arsize                   ( 3'b011                        ) , // input    [  2:0] 3
        .S01_AXI_0_arvalid                  ( s_axi_arvalid                 ) , // input    [  0:0] 1
        .S01_AXI_0_awaddr                   ( s_axi_awaddr[35:0]            ) , // input    [ 63:0]  
        .S01_AXI_0_awburst                  ( 2'b01                         ) , // input    [  1:0] 2
        .S01_AXI_0_awcache                  ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_awid                     ( 24'h000000                    ) , // input    [ 23:0]  
        .S01_AXI_0_awlen                    ( s_axi_awlen                   ) , // input    [  7:0] 8
        .S01_AXI_0_awlock                   ( 1'b0                          ) , // input    [  0:0] 1
        .S01_AXI_0_awprot                   ( 3'b000                        ) , // input    [  2:0] 3
        .S01_AXI_0_awqos                    ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_awregion                 ( 4'b0000                       ) , // input    [  3:0] 4
        .S01_AXI_0_awsize                   ( 3'b011                        ) , // input    [  2:0] 3
        .S01_AXI_0_awvalid                  ( s_axi_awvalid                 ) , // input    [  0:0] 1
        .S01_AXI_0_bready                   ( s_axi_bready                  ) , // input    [  0:0] 1
        .S01_AXI_0_rready                   ( s_axi_rready                  ) , // input    [  0:0] 1
        .S01_AXI_0_wdata                    ( s_axi_wdata                   ) , // input    [ 63:0]  
        .S01_AXI_0_wlast                    ( s_axi_wlast                   ) , // input    [  0:0] 1
        .S01_AXI_0_wstrb                    ( s_axi_wstrb                   ) , // input    [  7:0] 
        .S01_AXI_0_wvalid                   ( s_axi_wvalid                  ) , // input    [  0:0] 1

        .S01_AXI_0_arready                  ( s_axi_arready                 ) , // output   [  0:0] 1
        .S01_AXI_0_awready                  ( s_axi_awready                 ) , // output   [  0:0] 1
        .S01_AXI_0_bid                      (                               ) , // output   [ 23:0]  
        .S01_AXI_0_bresp                    ( s_axi_bresp                   ) , // output   [  1:0] 2
        .S01_AXI_0_bvalid                   ( s_axi_bvalid                  ) , // output   [  0:0] 1
        .S01_AXI_0_rdata                    ( s_axi_rdata                   ) , // output   [ 63:0] 
        .S01_AXI_0_rid                      (                               ) , // output   [ 23:0]  
        .S01_AXI_0_rlast                    ( s_axi_rlast                   ) , // output   [  0:0] 1
        .S01_AXI_0_rresp                    ( s_axi_rresp                   ) , // output   [  1:0] 2
        .S01_AXI_0_rvalid                   ( s_axi_rvalid                  ) , // output   [  0:0] 1
        .S01_AXI_0_wready                   ( s_axi_wready                  ) , // output   [  0:0] 1
        .c0_init_calib_complete_0           ( s_ddr4_calib_done             ) , // output   [  0:0] 1

        .ddr4_ui_clk                        ( s_ddr4_user_clk               ) , // output
        .ddr4_ui_rst                        ( s_ddr4_user_rst               )   // output  [  0:0]
    ) ;
    IOBUFDS u_iobufds_dimm_dqs8 ( .I(1'b1), .IO(DDR4_DIMM_DQS_P[8]),
                                           .IOB(DDR4_DIMM_DQS_N[8]), .T(1'b1)   );
    IOBUF   u_iobuf_dm8         ( .I(1'b1), .IO(DDR4_DIMM_DM[8]   ), .T(1'b1)   );
    IOBUF   u_iobuf_dq64        ( .I(1'b1), .IO(DDR4_DIMM_DQ[64]  ), .T(1'b1)   );
    IOBUF   u_iobuf_dq65        ( .I(1'b1), .IO(DDR4_DIMM_DQ[65]  ), .T(1'b1)   );
    IOBUF   u_iobuf_dq66        ( .I(1'b1), .IO(DDR4_DIMM_DQ[66]  ), .T(1'b1)   );
    IOBUF   u_iobuf_dq67        ( .I(1'b1), .IO(DDR4_DIMM_DQ[67]  ), .T(1'b1)   );
    IOBUF   u_iobuf_dq68        ( .I(1'b1), .IO(DDR4_DIMM_DQ[68]  ), .T(1'b1)   );
    IOBUF   u_iobuf_dq69        ( .I(1'b1), .IO(DDR4_DIMM_DQ[69]  ), .T(1'b1)   );
    IOBUF   u_iobuf_dq70        ( .I(1'b1), .IO(DDR4_DIMM_DQ[70]  ), .T(1'b1)   );
    IOBUF   u_iobuf_dq71        ( .I(1'b1), .IO(DDR4_DIMM_DQ[71]  ), .T(1'b1)   );
    end
endgenerate


    // ---------------------------------------------------------------
    // Functions added due to U2
    // ---------------------------------------------------------------
    // system bus interface decode/encode
//    assign s_ip_clk                 = sysbus_ghbd_i[      0];
//    assign s_ip_rst                 = sysbus_ghbd_i[      1];
//    assign s_reg_wr_en              = sysbus_ghbd_i[      2];
//    assign s_reg_rd_en              = sysbus_ghbd_i[      3];
//    assign s_reg_addr               = sysbus_ghbd_i[ 19:  4];
//    assign s_reg_wr_data            = sysbus_ghbd_i[ 51: 20]; 
//    assign s_sbus2ip_tvalid         = sysbus_ghbd_i[     52];
//    assign s_sbus2ip_tlast          = sysbus_ghbd_i[     53];
//    assign s_sbus2ip_tkeep          = sysbus_ghbd_i[ 61: 54];
//    assign s_sbus2ip_tdata          = sysbus_ghbd_i[125: 62];
//    assign s_ip2sbus_tready         = sysbus_ghbd_i[    126];
//
//    assign sysbus_ghbd_o[      0]   = s_reg_clk             ;
//    assign sysbus_ghbd_o[      1]   = s_reg_rst             ;
//    assign sysbus_ghbd_o[      2]   = s_ip2sbus_clk         ;
//    assign sysbus_ghbd_o[      3]   = s_ip2sbus_rst         ;
//    assign sysbus_ghbd_o[      4]   = s_intr                ;
//    assign sysbus_ghbd_o[      5]   = s_reg_wr_resp         ;
//    assign sysbus_ghbd_o[      6]   = s_reg_rd_resp         ;
//    assign sysbus_ghbd_o[ 38:  7]   = s_reg_rd_data         ;
//    assign sysbus_ghbd_o[     39]   = s_sbus2ip_tready      ;
//    assign sysbus_ghbd_o[     40]   = s_ip2sbus_tvalid      ;
//    assign sysbus_ghbd_o[     41]   = s_ip2sbus_tlast       ;
//    assign sysbus_ghbd_o[ 49: 42]   = s_ip2sbus_tkeep       ;
//    assign sysbus_ghbd_o[113: 50]   = s_ip2sbus_tdata       ;
//    assign sysbus_ghbd_o[199:114]   =  86'd0                ;
//    assign sysbus_ghbd_o[    200]   =   1'b1                ;
//    assign sysbus_ghbd_o[255:201]   =  55'd0                ;

//    uvw_u2_ip_if_wrapper u_sysbus_if (
    uvw_sbus_3_0_ip_if_wrapper #(
        .SYSTEMBUS_WIDTH                    (256                            ),
        .A_DATAWIDTH                        (64                             ),
        .REG_ADDR_WIDTH                     (16                             ),
        .REG_DATA_WIDTH                     (32                             ),
        .IP_UPSTREAM_PORT                   (1                              ),
        .BARNCH1_DEL                        (1                              ), // 
        .BARNCH2_DEL                        (1                              ), // 
        .IP_TYPE                            (                               ), // QSPI FLASH IP TYPE: 32'H0000_0009
        .IP_VERSION_REVISION                (                               ), //
        .IP_VERSION_MINOR                   (                               ), //
        .IP_VERSION_MAJOR                   (                               ), //
        .IP_VERSION_TYPE                    (                               ), //
        .IP_ALP_BYPASS                      (0                              )  // 1 ENABLE ALP BYPASS
    ) u_ip_if_wrapper (
        .systembus_i                        (sysbus_ghbd_i                  ), // (i) 
        .systembus_o                        (sysbus_ghbd_o                  ), // (o) 
        .sbus_clk_i                         (s_ip_clk                       ), // (o)
        .rst_sbus_clk_i                     (s_ip_rst                       ), // (o)
        .peri_clk                           (                               ), // (o)
        .rst_peri_clk                       (                               ), // (o)
        .uvhs_uclk                          (                               ), // (o)
        .uvhs_master_clk                    (                               ), // (o)
        .rst_uvhs_uclk                      (                               ), // (o)  
        .ip_stream_clk                      (s_ip2sbus_clk                  ), // (i)
        .ip_stream_rst                      (s_ip2sbus_rst                  ), // (i) 
        .up_ip2wrap_tdata                   (s_ip2sbus_tdata                ), // (i) not used
        .up_ip2wrap_tlast                   (s_ip2sbus_tlast                ), // (i) not used
        .up_ip2wrap_tvalid                  (s_ip2sbus_tvalid               ), // (i) not used
        .up_ip2wrap_tkeep                   (s_ip2sbus_tkeep                ), // (i) not used
        .up_wrap2ip_tready                  (s_ip2sbus_tready               ), // (o) not used
        .dn_wrap2ip_tdata                   (s_sbus2ip_tdata                ), // (o) not used
        .dn_wrap2ip_tlast                   (s_sbus2ip_tlast                ), // (o) not used
        .dn_wrap2ip_tvalid                  (s_sbus2ip_tvalid               ), // (o) not used
        .dn_wrap2ip_tkeep                   (s_sbus2ip_tkeep                ), // (o) not used
        .dn_ip2wrap_tready                  (s_sbus2ip_tready               ), // (i) not used

        .ip_ufc_clk                         (s_reg_clk                      ), // (i)
        .ip_ufc_rst                         (s_reg_rst                      ), // (i)
        .reg_wr_resp                        (s_reg_wr_resp                  ), // (i)
        .reg_wr_valid                       (s_reg_wr_valid                 ), // (i)
        .reg_rd_data                        (s_reg_rd_data                  ), // (i)
        .reg_rd_resp                        (s_reg_rd_resp                  ), // (i)
        .reg_rd_valid                       (s_reg_rd_valid                 ), // (i)
        .interrupt                          (s_intr                         ), // (i)
        .reg_rd_en                          (s_reg_rd_en                    ), // (o)
        .reg_addr                           (s_reg_addr                     ), // (o)
        .reg_wr_en                          (s_reg_wr_en                    ), // (o)
        .reg_wr_data                        (s_reg_wr_data                  ), // (o)
        .stop_clk_out                       (                               ), // (o) 
        .stop_clk_in                        (1'b0                           ), // (i)
        .alp_length                         (                               ), // (o) 
        .timestamp                          (11'b0                          ), // (i)
        .is_active_ip                       (1'b1                           ), // (i)
        .is_active_streamio                 (1'b1                           ), // (i)
        .is_active_coemu_ip                 (1'b0                           )  // (i)
    );



    // clock module
    uvw_ddr4_clk u_ddr4_clk (
        // clock and reset
        .ip_clk                             (s_ip_clk                       ), // input clock, 50MHz
        .ip_rst                             (s_ip_rst                       ), // input reset, high active
        // register module
        .regm_clk                           (s_regm_clk                     ), // output register clock
        .regm_rst                           (s_regm_rst                     ), // output register reset
        // stream module
        .stream_clk                         (s_stream_clk                   ), // output stream clock
        .stream_rst                         (s_stream_rst                   )  // output stream reset
    );

    assign s_axi_resetn = ~(s_stream_rst | s_ddr4_rst);

    // register module
    uvw_ddr4_reg u_ddr4_reg (
        // clock and reset
        .clk                                (s_regm_clk                     ), // input             clock
        .rst                                (s_regm_rst                     ), // input             reset, high active
        // system bus interface
        .reg_clk                            (s_reg_clk                      ), // output          
        .reg_rst                            (s_reg_rst                      ), // output          
        .reg_wr_en                          (s_reg_wr_en                    ), // input            write enable
        .reg_addr                           (s_reg_addr                     ), // input  [ 15:0]   write/read address
        .reg_wr_data                        (s_reg_wr_data                  ), // input  [ 31:0]   write data
        .reg_wr_resp                        (s_reg_wr_resp                  ), // output           write response
        .reg_wr_valid                       (s_reg_wr_valid                 ), // output           write valid
        .reg_rd_en                          (s_reg_rd_en                    ), // input            read enable
        .reg_rd_data                        (s_reg_rd_data                  ), // output [ 31:0]   read data
        .reg_rd_resp                        (s_reg_rd_resp                  ), // output           read response
        .reg_rd_valid                       (s_reg_rd_valid                 ), // output           read valid
        .intr                               (s_intr                         ), // output           interrupt
        // register (ddr4 ip)
        .bus_clear                          (s_bus_clear                    ), // output [ 31:0]  bus clear
        .ddr4_start_addr                    (s_ddr4_start_addr              ), // output [ 63:0]  ddr4 write/read start address
        .ddr4_size                          (s_ddr4_size                    ), // output [ 63:0]  ddr4 write/read size
        .ddr4_wcmd                          (s_ddr4_wcmd                    ), // output          ddr4 write command
        .ddr4_rcmd                          (s_ddr4_rcmd                    ), // output          ddr4 read command
        .ddr4_rst                           (s_ddr4_rst                     ), // output          ddr4 reset
        .ddr4_busy                          (s_ddr4_busy                    ), // input           
        .ddr4_calib_done                    (s_ddr4_calib_done              )  // input           
    );

    // axi stream <-> axi4
    uvw_stream_if u_stream_if (
        // clock and reset
        .clk                                 (s_stream_clk                   ), // input           
        .rst                                 (~s_axi_resetn                  ), // input   
        // register
        .bus_clear                           (s_bus_clear                    ), // input
        // stream interface
        .ip2sbus_clk                         (s_ip2sbus_clk                  ), // output          clock
        .ip2sbus_rst                         (s_ip2sbus_rst                  ), // output          reset, high active
        .sbus2ip_tvalid                      (s_sbus2ip_tvalid               ), // input           
        .sbus2ip_tlast                       (s_sbus2ip_tlast                ), // input           
        .sbus2ip_tkeep                       (s_sbus2ip_tkeep                ), // input  [  7:0]  
        .sbus2ip_tdata                       (s_sbus2ip_tdata                ), // input  [ 63:0]  
        .sbus2ip_tready                      (s_sbus2ip_tready               ), // output          
        .ip2sbus_tvalid                      (s_ip2sbus_tvalid               ), // output          
        .ip2sbus_tlast                       (s_ip2sbus_tlast                ), // output          
        .ip2sbus_tkeep                       (s_ip2sbus_tkeep                ), // output [  7:0]  
        .ip2sbus_tdata                       (s_ip2sbus_tdata                ), // output [ 63:0]  
        .ip2sbus_tready                      (s_ip2sbus_tready               ), // input           
        // axi interface
        .axi_araddr                          (s_axi_araddr                   ), // output [ 63:0]  read address
        .axi_arlen                           (s_axi_arlen                    ), // output [  7:0]  read length
        .axi_arvalid                         (s_axi_arvalid                  ), // output          read address valid
        .axi_awaddr                          (s_axi_awaddr                   ), // output [ 63:0]  
        .axi_awlen                           (s_axi_awlen                    ), // output [  7:0]  
        .axi_awvalid                         (s_axi_awvalid                  ), // output          
        .axi_bready                          (s_axi_bready                   ), // output          
        .axi_rready                          (s_axi_rready                   ), // output          
        .axi_wdata                           (s_axi_wdata                    ), // output [ 63:0]  
        .axi_wlast                           (s_axi_wlast                    ), // output          
        .axi_wstrb                           (s_axi_wstrb                    ), // output [  7:0]  
        .axi_wvalid                          (s_axi_wvalid                   ), // output          
        .axi_arready                         (s_axi_arready                  ), // input           
        .axi_awready                         (s_axi_awready                  ), // input           
        .axi_bresp                           (s_axi_bresp                    ), // input  [  1:0]  
        .axi_bvalid                          (s_axi_bvalid                   ), // input           
        .axi_rdata                           (s_axi_rdata                    ), // input  [ 63:0]  
        .axi_rlast                           (s_axi_rlast                    ), // input           
        .axi_rresp                           (s_axi_rresp                    ), // input  [  1:0]  
        .axi_rvalid                          (s_axi_rvalid                   ), // input           
        .axi_wready                          (s_axi_wready                   ), // input           
        // register
        .reg_clk                             (s_regm_clk                     ), // input           register clock domain
        .ddr4_start_addr                     (s_ddr4_start_addr              ), // input  [ 63:0]  start address
        .ddr4_size                           (s_ddr4_size                    ), // input  [ 63:0]  size
        .ddr4_wcmd                           (s_ddr4_wcmd                    ), // input           write command
        .ddr4_rcmd                           (s_ddr4_rcmd                    ), // input           read command
        .ddr4_busy                           (s_ddr4_busy                    )  // output          
    );



endmodule
