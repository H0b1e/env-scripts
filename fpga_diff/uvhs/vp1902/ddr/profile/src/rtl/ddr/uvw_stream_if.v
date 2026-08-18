// ================================================================================================
// Copyright(C) 2022 Univista Industrial Software Group Co.,Ltd All rights reserved.
// ================================================================================================
//
// ================================================================================================
// Module     : uvw_stream_if
// Function   : 
// ------------------------------------------------------------------------------------------------
// Update History
// ------------------------------------------------------------------------------------------------
// Version        Data           Author             Contents
// 1.0.0          2022/05/19     Jin Liu            Initial release
//
// ================================================================================================


// ================================================================================================
// RTL header
// ================================================================================================
// Define    ///

// Timiscale ///
`timescale 1 ps / 1 ps

// Module start /////////////////////////////////
module uvw_stream_if (
    // clock and reset
    input                                 clk                              , //
    input                                 rst                              , //
    // register
    input                                 bus_clear                        , //
    // stream interface
    output                                ip2sbus_clk                      , // clock
    output                                ip2sbus_rst                      , // reset, high active
    input                                 sbus2ip_tvalid                   , //
    input                                 sbus2ip_tlast                    , //
    input  [  7:0]                        sbus2ip_tkeep                    , //
    input  [ 63:0]                        sbus2ip_tdata                    , //
    output                                sbus2ip_tready                   , //
    output                                ip2sbus_tvalid                   , //
    output                                ip2sbus_tlast                    , //
    output [  7:0]                        ip2sbus_tkeep                    , //
    output [ 63:0]                        ip2sbus_tdata                    , //
    input                                 ip2sbus_tready                   , //
    // axi interface
    output [ 63:0]                        axi_araddr                       , // read address
    output [  7:0]                        axi_arlen                        , // read length
    output                                axi_arvalid                      , // read address valid
    output [ 63:0]                        axi_awaddr                       , //
    output [  7:0]                        axi_awlen                        , //
    output                                axi_awvalid                      , //
    output                                axi_bready                       , //
    output                                axi_rready                       , //
    output [ 63:0]                        axi_wdata                        , //
    output                                axi_wlast                        , //
    output [  7:0]                        axi_wstrb                        , //
    output                                axi_wvalid                       , //
    input                                 axi_arready                      , //
    input                                 axi_awready                      , //
    input  [  1:0]                        axi_bresp                        , //
    input                                 axi_bvalid                       , //
    input  [ 63:0]                        axi_rdata                        , //
    input                                 axi_rlast                        , //
    input  [  1:0]                        axi_rresp                        , //
    input                                 axi_rvalid                       , //
    input                                 axi_wready                       , //
    // register
    input                                 reg_clk                          , // register clock domain
    input  [ 63:0]                        ddr4_start_addr                  , // start address
    input  [ 63:0]                        ddr4_size                        , // size
    input                                 ddr4_wcmd                        , // write command
    input                                 ddr4_rcmd                        , // read command
    output                                ddr4_busy                          // 
);

    // -------------------------------------------------------------------
    // parameter declaration
    // -------------------------------------------------------------------
    parameter                             ST_DN_IDLE       = 8'b0000_0001 ;
    parameter                             ST_DN_WADDR      = 8'b0000_0010 ;
    parameter                             ST_DN_WDATA      = 8'b0000_0100 ;
    parameter                             ST_DN_WRESP      = 8'b0000_1000 ;
    parameter                             ST_DN_WCHK       = 8'b0001_0000 ;
    parameter                             ST_DN_RADDR      = 8'b0010_0000 ;
    parameter                             ST_DN_RDATA      = 8'b0100_0000 ;
    parameter                             ST_DN_RCHK       = 8'b1000_0000 ;

    // -------------------------------------------------------------------
    // signal declaration
    // -------------------------------------------------------------------
    // sync.
    reg    [ 63:0]                        r_start_addr                     ;
    reg    [ 63:0]                        r_size                           ;
    wire                                  s_wcmd                           ;
    wire                                  s_rcmd                           ;

    // stream -> axi4 (system bus -> IP)
    wire                                  s_dn_fifo_wen                    ;
    wire   [ 71:0]                        s_dn_fifo_wdata                  ;
    wire                                  s_dn_fifo_ren                    ;
    wire   [ 71:0]                        s_dn_fifo_rdata                  ;
    wire                                  s_dn_fifo_full                   ;
    wire                                  s_dn_fifo_empty                  ;
    wire   [  9:0]                        s_dn_fifo_dcnt                   ;
 
    reg    [  7:0]                        r_dn_fsm                         ;
    wire                                  s_busy                    	   ;
    reg                                   r_busy                           ;
    reg    [ 63:0]                        r_wr_size                        ;
    reg                                   r_wr_end                         ;
    reg    [ 63:0]                        r_axi_awaddr                     ;
    reg    [  7:0]                        r_axi_awlen                      ;
    reg                                   r_axi_awvalid                    ;
    wire                                  s_axi_wlast                      ;
    reg    [  8:0]                        r_awlen_cnt                      ;
    reg    [ 63:0]                        r_rd_size                        ;
    reg                                   r_rd_end                         ;
    reg    [ 63:0]                        r_axi_araddr                     ;
    reg    [  7:0]                        r_axi_arlen                      ;
    reg                                   r_axi_arvalid                    ;
    wire                                  s_axi_rready                     ;
    wire                                  s_axi_rlast                      ;

     // axi4 -> stream (IP -> system bus)
    wire                                  s_up_fifo_wen                    ;
    wire   [ 71:0]                        s_up_fifo_wdata                  ;
    wire                                  s_up_fifo_ren                    ;
    wire   [ 71:0]                        s_up_fifo_rdata                  ;
    wire                                  s_up_fifo_full                   ;
    wire                                  s_up_fifo_empty                  ;
    wire   [  9:0]                        s_up_fifo_dcnt                   ;

    reg    [ 63:0]                        r_up_size_cnt                    ;
    wire                                  s_up_end                         ;

    reg   [  3:0]                         r_bus_clear                      ;
    wire                                  s_bus_clear_rise_edge            ;
    reg   [  4:0]                         r_fifo_rst_cnt                   ;
    reg                                   r_fifo_rst                       ;
    wire                                  s_dummy_fifo_ren                 ;

// ================================================================================================
// RTL body
// ================================================================================================
    assign ddr4_busy       = r_busy ;
    assign ip2sbus_clk     = clk ;
    assign ip2sbus_rst     = rst ;

    // -------------------------------------------------------------------
    // commadn sync.
    // -------------------------------------------------------------------
    // start address and size
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_start_addr <= 64'd0;
            r_size       <= 64'd0;
        end else begin
            r_start_addr <= ddr4_start_addr;
            r_size       <= ddr4_size      ;
        end
    end

    // write command
    tk_pulse_gen u_wcmd_sync (
        .rst                     (rst             ), // (i) Reset Input ( Asynchronous )
        .clk_i                   (reg_clk         ), // (i) clock at input side
        .clk_o                   (clk             ), // (i) clock at output side
        .pulse_i                 (ddr4_wcmd       ), // (i) pulse input
        .pulse_o                 (s_wcmd          )  // (o) pulse output
    ) ;

    // read command
    tk_pulse_gen u_rcmd_sync (
        .rst                     (rst             ), // (i) Reset Input ( Asynchronous )
        .clk_i                   (reg_clk         ), // (i) clock at input side
        .clk_o                   (clk             ), // (i) clock at output side
        .pulse_i                 (ddr4_rcmd       ), // (i) pulse input
        .pulse_o                 (s_rcmd          )  // (o) pulse output
    ) ;

    // bus clear sync
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_bus_clear <= 4'b0;
        end else begin
            r_bus_clear <= {bus_clear,  r_bus_clear[3:1]};
        end
    end

    assign s_bus_clear_rise_edge = r_bus_clear[1] & (~r_bus_clear[0]);

    // -------------------------------------------------------------------
    // stream -> axi4 (system bus -> IP)
    // -------------------------------------------------------------------
    // fifo reset control
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_fifo_rst_cnt <= 5'd0;
            r_fifo_rst     <= 1'b1;
        end else begin
            if (s_bus_clear_rise_edge == 1'b1) begin
                r_fifo_rst_cnt <= 5'h1F;
            end else if (r_fifo_rst_cnt != 5'd0) begin
                r_fifo_rst_cnt <= r_fifo_rst_cnt - 1'b1;
            end

            r_fifo_rst <= |r_fifo_rst_cnt;
        end
    end

    // sysbus -> IP FIFO control
    assign s_dn_fifo_wen   = sbus2ip_tvalid & (~s_dn_fifo_full) & (~r_bus_clear[0]);
    assign s_dn_fifo_wdata = {sbus2ip_tkeep, sbus2ip_tdata};

    assign sbus2ip_tready  = ~s_dn_fifo_full | r_bus_clear[0];
    
    //assign s_dn_fifo_ren   = ~s_dn_fifo_empty & axi_wready & r_dn_fsm[2] & (~r_bus_clear[0]) ;
    assign s_dn_fifo_ren   = axi_wvalid & axi_wready & r_dn_fsm[2] & (~r_bus_clear[0]) ;

    sfifo_72bx512_fwft_wrapper u_dn_fifo (
        .clk                     (clk             ), // IN STD_LOGIC;
        .rst                     (r_fifo_rst      ), // IN STD_LOGIC;
        .din                     (s_dn_fifo_wdata ), // IN STD_LOGIC_VECTOR(71 DOWNTO 0);
        .wr_en                   (s_dn_fifo_wen   ), // IN STD_LOGIC;
        .rd_en                   (s_dn_fifo_ren   ), // IN STD_LOGIC;
        .dout                    (s_dn_fifo_rdata ), // OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
        .full                    (                ), // OUT STD_LOGIC;
        .empty                   (s_dn_fifo_empty ), // OUT STD_LOGIC;
        .data_count              (s_dn_fifo_dcnt  ), // OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        .prog_full               (s_dn_fifo_full  )  // OUT STD_LOGIC
    );

    // axi4 interace
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1) begin
            r_dn_fsm <= ST_DN_IDLE;
        end else begin
            case (r_dn_fsm)
                ST_DN_IDLE       : begin
                    if (s_wcmd == 1'b1) begin
                        r_dn_fsm <= ST_DN_WADDR;
                    end else if (s_rcmd == 1'b1) begin
                        r_dn_fsm <= ST_DN_RADDR;
                    end
                end

                ST_DN_WADDR      : begin
                    if (r_axi_awvalid == 1'b1 && axi_awready == 1'b1) begin
                        r_dn_fsm <= ST_DN_WDATA;
                    end
                end

                ST_DN_WDATA      : begin
                    if (s_axi_wlast == 1'b1) begin
                        r_dn_fsm <= ST_DN_WRESP;
                    end
                end

                ST_DN_WRESP      : begin
                    if (axi_bvalid == 1'b1) begin
                        r_dn_fsm <= ST_DN_WCHK;
                    end
                end

                ST_DN_WCHK       : begin
                    if (r_wr_end == 1'b1) begin
                        r_dn_fsm <= ST_DN_IDLE;
                    end else begin
                        r_dn_fsm <= ST_DN_WADDR;
                    end
                end

                ST_DN_RADDR      : begin
                    if (r_axi_arvalid == 1'b1 && axi_arready == 1'b1) begin
                        r_dn_fsm <= ST_DN_RDATA;
                    end
                end

                ST_DN_RDATA      : begin
                    if (s_axi_rlast == 1'b1) begin
                        r_dn_fsm <= ST_DN_RCHK;
                    end
                end

                ST_DN_RCHK       : begin
                    if (r_rd_end == 1'b1) begin
                        r_dn_fsm <= ST_DN_IDLE;
                    end else begin
                        r_dn_fsm <= ST_DN_RADDR;
                    end
                end

                default          : begin
                    r_dn_fsm <= ST_DN_IDLE;
                end
            endcase
        end
    end

    // access busy
//    always @( posedge clk or posedge rst ) begin
//        if ( rst == 1'b1 ) begin
//            r_busy <= 1'b0;
//        end else begin
//            if (r_dn_fsm[0] == 1'b1 && (s_wcmd == 1'b1 || s_rcmd == 1'b1)) begin
//                r_busy <= 1'b1;
//            end else if (r_wr_end == 1'b1 || r_rd_end == 1'b1) begin
//                r_busy <= 1'b0;
//            end
//        end
//    end
	
     assign s_busy = ~r_dn_fsm[0] ;
    // access busy
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_busy <= 1'b0;
        end else begin
            r_busy <= s_busy;
        end
    end


    // write size counter
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_wr_size <= 64'd0;
        end else begin
            if (r_dn_fsm[0] == 1'b1 && s_wcmd == 1'b1) begin
                r_wr_size <= {3'd0, r_size[63:3]};
            end else if (s_bus_clear_rise_edge == 1'b1) begin
                r_wr_size <= 64'd0;
            end else if (s_dn_fifo_ren == 1'b1) begin
                r_wr_size <= r_wr_size - 1'b1;
            end 
        end
    end

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_wr_end <= 1'b0;
        end else begin
            if ( s_bus_clear_rise_edge == 1'b1) begin
                r_wr_end <= 1'b1;
            end else if (s_dn_fifo_ren == 1'b1 && r_wr_size == 64'd1) begin
                r_wr_end <= 1'b1;
            end else if (r_dn_fsm[0] == 1'b1) begin
                r_wr_end <= 1'b0;
            end
        end
    end

    // awaddr
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_axi_awaddr <= 64'd0;
        end else begin
            if (r_dn_fsm[0] == 1'b1 && s_wcmd == 1'b1) begin
                r_axi_awaddr <= r_start_addr;
            end else if (r_dn_fsm[4] == 1'b1) begin
                r_axi_awaddr <= r_axi_awaddr + 64'd2048; // 8byte x 256 cycle = 2048byte
            end
        end
    end

    // awlen
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_axi_awlen <= 8'd0;
        end else begin
            if (r_dn_fsm[1] == 1'b1 && r_wr_size >= 64'd256) begin
                r_axi_awlen <= 8'hFF;
            end else begin
                r_axi_awlen <= r_wr_size[7:0]-1'b1;
            end
        end
    end

    // awvalid
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_axi_awvalid <= 1'b0;
        end else begin
            if (r_dn_fsm[1] == 1'b1 && r_axi_awvalid == 1'b1 && axi_awready == 1'b1) begin
                r_axi_awvalid <= 1'b0;
            end else if (r_dn_fsm[1] == 1'b1 && r_axi_awvalid == 1'b0) begin
                r_axi_awvalid <= 1'b1;
            end
        end
    end

    // wlast
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_awlen_cnt <= 9'd0;
        end else begin
            if (r_dn_fsm[1] == 1'b1 && r_axi_awvalid == 1'b1 && axi_awready == 1'b1) begin
                r_awlen_cnt <= r_axi_awlen + 1'b1;
            end else if (s_dn_fifo_ren == 1'b1 || s_dummy_fifo_ren == 1'b1 ) begin
                r_awlen_cnt <= r_awlen_cnt - 1'b1;
            end
        end
    end

    assign s_axi_wlast = ((s_dn_fifo_ren == 1'b1 || s_dummy_fifo_ren == 1'b1)  && r_awlen_cnt == 9'd1) ? 1'b1 : 1'b0;
    assign s_dummy_fifo_ren = (r_bus_clear[0] == 1'b1 && r_awlen_cnt != 0) ? 1'b1 : 1'b0;

    assign axi_awaddr         = r_axi_awaddr           ;
    assign axi_awlen          = r_axi_awlen            ;
    assign axi_awvalid        = r_axi_awvalid          ;
    assign axi_bready         = 1'b1                   ;
    assign axi_wdata          = s_dn_fifo_rdata[63: 0] ;
    assign axi_wlast          = s_axi_wlast            ;
    assign axi_wstrb          = s_dn_fifo_rdata[71:64] ;
    //assign axi_wvalid         = s_dn_fifo_ren | s_dummy_fifo_ren         ;
    //assign axi_wvalid         = ~s_dn_fifo_empty;
    assign axi_wvalid         = ~s_dn_fifo_empty| s_dummy_fifo_ren;




    // //////////////////////////////////////
    // read size counter
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_rd_size <= 64'd0;
        end else begin
            if (r_dn_fsm[0] == 1'b1 && s_rcmd == 1'b1) begin
                r_rd_size <= {3'd0, r_size[63:3]};
            end else if (axi_rvalid == 1'b1 && s_axi_rready == 1'b1 && (|r_rd_size== 1'b1) ) begin
                r_rd_size <= r_rd_size - 1'b1;
            end 
        end
    end

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_rd_end <= 1'b0;
        end else begin
            if (axi_rvalid == 1'b1 && s_axi_rready == 1'b1 && r_rd_size == 64'd1) begin
                r_rd_end <= 1'b1;
            end else if (r_dn_fsm[0] == 1'b1) begin
                r_rd_end <= 1'b0;
            end
        end
    end

    // araddr
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_axi_araddr <= 64'd0;
        end else begin
            if (r_dn_fsm[0] == 1'b1 && s_rcmd == 1'b1) begin
                r_axi_araddr <= r_start_addr;
            end else if (r_dn_fsm[7] == 1'b1) begin
                r_axi_araddr <= r_axi_araddr + 64'd2048; // 8byte x 256 cycle = 2048byte
            end
        end
    end

    // arlen
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_axi_arlen <= 8'd0;
        end else begin
            if (r_dn_fsm[5] == 1'b1 && r_rd_size >= 64'd256) begin
                r_axi_arlen <= 8'hFF;
            end else begin
                r_axi_arlen <= r_rd_size[7:0]-1'b1;
            end
        end
    end

    // arvalid
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_axi_arvalid <= 1'b0;
        end else begin
            if (r_dn_fsm[5] == 1'b1 && r_axi_arvalid == 1'b1 && axi_arready == 1'b1) begin
                r_axi_arvalid <= 1'b0;
            end else if (r_dn_fsm[5] == 1'b1 && r_axi_arvalid == 1'b0) begin
                r_axi_arvalid <= 1'b1;
            end
        end
    end

    // rlast
    assign s_axi_rlast = axi_rvalid & axi_rlast & s_axi_rready;

    // rready
    assign s_axi_rready = ~s_up_fifo_full;

    assign axi_araddr      = r_axi_araddr  ;
    assign axi_arlen       = r_axi_arlen   ;
    assign axi_arvalid     = r_axi_arvalid ;
    assign axi_rready      = s_axi_rready  ;

    // -------------------------------------------------------------------
    // axi4 -> stream (IP -> system bus)
    // -------------------------------------------------------------------
    assign s_up_fifo_wen   = axi_rvalid & s_axi_rready;
    assign s_up_fifo_wdata = {8'hFF, axi_rdata};

    sfifo_72bx512_fwft_wrapper u_up_fifo (
        .clk                     (clk             ), // IN STD_LOGIC;
        .rst                     (r_fifo_rst      ), // IN STD_LOGIC;
        .din                     (s_up_fifo_wdata ), // IN STD_LOGIC_VECTOR(71 DOWNTO 0);
        .wr_en                   (s_up_fifo_wen   ), // IN STD_LOGIC;
        .rd_en                   (s_up_fifo_ren   ), // IN STD_LOGIC;
        .dout                    (s_up_fifo_rdata ), // OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
        .full                    (                ), // OUT STD_LOGIC;
        .empty                   (s_up_fifo_empty ), // OUT STD_LOGIC;
        .data_count              (s_up_fifo_dcnt  ), // OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        .prog_full               (s_up_fifo_full  )  // OUT STD_LOGIC;

    );

    assign s_up_fifo_ren        = ip2sbus_tready & (~s_up_fifo_empty) ;

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_up_size_cnt <= 64'd0;
        end else begin
            if (r_dn_fsm[0] == 1'b1 && s_rcmd == 1'b1) begin
                r_up_size_cnt <= {3'd0, r_size[63:3]};
            end else if (s_up_fifo_ren == 1'b1 && (|r_up_size_cnt) == 1'b1 ) begin
                r_up_size_cnt <= r_up_size_cnt - 1'b1;
            end
        end
    end

    assign s_up_end = (s_up_fifo_ren == 1'b1 && r_up_size_cnt == 64'd1) ? 1'b1 : 1'b0;


    assign ip2sbus_tvalid       = s_up_fifo_ren          ;
    assign ip2sbus_tlast        = s_up_end               ;
    assign ip2sbus_tkeep        = s_up_fifo_rdata[71:64] ;
    assign ip2sbus_tdata        = s_up_fifo_rdata[63: 0] ;




endmodule

