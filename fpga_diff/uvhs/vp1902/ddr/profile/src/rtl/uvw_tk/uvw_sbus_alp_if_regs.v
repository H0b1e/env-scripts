// Copyright 2023 Shanghai UniVista Industrial Software Group Co., Ltd. All rights reserved worldwide.
// =======================================================================
// File     : $File:$
// Author   : HANBING 
// $Revision:$
// =======================================================================
// Description:  Automatic RTL generation by CSV2RTL.PL with arguments 'uvw_sbus_alp_if_regs.flat' 
//               Modifying this file is strictly forbidden.

module uvw_sbus_alp_if_regs 
(
// Individual register field inputs/outputs
input      [31:0]  ip_type_ip_type,
input      [31:0]  product_code_product_code,
output reg [31:0]  bus_clear_clear,
input      [15:0]  version_revision,
input      [7:0]   version_minor,
input      [3:0]   version_major,
input      [3:0]   version_type,
output reg [31:0]  src_address_src_address,
output reg [31:0]  dst0_address_dst0_address,
input      [31:0]  dst0_address_dst0_address_clr,
output reg [31:0]  dst1_address_dst1_address,
output reg [31:0]  dst2_address_dst2_address,
output reg [31:0]  dst3_address_dst3_address,
output reg [5:0]   ip_data_type_data_type0,
output reg [15:0]  alp_length_alp_length,
input      [31:0]  alp_tx_frame_cnt_alp_frame_cnt,
input      [31:0]  alp_rx_frame_cnt_alp_frame_cnt,
output reg [31:0]  alp_if_ctrl_resered,
input      [9:0]   h2c_cache_fifo_sts_fifo_cnt,
input              h2c_cache_fifo_sts_s_axis_tvalid,
input              h2c_cache_fifo_sts_s_axis_tready,
input              h2c_cache_fifo_sts_s_axis_tlast,
input              h2c_cache_fifo_sts_m_axis_tvalid,
input              h2c_cache_fifo_sts_m_axis_tready,
input              h2c_cache_fifo_sts_m_axis_tlast,
input              h2c_cache_fifo_sts_fifo_full,
input              h2c_cache_fifo_sts_fifo_empty,
output reg         alp_monitor_sts_alp_c2h_timeout,
input              alp_monitor_sts_alp_c2h_timeout_set,
output reg         alp_monitor_sts_alp_h2c_timeout,
input              alp_monitor_sts_alp_h2c_timeout_set,
input              io_status_dn_wrap2ip_tlast,
input              io_status_dn_wrap2ip_tvalid,
input              io_status_dn_ip2wrap_tready,
input              io_status_up_ip2wrap_tlast,
input              io_status_up_ip2wrap_tvalid,
input              io_status_up_wrap2ip_tready,

// CPU Bus Interface 
input      [ 7:0]  reg_addr,          // Address
input              reg_wr_en,         // Write enable
input      [31:0]  reg_wr_data,       // Write Data
input              reg_rd_en,         // Read  enable
output reg         reg_wr_resp,       // Write response
output reg         reg_wr_valid,      // Write valid
output reg [31:0]  reg_rd_data,       // Read Data
output reg         reg_rd_resp,       // Read response
output reg         reg_rd_valid,      // Read valid

input              rst,               // power-on reset for retention DFFs
input              clk                // main clock
);

// Local Parameters 
localparam IP_TYPE_OFFS                     = 8'h0;
localparam PRODUCT_CODE_OFFS                = 8'h4;
localparam BUS_CLEAR_OFFS                   = 8'h8;
localparam VERSION_OFFS                     = 8'hc;
localparam SRC_ADDRESS_OFFS                 = 8'h40;
localparam DST0_ADDRESS_OFFS                = 8'h44;
localparam DST1_ADDRESS_OFFS                = 8'h48;
localparam DST2_ADDRESS_OFFS                = 8'h4c;
localparam DST3_ADDRESS_OFFS                = 8'h50;
localparam IP_DATA_TYPE_OFFS                = 8'h54;
localparam ALP_LENGTH_OFFS                  = 8'h58;
localparam ALP_TX_FRAME_CNT_OFFS            = 8'h5c;
localparam ALP_RX_FRAME_CNT_OFFS            = 8'h60;
localparam ALP_IF_CTRL_OFFS                 = 8'h64;
localparam H2C_CACHE_FIFO_STS_OFFS          = 8'h68;
localparam ALP_MONITOR_STS_OFFS             = 8'h6c;
localparam IO_STATUS_OFFS                   = 8'h70;

