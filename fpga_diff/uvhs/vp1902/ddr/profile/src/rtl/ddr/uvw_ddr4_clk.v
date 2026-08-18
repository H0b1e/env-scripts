// ================================================================================================
// Copyright(C) 2022 Univista Industrial Software Group Co.,Ltd All rights reserved.
// ================================================================================================
//
// ================================================================================================
// Module     : uvw_ddr4_clk
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
module uvw_ddr4_clk (
    // clock and reset
    input                                ip_clk                           , // clock, 50MHz
    input                                ip_rst                           , // reset, high active
    // register module
    output                               regm_clk                         , // register clock
    output                               regm_rst                         , // register reset
    // stream module
    output                               stream_clk                       , // stream clock
    output                               stream_rst                         // stream reset
);

    // -------------------------------------------------------------------
    // parameter declaration
    // -------------------------------------------------------------------


    // -------------------------------------------------------------------
    // signal declaration
    // -------------------------------------------------------------------
    wire                                s_clk_fb                          ;
    wire                                s_lock                            ;
    wire                                s_clk_out0                        ;
    wire                                s_clk_out1                        ;
    wire                                s_clk_out0_bufg                   ;
    wire                                s_clk_out1_bufg                   ;

    wire                                s_rst                             ;
    reg   [  7:0]                       r_regm_rst                        ;
    reg   [  7:0]                       r_stream_rst                      ;

