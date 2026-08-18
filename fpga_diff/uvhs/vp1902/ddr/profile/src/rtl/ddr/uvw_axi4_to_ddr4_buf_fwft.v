// =================================================================================================
// File Name        : uvw_axi4_to_ddr4_buf_fwft
// Module           : uvw_axi4_to_ddr4_buf_fwft
// Function         : uvw_axi4_to_ddr4_buf_fwft
// Type             : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date                 Coded by         Contents
// 0.1.0      2022/1/24            zhang.h
//
// =================================================================================================
// End Revision
// =================================================================================================

// =================================================================================================
// RTL Header
// =================================================================================================
module uvw_axi4_to_ddr4_buf_fwft #(
    parameter                       p_data_width                    = 32    ,
    parameter                       p_addr_width                    = 10
    ) (
    input                           clk                             , // (i)
    input                           rst                             , // (i)
    input                           wren                            , // (i)
    input   [p_data_width-1:0]      wdat                            , // (i)
    input                           rden                            , // (i)
    output  [p_data_width-1:0]      rdat                            , // (o)
    output  [p_addr_width+1-1:0]    dcnt                            , // (o)
    output                          full                            , // (o)
    output                          empt                              // (o)
) ;

	//---------------------------------------------------------------------
	// defination of parameters
	//---------------------------------------------------------------------
    parameter                       p_buf_depth                     = 1<<p_addr_width ;

	//---------------------------------------------------------------------
	// defination of internal signals
	//---------------------------------------------------------------------
    reg     [p_data_width-1:0]      r_buf       [0:p_buf_depth-1]   ;

    reg                             r_wren                          ;
    reg     [p_data_width-1:0]      r_wdat                          ;
    reg     [p_addr_width-1:0]      r_wadr                          ;
    reg     [p_addr_width-1:0]      r_radr                          ;
    reg     [p_addr_width+1-1:0]    r_dcnt                          ;

    // mem
    parameter                       INIT_FILE                       = "" ;

    generate
        if (INIT_FILE != "") begin: use_init_file
            initial
            $readmemh(INIT_FILE, r_buf, 0, p_buf_depth-1);
        end else begin: init_r_buf_to_zero
            integer ram_index;
            initial
            for (ram_index = 0; ram_index < p_buf_depth; ram_index = ram_index + 1)
                r_buf[ram_index] = {p_data_width{1'b0}};
        end
    endgenerate

// =================================================================================================
// rtl body
// =================================================================================================

	//---------------------------------------------------------------------
	// write
	//---------------------------------------------------------------------
    always @( posedge clk ) begin
        r_wren  <= wren ;
        r_wdat  <= wdat ;
    end

    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_wadr  <= {p_addr_width{1'b0}} ;
        end else begin
            if ( r_wren == 1'b1 ) begin
                r_wadr  <= r_wadr + 1 ;
            end
        end
    end

    always @( posedge clk ) begin
        if ( r_wren == 1'b1 ) begin
            r_buf[r_wadr]   <= r_wdat ;
        end
    end

	//---------------------------------------------------------------------
	// read
	//---------------------------------------------------------------------
	always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_radr  <= {p_addr_width{1'b0}} ;
        end else begin
            if ( rden == 1'b1 ) begin
                r_radr  <= r_radr + 1 ;
            end
        end
    end

    assign rdat = r_buf[r_radr] ;

	//---------------------------------------------------------------------
	// status
	//---------------------------------------------------------------------
    always @( posedge clk or posedge rst ) begin
        if ( rst == 1'b1 ) begin
            r_dcnt  <= {(p_addr_width+1){1'b0}} ;
        end else begin
            r_dcnt  <= r_dcnt + r_wren - rden ;
//            r_dcnt  <= r_dcnt + r_wren ;
        end
    end

    assign dcnt = r_dcnt    ;
    assign full = ( r_dcnt >= p_buf_depth + 1           ) ? 1'b1 : 1'b0 ;
    assign empt = ( r_dcnt == {(p_addr_width+1){1'b0}}  ) ? 1'b1 : 1'b0 ;

endmodule