// Write enables from the CPU to each register
wire   bus_clear_sw_wen                 = reg_wr_en &                  (reg_addr == BUS_CLEAR_OFFS);
wire   src_address_sw_wen               = reg_wr_en &                  (reg_addr == SRC_ADDRESS_OFFS);
wire   dst0_address_sw_wen              = reg_wr_en &                  (reg_addr == DST0_ADDRESS_OFFS);
wire   dst1_address_sw_wen              = reg_wr_en &                  (reg_addr == DST1_ADDRESS_OFFS);
wire   dst2_address_sw_wen              = reg_wr_en &                  (reg_addr == DST2_ADDRESS_OFFS);
wire   dst3_address_sw_wen              = reg_wr_en &                  (reg_addr == DST3_ADDRESS_OFFS);
wire   ip_data_type_sw_wen              = reg_wr_en &                  (reg_addr == IP_DATA_TYPE_OFFS);
wire   alp_length_sw_wen                = reg_wr_en &                  (reg_addr == ALP_LENGTH_OFFS);
wire   alp_if_ctrl_sw_wen               = reg_wr_en &                  (reg_addr == ALP_IF_CTRL_OFFS);
wire   alp_monitor_sts_sw_wen           = reg_wr_en &                  (reg_addr == ALP_MONITOR_STS_OFFS);

genvar ii;


// Write response to the CPU
always @(posedge clk) begin
   if (rst) begin
      reg_wr_resp <= 1'b0;
   end else begin
      reg_wr_resp <= 1'b0;
      if (reg_wr_en) begin
         case (reg_addr)
            IP_TYPE_OFFS                     : reg_wr_resp <= 1'b1; // read only
            PRODUCT_CODE_OFFS                : reg_wr_resp <= 1'b1; // read only
            BUS_CLEAR_OFFS                   : reg_wr_resp <= 1'b0;
            VERSION_OFFS                     : reg_wr_resp <= 1'b1; // read only
            SRC_ADDRESS_OFFS                 : reg_wr_resp <= 1'b0;
            DST0_ADDRESS_OFFS                : reg_wr_resp <= 1'b0;
            DST1_ADDRESS_OFFS                : reg_wr_resp <= 1'b0;
            DST2_ADDRESS_OFFS                : reg_wr_resp <= 1'b0;
            DST3_ADDRESS_OFFS                : reg_wr_resp <= 1'b0;
            IP_DATA_TYPE_OFFS                : reg_wr_resp <= 1'b0;
            ALP_LENGTH_OFFS                  : reg_wr_resp <= 1'b0;
            ALP_TX_FRAME_CNT_OFFS            : reg_wr_resp <= 1'b1; // read only
            ALP_RX_FRAME_CNT_OFFS            : reg_wr_resp <= 1'b1; // read only
            ALP_IF_CTRL_OFFS                 : reg_wr_resp <= 1'b0;
            H2C_CACHE_FIFO_STS_OFFS          : reg_wr_resp <= 1'b1; // read only
            ALP_MONITOR_STS_OFFS             : reg_wr_resp <= 1'b0;
            IO_STATUS_OFFS                   : reg_wr_resp <= 1'b1; // read only
            default                          : reg_wr_resp <= 1'b1; // blank addr
         endcase
      end
   end
end

// write valid to the CPU
always @(posedge clk) begin
   if (rst) begin
      reg_wr_valid <= 1'b0;
   end else begin
      reg_wr_valid <= 1'b0;
      if (reg_wr_en) begin
         reg_wr_valid <= 1'b1;
      end
   end
end

////// Each register has its own ALWAYS block.

////// Start of code for register: ip_type
reg [31:0] ip_type_qq;


always @* begin
   ip_type_qq = 32'h0;
   ip_type_qq[31:0] = ip_type_ip_type;
end

////// Start of code for register: product_code
reg [31:0] product_code_qq;


