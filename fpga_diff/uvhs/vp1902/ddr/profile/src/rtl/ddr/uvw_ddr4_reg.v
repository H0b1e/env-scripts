// ================================================================================================
// Copyright(C) 2022 Univista Industrial Software Group Co.,Ltd All rights reserved.
// ================================================================================================
//
// ================================================================================================
// Module     : uvw_ddr4_reg
// Function   : 
// ------------------------------------------------------------------------------------------------
// Update History
// ------------------------------------------------------------------------------------------------
// Version        Data           Author             Contents
// 1.0.0          2022/05/18     Jin Liu            Initial release
//
// ================================================================================================


// ================================================================================================
// RTL header
// ================================================================================================
// Define    ///

// Timiscale ///
`timescale 1 ps / 1 ps

// Module start /////////////////////////////////
module uvw_ddr4_reg (
    // clock and reset
    input                                 clk                              , // clock
    input                                 rst                              , // reset, high active
    // system bus interface
    output                                reg_clk                          , //
    output                                reg_rst                          , //
    input                                 reg_wr_en                        , // write enable
    input  [ 15:0]                        reg_addr                         , // write/read address
    input  [ 31:0]                        reg_wr_data                      , // write data
    output                                reg_wr_resp                      , // write response
    output                                reg_wr_valid                     , // write valid
    input                                 reg_rd_en                        , // read enable
    output [ 31:0]                        reg_rd_data                      , // read data
    output                                reg_rd_resp                      , // read response
    output                                reg_rd_valid                     , // read valid
    output                                intr                             , // interrupt
    // register (ddr4 ip)
    output                                bus_clear                        , // bus clear
    output [ 63:0]                        ddr4_start_addr                  , // ddr4 write/read start address
    output [ 63:0]                        ddr4_size                        , // ddr4 write/read size
    output                                ddr4_wcmd                        , // ddr4 write command
    output                                ddr4_rcmd                        , // ddr4 read command
    output                                ddr4_rst                         , // ddr4 reset
    input                                 ddr4_busy                        , //
    input                                 ddr4_calib_done                  , //

    input [  3:0]                         version_type                     ,
    input [  3:0]                         version_major                    ,  
    input [  7:0]                         version_minor                    ,
    input [ 15:0]                         version_revision		   
);


    // -------------------------------------------------------------------
    // parameter declaration
    // -------------------------------------------------------------------
    parameter                            IP_TYPE           = 32'h0016     ;
    parameter                            IP_VERSION        = 32'h01010000 ;
    parameter                            IP_PROD_CODE      = 32'h0003     ;

    parameter                            ADR_IP_TYPE       = 16'h0000     ;
    parameter                            ADR_PROD_CODE     = 16'h0004     ;
    parameter                            ADR_BUS_CLEAR     = 16'h0008     ;
    parameter                            ADR_VERSION       = 16'h000c     ;

    parameter                            ADR_RST           = 16'h0110     ;
    parameter                            ADR_STATUS        = 16'h0120     ;
    parameter                            ADR_START_ADDR_L  = 16'h0130     ;
    parameter                            ADR_START_ADDR_H  = 16'h0134     ;
    parameter                            ADR_SIZE_L        = 16'h0138     ;
    parameter                            ADR_SIZE_H        = 16'h013C     ;
    parameter                            ADR_CMD           = 16'h0150     ;

    // -------------------------------------------------------------------
    // signal declaration
    // -------------------------------------------------------------------
    reg                                 r_bus_clear                       ;
    reg   [ 31:0]                       r_bus_clear_reg                   ;
    reg                                 r_rst                             ;
    reg   [ 63:0]                       r_start_addr                      ;
    reg   [ 63:0]                       r_size                            ;
    reg                                 r_wcmd                            ;
    reg                                 r_rcmd                            ;
    reg                                 r_wr_valid                        ;
    wire  [ 31:0]                       s_rd_data                         ;
    reg   [ 31:0]                       r_rd_data                         ;
    reg                                 r_rd_valid                        ;

    reg   [  3:0]                       r_calib_done                      ;

    reg                                 r_wr_en_dly1                      ;
    reg                                 r_wr_en_dly2                      ;
    reg   [ 15:0]                       r_wr_addr                         ;
    reg   [ 31:0]                       r_wr_data                         ;


    wire                                s_reg_wr_en                       ;
    wire  [ 15:0]                       s_reg_wr_addr                     ;
    wire  [ 31:0]                       s_reg_wr_data                     ;


// ================================================================================================
// RTL body
// ================================================================================================

    assign reg_clk = clk ;
    assign reg_rst = rst ;

    // -------------------------------------------------------------------
    // register write
    // -------------------------------------------------------------------
    assign reg_wr_resp = 1'b0;

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_wr_en_dly1 <= 1'b0;
            r_wr_en_dly2 <= 1'b0;
        end else begin
            r_wr_en_dly1 <= reg_wr_en   ;
            r_wr_en_dly2 <= r_wr_en_dly1;
        end
    end

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_wr_addr <= 16'd0;
        end else begin
            if (reg_wr_en == 1'b1) begin
                r_wr_addr <= reg_addr;
            end
        end
    end

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_wr_data <= 32'd0;
        end else begin
            if (reg_wr_en == 1'b1) begin
                r_wr_data <= reg_wr_data;
            end
        end
    end

    assign s_reg_wr_en        = r_wr_en_dly1;
    assign s_reg_wr_addr      = r_wr_addr   ;
    assign s_reg_wr_data      = r_wr_data   ;




    // bus clear
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_bus_clear <= 1'b0;
        end else begin
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_BUS_CLEAR && s_reg_wr_data == 32'h0000000A) begin
                r_bus_clear <= 1'b1;
            end else if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_BUS_CLEAR && s_reg_wr_data == 32'h00000005) begin
                r_bus_clear <= 1'b0;
            end
        end
    end

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_bus_clear_reg <= 32'd0;
        end else begin
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_BUS_CLEAR) begin r_bus_clear_reg <= s_reg_wr_data; end
        end
     end



    assign bus_clear = r_bus_clear;

    // reset
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_rst <= 1'b1;
        end else begin
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_RST) begin
                r_rst <= s_reg_wr_data[0];
            end
        end
    end
    
    assign ddr4_rst = r_rst ;

    // start address
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_start_addr[31: 0] <= 32'd0;
            r_start_addr[63:32] <= 32'd0;
        end else begin
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_START_ADDR_L) begin r_start_addr[31: 0] <= s_reg_wr_data; end
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_START_ADDR_H) begin r_start_addr[63:32] <= s_reg_wr_data; end
        end
     end
 
    assign ddr4_start_addr = r_start_addr;

    // size
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_size[31: 0] <= 32'd0;
            r_size[63:32] <= 32'd0;
        end else begin
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_SIZE_L) begin r_size[31: 0] <= s_reg_wr_data; end
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_SIZE_H) begin r_size[63:32] <= s_reg_wr_data; end
        end
    end

    assign ddr4_size = r_size;

    // command
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_wcmd <= 1'b0;
            r_rcmd <= 1'b0;
        end else begin
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_CMD && s_reg_wr_data[0] == 1'b1) begin
                r_wcmd <= 1'b1;
            end else begin
                r_wcmd <= 1'b0;
            end
 
            if (s_reg_wr_en == 1'b1 && s_reg_wr_addr == ADR_CMD && s_reg_wr_data[1] == 1'b1) begin
                r_rcmd <= 1'b1;
            end else begin
                r_rcmd <= 1'b0;
            end
 
        end
    end

   assign ddr4_wcmd = r_wcmd;
   assign ddr4_rcmd = r_rcmd;

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_wr_valid <= 1'b0;
        end else begin
            r_wr_valid <= reg_wr_en;
        end
    end

    assign reg_wr_valid = r_wr_valid;

    // -------------------------------------------------------------------
    // sync.
    // -------------------------------------------------------------------

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_calib_done <= 4'd0;
        end else begin
            r_calib_done <= { ddr4_calib_done, r_calib_done[3:1] };
        end
    end

    // -------------------------------------------------------------------
    // register read
    // -------------------------------------------------------------------
    assign reg_rd_resp = 1'b0;
    assign s_rd_data   = (reg_addr == ADR_IP_TYPE       ) ? IP_TYPE                                     :
                         (reg_addr == ADR_PROD_CODE     ) ? IP_PROD_CODE                                :
                         (reg_addr == ADR_BUS_CLEAR     ) ? r_bus_clear_reg                             :
                         (reg_addr == ADR_VERSION       ) ? {version_type, version_major, version_minor, version_revision}:
                         (reg_addr == ADR_RST           ) ? {31'd0, r_rst                             } :
//                       (reg_addr == ADR_STATUS        ) ? {30'd0, ddr4_busy, ddr4_calib_done        } :
                         (reg_addr == ADR_STATUS        ) ? {30'd0, ddr4_busy, r_calib_done[0]        } :
                         (reg_addr == ADR_START_ADDR_L  ) ? r_start_addr[31: 0]                         :
                         (reg_addr == ADR_START_ADDR_H  ) ? r_start_addr[63:32]                         :
                         (reg_addr == ADR_SIZE_L        ) ? r_size[31: 0]                               :
                         (reg_addr == ADR_SIZE_H        ) ? r_size[63:32]                               :
                         32'd0;

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_rd_data  <= 32'd0;
            r_rd_valid <=  1'b0;
        end else begin
            r_rd_data  <= s_rd_data;
            r_rd_valid <= reg_rd_en;
        end
    end

    assign reg_rd_data = r_rd_data;
    assign reg_rd_valid = r_rd_valid;


    // -------------------------------------------------------------------
    // Interrupt
    // -------------------------------------------------------------------
    assign intr = 1'b0;

 

endmodule
