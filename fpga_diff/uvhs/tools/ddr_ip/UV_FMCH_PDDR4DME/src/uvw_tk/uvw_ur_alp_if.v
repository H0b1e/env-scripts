// ================================================================================================
// Copyright(C) 2022 Univista Industrial Software Group Co.,Ltd All rights reserved.
// ================================================================================================
//
// ================================================================================================
// Module     : uvw_ur_alp_if 
// Function   : systembus 3.0 interface control for ip. 
// ------------------------------------------------------------------------------------------------
// Update History
// ------------------------------------------------------------------------------------------------
// Version        Data           Author             Contents
// 1.0.0          2023/03/10     hanbing            Initial release
// 1.0.1          2023/03/20     hanbing            sbus 4.0
// ================================================================================================

// ================================================================================================
// RTL header
// ================================================================================================
// Timiscale ///
`timescale 1ps/1ps

module uvw_ur_alp_if (
// IO for sbus3.0
    ip_stream_clk              ,
    ip_stream_rst              ,
    ip_ufc_clk                 ,
    ip_ufc_rst                 ,
    dn_wrap2ip_tdata           ,
    dn_wrap2ip_tlast           ,
    dn_wrap2ip_tvalid          ,
    dn_ip2wrap_tready          ,
    dn_wrap2ip_tkeep           ,
    up_ip2wrap_tdata           ,
    up_ip2wrap_tlast           ,
    up_ip2wrap_tvalid          ,
    up_wrap2ip_tready          ,
    up_ip2wrap_tkeep           ,
    reg_addr                   ,
    reg_wr_en                  ,
    reg_wr_data                ,
    reg_wr_resp                ,
    reg_wr_valid               ,
    reg_rd_en                  ,
    reg_rd_data                ,
    reg_rd_resp                ,
    reg_rd_valid               ,
    interrupt                  ,
// IO for IP 
    s_ip_stream_clk            ,
    s_ip_stream_rst            ,
    s_ip_ufc_clk               ,
    s_ip_ufc_rst               ,
    s_dn_wrap2ip_tdata         ,
    s_dn_wrap2ip_tlast         ,
    s_dn_wrap2ip_tvalid        ,
    s_dn_ip2wrap_tready        ,
    s_dn_wrap2ip_tkeep         ,
    s_up_ip2wrap_tdata         ,
    s_up_ip2wrap_tlast         ,
    s_up_ip2wrap_tvalid        ,
    s_up_wrap2ip_tready        ,
    s_up_ip2wrap_tkeep         ,
    s_reg_addr                 ,
    s_reg_wr_en                ,
    s_reg_wr_data              ,
    s_reg_wr_valid             ,
    s_reg_wr_resp              ,
    s_reg_rd_en                ,
    s_reg_rd_data              ,
    s_reg_rd_resp              ,
    s_reg_rd_valid             ,
    s_interrupt                ,
    timestamp                  ,
    alp_length                 
);
parameter STREAM_DATA_WIDTH   = 64; 
parameter REG_DATA_WIDTH      = 32;
parameter REG_ADDR_WIDTH      = 16;
parameter BARNCH1_DEL         = 1 ;/// The difference in delay time. ur_alp_if del 1.
parameter BARNCH2_DEL         = 1 ;/// The difference in delay time. if brch2 del is 2. set BARNCH1_DEL =2; parameter IP_STREAM_PORT  = 4; //1~4
parameter IP_STREAM_PORT      = 4 ;
parameter IP_TYPE         = 0;  /// EDPI IP_TYPE is 0XB
parameter IP_VERSION_TYPE = 0;
parameter IP_VERSION_MAJOR= 0;
parameter IP_VERSION_MINOR= 0;
parameter IP_VERSION_REVISION=0;
parameter IP_ALP_BYPASS = 0; // 1 ENABLE ALP BYPASS

output                               ip_stream_clk              ;
output                               ip_stream_rst              ;
output                               ip_ufc_clk                 ;
output                               ip_ufc_rst                 ;
input  [STREAM_DATA_WIDTH-1'b1 :0]   dn_wrap2ip_tdata           ;
input                                dn_wrap2ip_tlast           ;
input                                dn_wrap2ip_tvalid          ;
output                               dn_ip2wrap_tready          ;
input  [STREAM_DATA_WIDTH/8-1'b1 :0] dn_wrap2ip_tkeep           ;
output [STREAM_DATA_WIDTH-1'b1 :0]   up_ip2wrap_tdata           ;
output                               up_ip2wrap_tlast           ;
output                               up_ip2wrap_tvalid          ;
input                                up_wrap2ip_tready          ;
output [STREAM_DATA_WIDTH/8-1'b1 :0] up_ip2wrap_tkeep           ;
input  [REG_ADDR_WIDTH-1'b1 :0]      reg_addr                   ;
input                                reg_wr_en                  ;
input  [REG_DATA_WIDTH-1'b1 :0]      reg_wr_data                ;
output                               reg_wr_resp                ;
output                               reg_wr_valid               ;
input                                reg_rd_en                  ;
output [REG_DATA_WIDTH-1'b1 :0]      reg_rd_data                ;
output                               reg_rd_resp                ;
output                               reg_rd_valid               ;
output                               interrupt                  ;


input                                               s_ip_stream_clk            ;
input                                               s_ip_stream_rst            ;
input                                               s_ip_ufc_clk               ;
input                                               s_ip_ufc_rst               ;
output [STREAM_DATA_WIDTH-1'b1 :0]                  s_dn_wrap2ip_tdata         ;
output                                              s_dn_wrap2ip_tlast         ;
output                                              s_dn_wrap2ip_tvalid        ;
input                                               s_dn_ip2wrap_tready        ;
output [STREAM_DATA_WIDTH/8-1'b1 :0]                s_dn_wrap2ip_tkeep         ;
input  [STREAM_DATA_WIDTH*IP_STREAM_PORT-1'b1 :0]   s_up_ip2wrap_tdata         ;
input  [1*IP_STREAM_PORT-1 :0]                      s_up_ip2wrap_tlast         ;
input  [1*IP_STREAM_PORT-1 :0]                      s_up_ip2wrap_tvalid        ;
output [1*IP_STREAM_PORT-1 :0]                      s_up_wrap2ip_tready        ;
input  [STREAM_DATA_WIDTH*IP_STREAM_PORT/8-1'b1 :0] s_up_ip2wrap_tkeep         ;
output [REG_ADDR_WIDTH-1'b1 :0]                     s_reg_addr                 ;
output                                              s_reg_wr_en                ;
output [REG_DATA_WIDTH-1'b1 :0]                     s_reg_wr_data              ;
input                                               s_reg_wr_valid             ;
input                                               s_reg_wr_resp              ;
output                                              s_reg_rd_en                ;
input [REG_DATA_WIDTH-1'b1 :0]                      s_reg_rd_data              ;
input                                               s_reg_rd_resp              ;
input                                               s_reg_rd_valid             ;
input                                               s_interrupt                ;
input  [11-1'b1 :0]                                 timestamp                  ;
output [REG_DATA_WIDTH-1'b1 :0]                     alp_length                 ;
    
localparam ALP_LENGTH_FIXED = 16'H800;    
localparam FRAME_HEAD = 16'HA781;
localparam FRAME_END  = 16'HBDAF;

localparam STATE_IDLE = 8'h0;
localparam STATE_START= 8'b1;
localparam STATE_END  = 8'h2;
localparam STATE_S1   = 8'H4;
localparam STATE_S2   = 8'H8;
localparam STATE_S3   = 8'H10;
localparam STATE_S4   = 8'H20;

(*ASYNC_REG = "true" *)reg         bus_clear_en          ;
reg   [3:0] axis_bus_clear_en_sync; 
(* SRL_STYLE = "register" *) reg   [3:0] ip_bus_clear_en_sync;
wire        axis_bus_clear_en     ;
wire  [31:0]bus_clear_bus_clear   ;

    wire  [REG_ADDR_WIDTH-1'b1 :0]                     if_reg_addr                 ;
    wire                                               if_reg_wr_en                ;
    wire  [REG_DATA_WIDTH-1'b1 :0]                     if_reg_wr_data              ;
    wire                                               if_reg_wr_valid             ;
    wire                                               if_reg_wr_resp              ;
    wire                                               if_reg_rd_en                ;
    wire  [REG_DATA_WIDTH-1'b1 :0]                     if_reg_rd_data              ;
    wire                                               if_reg_rd_resp              ;
    wire                                               if_reg_rd_valid             ;

    wire                                               aclk                        ;
    wire                                               aresetn                     ;
    
    wire [STREAM_DATA_WIDTH-1'b1 :0]   dn_wrap2ip_tdata             ;
    wire                               dn_wrap2ip_tlast             ;
    wire                               dn_wrap2ip_tvalid            ;
    wire                               dn_ip2wrap_tready            ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] dn_wrap2ip_tkeep             ;    
                                                                    
    wire [STREAM_DATA_WIDTH-1'b1 :0]   sdn_wrap2ip_tdata            ;
    wire                               sdn_wrap2ip_tlast            ;
    wire                               sdn_wrap2ip_tvalid           ;
    wire                               sdn_ip2wrap_tready           ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] sdn_wrap2ip_tkeep            ;     
    
    wire [STREAM_DATA_WIDTH-1'b1 :0]   ssdn_wrap2ip_tdata           ;
    wire                               ssdn_wrap2ip_tlast           ;
    wire                               ssdn_wrap2ip_tvalid          ;
    wire                               ssdn_ip2wrap_tready          ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] ssdn_wrap2ip_tkeep           ;      

    wire [STREAM_DATA_WIDTH-1'b1 :0]   s_ssdn_wrap2ip_tdata         ;
    wire                               s_ssdn_wrap2ip_tlast         ;
    wire                               s_ssdn_wrap2ip_tvalid        ;
    wire                               s_ssdn_ip2wrap_tready        ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] s_ssdn_wrap2ip_tkeep         ;  
    
    wire [STREAM_DATA_WIDTH-1'b1 :0]   sssdn_wrap2ip_tdata          ;
    wire                               sssdn_wrap2ip_tlast          ;
    wire                               sssdn_wrap2ip_tvalid         ;
    wire                               sssdn_ip2wrap_tready         ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] sssdn_wrap2ip_tkeep          ;    

    wire [STREAM_DATA_WIDTH-1'b1 :0]   s_sssdn_wrap2ip_tdata        ;
    wire                               s_sssdn_wrap2ip_tlast        ;
    wire                               s_sssdn_wrap2ip_tvalid       ;
    wire                               s_sssdn_ip2wrap_tready       ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] s_sssdn_wrap2ip_tkeep        ;  

    wire [STREAM_DATA_WIDTH-1'b1 :0]   s4dn_wrap2ip_tdata         ;
    wire                               s4dn_wrap2ip_tlast         ;
    wire                               s4dn_wrap2ip_tvalid        ;
    wire                               s4dn_ip2wrap_tready        ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] s4dn_wrap2ip_tkeep         ;      
    
    wire [STREAM_DATA_WIDTH-1'b1 :0]   ssssdn_wrap2ip_tdata         ;
    wire                               ssssdn_wrap2ip_tlast         ;
    wire                               ssssdn_wrap2ip_tvalid        ;
    wire                               ssssdn_ip2wrap_tready        ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] ssssdn_wrap2ip_tkeep         ;   

    wire [STREAM_DATA_WIDTH-1'b1 :0]   sssssdn_wrap2ip_tdata        ;
    wire                               sssssdn_wrap2ip_tlast        ;
    wire                               sssssdn_wrap2ip_tvalid       ;
    wire                               sssssdn_ip2wrap_tready       ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0] sssssdn_wrap2ip_tkeep        ;     

    wire [STREAM_DATA_WIDTH*4-1'b1 :0]   ss_up_ip2wrap_tdata         ;
    wire [1*4-1 :0]                      ss_up_ip2wrap_tlast         ;
    wire [1*4-1 :0]                      ss_up_ip2wrap_tvalid        ;
    wire [1*4-1 :0]                      ss_up_wrap2ip_tready        ;
    wire [STREAM_DATA_WIDTH*4/8-1'b1 :0] ss_up_ip2wrap_tkeep         ;
    
    wire [IP_STREAM_PORT-1 :0]           s_arp_req_supperss           ;
    wire [4-1 :0]                        ss_arp_req_supperss          ;
    
    
    
    wire [STREAM_DATA_WIDTH-1'b1 :0]                  s_sss_up_ip2wrap_tdata      ;
    wire [STREAM_DATA_WIDTH-1'b1 :0]                  sss_up_ip2wrap_tdata        ;
    wire [1-1 :0]                                     sss_up_ip2wrap_tlast        ;
    wire [1-1 :0]                                     sss_up_ip2wrap_tvalid       ;
    wire [1-1 :0]                                     sss_up_wrap2ip_tready       ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0]                sss_up_ip2wrap_tkeep        ;

    wire [STREAM_DATA_WIDTH-1'b1 :0]                  ssss_up_ip2wrap_tdata       ;
    wire [1-1 :0]                                     ssss_up_ip2wrap_tlast       ;
    wire [1-1 :0]                                     ssss_up_ip2wrap_tvalid      ;
    wire [1-1 :0]                                     ssss_up_wrap2ip_tready      ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0]                ssss_up_ip2wrap_tkeep       ;
    
    reg  [1-1 :0]                                     ssss_up_ip2wrap_tvalid_tig  ;

    wire [STREAM_DATA_WIDTH-1'b1 :0]                  sssss_up_ip2wrap_tdata       ;
    wire [1-1 :0]                                     sssss_up_ip2wrap_tlast       ;
    wire [1-1 :0]                                     sssss_up_ip2wrap_tvalid      ;
    wire [1-1 :0]                                     sssss_up_wrap2ip_tready      ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0]                sssss_up_ip2wrap_tkeep       ;

    wire [STREAM_DATA_WIDTH-1'b1 :0]                  alp_up_ip2wrap_tdata       ;
    wire [1-1 :0]                                     alp_up_ip2wrap_tlast       ;
    wire [1-1 :0]                                     alp_up_ip2wrap_tvalid      ;
    wire [1-1 :0]                                     alp_up_wrap2ip_tready      ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0]                alp_up_ip2wrap_tkeep       ;
    
    wire [STREAM_DATA_WIDTH-1'b1 :0]                  salp_up_ip2wrap_tdata       ;
    wire [1-1 :0]                                     salp_up_ip2wrap_tlast       ;
    wire [1-1 :0]                                     salp_up_ip2wrap_tvalid      ;
    wire [1-1 :0]                                     salp_up_wrap2ip_tready      ;
    wire [STREAM_DATA_WIDTH/8-1'b1 :0]                salp_up_ip2wrap_tkeep       ;    
    


    reg [31:0] src_address    ; 
    reg [31:0] dst0_address   ; 
    reg [31:0] dst1_address   ; 
    reg [31:0] dst2_address   ; 
    reg [31:0] dst3_address   ; 
    reg [ 4:0] ip_data_type   ; 
    reg [31:0] alp_length     ;
    reg [31:0] r_alp_length   ;

    reg  [31:0] alp_rx_frame_cnt;
    reg  [31:0] alp_tx_frame_cnt;
    wire [31:0] alp_if_ctrl     ;
    
    wire [4-1:0] stream_sel_tig;
    wire almost_full  ;
    wire almost_empty ;
    reg  [31:0]dst_address;
    reg  [15:0]up_alp_length_cnt;
    reg  [15:0]up_payload_length_cnt;
    reg  [7:0] state_current;
    reg  [7:0] state_next;
    reg  [7:0] state_dn_current;
    reg  [7:0] state_dn_next;    
    
    wire [STREAM_DATA_WIDTH-1 : 0]   alp_protocol_data;
    reg                              alp_protocol_valid;
    reg  [STREAM_DATA_WIDTH/8-1 : 0] alp_protocol_keep;
    reg                              alp_protocol_last;
    reg                              r_sss_up_wrap2ip_tready;    

   //////////////////////////////////////////
    reg  [15:0]                      dn_alp_length_cnt      ;
    reg  [15:0]                      r_dn_alp_length_cnt    ;
    wire                             s_sdn_wrap2ip_tvalid   ;
    reg  [15:0]                      dn_payload_length_cnt  ;
(* keep = "true" *)    reg  [15:0]                      dn_payload_length      ;
    reg  [16*3-1 :0]                 r_dn_payload_length    ;
    reg  [3:0]                       wr_dn_payload_frame_cnt;
    reg  [3:0]                       rd_dn_payload_frame_cnt;


    reg                                r_sssdn_wrap2ip_tlast        ;
    reg  [STREAM_DATA_WIDTH/8-1'b1 :0] r_sssdn_wrap2ip_tkeep        ;
    reg  [15:0]                        dn_payload_end_byte          ;
    
    wire [31:0]                        axis_wr_data_count           ;
    reg                                fifo_flow_data_en            ;

    wire dn_payload_almost_ongoing;
    wire dn_payload_ongoing;
    wire dn_alp_ongoing;

    wire [31:0]  ip_type_ip_type;
    wire [3:0]   version_type;
    wire [3:0]   version_major;
    wire [7:0]   version_minor;
    wire [15:0]  version_revision;
    wire [31:0]  src_address_src_address;
    wire [31:0]  dst0_address_dst0_address;
    wire [31:0]  dst1_address_dst1_address;
    wire [31:0]  dst2_address_dst2_address;
    wire [31:0]  dst3_address_dst3_address;
    wire [5:0]   ip_data_type_data_type0;
    wire [15:0]  alp_length_alp_length;
    wire [31:0]  alp_tx_frame_cnt_alp_frame_cnt;
    wire [31:0]  alp_rx_frame_cnt_alp_frame_cnt;
    wire [31:0]  alp_if_ctrl_resered;
    wire [31:0]  dst0_address_dst0_address_clr;
    localparam BUS_CLEAR_OFFS                   = 16'h8;
    reg [31:0] bus_clear_clear;
    reg ip_bus_clear_en;
    wire   bus_clear_sw_wen ;

    reg s_dn_pause;
    reg ip_clear_enable;

    //added by chunfeng.li
    reg  s_ip_ufc_rst_sync0   ;
    reg  s_ip_ufc_rst_sync1   ;
    reg  s_ip_stream_rst_sync0;
    reg  s_ip_stream_rst_sync1;

    always @(posedge s_ip_ufc_clk)
    begin
       s_ip_ufc_rst_sync0  <=  s_ip_ufc_rst;
       s_ip_ufc_rst_sync1  <=  s_ip_ufc_rst_sync0;
    end 

    always @(posedge s_ip_stream_clk) begin
        s_ip_stream_rst_sync0 <= s_ip_stream_rst;
        s_ip_stream_rst_sync1 <= s_ip_stream_rst_sync0;
    end


    initial begin 
        src_address     = 0; 
        dst0_address    = 0; 
        dst1_address    = 0; 
        dst2_address    = 0; 
        dst3_address    = 0; 
        alp_length      = 0;
        r_alp_length    = 0;
        ip_data_type    = 0; 
        //ip_stream_rst   = 1;
        ip_clear_enable = 0;
        ip_bus_clear_en_sync = 0;
    end



    assign ip_type_ip_type = IP_TYPE;
    assign version_type    = IP_VERSION_TYPE;
    assign version_major   = IP_VERSION_MAJOR;
    assign version_minor   = IP_VERSION_MINOR;
    assign version_revision= IP_VERSION_REVISION;
    assign alp_tx_frame_cnt_alp_frame_cnt = alp_tx_frame_cnt;
    assign alp_rx_frame_cnt_alp_frame_cnt = alp_rx_frame_cnt;
    always @( posedge s_ip_stream_clk) begin
        src_address     <= src_address_src_address ; 
        dst0_address    <= dst0_address_dst0_address; 
        dst1_address    <= dst1_address_dst1_address; 
        dst2_address    <= dst2_address_dst2_address; 
        dst3_address    <= dst3_address_dst3_address; 
        alp_length      <= ALP_LENGTH_FIXED;//alp_length_alp_length;
        r_alp_length    <= alp_length;
        ip_data_type    <= ip_data_type_data_type0;
        ip_clear_enable <= ip_bus_clear_en_sync[3] & (!ssss_up_ip2wrap_tvalid);
    end

// timing violation
reg r_dn_wrap2ip_tlast;
reg r_dn_wrap2ip_tvalid;
reg r_dn_ip2wrap_tready;
reg r_up_ip2wrap_tlast;
reg r_up_ip2wrap_tvalid;
reg r_up_wrap2ip_tready;
initial begin
    r_dn_wrap2ip_tlast    = 0;
    r_dn_wrap2ip_tvalid   = 0;
    r_dn_ip2wrap_tready   = 0;
    r_up_ip2wrap_tlast    = 0;
    r_up_ip2wrap_tvalid   = 0;
    r_up_wrap2ip_tready   = 0;
end
always @( posedge s_ip_stream_clk) begin
    r_dn_wrap2ip_tlast    <= dn_wrap2ip_tlast ;
    r_dn_wrap2ip_tvalid   <= dn_wrap2ip_tvalid;
    r_dn_ip2wrap_tready   <= dn_ip2wrap_tready;
    r_up_ip2wrap_tlast    <= up_ip2wrap_tlast  ;
    r_up_ip2wrap_tvalid   <= up_ip2wrap_tvalid ;
    r_up_wrap2ip_tready   <= up_wrap2ip_tready ;    
end
// end timing violation



    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           alp_tx_frame_cnt <= {32{1'b0}};
       end 
       else begin
           if(r_dn_wrap2ip_tlast & r_dn_wrap2ip_tvalid & r_dn_ip2wrap_tready)
               alp_tx_frame_cnt <= alp_tx_frame_cnt + 1'b1;                  
           else alp_tx_frame_cnt <= alp_tx_frame_cnt;
       end                                                            
    end    
    
    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           alp_rx_frame_cnt <= {32{1'b0}};
       end 
       else begin
           if(r_up_ip2wrap_tlast & r_up_ip2wrap_tvalid & r_up_wrap2ip_tready)
               alp_rx_frame_cnt <= alp_rx_frame_cnt + 1'b1;                  
           else alp_rx_frame_cnt <= alp_rx_frame_cnt;
       end                                                            
    end     

//////// monitor c2h alp timeout 
`ifdef  SIM_SBUS
    parameter INIT_width = 10;