always @* begin
   product_code_qq = 32'h0;
   product_code_qq[31:0] = product_code_product_code;
end

////// Start of code for register: bus_clear
reg [31:0] bus_clear_qq;

always @(posedge clk) begin
   if (rst) begin
      bus_clear_clear <= 32'h0;
   end else if (bus_clear_sw_wen) begin 
      bus_clear_clear <= reg_wr_data[31:0];
   end
end


always @* begin
   bus_clear_qq = 32'h0;
   bus_clear_qq[31:0]= bus_clear_clear;
end

////// Start of code for register: version
reg [31:0] version_qq;


always @* begin
   version_qq = 32'h0;
   version_qq[15:0] = version_revision;
   version_qq[23:16] = version_minor;
   version_qq[27:24] = version_major;
   version_qq[31:28] = version_type;
end

////// Start of code for register: src_address
reg [31:0] src_address_qq;

always @(posedge clk) begin
   if (rst) begin
      src_address_src_address <= 32'hffffffff;
   end else if (src_address_sw_wen) begin 
      src_address_src_address <= reg_wr_data[31:0];
   end
end


always @* begin
   src_address_qq = 32'h0;
   src_address_qq[31:0]= src_address_src_address;
end

////// Start of code for register: dst0_address
reg [31:0] dst0_address_qq;
reg dst0_address_wen;
reg [31:0] dst0_address_dst0_address_nxt2;

always @(posedge clk) begin
   if (rst) begin
      dst0_address_dst0_address <= 32'h0;
   end else begin
      dst0_address_dst0_address <= dst0_address_dst0_address_nxt2;
   end
end

always @* begin
   dst0_address_wen = dst0_address_sw_wen;

   // Next value for dst0_address_dst0_address
   dst0_address_dst0_address_nxt2 = dst0_address_dst0_address;
   dst0_address_dst0_address_nxt2 = dst0_address_dst0_address_nxt2 & ~dst0_address_dst0_address_clr;
   dst0_address_wen = dst0_address_wen || (|(dst0_address_dst0_address_clr)); // HW update
   if (dst0_address_sw_wen) // SW update
      dst0_address_dst0_address_nxt2 = dst0_address_dst0_address_nxt2 | (reg_wr_data[31:0]);
end


always @* begin
   dst0_address_qq = 32'h0;
   dst0_address_qq[31:0] = dst0_address_dst0_address;
end

////// Start of code for register: dst1_address
reg [31:0] dst1_address_qq;

always @(posedge clk) begin
   if (rst) begin
      dst1_address_dst1_address <= 32'h0;
   end else if (dst1_address_sw_wen) begin 
      dst1_address_dst1_address <= reg_wr_data[31:0];
   end
end


always @* begin
   dst1_address_qq = 32'h0;
   dst1_address_qq[31:0]= dst1_address_dst1_address;
end

////// Start of code for register: dst2_address
reg [31:0] dst2_address_qq;

always @(posedge clk) begin
   if (rst) begin
      dst2_address_dst2_address <= 32'h0;
   end else if (dst2_address_sw_wen) begin 
      dst2_address_dst2_address <= reg_wr_data[31:0];
   end
end


always @* begin
   dst2_address_qq = 32'h0;
   dst2_address_qq[31:0]= dst2_address_dst2_address;
end

////// Start of code for register: dst3_address
reg [31:0] dst3_address_qq;

always @(posedge clk) begin
   if (rst) begin
      dst3_address_dst3_address <= 32'h0;
   end else if (dst3_address_sw_wen) begin 
      dst3_address_dst3_address <= reg_wr_data[31:0];
   end
end


always @* begin
   dst3_address_qq = 32'h0;
   dst3_address_qq[31:0]= dst3_address_dst3_address;
end

////// Start of code for register: ip_data_type
reg [31:0] ip_data_type_qq;

always @(posedge clk) begin
   if (rst) begin
      ip_data_type_data_type0 <= 6'h1;
   end else if (ip_data_type_sw_wen) begin 
      ip_data_type_data_type0 <= reg_wr_data[5:0];
   end
end


always @* begin
   ip_data_type_qq = 32'h0;
   ip_data_type_qq[5:0]= ip_data_type_data_type0;
end

////// Start of code for register: alp_length
reg [31:0] alp_length_qq;

