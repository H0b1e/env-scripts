// ================================================================================================
// Copyright(C) 2022 Univista Industrial Software Group Co.,Ltd All rights reserved.
// ================================================================================================
//
// ================================================================================================
// Module     : uvw_u3_ip_if_wrapper 
// Function   : systembus 3.0 IP interface wrapper . 
// ------------------------------------------------------------------------------------------------
// Update History
// ------------------------------------------------------------------------------------------------
// Version        Data           Author             Contents
// 1.0.0          2023/03/10     hanbing            Initial release
// ================================================================================================

// ================================================================================================
// RTL header
// ================================================================================================
// Timiscale ///
`timescale 1ps/1ps
module uvw_sbus_3_0_ip_if_wrapper(/*AUTOARG*/
   // Outputs
   systembus_o, sbus_clk_i, rst_sbus_clk_i, peri_clk, rst_peri_clk,
   up_wrap2ip_tready, dn_wrap2ip_tdata, dn_wrap2ip_tlast,
   dn_wrap2ip_tvalid, dn_wrap2ip_tkeep, reg_rd_en, reg_addr,
   reg_wr_en, reg_wr_data,alp_length,rst_uvhs_uclk,
   uvhs_uclk,uvhs_master_clk,stop_clk_out,
   // Inputs
   systembus_i, ip_stream_clk, ip_stream_rst, up_ip2wrap_tdata,
   up_ip2wrap_tlast, up_ip2wrap_tvalid, up_ip2wrap_tkeep,
   dn_ip2wrap_tready, ip_ufc_clk, ip_ufc_rst, reg_wr_resp,
   reg_wr_valid, reg_rd_data, reg_rd_resp, reg_rd_valid, interrupt,
   is_active_ip,is_active_streamio,is_active_coemu_ip,timestamp,stop_clk_in
   );

parameter SYSTEMBUS_WIDTH = 256;
parameter A_DATAWIDTH     = 64;
parameter REG_ADDR_WIDTH  = 16;
parameter REG_DATA_WIDTH  = 32;
parameter IP_UPSTREAM_PORT= 1 ; //  EDPI IP SET 2. other backdoor ip set 1. field 1~4
parameter BARNCH1_DEL     = 1 ; // The difference in delay time. ur_alp_if del 1.
parameter BARNCH2_DEL     = 1 ; // The difference in delay time. if brch2 del is 2. set BARNCH1_DEL =2; Adjust the register access delay to equal.
parameter IP_TYPE         = 0;  
parameter IP_VERSION_TYPE = 0;  //  EDPI IP_TYPE is 0XB
parameter IP_VERSION_MAJOR= 0;  // 
parameter IP_VERSION_MINOR= 0;  // 
parameter IP_VERSION_REVISION=0;// 
parameter IP_ALP_BYPASS = 0;    // 1 ENABLE ALP BYPASS for SBUS2.0   ;sbus3.0 set 0;             
 
                                

input  [SYSTEMBUS_WIDTH-1:0]    systembus_i;
output [SYSTEMBUS_WIDTH-1:0]    systembus_o;

input                           ip_stream_clk              ;    // ip ip_stream_clk
input                           ip_stream_rst              ;    // ip ip_stream_rst

output                          sbus_clk_i                 ;
output                          rst_sbus_clk_i             ;
output                          rst_uvhs_uclk              ;

output                          peri_clk                   ;
output                          rst_peri_clk               ;

input  [A_DATAWIDTH*IP_UPSTREAM_PORT - 1:0  ]    up_ip2wrap_tdata            ;    // outgoing data of ip down fifo
input  [1*IP_UPSTREAM_PORT - 1:0  ]              up_ip2wrap_tlast            ;    // indicates the end of the frame , ip down fifo
input  [1*IP_UPSTREAM_PORT - 1:0  ]              up_ip2wrap_tvalid           ;    // the source are valid of ip down fifo
input  [A_DATAWIDTH/8*IP_UPSTREAM_PORT - 1:0]    up_ip2wrap_tkeep            ;    // specifies the number of valid bytes in the last data ,ip down fifo 
input                                            dn_ip2wrap_tready           ;    // asserted when signals are accepted of ip up fifo 
output [1*IP_UPSTREAM_PORT - 1:0  ]              up_wrap2ip_tready           ;    // asserted when signals are accepted of ip down fifo 
output [A_DATAWIDTH - 1:0  ]                     dn_wrap2ip_tdata            ;    // incoming data of ip up fifo  
output                                           dn_wrap2ip_tlast            ;    // indicates the end of the frame , ip up fifo
output                                           dn_wrap2ip_tvalid           ;    // the source are valid of ip up fifo
output [A_DATAWIDTH/8 - 1:0]                     dn_wrap2ip_tkeep            ;    // specifies the number of valid bytes in the last data ,ip up fifo 

input                           ip_ufc_clk                 ;    // ip ip_ufc_clk
input                           ip_ufc_rst                 ;    // ip ip_ufc_rst
input                           reg_wr_resp                ; // Response from register . 0: write operation done; 1: write operation failed.
input                           reg_wr_valid               ;
input  [REG_DATA_WIDTH - 1:0]   reg_rd_data                ; // Read data from register 
input                           reg_rd_resp                ; // Response from register. 0: read operation done; 1: read operation failed
input                           reg_rd_valid               ;
input                           interrupt                  ; // Active high, level interrupt
output                          reg_rd_en                  ; // Read enable to register 
output [REG_ADDR_WIDTH - 1:0]   reg_addr                   ; // Write address to register 
output                          reg_wr_en                  ; // Write enable to register 
output [REG_DATA_WIDTH - 1:0]   reg_wr_data                ; // Write data to register 

input                           is_active_ip               ;
input                           is_active_streamio         ;
input                           is_active_coemu_ip         ;

input  [11-1'b1 :0]             timestamp                  ;
output [REG_DATA_WIDTH-1'b1 :0] alp_length                 ;

output                          uvhs_uclk                  ;
output                          uvhs_master_clk            ;
input                           stop_clk_in                ;
output                          stop_clk_out               ;

wire                           s_ip_stream_clk               ;
wire                           s_ip_stream_rst               ;
wire                           s_ip_ufc_clk                  ;
wire                           s_ip_ufc_rst                  ;

wire  [A_DATAWIDTH - 1:0  ]    s_up_ip2wrap_tdata            ;    // outgoing data of ip down fifo
wire                           s_up_ip2wrap_tlast            ;    // indicates the end of the frame , ip down fifo
wire                           s_up_ip2wrap_tvalid           ;    // the source are valid of ip down fifo
wire  [A_DATAWIDTH/8 - 1:0]    s_up_ip2wrap_tkeep            ;    // specifies the number of valid bytes in the last data ,ip down fifo 
wire                           s_dn_ip2wrap_tready           ;    // asserted when signals are accepted of ip up fifo 
wire                           s_up_wrap2ip_tready           ;    // asserted when signals are accepted of ip down fifo 
wire  [A_DATAWIDTH - 1:0  ]    s_dn_wrap2ip_tdata            ;    // incoming data of ip up fifo  
wire                           s_dn_wrap2ip_tlast            ;    // indicates the end of the frame , ip up fifo
wire                           s_dn_wrap2ip_tvalid           ;    // the source are valid of ip up fifo
wire  [A_DATAWIDTH/8 - 1:0]    s_dn_wrap2ip_tkeep            ;    // specifies the number of valid bytes in the last data ,ip up fifo 


wire                           s_reg_wr_resp                ; // Response from register . 0: write operation done; 1: write operation failed.
wire                           s_reg_wr_valid               ;
wire  [REG_DATA_WIDTH - 1:0]   s_reg_rd_data                ; // Read data from register 
wire                           s_reg_rd_resp                ; // Response from register. 0: read operation done; 1: read operation failed
wire                           s_reg_rd_valid               ;
wire                           s_interrupt                  ; // Active high, level interrupt
wire                           s_reg_rd_en                  ; // Read enable to register 
wire  [REG_ADDR_WIDTH - 1:0]   s_reg_addr                   ; // Write address to register 
wire                           s_reg_wr_en                  ; // Write enable to register 
wire  [REG_DATA_WIDTH - 1:0]   s_reg_wr_data                ; // Write data to register 






//37
assign systembus_o [200]                                               = is_active_ip                            ;
assign systembus_o [201]                                               = is_active_streamio                      ;  
assign systembus_o [202]                                               = is_active_coemu_ip                      ;  
assign systembus_o [255]                                               = stop_clk_in                             ;
localparam  REG_START_OUT  = 0;
localparam  DATA_START_OUT = REG_START_OUT+REG_DATA_WIDTH+7;
localparam  REG_START_IN  = 0;
localparam  DATA_START_IN = REG_START_IN+REG_DATA_WIDTH+REG_ADDR_WIDTH+4;

assign systembus_o [REG_START_OUT+0]                                          = s_ip_ufc_clk                             ;    
assign systembus_o [REG_START_OUT+1]                                          = s_ip_ufc_rst                             ;    
assign systembus_o [REG_START_OUT+4]                                          = s_interrupt                              ; 
assign systembus_o [REG_START_OUT+5]                                          = 1'b0; 
assign systembus_o [REG_START_OUT+6]                                          = 1'b0; 
assign systembus_o [REG_START_OUT+REG_DATA_WIDTH-1+7:REG_START_OUT+7]         = s_reg_rd_data[REG_DATA_WIDTH - 1:0]      ; 
                                                                                                           
//77                                                                                                       
assign systembus_o [REG_START_OUT+2]                                          = s_ip_stream_clk                          ;    
assign systembus_o [REG_START_OUT+3]                                          = s_ip_stream_rst                          ;    
            
assign systembus_o [DATA_START_OUT+0]                                         = s_dn_ip2wrap_tready                      ;    
assign systembus_o [DATA_START_OUT+1]                                         = s_up_ip2wrap_tvalid                      ;    
assign systembus_o [DATA_START_OUT+2]                                         = s_up_ip2wrap_tlast                       ;    
assign systembus_o [DATA_START_OUT+A_DATAWIDTH/8-1+3:DATA_START_OUT+3]        = s_up_ip2wrap_tkeep[A_DATAWIDTH/8 - 1:0]  ;    
assign systembus_o [DATA_START_OUT+A_DATAWIDTH/8+3+A_DATAWIDTH-1:DATA_START_OUT+A_DATAWIDTH/8+3]              = s_up_ip2wrap_tdata[A_DATAWIDTH - 1:0  ]  ;    
//114
assign systembus_o [DATA_START_OUT+A_DATAWIDTH/8+3+A_DATAWIDTH+0]             = s_reg_wr_valid                           ; 
assign systembus_o [DATA_START_OUT+A_DATAWIDTH/8+3+A_DATAWIDTH+1]             = s_reg_rd_valid                           ; 
//======================================
//to optimize ur_alp_if, output will be cut off in uvw_sysbus_3_0_if_wrapper.v
assign sbus_clk_i                              = (!is_active_ip) ?                   1'b0 : systembus_i[REG_START_IN+0];
assign rst_sbus_clk_i                          = (!is_active_ip) ?                   1'b0 : systembus_i[REG_START_IN+1];
assign s_reg_wr_en                             = (!is_active_ip) ?                   1'b0 : systembus_i[REG_START_IN+2]                                                   ; 
assign s_reg_rd_en                             = (!is_active_ip) ?                   1'b0 : systembus_i[REG_START_IN+3]                                                   ; 
assign s_reg_addr[REG_ADDR_WIDTH - 1:0]        = (!is_active_ip) ? {REG_ADDR_WIDTH{1'b0}} : systembus_i[REG_START_IN+REG_ADDR_WIDTH-1+4:REG_START_IN+4]                                ; 
assign s_reg_wr_data[REG_DATA_WIDTH - 1:0]     = (!is_active_ip) ? {REG_DATA_WIDTH{1'b0}} : systembus_i[REG_START_IN+REG_DATA_WIDTH-1+REG_ADDR_WIDTH+4:REG_START_IN+REG_ADDR_WIDTH+4]  ; 


assign s_dn_wrap2ip_tvalid                     = (!is_active_streamio) ?                   1'b0 : systembus_i[DATA_START_IN+0]                                               ;    
assign s_dn_wrap2ip_tlast                      = (!is_active_streamio) ?                   1'b0 : systembus_i[DATA_START_IN+1]                                               ;    
assign s_dn_wrap2ip_tkeep[A_DATAWIDTH/8 - 1:0] = (!is_active_streamio) ? {A_DATAWIDTH/8{1'b0}}  : systembus_i[DATA_START_IN+2+A_DATAWIDTH/8-1:DATA_START_IN+2] ;    
assign s_dn_wrap2ip_tdata[A_DATAWIDTH - 1:0  ] = (!is_active_streamio) ? {A_DATAWIDTH{1'b0}}    : systembus_i[DATA_START_IN+2+A_DATAWIDTH/8+A_DATAWIDTH-1:DATA_START_IN+2+A_DATAWIDTH/8]                               ;    
assign s_up_wrap2ip_tready                     = (!is_active_streamio) ?                   1'b0 : systembus_i[DATA_START_IN+2+A_DATAWIDTH/8+A_DATAWIDTH]                    ;    

assign peri_clk                                = (!is_active_ip) ? 1'b0 : systembus_i[200];
assign rst_peri_clk                            = (!is_active_ip) ? 1'b0 : systembus_i[201];

assign uvhs_uclk                               = (!is_active_ip) ? 1'b0 : systembus_i[202];
assign uvhs_master_clk                         = (!is_active_ip) ? 1'b0 : systembus_i[203];
assign rst_uvhs_uclk                           = (!is_active_ip) ? 1'b0 : systembus_i[204];
assign stop_clk_out                            = (!is_active_ip) ? 1'b0 : systembus_i[255];





 uvw_ur_alp_if 
 # ( 
      .BARNCH1_DEL         (  BARNCH1_DEL          ),// The difference in delay time. ur_alp_if del 1.
      .BARNCH2_DEL         (  BARNCH2_DEL          ),// The difference in delay time. if brch2 del is 2. set BARNCH1_DEL =2; Adjust the register access delay to equal.
      .IP_STREAM_PORT      (  IP_UPSTREAM_PORT     ),//  EDPI IP SET 2. other backdoor ip set 1. parameter IP_STREAM_PORT  = 4; //1~4
      .IP_TYPE             (  IP_TYPE              ),//  EDPI IP_TYPE is 0XB
      .IP_VERSION_TYPE     (  IP_VERSION_TYPE      ),// 
      .IP_VERSION_MAJOR    (  IP_VERSION_MAJOR     ),// 
      .IP_VERSION_MINOR    (  IP_VERSION_MINOR     ),// 
      .IP_VERSION_REVISION (  IP_VERSION_REVISION  ),// 
      .IP_ALP_BYPASS       (  IP_ALP_BYPASS        ) // 1 ENABLE ALP BYPASS for SBUS2.0   ;sbus3.0 set 0;             
                            )
 u_uvw_ur_alp_if
 (
// IO for sbus3.0
    .ip_stream_clk              (s_ip_stream_clk              ),
    .ip_stream_rst              (s_ip_stream_rst              ),
    .ip_ufc_clk                 (s_ip_ufc_clk                 ),
    .ip_ufc_rst                 (s_ip_ufc_rst                 ),
    .dn_wrap2ip_tdata           (s_dn_wrap2ip_tdata           ),
    .dn_wrap2ip_tlast           (s_dn_wrap2ip_tlast           ),
    .dn_wrap2ip_tvalid          (s_dn_wrap2ip_tvalid          ),
    .dn_ip2wrap_tready          (s_dn_ip2wrap_tready          ),
    .dn_wrap2ip_tkeep           (s_dn_wrap2ip_tkeep           ),
    .up_ip2wrap_tdata           (s_up_ip2wrap_tdata           ),
    .up_ip2wrap_tlast           (s_up_ip2wrap_tlast           ),
    .up_ip2wrap_tvalid          (s_up_ip2wrap_tvalid          ),
    .up_wrap2ip_tready          (s_up_wrap2ip_tready          ),
    .up_ip2wrap_tkeep           (s_up_ip2wrap_tkeep           ),
    .reg_addr                   (s_reg_addr                   ),
    .reg_wr_en                  (s_reg_wr_en                  ),
    .reg_wr_data                (s_reg_wr_data                ),
    .reg_wr_resp                (s_reg_wr_resp                ),
    .reg_wr_valid               (s_reg_wr_valid               ),
    .reg_rd_en                  (s_reg_rd_en                  ),
    .reg_rd_data                (s_reg_rd_data                ),
    .reg_rd_resp                (s_reg_rd_resp                ),
    .reg_rd_valid               (s_reg_rd_valid               ),
    .interrupt                  (s_interrupt                  ),
// IO for IP 
    .s_ip_stream_clk            (ip_stream_clk              ),
    .s_ip_stream_rst            (ip_stream_rst              ),
    .s_ip_ufc_clk               (ip_ufc_clk                 ),
    .s_ip_ufc_rst               (ip_ufc_rst                 ),
    .s_dn_wrap2ip_tdata         (dn_wrap2ip_tdata           ),
    .s_dn_wrap2ip_tlast         (dn_wrap2ip_tlast           ),
    .s_dn_wrap2ip_tvalid        (dn_wrap2ip_tvalid          ),
    .s_dn_ip2wrap_tready        (dn_ip2wrap_tready          ),
    .s_dn_wrap2ip_tkeep         (dn_wrap2ip_tkeep           ),
    .s_up_ip2wrap_tdata         (up_ip2wrap_tdata           ),
    .s_up_ip2wrap_tlast         (up_ip2wrap_tlast           ),
    .s_up_ip2wrap_tvalid        (up_ip2wrap_tvalid          ),
    .s_up_wrap2ip_tready        (up_wrap2ip_tready          ),
    .s_up_ip2wrap_tkeep         (up_ip2wrap_tkeep           ),
    .s_reg_addr                 (reg_addr                   ),
    .s_reg_wr_en                (reg_wr_en                  ),
    .s_reg_wr_data              (reg_wr_data                ),
    .s_reg_wr_valid             (reg_wr_valid               ),
    .s_reg_wr_resp              (1'b0),
    .s_reg_rd_en                (reg_rd_en                  ),
    .s_reg_rd_data              (reg_rd_data                ),
    .s_reg_rd_resp              (1'b0),
    .s_reg_rd_valid             (reg_rd_valid               ),
    .s_interrupt                (interrupt                  ),
    .timestamp                  (timestamp                  ),
    .alp_length                 (alp_length                 )
);






endmodule