// ================================================================================================
// RTL body
// ================================================================================================


    // -------------------------------------------------------------------
    // MMCM primitive instance
    // -------------------------------------------------------------------
    MMCME5 # (
        .BANDWIDTH            ("OPTIMIZED"),                           
        .CLKFBOUT_FRACT       (0.00),                
        .CLKFBOUT_PHASE       (0.00), 
        .CLKFBOUT_MULT        (12),               // Multiply value for all CLKOUT, (4-432)               
        .CLKIN1_PERIOD        (5.00),                
        .CLKOUT0_DIVIDE       (48), 
        .CLKOUT0_PHASE        (0.00),                
        .CLKOUT0_DUTY_CYCLE   (0.50), 
        .CLKOUT1_DIVIDE       (24),               
        .CLKOUT1_PHASE        (0.00),              
        .CLKOUT1_DUTY_CYCLE   (0.50),
        .COMPENSATION         ("AUTO"),                              
        .DIVCLK_DIVIDE        (1),                   
        .LOCK_WAIT            ("FALSE"),      
        .REF_JITTER1          (0.0),                
        .REF_JITTER2          (0.0),                
        .SS_EN                ("FALSE")  
    )
    u_mmcm (
        .CLKFBOUT            (s_clk_fb  ),
        .CLKOUT0             (s_clk_out0),
        .CLKOUT1             (s_clk_out1),
        .CLKOUT2             (          ),
        .CLKOUT3             (          ),
        .CLKOUT4             (          ),
        .CLKOUT5             (          ),
        .CLKOUT6             (          ),
         // Input clock control
        .CLKFBIN             (s_clk_fb  ),
        .CLKIN1              (ip_clk    ),
        .CLKIN2              (1'b0      ),
         // Tied to always select the primary input clock
        .CLKINSEL            (1'b1),
        // Ports for dynamic reconfiguration
        .DADDR               (7'h0),                  
        .DCLK                (1'b0),                  
        .DEN                 (1'b0),                  
        .DI                  (16'h0),                 
        .DO                  ( ),                     
        .DRDY                ( ),                     
        .DWE                 (1'b0),                                
        // Ports for dynamic phase shift              
        .PSCLK               (1'b0),                  
        .PSEN                (1'b0),                  
        .PSINCDEC            (1'b0),                  
        .PSDONE              ( ),                     
        // Other control and status signals           
        .LOCKED              (s_lock),               
        .CLKINSTOPPED        ( ),                     
        .CLKFBSTOPPED        ( ),                     
        .PWRDWN              (1'b0),                  
        .RST                 (ip_rst),
        //
        .LOCKED1_DESKEW      (), 
        .LOCKED2_DESKEW      (), 
        .LOCKED_FB           (),      
        .CLKFB1_DESKEW       (),  
        .CLKFB2_DESKEW       (),  
        .CLKIN1_DESKEW       (),  
        .CLKIN2_DESKEW       () 
    ); 


    /*
    MMCME4_ADV # (
        .BANDWIDTH                ("OPTIMIZED"         ),
        .CLKOUT4_CASCADE          ("FALSE"             ),
        .COMPENSATION             ("AUTO"              ),
        .STARTUP_WAIT             ("FALSE"             ),
        .DIVCLK_DIVIDE            (1                   ),
        .CLKFBOUT_MULT_F          (6.000              ),
        .CLKFBOUT_PHASE           (0.000               ),
        .CLKFBOUT_USE_FINE_PS     ("FALSE"             ),
        .CLKOUT0_DIVIDE_F         (24.000              ),
        .CLKOUT0_PHASE            (0.000               ),
        .CLKOUT0_DUTY_CYCLE       (0.500               ),
        .CLKOUT0_USE_FINE_PS      ("FALSE"             ),
        .CLKOUT1_DIVIDE           (12                  ),
        .CLKOUT1_PHASE            (0.000               ),
        .CLKOUT1_DUTY_CYCLE       (0.500               ),
        .CLKOUT1_USE_FINE_PS      ("FALSE"             ),
        .CLKIN1_PERIOD            (5.000              )
    )
    u_mmcm (
        .CLKFBOUT                 (s_clk_fb            ),
        .CLKFBOUTB                (                    ),
        .CLKOUT0                  (s_clk_out0          ),
        .CLKOUT0B                 (                    ),
        .CLKOUT1                  (s_clk_out1          ),
        .CLKOUT1B                 (                    ),
        .CLKOUT2                  (                    ),
        .CLKOUT2B                 (                    ),
        .CLKOUT3                  (                    ),
        .CLKOUT3B                 (                    ),
        .CLKOUT4                  (                    ),
        .CLKOUT5                  (                    ),
        .CLKOUT6                  (                    ),
         // Input clock control
        .CLKFBIN                  (s_clk_fb            ),
        .CLKIN1                   (ip_clk              ),
        .CLKIN2                   (1'b0                ),
         // Tied to always select the primary input clock
        .CLKINSEL                 (1'b1                ),
        // Ports for dynamic reconfiguration
        .DADDR                    (7'h0                ),
        .DCLK                     (1'b0                ),
        .DEN                      (1'b0                ),
        .DI                       (16'h0               ),
        .DO                       (                    ),
        .DRDY                     (                    ),
        .DWE                      (1'b0                ),
        .CDDCDONE                 (                    ),
        .CDDCREQ                  (1'b0                ),
        // Ports for dynamic phase shift
        .PSCLK                    (1'b0                ),
        .PSEN                     (1'b0                ),
        .PSINCDEC                 (1'b0                ),
        .PSDONE                   (                    ),
        // Other control and status signals
        .LOCKED                   (s_lock              ),
        .CLKINSTOPPED             (                    ),
        .CLKFBSTOPPED             (                    ),
        .PWRDWN                   (1'b0                ),
        .RST                      (ip_rst              )
    );
    */

    // -------------------------------------------------------------------
    // clock
    // -------------------------------------------------------------------
    BUFG u_bufg_clk0 (.I(s_clk_out0), .O(s_clk_out0_bufg));
    BUFG u_bufg_clk1 (.I(s_clk_out1), .O(s_clk_out1_bufg));

    assign regm_clk   = s_clk_out0_bufg;
    assign stream_clk = s_clk_out1_bufg;

    // -------------------------------------------------------------------
    // reset
    // -------------------------------------------------------------------
    assign s_rst = ip_rst | (~s_lock);

    always @( posedge s_clk_out0_bufg or posedge s_rst ) begin
        if ( s_rst == 1'b1 ) begin
            r_regm_rst <= 8'hFF;
        end else begin
            r_regm_rst <= {1'b0, r_regm_rst[7:1]};
        end
    end

    always @( posedge s_clk_out1_bufg or posedge s_rst ) begin
        if ( s_rst == 1'b1 ) begin
            r_stream_rst <= 8'hFF;
        end else begin
            r_stream_rst <= {1'b0, r_stream_rst[7:1]};
        end
    end

    assign regm_rst   = r_regm_rst[0]  ;
    assign stream_rst = r_stream_rst[0];


endmodule