always @(posedge clk) begin
   if (rst) begin
      alp_length_alp_length <= 16'h800;
   end else if (alp_length_sw_wen) begin 
      alp_length_alp_length <= reg_wr_data[15:0];
   end
end


always @* begin
   alp_length_qq = 32'h0;
   alp_length_qq[15:0]= alp_length_alp_length;
end

////// Start of code for register: alp_tx_frame_cnt
reg [31:0] alp_tx_frame_cnt_qq;


always @* begin
   alp_tx_frame_cnt_qq = 32'h0;
   alp_tx_frame_cnt_qq[31:0] = alp_tx_frame_cnt_alp_frame_cnt;
end

////// Start of code for register: alp_rx_frame_cnt
reg [31:0] alp_rx_frame_cnt_qq;


always @* begin
   alp_rx_frame_cnt_qq = 32'h0;
   alp_rx_frame_cnt_qq[31:0] = alp_rx_frame_cnt_alp_frame_cnt;
end

////// Start of code for register: alp_if_ctrl
reg [31:0] alp_if_ctrl_qq;

always @(posedge clk) begin
   if (rst) begin
      alp_if_ctrl_resered <= 32'h0;
   end else if (alp_if_ctrl_sw_wen) begin 
      alp_if_ctrl_resered <= reg_wr_data[31:0];
   end
end


always @* begin
   alp_if_ctrl_qq = 32'h0;
   alp_if_ctrl_qq[31:0]= alp_if_ctrl_resered;
end

////// Start of code for register: h2c_cache_fifo_sts
reg [31:0] h2c_cache_fifo_sts_qq;


always @* begin
   h2c_cache_fifo_sts_qq = 32'h0;
   h2c_cache_fifo_sts_qq[9:0] = h2c_cache_fifo_sts_fifo_cnt;
   h2c_cache_fifo_sts_qq[20] = h2c_cache_fifo_sts_s_axis_tvalid;
   h2c_cache_fifo_sts_qq[21] = h2c_cache_fifo_sts_s_axis_tready;
   h2c_cache_fifo_sts_qq[22] = h2c_cache_fifo_sts_s_axis_tlast;
   h2c_cache_fifo_sts_qq[24] = h2c_cache_fifo_sts_m_axis_tvalid;
   h2c_cache_fifo_sts_qq[25] = h2c_cache_fifo_sts_m_axis_tready;
   h2c_cache_fifo_sts_qq[26] = h2c_cache_fifo_sts_m_axis_tlast;
   h2c_cache_fifo_sts_qq[30] = h2c_cache_fifo_sts_fifo_full;
   h2c_cache_fifo_sts_qq[31] = h2c_cache_fifo_sts_fifo_empty;
end

////// Start of code for register: alp_monitor_sts
reg [31:0] alp_monitor_sts_qq;
reg alp_monitor_sts_wen;
reg  alp_monitor_sts_alp_c2h_timeout_nxt2;
reg  alp_monitor_sts_alp_h2c_timeout_nxt2;

always @(posedge clk) begin
   if (rst) begin
      alp_monitor_sts_alp_c2h_timeout <= 1'b0;
      alp_monitor_sts_alp_h2c_timeout <= 1'b0;
   end else begin
      alp_monitor_sts_alp_c2h_timeout <= alp_monitor_sts_alp_c2h_timeout_nxt2;
      alp_monitor_sts_alp_h2c_timeout <= alp_monitor_sts_alp_h2c_timeout_nxt2;
   end
end