`else
    parameter INIT_width = 28;
`endif  
reg [INIT_width:0] c2h_alp_timeout_cnt=0;
reg [1:0] c2h_monitor_state=0;
reg [INIT_width:0] h2c_alp_timeout_cnt=0;
reg [1:0] h2c_monitor_state=0;

always @ (posedge s_ip_stream_clk) begin
    case (c2h_monitor_state)
        2'h0 : begin if(r_up_ip2wrap_tvalid& r_up_wrap2ip_tready)
                       c2h_monitor_state <= 2'h1;
                     else c2h_monitor_state <= c2h_monitor_state;
                     
                     c2h_alp_timeout_cnt <= {INIT_width{1'h0}};
               end
        2'h1 : begin if (r_up_ip2wrap_tlast & r_up_ip2wrap_tvalid & r_up_wrap2ip_tready)
                       c2h_monitor_state <= 2'h0;
                     if(c2h_alp_timeout_cnt[INIT_width])
                       c2h_monitor_state <= 2'h2;
                     else c2h_monitor_state <= c2h_monitor_state;
                     
                     c2h_alp_timeout_cnt <= c2h_alp_timeout_cnt + 1'h1;
               end
        2'h2 : begin 
                     c2h_monitor_state <= 2'h3;
                     c2h_alp_timeout_cnt <= c2h_alp_timeout_cnt;
               end
        2'h3 : begin 
                     c2h_monitor_state <= 2'h0;
                     c2h_alp_timeout_cnt <= c2h_alp_timeout_cnt;
               end
        default : begin
                     c2h_monitor_state <= 2'h0;
                     c2h_alp_timeout_cnt <= {INIT_width{1'h0}};
        end
    endcase
end
always @ (posedge s_ip_stream_clk) begin
    case (h2c_monitor_state)
        2'h0 : begin if(r_dn_wrap2ip_tvalid & r_dn_ip2wrap_tready)
                       h2c_monitor_state <= 2'h1;
                     else h2c_monitor_state <= h2c_monitor_state;
                     
                     h2c_alp_timeout_cnt <= {INIT_width{1'h0}};
               end
        2'h1 : begin if (r_dn_wrap2ip_tlast & r_dn_wrap2ip_tvalid & r_dn_ip2wrap_tready)
                       h2c_monitor_state <= 2'h0;
                     if(h2c_alp_timeout_cnt[INIT_width])
                       h2c_monitor_state <= 2'h2;
                     else h2c_monitor_state <= h2c_monitor_state;
                     
                     h2c_alp_timeout_cnt <= h2c_alp_timeout_cnt + 1'h1;
               end
        2'h2 : begin 
                     h2c_monitor_state <= 2'h3;
                     h2c_alp_timeout_cnt <= h2c_alp_timeout_cnt;
               end
        2'h3 : begin 
                     h2c_monitor_state <= 2'h0;
                     h2c_alp_timeout_cnt <= h2c_alp_timeout_cnt;
               end
        default : begin
                     h2c_monitor_state <= 2'h0;
                     h2c_alp_timeout_cnt <= {INIT_width{1'h0}};
        end
    endcase
end
//end monitor alp time out  
generate
    //*********************************************
    //        IP_ALP_BYPASS_ENABLE design
    //*********************************************
    if ( IP_ALP_BYPASS == 1 ) begin : IP_ALP_BYPASS_ENABLE
    assign up_ip2wrap_tdata      =   s_up_ip2wrap_tdata[STREAM_DATA_WIDTH*0 +: STREAM_DATA_WIDTH]         ;
    assign up_ip2wrap_tlast      =   s_up_ip2wrap_tlast[0]                                                ;
    assign up_ip2wrap_tvalid     =   (~axis_bus_clear_en) & s_up_ip2wrap_tvalid[0]                                               ;
    assign s_up_wrap2ip_tready[0]=   axis_bus_clear_en    | up_wrap2ip_tready                                                    ;
    assign up_ip2wrap_tkeep      =   s_up_ip2wrap_tkeep[STREAM_DATA_WIDTH/8*0 +: STREAM_DATA_WIDTH/8]     ;

    assign  s_dn_wrap2ip_tdata   = dn_wrap2ip_tdata                                ;
    assign  s_dn_wrap2ip_tlast   = dn_wrap2ip_tlast                                ;
    assign  s_dn_wrap2ip_tvalid  = (~axis_bus_clear_en) & dn_wrap2ip_tvalid        ;
    assign  dn_ip2wrap_tready    = axis_bus_clear_en    | s_dn_ip2wrap_tready      ;
    assign  s_dn_wrap2ip_tkeep   = dn_wrap2ip_tkeep                                ;
    assign interrupt       = s_interrupt     ;
    assign ip_stream_clk   = s_ip_stream_clk ;
    assign ip_stream_rst   = s_ip_stream_rst_sync1 ;
    assign ip_ufc_clk      = s_ip_ufc_clk    ;
    assign ip_ufc_rst      = s_ip_ufc_rst_sync1    ; 
    //always @ (posedge s_ip_stream_clk) begin
    //    case (ip_stream_rst)
    //      1'b0 : ip_stream_rst <= 1'b0;
    //      1'b1 : ip_stream_rst <= s_ip_stream_rst_sync1;
    //      default : ip_stream_rst <= 1'b1;
    //    endcase
    //end
    end
    //*********************************************
    //        IP_ALP_CODES design
    //*********************************************
    else begin :IP_ALP_CODES
    //*********************************************
    //        up stream design
    //********************************************* 

    

    assign interrupt       = s_interrupt     ;
    assign ip_stream_clk   = s_ip_stream_clk ;
    assign ip_stream_rst   = s_ip_stream_rst_sync1 ;
    assign ip_ufc_clk      = s_ip_ufc_clk    ;
    assign ip_ufc_rst      = s_ip_ufc_rst_sync1    ;
    //always @ (posedge s_ip_stream_clk) begin
    //    case (ip_stream_rst)
    //      1'b0 : ip_stream_rst <= 1'b0;
    //      1'b1 : ip_stream_rst <= s_ip_stream_rst_sync1;
    //      default : ip_stream_rst <= 1'b1;
    //    endcase
    //end
    assign aclk            = s_ip_stream_clk           ;
    assign aresetn         = ~ip_stream_rst          ;
    
    assign ss_up_ip2wrap_tdata       =  {{4{32'h0}},s_up_ip2wrap_tdata};
    assign ss_up_ip2wrap_tlast       =  {4'h0,s_up_ip2wrap_tlast };
    assign ss_up_ip2wrap_tvalid      =  {4'h0, ((~axis_bus_clear_en) & s_up_ip2wrap_tvalid)};
    assign s_up_wrap2ip_tready       =  {4{axis_bus_clear_en}} || ss_up_wrap2ip_tready[IP_STREAM_PORT-1 :0];
    assign ss_up_ip2wrap_tkeep       =  {{4{8'h0}},s_up_ip2wrap_tkeep };
    assign s_arp_req_supperss        =  {IP_STREAM_PORT{1'b0}};
    assign ss_arp_req_supperss       =  {4'hf,s_arp_req_supperss};

    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           r_sss_up_wrap2ip_tready <= {1{1'b0}};
       end 
       else begin
           if ((state_current == STATE_IDLE))
           r_sss_up_wrap2ip_tready <= 1'b1;
           else if(sss_up_ip2wrap_tlast & sss_up_wrap2ip_tready & sss_up_ip2wrap_tvalid)
           r_sss_up_wrap2ip_tready <= 1'b0;
           else r_sss_up_wrap2ip_tready <= r_sss_up_wrap2ip_tready;
       end                                                            
    end 
    
    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           up_alp_length_cnt <= {16{1'b0}};
       end 
       else begin
           if(up_alp_length_cnt >= (alp_length[15:0]))begin
           up_alp_length_cnt <= {16{1'b0}};
           end else if ((ssss_up_ip2wrap_tvalid && ssss_up_wrap2ip_tready) || (alp_up_ip2wrap_tvalid && alp_up_wrap2ip_tready))begin 
           up_alp_length_cnt <= up_alp_length_cnt + 4'h8;
           end else begin 
           up_alp_length_cnt <= up_alp_length_cnt;
           end          
       end                                                            
    end 


    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           up_payload_length_cnt <= {16{1'b0}};
       end 
       else begin
            if(state_current[1] & alp_protocol_valid & alp_up_wrap2ip_tready)begin
            up_payload_length_cnt <= {16{1'b0}};
            end else if (ssss_up_ip2wrap_tvalid && ssss_up_wrap2ip_tready)begin 
            up_payload_length_cnt <= up_payload_length_cnt + ssss_up_ip2wrap_tkeep[0] + ssss_up_ip2wrap_tkeep[1] +
                                        ssss_up_ip2wrap_tkeep[2] + ssss_up_ip2wrap_tkeep[3] + 
                                        ssss_up_ip2wrap_tkeep[4] + ssss_up_ip2wrap_tkeep[5] + 
                                        ssss_up_ip2wrap_tkeep[6] + ssss_up_ip2wrap_tkeep[7]  ;
            end else begin 
            up_payload_length_cnt <= up_payload_length_cnt;
            end
       end                                                            
    end 

    
    assign    stream_sel_tig = 
                             {
                              (ss_up_ip2wrap_tvalid[3]&ss_up_wrap2ip_tready[3]),
                              (ss_up_ip2wrap_tvalid[2]&ss_up_wrap2ip_tready[2]),
                              (ss_up_ip2wrap_tvalid[1]&ss_up_wrap2ip_tready[1]),
                              (ss_up_ip2wrap_tvalid[0]&ss_up_wrap2ip_tready[0])
                             };  
    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           dst_address <= {REG_DATA_WIDTH{1'b0}};
       end 
       else begin
           case (stream_sel_tig)
           4'b0001 : begin dst_address <= dst0_address;  end 
           4'b0010 : begin dst_address <= dst1_address;  end
           4'b0100 : begin dst_address <= dst2_address;  end        
           4'b1000 : begin dst_address <= dst3_address;  end
           default : begin dst_address <= dst_address ;  end
           endcase           
       end                                                            
    end   
    //emu-18027
    reg [5:0] upload_timeout_cnt = 0;
    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           upload_timeout_cnt <= {6{1'b0}};
       end else begin
           if(ssss_up_ip2wrap_tvalid & ssss_up_wrap2ip_tready)
               upload_timeout_cnt <= {6{1'b0}};
           else if((!ssss_up_ip2wrap_tvalid) & ssss_up_wrap2ip_tready)
               upload_timeout_cnt <= upload_timeout_cnt + 1'b1;
           else if((sssss_up_ip2wrap_tvalid) & (!sssss_up_wrap2ip_tready))
               upload_timeout_cnt <= {6{1'b0}};
           else 
               upload_timeout_cnt <= upload_timeout_cnt;
       end                                                            
    end 
    //end emu-18027

    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           state_current <= {8{1'b0}};
       end 
       else begin
           state_current <= state_next;
       end                                                            
    end 

    always @(*) begin 
       if (ip_stream_rst) begin 
           state_next = {8{1'b0}};
       end 
       else begin
           case (state_current)
               STATE_IDLE     : begin 
                                if ((sss_up_ip2wrap_tvalid & sss_up_wrap2ip_tready & r_sss_up_wrap2ip_tready) || ssss_up_ip2wrap_tvalid_tig)
                                     state_next =  STATE_START;  
                                else state_next =  STATE_IDLE;
                                end
               STATE_START    : begin 
                                if (alp_up_ip2wrap_tvalid&alp_up_wrap2ip_tready)
                                     state_next =  STATE_S1;  
                                else state_next =  STATE_START;
                                end  //send ALP frame head ETC
               STATE_END      : begin//send ALP frame end ETC
                                if (alp_up_ip2wrap_tvalid&alp_up_wrap2ip_tready)
                                     state_next =  STATE_IDLE;  
                                else state_next =  STATE_END;               
                                end
               STATE_S1       : begin 
                                if (ip_clear_enable) begin
                                            if (up_alp_length_cnt >= (alp_length[15:0]-16'h8))
                                                 state_next =  STATE_END;
                                            else state_next =  STATE_S3;
                                end else begin
                                        if (ssss_up_ip2wrap_tlast & ssss_up_ip2wrap_tvalid & ssss_up_wrap2ip_tready) begin
                                            if (up_alp_length_cnt >= (alp_length[15:0]-16'h10))
                                                 state_next =  STATE_END;
                                            else state_next =  STATE_S3;
                                        end else if(ssss_up_ip2wrap_tvalid & ssss_up_wrap2ip_tready)begin 
                                                        if (up_alp_length_cnt >= (alp_length[15:0]-16'h10))
                                                             state_next =  STATE_END;
                                                        else state_next =  STATE_S1;
                                        end else if (upload_timeout_cnt[5]) begin
                                                 state_next =  STATE_S3;
                                        end else begin 
                                            state_next =  STATE_S1;
                                        end
                                end
                                end  //send payload
               STATE_S2       : begin
                                    state_next =  STATE_S3;
                                end  //fifo empty
               STATE_S3       : begin //padding type 8`h ee 
                                if (up_alp_length_cnt >= (alp_length[15:0]-16'h10))
                                     state_next =  STATE_S4;  
                                else state_next =  STATE_S3;                                
                                end 
               STATE_S4       : begin //padding type 8`h ee 
                                if (up_alp_length_cnt >= (alp_length[15:0]-16'h8))
                                     state_next =  STATE_END;  
                                else state_next =  STATE_S4;                                
                                end 
               default        : begin state_next =  STATE_IDLE;end
           endcase
       end                                                            
    end 

    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
            alp_protocol_valid<= 1'b0;
            alp_protocol_keep <= {(STREAM_DATA_WIDTH/8){1'b0}};
            alp_protocol_last <= 1'b0;
       end 
       else begin
           case (state_next)
               STATE_IDLE     : begin 
                                    alp_protocol_valid<= 1'b0;
                                    alp_protocol_keep <= {(STREAM_DATA_WIDTH/8){1'b0}};
                                    alp_protocol_last <= 1'b0;
                                end
               STATE_START    : begin 
                                    alp_protocol_valid<= 1'b1;
                                    alp_protocol_keep <= {(STREAM_DATA_WIDTH/8){1'b1}};
                                    alp_protocol_last <= 1'b0;
                                end  //send ALP frame head ETC
               STATE_END      : begin//send ALP frame end ETC
                                    alp_protocol_valid<= 1'b1;
                                    alp_protocol_keep <= {(STREAM_DATA_WIDTH/8){1'b1}};
                                    alp_protocol_last <= 1'b1;
                                end
               STATE_S1       : begin ///check sss_up_ip2wrap_last
                                    alp_protocol_valid<= 1'b0;
                                    alp_protocol_keep <= {(STREAM_DATA_WIDTH/8){1'b0}};
                                    alp_protocol_last <= 1'b0;
                                end  //send payload
               STATE_S2       : begin
                                    alp_protocol_valid<= 1'b0;
                                    alp_protocol_keep <= {(STREAM_DATA_WIDTH/8){1'b0}};
                                    alp_protocol_last <= 1'b0;
                                end  //fifo empty
               STATE_S3       : begin //padding type 8`h ee 
                                    alp_protocol_valid<= 1'b1;
                                    alp_protocol_keep <= {(STREAM_DATA_WIDTH/8){1'b1}};
                                    alp_protocol_last <= 1'b0;
                                end
               STATE_S4       : begin //padding type 8`h ee 
                                if (alp_up_wrap2ip_tready) begin
                                    alp_protocol_valid<= 1'b0;
                                    alp_protocol_keep <= {(STREAM_DATA_WIDTH/8){1'b1}};
                                    alp_protocol_last <= 1'b0;
                                end
                                end
               default        : begin end
           endcase
       end                                                            
    end 


assign alp_protocol_data = (alp_protocol_valid & alp_up_wrap2ip_tready & state_current[0]) ? {dst_address,timestamp,ip_data_type,FRAME_HEAD} :
                           (alp_protocol_valid & alp_up_wrap2ip_tready & state_current[1]) ? {FRAME_END,src_address,up_payload_length_cnt} :
                                                                     {8{8'hee}};


assign ssss_up_wrap2ip_tready  = ((state_current [2]) || (state_current [3]) ) ? sssss_up_wrap2ip_tready : 1'b0;
//assign ssss_up_wrap2ip_tready  = ((up_alp_length_cnt < (alp_length[15:0]-16'h10)||(|up_alp_length_cnt)) ? sssss_up_wrap2ip_tready : 1'b0;
assign salp_up_wrap2ip_tready  = ((state_current [2]) || (state_current [3])) ? 1'b0 : sssss_up_wrap2ip_tready;
assign sssss_up_ip2wrap_tvalid = ((state_current [2]) || (state_current [3])) ? ssss_up_ip2wrap_tvalid : salp_up_ip2wrap_tvalid;
assign sssss_up_ip2wrap_tdata  = ((state_current [2]) || (state_current [3])) ? ssss_up_ip2wrap_tdata : salp_up_ip2wrap_tdata;
assign sssss_up_ip2wrap_tkeep  = 8'hFF;
assign sssss_up_ip2wrap_tlast  = (state_current[1]) ? salp_up_ip2wrap_tlast:1'b0;
                                 
assign alp_up_ip2wrap_tdata   =  alp_protocol_data  ;
assign alp_up_ip2wrap_tlast   =  alp_protocol_last  ;
assign alp_up_ip2wrap_tvalid  =  alp_protocol_valid ;
assign alp_up_ip2wrap_tkeep   =  alp_protocol_keep  ;


    uvw_axis_register_slice u_uvw_axis_interconnect(
        .aclk           (aclk    ) ,
        .aresetn        (aresetn ) ,
        .s_axis_tvalid  (ss_up_ip2wrap_tvalid[0] ),
        .s_axis_tready  (ss_up_wrap2ip_tready[0] ),
        .s_axis_tdata   (ss_up_ip2wrap_tdata[STREAM_DATA_WIDTH*0 +: STREAM_DATA_WIDTH]),
        .s_axis_tkeep   (ss_up_ip2wrap_tkeep[STREAM_DATA_WIDTH/8*0 +: STREAM_DATA_WIDTH/8]  ),
        .s_axis_tlast   (ss_up_ip2wrap_tlast[0]  ),
        .m_axis_tvalid  (sss_up_ip2wrap_tvalid ),                          
        .m_axis_tready  (sss_up_wrap2ip_tready & r_sss_up_wrap2ip_tready ),
        .m_axis_tdata   (sss_up_ip2wrap_tdata  ),                          
        .m_axis_tkeep   (sss_up_ip2wrap_tkeep  ),                          
        .m_axis_tlast   (sss_up_ip2wrap_tlast  )                          
    );
//    uvw_axis_interconnect u_uvw_axis_interconnect(
//        .ACLK                    (aclk                  ),
//        .ARESETN                 (aresetn               ),
//        .S00_AXIS_ACLK           (aclk                  ),
//        .S01_AXIS_ACLK           (aclk                  ),
//        .S02_AXIS_ACLK           (aclk                  ),
//        .S03_AXIS_ACLK           (aclk                  ),
//        .S00_AXIS_ARESETN        (aresetn               ),
//        .S01_AXIS_ARESETN        (aresetn               ),
//        .S02_AXIS_ARESETN        (aresetn               ),
//        .S03_AXIS_ARESETN        (aresetn               ),
//        .S00_AXIS_TVALID         (ss_up_ip2wrap_tvalid[0]   ),
//        .S01_AXIS_TVALID         (ss_up_ip2wrap_tvalid[1]   ),
//        .S02_AXIS_TVALID         (ss_up_ip2wrap_tvalid[2]   ),
//        .S03_AXIS_TVALID         (ss_up_ip2wrap_tvalid[3]   ),
//        .S00_AXIS_TREADY         (ss_up_wrap2ip_tready[0]   ),
//        .S01_AXIS_TREADY         (ss_up_wrap2ip_tready[1]   ),
//        .S02_AXIS_TREADY         (ss_up_wrap2ip_tready[2]   ),
//        .S03_AXIS_TREADY         (ss_up_wrap2ip_tready[3]   ),
//        .S00_AXIS_TDATA          (ss_up_ip2wrap_tdata[STREAM_DATA_WIDTH*0 +: STREAM_DATA_WIDTH]       ),
//        .S01_AXIS_TDATA          (ss_up_ip2wrap_tdata[STREAM_DATA_WIDTH*1 +: STREAM_DATA_WIDTH]       ),
//        .S02_AXIS_TDATA          (ss_up_ip2wrap_tdata[STREAM_DATA_WIDTH*2 +: STREAM_DATA_WIDTH]       ),
//        .S03_AXIS_TDATA          (ss_up_ip2wrap_tdata[STREAM_DATA_WIDTH*3 +: STREAM_DATA_WIDTH]       ),
//        .S00_AXIS_TKEEP          (ss_up_ip2wrap_tkeep[STREAM_DATA_WIDTH/8*0 +: STREAM_DATA_WIDTH/8]   ),
//        .S01_AXIS_TKEEP          (ss_up_ip2wrap_tkeep[STREAM_DATA_WIDTH/8*1 +: STREAM_DATA_WIDTH/8]   ),
//        .S02_AXIS_TKEEP          (ss_up_ip2wrap_tkeep[STREAM_DATA_WIDTH/8*2 +: STREAM_DATA_WIDTH/8]   ),
//        .S03_AXIS_TKEEP          (ss_up_ip2wrap_tkeep[STREAM_DATA_WIDTH/8*3 +: STREAM_DATA_WIDTH/8]   ),
//        .S00_AXIS_TLAST          (ss_up_ip2wrap_tlast[0]    ),
//        .S01_AXIS_TLAST          (ss_up_ip2wrap_tlast[1]    ),
//        .S02_AXIS_TLAST          (ss_up_ip2wrap_tlast[2]    ),
//        .S03_AXIS_TLAST          (ss_up_ip2wrap_tlast[3]    ),
//        .M00_AXIS_ACLK           (aclk                  ),
//        .M00_AXIS_ARESETN        (aresetn               ),
//        .M00_AXIS_TVALID         (sss_up_ip2wrap_tvalid ),
//        .M00_AXIS_TREADY         (sss_up_wrap2ip_tready & r_sss_up_wrap2ip_tready ),
//        .M00_AXIS_TDATA          (sss_up_ip2wrap_tdata  ),
//        .M00_AXIS_TKEEP          (sss_up_ip2wrap_tkeep  ),
//        .M00_AXIS_TLAST          (sss_up_ip2wrap_tlast  ),
//        .S00_ARB_REQ_SUPPRESS    (ss_arp_req_supperss[0]),
//        .S01_ARB_REQ_SUPPRESS    (ss_arp_req_supperss[1]),
//        .S02_ARB_REQ_SUPPRESS    (ss_arp_req_supperss[2]),
//        .S03_ARB_REQ_SUPPRESS    (ss_arp_req_supperss[3])
//    );

    genvar i;
    //generate
        for (i = 0; i < 8; i = i + 1 ) begin : W1
            assign s_sss_up_ip2wrap_tdata [8*i +: 8] = sss_up_ip2wrap_tkeep [i] ? sss_up_ip2wrap_tdata [8*i +: 8] : 8'hee;  
        end        
    //endgenerate
    
    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           ssss_up_ip2wrap_tvalid_tig <= 1'b0;
       end 
       else begin
           if (sss_up_ip2wrap_tvalid & r_sss_up_wrap2ip_tready & sss_up_wrap2ip_tready)
               ssss_up_ip2wrap_tvalid_tig <= 1'b1;
           else ssss_up_ip2wrap_tvalid_tig <= ssss_up_ip2wrap_tvalid;

           //if (ssss_up_ip2wrap_tvalid) 
           //    ssss_up_ip2wrap_tvalid_tig <= 1'b1;
           //else 
           //    ssss_up_ip2wrap_tvalid_tig <= 1'b0;

           //if (ssss_up_ip2wrap_tvalid & ssss_up_wrap2ip_tready)
           //    ssss_up_ip2wrap_tvalid_tig <= 1'b0;
           //else ssss_up_ip2wrap_tvalid_tig <= ssss_up_ip2wrap_tvalid_tig;
       end                                                            
    end 
    
//when reset, input ready is low will cause a data stuffed to this register
//slice. when reset release, this register slice will output a dirty data.
    uvw_axis_register_slice u_uvw_axis_up_slice(
       .aclk          (aclk    ) ,
       .aresetn       (aresetn ) ,
       //.aresetn       (1'b1 ) ,
        .s_axis_tvalid  (sss_up_ip2wrap_tvalid & r_sss_up_wrap2ip_tready ),
        .s_axis_tready  (sss_up_wrap2ip_tready ),
        .s_axis_tdata   (s_sss_up_ip2wrap_tdata),
        .s_axis_tkeep   (sss_up_ip2wrap_tkeep  ),
        .s_axis_tlast   (sss_up_ip2wrap_tlast  ),
        .m_axis_tvalid  (ssss_up_ip2wrap_tvalid),
        .m_axis_tready  (ssss_up_wrap2ip_tready),
        .m_axis_tdata   (ssss_up_ip2wrap_tdata ),
        .m_axis_tkeep   (ssss_up_ip2wrap_tkeep ),
        .m_axis_tlast   (ssss_up_ip2wrap_tlast )
    );




//when reset, input ready is low will cause a data stuffed to this register
//slice. when reset release, this register slice will output a dirty data.
    uvw_axis_register_slice u_uvw_axis_register_slice(
       .aclk          (aclk    ) ,
       .aresetn       (aresetn ) ,
       //.aresetn       (1'b1) ,
       .s_axis_tvalid (sssss_up_ip2wrap_tvalid ) ,
       .s_axis_tready (sssss_up_wrap2ip_tready ) ,
       .s_axis_tdata  (sssss_up_ip2wrap_tdata  ) ,
       .s_axis_tkeep  (sssss_up_ip2wrap_tkeep  ) ,
       .s_axis_tlast  (sssss_up_ip2wrap_tlast  ) ,
       .m_axis_tvalid (up_ip2wrap_tvalid ) ,
       .m_axis_tready (up_wrap2ip_tready ) ,
       .m_axis_tdata  (up_ip2wrap_tdata  ) ,
       .m_axis_tkeep  (up_ip2wrap_tkeep  ) ,
       .m_axis_tlast  (up_ip2wrap_tlast  ) 
    );



    assign salp_up_ip2wrap_tvalid  =  alp_up_ip2wrap_tvalid   ;
    assign alp_up_wrap2ip_tready   = salp_up_wrap2ip_tready   ;
    assign salp_up_ip2wrap_tdata   =  alp_up_ip2wrap_tdata    ;
    assign salp_up_ip2wrap_tkeep   =  alp_up_ip2wrap_tkeep    ;
    assign salp_up_ip2wrap_tlast   =  alp_up_ip2wrap_tlast    ;

    //*********************************************
    //        down stream design
    //********************************************* 
 

    wire dn_ip2wrap_tready_pause;
    wire dn_wrap2ip_tvalid_pause;
    assign dn_wrap2ip_tvalid_pause = (~axis_bus_clear_en) & dn_wrap2ip_tvalid & s_dn_pause;
    assign dn_ip2wrap_tready       = axis_bus_clear_en    | (dn_ip2wrap_tready_pause & s_dn_pause);

//when reset, input ready is low will cause a data stuffed to this register
//slice. when reset release, this register slice will output a dirty data.
    uvw_axis_register_slice u_uvw_axis_dn_induf(
       .aclk          (aclk    ) ,
       .aresetn       (aresetn ) ,
       //.aresetn       (1'b1) ,
       .s_axis_tvalid (dn_wrap2ip_tvalid_pause   ) ,
       .s_axis_tready (dn_ip2wrap_tready_pause   ) ,
       .s_axis_tdata  (dn_wrap2ip_tdata    ) ,
       .s_axis_tkeep  (dn_wrap2ip_tkeep    ) ,
       .s_axis_tlast  (dn_wrap2ip_tlast    ) ,
       .m_axis_tvalid (sdn_wrap2ip_tvalid  ) ,
       .m_axis_tready (sdn_ip2wrap_tready  ) ,
       .m_axis_tdata  (sdn_wrap2ip_tdata   ) ,
       .m_axis_tkeep  (sdn_wrap2ip_tkeep   ) ,
       .m_axis_tlast  (sdn_wrap2ip_tlast   ) 
    );

    
    
    assign s_sdn_wrap2ip_tvalid  = (r_dn_alp_length_cnt == 16'h0) ? 1'b0 :
                                   (r_dn_alp_length_cnt >= (r_alp_length[15:0]-16'h8)) ? 1'b0 : 1'b1;
   
    assign ssdn_wrap2ip_tvalid  = sdn_wrap2ip_tvalid  && s_sdn_wrap2ip_tvalid  ;
    assign sdn_ip2wrap_tready   = ssdn_ip2wrap_tready   ;
    assign ssdn_wrap2ip_tdata   = sdn_wrap2ip_tdata     ;
    assign ssdn_wrap2ip_tkeep   = sdn_wrap2ip_tkeep     ;
    assign ssdn_wrap2ip_tlast   = (r_dn_alp_length_cnt == (r_alp_length[15:0]-16'h10))     ;
    
    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           r_dn_alp_length_cnt <= {16{1'b0}};
       end 
       else begin
           if(sdn_wrap2ip_tlast)
           r_dn_alp_length_cnt <= {16{1'b0}};
           else if (sdn_wrap2ip_tvalid && sdn_ip2wrap_tready)
               r_dn_alp_length_cnt <= r_dn_alp_length_cnt + 4'h8;
           else r_dn_alp_length_cnt <= r_dn_alp_length_cnt;
       end                                                            
    end 
    
    always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
       if (ip_stream_rst) begin 
           dn_alp_length_cnt <= {16{1'b0}};
       end 
       else begin
           if(dn_wrap2ip_tlast)begin
           dn_alp_length_cnt <= {16{1'b0}};
           end else if ((dn_wrap2ip_tvalid && dn_ip2wrap_tready) )begin 
           dn_alp_length_cnt <= dn_alp_length_cnt + 4'h8;
           end else begin 
           dn_alp_length_cnt <= dn_alp_length_cnt;
           end          
       end                                                            
    end       
    
    //generate
    //*********************************************
    //        CO_EMU_IP down stream design
    //********************************************* 
        if ( IP_TYPE == 32'hB ) begin : CO_EMU_IP

//when reset, input ready is low will cause a data stuffed to this register
//slice. when reset release, this register slice will output a dirty data.
            uvw_axis_register_slice u_uvw_axis_dn_co_emu (
               .aclk          (aclk    ) ,
               .aresetn       (aresetn ) ,
               //.aresetn       (1'b1) ,
               .s_axis_tvalid (ssdn_wrap2ip_tvalid   ) ,
               .s_axis_tready (ssdn_ip2wrap_tready   ) ,
               .s_axis_tdata  (ssdn_wrap2ip_tdata    ) ,
               .s_axis_tkeep  (ssdn_wrap2ip_tkeep    ) ,
               .s_axis_tlast  (ssdn_wrap2ip_tlast    ) ,
               .m_axis_tvalid (s_dn_wrap2ip_tvalid   ) ,
               .m_axis_tready (s_dn_ip2wrap_tready   ) ,
               .m_axis_tdata  (s_dn_wrap2ip_tdata    ) ,
               .m_axis_tkeep  (s_dn_wrap2ip_tkeep    ) ,
               .m_axis_tlast  (s_dn_wrap2ip_tlast    ) 
            );            
            //assign s_dn_wrap2ip_tvalid  =  ssdn_wrap2ip_tvalid  ;
            //assign ssdn_ip2wrap_tready  =  s_dn_ip2wrap_tready  ;
            //assign s_dn_wrap2ip_tdata   =  ssdn_wrap2ip_tdata   ;
            //assign s_dn_wrap2ip_tkeep   =  ssdn_wrap2ip_tkeep   ;
            //assign s_dn_wrap2ip_tlast   =  ssdn_wrap2ip_tlast   ;       
                initial begin
                    s_dn_pause   =   1;
                end 
             assign  almost_full  = 1'b0;
             assign  almost_empty = 1'b1; 
             assign  axis_wr_data_count = {29'h0,s_dn_wrap2ip_tvalid};                
        end 
    //*********************************************
    //        BACKDOOR_IP down stream design
    //*********************************************         
        else begin : BACKDOOR_IP

        
        assign s_ssdn_wrap2ip_tvalid    =  fifo_flow_data_en & ssdn_wrap2ip_tvalid  ;
        assign ssdn_ip2wrap_tready      =  fifo_flow_data_en & s_ssdn_ip2wrap_tready;
        assign s_ssdn_wrap2ip_tdata     =  ssdn_wrap2ip_tdata                       ;
        assign s_ssdn_wrap2ip_tkeep     =  {(STREAM_DATA_WIDTH/8){1'b0}};//ssdn_wrap2ip_tkeep                       ;
        assign s_ssdn_wrap2ip_tlast     =  ssdn_wrap2ip_tlast                       ;    
    
    
        
    
        always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
        if (ip_stream_rst) begin  
                fifo_flow_data_en <= 1'h1;            
        end 
        else begin
                if (axis_wr_data_count >= alp_length[REG_DATA_WIDTH-1:3])
                fifo_flow_data_en <= 1'b0;
                else fifo_flow_data_en <= 1'h1;  
        end                                                            
        end     
    
 
    
        always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
        if (ip_stream_rst) begin 
                wr_dn_payload_frame_cnt <= 4'h0;
        end 
        else begin
                //if(ssdn_wrap2ip_tlast & ssdn_ip2wrap_tready & ssdn_wrap2ip_tvalid)
                if(sdn_wrap2ip_tlast & sdn_ip2wrap_tready & sdn_wrap2ip_tvalid)
                    wr_dn_payload_frame_cnt <= wr_dn_payload_frame_cnt + 1'h1;
                else
                    wr_dn_payload_frame_cnt <= wr_dn_payload_frame_cnt;
        end                                                            
        end          
            
        always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
        if (ip_stream_rst) begin 
                rd_dn_payload_frame_cnt <= 4'h0;
        end 
        else begin
                if(sssdn_wrap2ip_tlast & sssdn_ip2wrap_tready & sssdn_wrap2ip_tvalid)
                    rd_dn_payload_frame_cnt <= rd_dn_payload_frame_cnt + 1'h1;
                else
                    rd_dn_payload_frame_cnt <= rd_dn_payload_frame_cnt;
        end                                                            
        end    

        always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
        if (ip_stream_rst) begin 
            dn_payload_length   <= 16'h0;
        end else begin
            if ((sdn_wrap2ip_tvalid & sdn_ip2wrap_tready & sdn_wrap2ip_tlast ) )
            dn_payload_length <= sdn_wrap2ip_tdata[15:0];
            else dn_payload_length <= dn_payload_length;
        end                                                            
        end       
    
        always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
            if (ip_stream_rst) begin 
                dn_payload_length_cnt   <= 16'h0;
            end 
            else begin
                if(sssdn_wrap2ip_tlast & sssdn_ip2wrap_tready & sssdn_wrap2ip_tvalid)
                dn_payload_length_cnt <= 16'h0;
                else if ((sssdn_ip2wrap_tready & sssdn_wrap2ip_tvalid) )
                dn_payload_length_cnt <= dn_payload_length_cnt + 16'h8;
                else dn_payload_length_cnt <= dn_payload_length_cnt;
            end                                                            
        end  


        assign dn_payload_ongoing = (dn_payload_length > dn_payload_length_cnt) ? 1'b1 : 1'b0;

        //assign dn_payload_almost_ongoing = (dn_payload_length - 16'h8 > dn_payload_length_cnt) ? 1'b1 : 1'b0;
        assign dn_payload_almost_ongoing = (dn_payload_length  > dn_payload_length_cnt + 16'h8) ? 1'b1 : 1'b0;

        assign dn_alp_ongoing     = |dn_payload_length ;
        // fixed emu EMU-17497 
        (* keep = "true" *)reg [16-1:0] dn_payload_length_copy = 0;
        (* keep = "true" *)reg r_dn_alp_ongoing = 0;
        always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
             if (ip_stream_rst) begin 
                 dn_payload_length_copy   <= 16'h0;
                 r_dn_alp_ongoing         <= 1'b0;
             end else begin
                 if ((sdn_wrap2ip_tvalid & sdn_ip2wrap_tready & sdn_wrap2ip_tlast ) ) begin 
                     dn_payload_length_copy <= sdn_wrap2ip_tdata[15:0];
                     r_dn_alp_ongoing       <= |sdn_wrap2ip_tdata[15:0];
                 end else begin  
                     dn_payload_length_copy <= dn_payload_length_copy;
                     r_dn_alp_ongoing       <= r_dn_alp_ongoing; 
                 end
             end                                                            
        end
        
        always @(posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
            if (ip_stream_rst) begin  
                r_sssdn_wrap2ip_tkeep <= 8'b00000000 ;             
            end 
            else begin
                //if(dn_payload_ongoing&(~dn_payload_almost_ongoing))begin 
                    case (dn_payload_length_copy[2:0])
                    0: begin r_sssdn_wrap2ip_tkeep <= 8'b11111111 ;end
                    1: begin r_sssdn_wrap2ip_tkeep <= 8'b00000001 ;end 
                    2: begin r_sssdn_wrap2ip_tkeep <= 8'b00000011 ;end
                    3: begin r_sssdn_wrap2ip_tkeep <= 8'b00000111 ;end 
                    4: begin r_sssdn_wrap2ip_tkeep <= 8'b00001111 ;end 
                    5: begin r_sssdn_wrap2ip_tkeep <= 8'b00011111 ;end 
                    6: begin r_sssdn_wrap2ip_tkeep <= 8'b00111111 ;end 
                    7: begin r_sssdn_wrap2ip_tkeep <= 8'b01111111 ;end 
                    default : begin  r_sssdn_wrap2ip_tkeep <= 8'b11111111 ;end 
                    endcase   
                //end  else begin 
                //    r_sssdn_wrap2ip_tkeep <= r_sssdn_wrap2ip_tkeep ; 
                //end         
            end                                                            
        end
        
        assign sssdn_ip2wrap_tready    = (|(wr_dn_payload_frame_cnt ^ rd_dn_payload_frame_cnt)) ?  (s_sssdn_ip2wrap_tready  & (r_dn_alp_ongoing) ) : 1'b0; 
        assign s_sssdn_wrap2ip_tkeep   =   sssdn_wrap2ip_tkeep   ;
        assign s_sssdn_wrap2ip_tlast   =  (dn_payload_length_copy[16-1:0] <= dn_payload_length_cnt[16-1:0] + 16'h8) ? 1'b1 : sssdn_wrap2ip_tlast   ;         
        // end fixed emu EMU-17497
        
        //always @(*) begin 
        //    if (ip_stream_rst) begin  
        //        r_sssdn_wrap2ip_tlast = 0; r_sssdn_wrap2ip_tkeep = 8'b00000000 ;             
        //    end 
        //    else begin
        //        if(dn_payload_ongoing&(~dn_payload_almost_ongoing))begin 
        //            case (dn_payload_length_copy[2:0])
        //            0: begin r_sssdn_wrap2ip_tlast = 1; r_sssdn_wrap2ip_tkeep = 8'b11111111 ;end
        //            1: begin r_sssdn_wrap2ip_tlast = 1; r_sssdn_wrap2ip_tkeep = 8'b00000001 ;end 
        //            2: begin r_sssdn_wrap2ip_tlast = 1; r_sssdn_wrap2ip_tkeep = 8'b00000011 ;end
        //            3: begin r_sssdn_wrap2ip_tlast = 1; r_sssdn_wrap2ip_tkeep = 8'b00000111 ;end 
        //            4: begin r_sssdn_wrap2ip_tlast = 1; r_sssdn_wrap2ip_tkeep = 8'b00001111 ;end 
        //            5: begin r_sssdn_wrap2ip_tlast = 1; r_sssdn_wrap2ip_tkeep = 8'b00011111 ;end 
        //            6: begin r_sssdn_wrap2ip_tlast = 1; r_sssdn_wrap2ip_tkeep = 8'b00111111 ;end 
        //            7: begin r_sssdn_wrap2ip_tlast = 1; r_sssdn_wrap2ip_tkeep = 8'b01111111 ;end 
        //            default : begin r_sssdn_wrap2ip_tlast = 0; r_sssdn_wrap2ip_tkeep = 8'b00000000 ;end 
        //            endcase   
        //        end  else begin 
        //            r_sssdn_wrap2ip_tlast = 0; r_sssdn_wrap2ip_tkeep = 8'b00000000 ; 
        //        end         
        //    end                                                            
        //end
        
        
        //assign sssdn_ip2wrap_tready    = (|(wr_dn_payload_frame_cnt ^ rd_dn_payload_frame_cnt)) ?  (s_sssdn_ip2wrap_tready  & (dn_alp_ongoing) ) : 1'b0; 
        assign s_sssdn_wrap2ip_tvalid  = (|(wr_dn_payload_frame_cnt ^ rd_dn_payload_frame_cnt)) ?  (sssdn_wrap2ip_tvalid & dn_payload_ongoing)     : 1'b0;   
        assign s_sssdn_wrap2ip_tdata   =  sssdn_wrap2ip_tdata   ;
        //assign s_sssdn_wrap2ip_tkeep   =  (dn_payload_ongoing&(~dn_payload_almost_ongoing)) ? (sssdn_wrap2ip_tkeep & r_sssdn_wrap2ip_tkeep) : sssdn_wrap2ip_tkeep   ;
        //assign s_sssdn_wrap2ip_tlast   =  (dn_payload_ongoing&(~dn_payload_almost_ongoing)) ? r_sssdn_wrap2ip_tlast : sssdn_wrap2ip_tlast   ;   
        assign sssdn_wrap2ip_tkeep = {(STREAM_DATA_WIDTH/8){1'b1}};
      //  uvw_axis_data_fifo_4KB u_uvw_axis_data_fifo_4kB(
      //      .s_axis_aresetn    (aresetn                 ),
      //      .s_axis_aclk       (aclk                    ),
      //      .s_axis_tvalid     (s_ssdn_wrap2ip_tvalid     ),
      //      .s_axis_tready     (s_ssdn_ip2wrap_tready     ),
      //      .s_axis_tdata      (s_ssdn_wrap2ip_tdata      ),
      //      //.s_axis_tkeep      (s_ssdn_wrap2ip_tkeep      ),
      //      .s_axis_tlast      (s_ssdn_wrap2ip_tlast      ),
      //      .m_axis_tvalid     (sssdn_wrap2ip_tvalid    ),
      //      .m_axis_tready     (sssdn_ip2wrap_tready    ),
      //      .m_axis_tdata      (sssdn_wrap2ip_tdata     ),
      //      //.m_axis_tkeep      (sssdn_wrap2ip_tkeep     ),
      //      .m_axis_tlast      (sssdn_wrap2ip_tlast     ),
      //      .axis_wr_data_count(axis_wr_data_count      ),
      //      .almost_full       (almost_full             ),
      //      .almost_empty      (almost_empty            )
      //  );
   // xpm_fifo_axis: AXI Stream FIFO
   // Xilinx Parameterized Macro, version 2024.1
   wire [10-1:0] s_axis_wr_data_count;
   assign axis_wr_data_count = {20'h0,s_axis_wr_data_count};
   xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(3),            // DECIMAL
      .CLOCKING_MODE("common_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .FIFO_DEPTH(512),              // DECIMAL
      .FIFO_MEMORY_TYPE("auto"),      // String
      .PACKET_FIFO("false"),          // String
      .PROG_EMPTY_THRESH(10),         // DECIMAL
      .PROG_FULL_THRESH(10),          // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(64),                // DECIMAL
      .TDEST_WIDTH(1),                // DECIMAL
      .TID_WIDTH(1),                  // DECIMAL
      .TUSER_WIDTH(1),                // DECIMAL
      .USE_ADV_FEATURES("0e0e"),      // String
      .WR_DATA_COUNT_WIDTH(10)         // DECIMAL
   )
   u_uvw_axis_data_fifo_4kB (
      .almost_empty_axis(almost_empty),   // 1-bit output: Almost Empty : When asserted, this signal
                                               // indicates that only one more read can be performed before the
                                               // FIFO goes to empty.

      .almost_full_axis(almost_full),     // 1-bit output: Almost Full: When asserted, this signal
                                               // indicates that only one more write can be performed before
                                               // the FIFO is full.

      .dbiterr_axis(),             // 1-bit output: Double Bit Error- Indicates that the ECC
                                               // decoder detected a double-bit error and data in the FIFO core
                                               // is corrupted.

      .m_axis_tdata(sssdn_wrap2ip_tdata),             // TDATA_WIDTH-bit output: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.

      .m_axis_tdest(),             // TDEST_WIDTH-bit output: TDEST: Provides routing information
                                               // for the data stream.

      .m_axis_tid(),                 // TID_WIDTH-bit output: TID: The data stream identifier that
                                               // indicates different streams of data.

      .m_axis_tkeep(),             // TDATA_WIDTH/8-bit output: TKEEP: The byte qualifier that
                                               // indicates whether the content of the associated byte of TDATA
                                               // is processed as part of the data stream. Associated bytes
                                               // that have the TKEEP byte qualifier deasserted are null bytes
                                               // and can be removed from the data stream. For a 64-bit DATA,
                                               // bit 0 corresponds to the least significant byte on DATA, and
                                               // bit 7 corresponds to the most significant byte. For example:
                                               // KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b,
                                               // DATA[63:56] is a NULL byte

      .m_axis_tlast(sssdn_wrap2ip_tlast),             // 1-bit output: TLAST: Indicates the boundary of a packet.
      .m_axis_tstrb(),             // TDATA_WIDTH/8-bit output: TSTRB: The byte qualifier that
                                               // indicates whether the content of the associated byte of TDATA
                                               // is processed as a data byte or a position byte. For a 64-bit
                                               // DATA, bit 0 corresponds to the least significant byte on
                                               // DATA, and bit 0 corresponds to the least significant byte on
                                               // DATA, and bit 7 corresponds to the most significant byte. For
                                               // example: STROBE[0] = 1b, DATA[7:0] is valid STROBE[7] = 0b,
                                               // DATA[63:56] is not valid

      .m_axis_tuser(),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .m_axis_tvalid(sssdn_wrap2ip_tvalid),           // 1-bit output: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted

      .prog_empty_axis(),       // 1-bit output: Programmable Empty- This signal is asserted
                                               // when the number of words in the FIFO is less than or equal to
                                               // the programmable empty threshold value. It is de-asserted
                                               // when the number of words in the FIFO exceeds the programmable
                                               // empty threshold value.

      .prog_full_axis(),         // 1-bit output: Programmable Full: This signal is asserted when
                                               // the number of words in the FIFO is greater than or equal to
                                               // the programmable full threshold value. It is de-asserted when
                                               // the number of words in the FIFO is less than the programmable
                                               // full threshold value.

      .rd_data_count_axis(), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count- This bus
                                               // indicates the number of words available for reading in the
                                               // FIFO.

      .s_axis_tready(s_ssdn_ip2wrap_tready),           // 1-bit output: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.

      .sbiterr_axis(),             // 1-bit output: Single Bit Error- Indicates that the ECC
                                               // decoder detected and fixed a single-bit error.

      .wr_data_count_axis(s_axis_wr_data_count), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus
                                               // indicates the number of words written into the FIFO.

      .injectdbiterr_axis(0), // 1-bit input: Double Bit Error Injection- Injects a double bit
                                               // error if the ECC feature is used.

      .injectsbiterr_axis(0), // 1-bit input: Single Bit Error Injection- Injects a single bit
                                               // error if the ECC feature is used.

      .m_aclk(aclk),                         // 1-bit input: Master Interface Clock: All signals on master
                                               // interface are sampled on the rising edge of this clock.

      .m_axis_tready(sssdn_ip2wrap_tready),           // 1-bit input: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.

      .s_aclk(aclk),                         // 1-bit input: Slave Interface Clock: All signals on slave
                                               // interface are sampled on the rising edge of this clock.

      .s_aresetn(aresetn),                   // 1-bit input: Active low asynchronous reset.
      .s_axis_tdata(s_ssdn_wrap2ip_tdata),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.

      .s_axis_tdest(0),             // TDEST_WIDTH-bit input: TDEST: Provides routing information
                                               // for the data stream.

      .s_axis_tid(0),                 // TID_WIDTH-bit input: TID: The data stream identifier that
                                               // indicates different streams of data.

      .s_axis_tkeep(s_ssdn_wrap2ip_tkeep),             // TDATA_WIDTH/8-bit input: TKEEP: The byte qualifier that
                                               // indicates whether the content of the associated byte of TDATA
                                               // is processed as part of the data stream. Associated bytes
                                               // that have the TKEEP byte qualifier deasserted are null bytes
                                               // and can be removed from the data stream. For a 64-bit DATA,
                                               // bit 0 corresponds to the least significant byte on DATA, and
                                               // bit 7 corresponds to the most significant byte. For example:
                                               // KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b,
                                               // DATA[63:56] is a NULL byte

      .s_axis_tlast(s_ssdn_wrap2ip_tlast),             // 1-bit input: TLAST: Indicates the boundary of a packet.
      .s_axis_tstrb(0),             // TDATA_WIDTH/8-bit input: TSTRB: The byte qualifier that
                                               // indicates whether the content of the associated byte of TDATA
                                               // is processed as a data byte or a position byte. For a 64-bit
                                               // DATA, bit 0 corresponds to the least significant byte on
                                               // DATA, and bit 0 corresponds to the least significant byte on
                                               // DATA, and bit 7 corresponds to the most significant byte. For
                                               // example: STROBE[0] = 1b, DATA[7:0] is valid STROBE[7] = 0b,
                                               // DATA[63:56] is not valid

      .s_axis_tuser(0),             // TUSER_WIDTH-bit input: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .s_axis_tvalid(s_ssdn_wrap2ip_tvalid)            // 1-bit input: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted

   );
        
//when reset, input ready is low will cause a data stuffed to this register
//slice. when reset release, this register slice will output a dirty data.
        uvw_axis_register_slice u_uvw_axis_dn_duf(
            .aclk          (aclk                     ) ,
            .aresetn       (aresetn                  ) ,
            .s_axis_tvalid (s_sssdn_wrap2ip_tvalid   ) ,
            .s_axis_tready (s_sssdn_ip2wrap_tready   ) ,
            .s_axis_tdata  (s_sssdn_wrap2ip_tdata    ) ,
            .s_axis_tkeep  (s_sssdn_wrap2ip_tkeep    ) ,
            .s_axis_tlast  (s_sssdn_wrap2ip_tlast    ) ,
            .m_axis_tvalid (s4dn_wrap2ip_tvalid    ) ,
            .m_axis_tready (s4dn_ip2wrap_tready    ) ,
            .m_axis_tdata  (s4dn_wrap2ip_tdata     ) ,
            .m_axis_tkeep  (                       ) ,
            .m_axis_tlast  (s4dn_wrap2ip_tlast     ) 
        );
        assign s4dn_wrap2ip_tkeep = s4dn_wrap2ip_tlast ? r_sssdn_wrap2ip_tkeep : {(STREAM_DATA_WIDTH/8){1'b1}};
        uvw_axis_register_slice u_uvw_axis_dn_outduf(
            .aclk          (aclk                     ) ,
            .aresetn       (aresetn                  ) ,
            .s_axis_tvalid (s4dn_wrap2ip_tvalid   ) ,
            .s_axis_tready (s4dn_ip2wrap_tready   ) ,
            .s_axis_tdata  (s4dn_wrap2ip_tdata    ) ,
            .s_axis_tkeep  (s4dn_wrap2ip_tkeep    ) ,
            .s_axis_tlast  (s4dn_wrap2ip_tlast    ) ,
            .m_axis_tvalid (ssssdn_wrap2ip_tvalid    ) ,
            .m_axis_tready (ssssdn_ip2wrap_tready    ) ,
            .m_axis_tdata  (ssssdn_wrap2ip_tdata     ) ,
            .m_axis_tkeep  (ssssdn_wrap2ip_tkeep     ) ,
            .m_axis_tlast  (ssssdn_wrap2ip_tlast     ) 
        );

        always @( posedge s_ip_stream_clk or posedge ip_stream_rst) begin 
            if (ip_stream_rst) begin 
                s_dn_pause   <= 1'h1;
            end else if (s_dn_wrap2ip_tvalid && (!ssssdn_ip2wrap_tready))begin 
                s_dn_pause   <= 1'h0;
            end else begin 
                s_dn_pause   <= 1'h1;
            end 
        end

            assign s_dn_wrap2ip_tvalid     =  (~axis_bus_clear_en) & ssssdn_wrap2ip_tvalid  ;
            assign ssssdn_ip2wrap_tready   =  axis_bus_clear_en    | s_dn_ip2wrap_tready    ;
            assign s_dn_wrap2ip_tdata      =  ssssdn_wrap2ip_tdata   ;
            assign s_dn_wrap2ip_tkeep      =  ssssdn_wrap2ip_tkeep   ;
            assign s_dn_wrap2ip_tlast      =  ssssdn_wrap2ip_tlast   ;  
            
    
    end        
    //endgenerate
end
endgenerate 


assign axis_bus_clear_en = axis_bus_clear_en_sync[3];

always @(posedge s_ip_stream_clk or posedge ip_stream_rst)
begin
    if (ip_stream_rst) begin
       axis_bus_clear_en_sync <= 4'hf;
    end else begin
       axis_bus_clear_en_sync <= {axis_bus_clear_en_sync[2:0], bus_clear_en};
    end
end

always @(posedge s_ip_ufc_clk or posedge s_ip_ufc_rst_sync1)
begin
    if (s_ip_ufc_rst_sync1) begin
        bus_clear_en <= 1'b0;
    end else begin
        if (bus_clear_bus_clear == 32'h0000000a) begin
            bus_clear_en <= 1'b1;
        end else if (bus_clear_bus_clear == 32'h00000005)  begin
            bus_clear_en <= 1'b0;
        end
    end
end   
//monitor ip clear register

assign bus_clear_sw_wen = s_reg_wr_en &                  (s_reg_addr == BUS_CLEAR_OFFS);
always @(posedge s_ip_ufc_clk or posedge s_ip_ufc_rst_sync1) begin
   if (s_ip_ufc_rst_sync1) begin
      bus_clear_clear <= 32'h0;
   end else if (bus_clear_sw_wen) begin 
      bus_clear_clear <= s_reg_wr_data[31:0];
   end
end
always @(posedge s_ip_ufc_clk or posedge s_ip_ufc_rst_sync1)
begin
    if (s_ip_ufc_rst_sync1) begin
        ip_bus_clear_en <= 1'b0;
    end else begin
        if (bus_clear_clear == 32'h0000000a) begin
            ip_bus_clear_en <= 1'b1;
        end else if (bus_clear_clear == 32'h00000005)  begin
            ip_bus_clear_en <= 1'b0;
        end
    end
end

always @(posedge s_ip_stream_clk )
begin
    //if (ip_stream_rst) begin
    //   ip_bus_clear_en_sync <= 4'hf;
    //end else begin
       ip_bus_clear_en_sync <= {ip_bus_clear_en_sync[2:0], ip_bus_clear_en};
    //end
end
// end monitor


//// instantiation if_regs
    uvw_sbus_register_branch   # ( 
                .BRANCH_ADDR1      (32'H100      ),
                .BRANCH_ADDR2      (32'H3000      ),
                .BRANCH_ADDR3      (32'HD000      ),
                .BRANCH_ADDR4      (32'H2000      ),   
                .BRANCH_ADDR5      (32'H4000      ),
                .BRANCH_ADDR6      (32'H9000      ),
                .BRANCH_ADDR7      (32'H10000     ),
                .REG_ADDR_WIDTH    (REG_ADDR_WIDTH),       // Register Addr WIDTH of IP
                .REG_DATA_WIDTH    (REG_DATA_WIDTH),       // Register data width of IP  ) 
                .BARNCH1_DEL       (BARNCH1_DEL   ),/// The difference in delay time. ur_alp_if del 1.
                .BARNCH2_DEL       (BARNCH2_DEL   ),/// The difference in delay time. if brch2 del is 2. set BARNCH1_DEL =2;                
                .BRANCH_SEL        (1             )                    
        )
    u_uvw_sbus_register_branch(
        .sbus_clk              (s_ip_ufc_clk                 ),
        .sbus_rst              (s_ip_ufc_rst_sync1                 ),
        // IP_register_from                                 
        .reg_addr              (reg_addr                     ),
        .reg_wr_en             (reg_wr_en                    ),
        .reg_wr_data           (reg_wr_data                  ),
        .reg_wr_resp           (reg_wr_resp                  ),
        .reg_wr_valid          (reg_wr_valid                 ),
        .reg_rd_en             (reg_rd_en                    ),
        .reg_rd_data           (reg_rd_data                  ),
        .reg_rd_resp           (reg_rd_resp                  ),
        .reg_rd_valid          (reg_rd_valid                 ),

        // IP_register                                        
        .ip_brch1_reg_addr     (if_reg_addr                ),
        .ip_brch1_reg_wr_en    (if_reg_wr_en                 ),
        .ip_brch1_reg_wr_data  (if_reg_wr_data               ),
        .ip_brch1_reg_wr_valid (if_reg_wr_valid              ),
        .ip_brch1_reg_wr_resp  (if_reg_wr_resp               ),
        .ip_brch1_reg_rd_en    (if_reg_rd_en                 ),
        .ip_brch1_reg_rd_data  (if_reg_rd_data               ),
        .ip_brch1_reg_rd_resp  (if_reg_rd_resp               ),
        .ip_brch1_reg_rd_valid (if_reg_rd_valid              ),
                          
        .ip_brch2_reg_addr     (s_reg_addr                   ),
        .ip_brch2_reg_wr_en    (s_reg_wr_en                  ),
        .ip_brch2_reg_wr_data  (s_reg_wr_data                ),
        .ip_brch2_reg_wr_valid (s_reg_wr_valid               ),
        .ip_brch2_reg_wr_resp  (s_reg_wr_resp                ),
        .ip_brch2_reg_rd_en    (s_reg_rd_en                  ),
        .ip_brch2_reg_rd_data  (s_reg_rd_data                ),
        .ip_brch2_reg_rd_resp  (s_reg_rd_resp                ),
        .ip_brch2_reg_rd_valid (s_reg_rd_valid               )

    );
// add lock register 0x44
reg lock_offset_0x44;
wire s_if_reg_wr_en;
wire [7:0] s_if_reg_addr;
always @(posedge s_ip_ufc_clk or posedge s_ip_ufc_rst)begin 
    if(s_ip_ufc_rst)
        lock_offset_0x44 <= 1'b0;
    else lock_offset_0x44 <= |dst0_address_dst0_address;
end
//assign s_if_reg_wr_en = lock_offset_0x44 && (if_reg_addr == 16'h44) ? 1'b0 : if_reg_wr_en;
assign s_if_reg_addr = lock_offset_0x44 && (if_reg_addr == 16'h44) && if_reg_wr_en ? 8'b0 : if_reg_addr; // when it is locded ,the address is 0;
assign dst0_address_dst0_address_clr = {32{alp_if_ctrl_resered[0]}};
// end add lock register 0x44 

reg io_status_dn_wrap2ip_tlast =0; 
reg io_status_dn_wrap2ip_tvalid=0; 
reg io_status_dn_ip2wrap_tready=0; 
reg io_status_up_ip2wrap_tlast =0; 
reg io_status_up_ip2wrap_tvalid=0; 
reg io_status_up_wrap2ip_tready=0; 

always @ (posedge s_ip_stream_clk) begin
   if(s_dn_wrap2ip_tlast)
       io_status_dn_wrap2ip_tlast <= 1;
   else io_status_dn_wrap2ip_tlast <= 0;

   if(s_dn_wrap2ip_tvalid)
       io_status_dn_wrap2ip_tvalid <= 1;
   else io_status_dn_wrap2ip_tvalid <= 0;

   if(s_dn_ip2wrap_tready)
       io_status_dn_ip2wrap_tready <= 1;
   else io_status_dn_ip2wrap_tready <= 0;

   if(s_up_ip2wrap_tlast)
       io_status_up_ip2wrap_tlast <= 1;
   else io_status_up_ip2wrap_tlast <= 0;

   if(s_up_ip2wrap_tvalid)
       io_status_up_ip2wrap_tvalid <= 1;
   else io_status_up_ip2wrap_tvalid <= 0;

   if(s_up_wrap2ip_tready)
       io_status_up_wrap2ip_tready <= 1;
   else io_status_up_wrap2ip_tready <= 0;

end




uvw_sbus_alp_if_regs u_uvw_sbus_alp_if_regs   
(
  .ip_type_ip_type                (ip_type_ip_type               ) ,
  .bus_clear_clear                (bus_clear_bus_clear           ) ,
  .version_type                   (version_type                  ) ,
  .version_major                  (version_major                 ) ,
  .version_minor                  (version_minor                 ) ,
  .version_revision               (version_revision              ) ,
  .src_address_src_address        (src_address_src_address       ) ,
  .dst0_address_dst0_address      (dst0_address_dst0_address     ) ,
  .dst0_address_dst0_address_clr  (dst0_address_dst0_address_clr ) ,
  .dst1_address_dst1_address      (dst1_address_dst1_address     ) ,
  .dst2_address_dst2_address      (dst2_address_dst2_address     ) ,
  .dst3_address_dst3_address      (dst3_address_dst3_address     ) ,
  .ip_data_type_data_type0        (ip_data_type_data_type0       ) ,
  .alp_length_alp_length          (alp_length_alp_length         ) ,
  .alp_tx_frame_cnt_alp_frame_cnt (alp_tx_frame_cnt_alp_frame_cnt) ,
  .alp_rx_frame_cnt_alp_frame_cnt (alp_rx_frame_cnt_alp_frame_cnt) ,
  .alp_if_ctrl_resered            (alp_if_ctrl_resered           ) ,
  .h2c_cache_fifo_sts_fifo_cnt    (axis_wr_data_count[29:0]      ) ,
  .h2c_cache_fifo_sts_fifo_full   (almost_full                   ) ,
  .h2c_cache_fifo_sts_fifo_empty  (almost_empty                  ) ,
  .alp_monitor_sts_alp_c2h_timeout    ( ),
  .alp_monitor_sts_alp_c2h_timeout_set(c2h_alp_timeout_cnt[INIT_width] ),
  .alp_monitor_sts_alp_h2c_timeout    ( ),
  .alp_monitor_sts_alp_h2c_timeout_set(h2c_alp_timeout_cnt[INIT_width] ),
  .io_status_dn_wrap2ip_tlast     (io_status_dn_wrap2ip_tlast  ),
  .io_status_dn_wrap2ip_tvalid    (io_status_dn_wrap2ip_tvalid ),
  .io_status_dn_ip2wrap_tready    (io_status_dn_ip2wrap_tready ),
  .io_status_up_ip2wrap_tlast     (io_status_up_ip2wrap_tlast  ),
  .io_status_up_ip2wrap_tvalid    (io_status_up_ip2wrap_tvalid ),
  .io_status_up_wrap2ip_tready    (io_status_up_wrap2ip_tready ),

  // CPU Bus Interface 
  .reg_addr                       (s_if_reg_addr[7:0]            ) ,       // Address
  .reg_wr_en                      (if_reg_wr_en                  ) ,       // Write enable
  .reg_wr_data                    (if_reg_wr_data                ) ,       // Write Data
  .reg_rd_en                      (if_reg_rd_en                  ) ,       // Read  enable
  .reg_wr_resp                    (if_reg_wr_resp                ) ,       // Write response
  .reg_wr_valid                   (if_reg_wr_valid               ) ,       // Write valid
  .reg_rd_data                    (if_reg_rd_data                ) ,       // Read Data
  .reg_rd_resp                    (if_reg_rd_resp                ) ,       // Read response
  .reg_rd_valid                   (if_reg_rd_valid               ) ,       // Read valid
  
  .rst                            (s_ip_ufc_rst_sync1                  ) ,       // power-on reset for retention DFFs
  .clk                            (s_ip_ufc_clk                  )         // main clock
);

    
    
//// end

endmodule
