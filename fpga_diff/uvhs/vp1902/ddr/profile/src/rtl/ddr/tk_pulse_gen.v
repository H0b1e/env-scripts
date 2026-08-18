// ================================================================================================
// Copyright(C) 2022 Univista Industrial Software Group Co.,Ltd All rights reserved.
// ================================================================================================
//
// ================================================================================================
// Module     : tk_pulse_gen
// Function   : Synchronous. pulse from clk_i to clk_o
// ------------------------------------------------------------------------------------------------
// Update History
// ------------------------------------------------------------------------------------------------
// Version        Data           Author             Contents
// 1.0.0          2022/03/04     Jin Liu            Initial release
//
// ================================================================================================


// ================================================================================================
// RTL header
// ================================================================================================
// Define    ///

// Timiscale ///
`timescale 1 ps / 1 ps

// Module start /////////////////////////////////
module tk_pulse_gen (
    input                   rst                     , // (i) Reset Input ( Asynchronous )
    input                   clk_i                   , // (i) clock at input side
    input                   clk_o                   , // (i) clock at output side
    input                   pulse_i                 , // (i) pulse input
    output                  pulse_o                   // (o) pulse output
) ;

    // -------------------------------------------------------------------
    // parameter declaration
    // -------------------------------------------------------------------
    parameter               p_type = 0              ;   //

    // -------------------------------------------------------------------
    // signal declaration
    // -------------------------------------------------------------------
    reg                     r_pulse_i               ;   //
    reg     [2:0]           r_pulse_o   /* synthesis syn_maxfan=9999 */; //r_pulse_o[0], r_pluse_o[1] should not be duplicated
                                                                         // synthesis attribute MAX_FANOUT of r_pulse_o is 9999;

// ================================================================================================
// RTL body
// ================================================================================================
    generate
    if(p_type == 0) begin :type_0_pulsegen
    // -------------------------------------------------------------------
    // Input pulse keep     ( clk_i domain )
    // -------------------------------------------------------------------
        always @( posedge clk_i or posedge rst ) begin
            if( rst ) begin
                r_pulse_i       <= 1'b0 ;
            end else begin
                if ( pulse_i == 1'b1 ) begin
                    r_pulse_i   <= ~r_pulse_i ;
                end
            end
        end
    // -------------------------------------------------------------------
    // Output pulse sync. and generate      ( clk_o domain )
    // -------------------------------------------------------------------
        always @( posedge clk_o or posedge rst ) begin
            if( rst ) begin
                r_pulse_o   <= 3'b000 ;
            end else begin
                r_pulse_o   <= { r_pulse_o[1:0] , r_pulse_i } ;
            end
        end

        assign pulse_o = (r_pulse_o[2] != r_pulse_o[1] ) ;   // 0 -> 1

    end
    endgenerate

endmodule
// Module end ///////////////////////////////////