always @* begin
   alp_monitor_sts_wen = alp_monitor_sts_sw_wen;

   // Next value for alp_monitor_sts_alp_c2h_timeout
   alp_monitor_sts_alp_c2h_timeout_nxt2 = alp_monitor_sts_alp_c2h_timeout;
   if (alp_monitor_sts_sw_wen && (reg_wr_data[0] == 1'b1)) // SW update
      alp_monitor_sts_alp_c2h_timeout_nxt2 = 1'b0;
   else if (alp_monitor_sts_alp_c2h_timeout_set) // HW update
   begin
      alp_monitor_sts_alp_c2h_timeout_nxt2 = 1'b1;
      alp_monitor_sts_wen = 1'b1;
   end

   // Next value for alp_monitor_sts_alp_h2c_timeout
   alp_monitor_sts_alp_h2c_timeout_nxt2 = alp_monitor_sts_alp_h2c_timeout;
   if (alp_monitor_sts_sw_wen && (reg_wr_data[1] == 1'b1)) // SW update
      alp_monitor_sts_alp_h2c_timeout_nxt2 = 1'b0;
   else if (alp_monitor_sts_alp_h2c_timeout_set) // HW update
   begin
      alp_monitor_sts_alp_h2c_timeout_nxt2 = 1'b1;
      alp_monitor_sts_wen = 1'b1;
   end
end


always @* begin
   alp_monitor_sts_qq = 32'h0;
   alp_monitor_sts_qq[0] = alp_monitor_sts_alp_c2h_timeout;
   alp_monitor_sts_qq[1] = alp_monitor_sts_alp_h2c_timeout;
end

////// Start of code for register: io_status
reg [31:0] io_status_qq;


always @* begin
   io_status_qq = 32'h0;
   io_status_qq[0] = io_status_dn_wrap2ip_tlast;
   io_status_qq[1] = io_status_dn_wrap2ip_tvalid;
   io_status_qq[2] = io_status_dn_ip2wrap_tready;
   io_status_qq[4] = io_status_up_ip2wrap_tlast;
   io_status_qq[5] = io_status_up_ip2wrap_tvalid;
   io_status_qq[6] = io_status_up_wrap2ip_tready;
end


 ///////////////// Readback mux //////////////////////////
always @(posedge clk) begin
   if (rst) begin
      reg_rd_data <= 32'h0;
      reg_rd_resp <=  1'b0;
   end else begin
      reg_rd_data <= 32'h0;
      reg_rd_resp <=  1'b0;
      if (reg_rd_en) begin 
         case (reg_addr)
            IP_TYPE_OFFS                     : reg_rd_data <= ip_type_qq;
            PRODUCT_CODE_OFFS                : reg_rd_data <= product_code_qq;
            BUS_CLEAR_OFFS                   : reg_rd_data <= bus_clear_qq;
            VERSION_OFFS                     : reg_rd_data <= version_qq;
            SRC_ADDRESS_OFFS                 : reg_rd_data <= src_address_qq;
            DST0_ADDRESS_OFFS                : reg_rd_data <= dst0_address_qq;
            DST1_ADDRESS_OFFS                : reg_rd_data <= dst1_address_qq;
            DST2_ADDRESS_OFFS                : reg_rd_data <= dst2_address_qq;
            DST3_ADDRESS_OFFS                : reg_rd_data <= dst3_address_qq;
            IP_DATA_TYPE_OFFS                : reg_rd_data <= ip_data_type_qq;
            ALP_LENGTH_OFFS                  : reg_rd_data <= alp_length_qq;
            ALP_TX_FRAME_CNT_OFFS            : reg_rd_data <= alp_tx_frame_cnt_qq;
            ALP_RX_FRAME_CNT_OFFS            : reg_rd_data <= alp_rx_frame_cnt_qq;
            ALP_IF_CTRL_OFFS                 : reg_rd_data <= alp_if_ctrl_qq;
            H2C_CACHE_FIFO_STS_OFFS          : reg_rd_data <= h2c_cache_fifo_sts_qq;
            ALP_MONITOR_STS_OFFS             : reg_rd_data <= alp_monitor_sts_qq;
            IO_STATUS_OFFS                   : reg_rd_data <= io_status_qq;
            default                          : begin
                                               reg_rd_data <= 32'h0;
                                               reg_rd_resp <=  1'b1; // blank addr
                                               end
         endcase
      end
   end
end

// read valid to the CPU
always @(posedge clk) begin
   if (rst) begin
      reg_rd_valid <= 1'b0;
   end else begin
      reg_rd_valid <= 1'b0;
      if (reg_rd_en) begin
         reg_rd_valid <= 1'b1;
      end
   end
end

endmodule
//VER:UV-IP-SBUS_IP0.4.0.xlsx:2026/1/6:uvw_sbus_alp_if:1:SBUS_ALP_IF:8:32::-1:
//REG:IP_TYPE:IP0 type value:32:0x0:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:IP_TYPE:0:31:W:R:0:
//REG:PRODUCT_CODE:product code:32:0x4:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:PRODUCT_CODE:0:31:RW:R:0:
//REG:BUS_CLEAR:ip0 clear system bus:32:0x8:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:CLEAR:0:31:R:RW:0:
//REG:VERSION:IP0 release version:32:0xC:USER:VSBL:RET::1:4:0x14000000:0::
//FLD:REVISION:0:15:RW:R:0:
//FLD:MINOR:16:23:RW:R:0:
//FLD:MAJOR:24:27:RW:R:4:
//FLD:TYPE:28:31:RW:R:1:
//REG:SRC_ADDRESS:source address for ALP:32:0x40:USER:VSBL:RET::1:4:0xFFFFFFFF:0::
//FLD:SRC_ADDRESS:0:31:R:RW:4294967295:
//REG:DST0_ADDRESS:The first ALP Destination address:32:0x44:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:DST0_ADDRESS:0:31:RW1C:RW1S:0:
//REG:DST1_ADDRESS:The second ALP Destination address:32:0x48:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:DST1_ADDRESS:0:31:R:RW:0:
//REG:DST2_ADDRESS:The third ALP Destination address:32:0x4C:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:DST2_ADDRESS:0:31:R:RW:0:
//REG:DST3_ADDRESS:The fourth ALP Destination address:32:0x50:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:DST3_ADDRESS:0:31:R:RW:0:
//REG:IP_DATA_TYPE:IP_data type of IP. Backdoor IP or edpi IP:6:0x54:USER:VSBL:RET::1:4:0x00000001:0::
//FLD:DATA_TYPE0:0:5:R:RW:1:
//REG:ALP_LENGTH:The max ALP length of one frame. Payload length is ALP_LENGTH - 16B, the min alp_length is 32B and the unit is 1B. The field is 32B~4096B, and align 8B:32:0x58:USER:VSBL:RET::1:4:0x00000800:0::
//FLD:ALP_LENGTH:0:15:R:RW:2048:
//REG:ALP_TX_FRAME_CNT:send  alp_frame counter to IPs:32:0x5C:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:ALP_FRAME_CNT:0:31:W:R:0:
//REG:ALP_RX_FRAME_CNT:send  alp_frame counter to system bus:32:0x60:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:ALP_FRAME_CNT:0:31:W:R:0:
//REG:ALP_IF_CTRL:uf_alp_if control:32:0x64:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:resered:0:31:R:RW:0:
//REG:H2C_CACHE_FIFO_STS:FIFO is saved in backdoor module and no fifo is generated in emu.:32:0x68:USER:VSBL:RET::1:4:0x80000000:0::
//FLD:FIFO_CNT:0:9:RW:R:0:
//FLD:S_AXIS_TVALID:20:20:RW:R:0:
//FLD:S_AXIS_TREADY:21:21:RW:R:0:
//FLD:S_AXIS_TLAST:22:22:RW:R:0:
//FLD:M_AXIS_TVALID:24:24:RW:R:0:
//FLD:M_AXIS_TREADY:25:25:RW:R:0:
//FLD:M_AXIS_TLAST:26:26:RW:R:0:
//FLD:FIFO_FULL:30:30:RW:R:0:
//FLD:FIFO_EMPTY:31:31:RW:R:1:
//REG:ALP_MONITOR_STS:monitor ip io signals:32:0x6C:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:ALP_C2H_TIMEOUT:0:0:RW1S:RW1C:0:
//FLD:ALP_H2C_TIMEOUT:1:1:RW1S:RW1C:0:
//REG:IO_STATUS:stream io status:32:0x70:USER:VSBL:RET::1:4:0x00000000:0::
//FLD:DN_WRAP2IP_TLAST:0:0:RW:R:0:
//FLD:DN_WRAP2IP_TVALID:1:1:RW:R:0:
//FLD:DN_IP2WRAP_TREADY:2:2:RW:R:0:
//FLD:UP_IP2WRAP_TLAST:4:4:RW:R:0:
//FLD:UP_IP2WRAP_TVALID:5:5:RW:R:0:
//FLD:UP_WRAP2IP_TREADY:6:6:RW:R:0:
