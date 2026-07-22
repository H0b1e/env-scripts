// ================================================================================================
// Copyright(C) 2022 Univista Industrial Software Group Co.,Ltd All rights reserved.
// ================================================================================================
//
// ================================================================================================
// Module     : uvw_sbus_register_branch 
// Function   : systembus 3.0 register branch.
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
module uvw_sbus_register_branch                        
(
    sbus_clk          ,
    sbus_rst          ,
    // IP_register_from
    reg_addr     ,
    reg_wr_en    ,
    reg_wr_data  ,
    reg_wr_resp  ,
    reg_wr_valid ,
    reg_rd_en    ,
    reg_rd_data  ,
    reg_rd_resp  ,
    reg_rd_valid ,
    
    // IP_register
    ip_brch1_reg_addr     ,
    ip_brch1_reg_wr_en    ,
    ip_brch1_reg_wr_data  ,
    ip_brch1_reg_wr_valid ,
    ip_brch1_reg_wr_resp  ,
    ip_brch1_reg_rd_en    ,
    ip_brch1_reg_rd_data  ,
    ip_brch1_reg_rd_resp  ,
    ip_brch1_reg_rd_valid ,   

    ip_brch2_reg_addr     ,
    ip_brch2_reg_wr_en    ,
    ip_brch2_reg_wr_data  ,
    ip_brch2_reg_wr_valid ,
    ip_brch2_reg_wr_resp  ,
    ip_brch2_reg_rd_en    ,
    ip_brch2_reg_rd_data  ,
    ip_brch2_reg_rd_resp  ,
    ip_brch2_reg_rd_valid       
    
);

   // generate
      // case (<constant_expression>)
         // <value>: begin: <label_1>
                     // <code>
                  // end
         // <value>: begin: <label_2>
                     // <code>
                  // end
         // default: begin: <label_3>
                     // <code>
                  // end
      // endcase
   // endgenerate

    parameter BRANCH_ADDR1      = 32'H2000             ;
    parameter BRANCH_ADDR2      = 32'H3000             ;
    parameter BRANCH_ADDR3      = 32'H4000             ;
    parameter BRANCH_ADDR4      = 32'H5000             ; 
    parameter BRANCH_ADDR5      = 32'H9000             ;
    parameter BRANCH_ADDR6      = 32'HD000             ;
    parameter BRANCH_ADDR7      = 32'H10000            ;
    parameter REG_ADDR_WIDTH    = 16                   ;     // Register Addr WIDTH of IP
    parameter REG_DATA_WIDTH    = 32                   ;    // Register data width of IP  )   
    parameter BRANCH_SEL        = 8                    ;
   
    parameter BARNCH1_DEL       = 1;/// The difference in delay time
    parameter BARNCH2_DEL       = 1;/// The difference in delay time

    input                          sbus_clk                      ;
    input                          sbus_rst                      ;
    input  [REG_ADDR_WIDTH-1   : 0]reg_addr                      ;
    input                          reg_wr_en                     ;
    input  [REG_DATA_WIDTH-1   : 0]reg_wr_data                   ;
    output                         reg_wr_valid                  ;
    output                         reg_wr_resp                   ;
    
    input                          reg_rd_en                     ;
    output [REG_DATA_WIDTH-1   : 0]reg_rd_data                   ;
    output                         reg_rd_resp                   ;
    output                         reg_rd_valid                  ;
    
    output [REG_ADDR_WIDTH-1   : 0]ip_brch1_reg_addr             ;
    output                         ip_brch1_reg_wr_en            ;
    output [REG_DATA_WIDTH-1   : 0]ip_brch1_reg_wr_data          ;
    input                          ip_brch1_reg_wr_valid         ;
    input                          ip_brch1_reg_wr_resp          ;
    output                         ip_brch1_reg_rd_en            ;
    input  [REG_DATA_WIDTH-1   : 0]ip_brch1_reg_rd_data          ;
    input                          ip_brch1_reg_rd_resp          ;
    input                          ip_brch1_reg_rd_valid         ;    
    
    output [REG_ADDR_WIDTH-1   : 0]ip_brch2_reg_addr             ;
    output                         ip_brch2_reg_wr_en            ;
    output [REG_DATA_WIDTH-1   : 0]ip_brch2_reg_wr_data          ;
    input                          ip_brch2_reg_wr_valid         ;    
    input                          ip_brch2_reg_wr_resp          ;
    output                         ip_brch2_reg_rd_en            ;
    input  [REG_DATA_WIDTH-1   : 0]ip_brch2_reg_rd_data          ;
    input                          ip_brch2_reg_rd_resp          ;
    input                          ip_brch2_reg_rd_valid         ; 

    reg                         r_reg_wr_en                     ;
    reg                         r_reg_rd_en                     ;    
    reg[REG_ADDR_WIDTH-1   : 0] r_reg_addr                      ;
    reg[REG_DATA_WIDTH-1   : 0] r_reg_wr_data                   ;    
    reg[REG_DATA_WIDTH-1   : 0] r_reg_rd_data                   ;
    reg                         r_reg_rd_valid                  ;
    reg                         r_reg_wr_valid                  ;    
 
    reg [REG_ADDR_WIDTH-1   : 0]r_ip_brch1_reg_addr             ;
    reg                         r_ip_brch1_reg_wr_en            ;
    reg [REG_DATA_WIDTH-1   : 0]r_ip_brch1_reg_wr_data          ;
    reg                         r_ip_brch1_reg_wr_valid         ;    
    reg                         r_ip_brch1_reg_rd_en            ;
    reg [REG_DATA_WIDTH-1   : 0]r_ip_brch1_reg_rd_data          ;
    reg                         r_ip_brch1_reg_rd_valid         ;       
    
   
    reg [REG_ADDR_WIDTH-1   : 0]r_ip_brch2_reg_addr             ;
    reg                         r_ip_brch2_reg_wr_en            ;
    reg [REG_DATA_WIDTH-1   : 0]r_ip_brch2_reg_wr_data          ;
    reg                         r_ip_brch2_reg_wr_valid         ;      
    reg                         r_ip_brch2_reg_rd_en            ;
    reg [REG_DATA_WIDTH-1   : 0]r_ip_brch2_reg_rd_data          ;
    reg                         r_ip_brch2_reg_rd_valid         ;    

    reg [BARNCH1_DEL-1 : 0]                 rr_ip_brch1_reg_wr_valid         ;      
    reg [REG_DATA_WIDTH*BARNCH1_DEL-1   : 0]rr_ip_brch1_reg_rd_data          ;
    reg [BARNCH1_DEL-1 : 0]                 rr_ip_brch1_reg_rd_valid         ;  
    reg [BARNCH2_DEL-1 : 0]                 rr_ip_brch2_reg_wr_valid         ;      
    reg [REG_DATA_WIDTH*BARNCH2_DEL-1   : 0]rr_ip_brch2_reg_rd_data          ;
    reg [BARNCH2_DEL-1 : 0]                 rr_ip_brch2_reg_rd_valid         ;  

   
    wire [REG_ADDR_WIDTH-1   : 0] branch_addr;
    assign reg_rd_resp  = 1'b0;
    assign reg_wr_resp  = 1'b0;
    assign reg_wr_valid = r_reg_wr_valid;
    assign reg_rd_data  = r_reg_rd_data ;
    assign reg_rd_valid = r_reg_rd_valid;    
    assign ip_brch1_reg_addr            =  r_ip_brch1_reg_addr     ;
    assign ip_brch1_reg_wr_en           =  r_ip_brch1_reg_wr_en    ;
    assign ip_brch1_reg_wr_data         =  r_ip_brch1_reg_wr_data  ;
    assign ip_brch1_reg_rd_en           =  r_ip_brch1_reg_rd_en    ;  
    
    assign ip_brch2_reg_addr            =  r_ip_brch2_reg_addr     ;
    assign ip_brch2_reg_wr_en           =  r_ip_brch2_reg_wr_en    ;
    assign ip_brch2_reg_wr_data         =  r_ip_brch2_reg_wr_data  ;
    assign ip_brch2_reg_rd_en           =  r_ip_brch2_reg_rd_en    ;    
    
generate
     case  ( BRANCH_SEL) 
       1 : begin : U1
                 assign  branch_addr    = BRANCH_ADDR1 ;
              end 
       2 : begin : U2
                 assign  branch_addr    = BRANCH_ADDR2 ;
              end 
       3 : begin : U3
                 assign  branch_addr    = BRANCH_ADDR3 ;
              end 
       4 : begin : U4
                 assign  branch_addr    = BRANCH_ADDR4 ;
              end 
       5 : begin : U5
                 assign  branch_addr    = BRANCH_ADDR5 ;
              end 
       6 : begin : U6
                 assign  branch_addr    = BRANCH_ADDR6 ;
              end     
       7 : begin : U7
                 assign  branch_addr    = BRANCH_ADDR7 ;
              end       
       default : begin : U8
                  assign  branch_addr    = BRANCH_ADDR1 ;
              end            
     endcase
endgenerate
    

    always @(posedge sbus_clk )    begin
              r_reg_addr   <= reg_addr ;
              r_reg_wr_en  <= reg_wr_en;
              r_reg_rd_en  <= reg_rd_en;
              r_reg_wr_data<= reg_wr_data;
    end
    
     always @(posedge sbus_clk or posedge sbus_rst)    begin
           if(sbus_rst) begin 
               r_ip_brch1_reg_addr      <= {REG_ADDR_WIDTH{1'b0}};
               r_ip_brch1_reg_wr_en     <= 1'b0;
               r_ip_brch1_reg_rd_en     <= 1'b0;
               r_ip_brch1_reg_wr_data   <= {REG_DATA_WIDTH{1'b0}};
               //r_ip_brch1_reg_wr_valid  <= 1'b0;                  
           end else begin          
                if(r_reg_wr_en | r_reg_rd_en) begin
                    if((r_reg_addr<branch_addr)&&(r_reg_addr > 32'h10))begin
                        r_ip_brch1_reg_addr      <= r_reg_addr  ;
                        r_ip_brch1_reg_wr_en     <= r_reg_wr_en ;
                        r_ip_brch1_reg_rd_en     <= r_reg_rd_en;
                        r_ip_brch1_reg_wr_data   <= r_reg_wr_data ;
                        //r_ip_brch1_reg_wr_valid  <= reg_wr_valid;
                    end else begin 
                        r_ip_brch1_reg_addr      <= {REG_ADDR_WIDTH{1'b0}};
                        r_ip_brch1_reg_wr_en     <= 1'b0;
                        r_ip_brch1_reg_rd_en     <= 1'b0;
                        r_ip_brch1_reg_wr_data   <= {REG_DATA_WIDTH{1'b0}};
                        //r_ip_brch1_reg_wr_valid  <= 1'b0;                      
                    end
                end else begin 
                    r_ip_brch1_reg_addr      <= {REG_ADDR_WIDTH{1'b0}};
                    r_ip_brch1_reg_wr_en     <= 1'b0;
                    r_ip_brch1_reg_rd_en     <= 1'b0;
                    r_ip_brch1_reg_wr_data   <= {REG_DATA_WIDTH{1'b0}};
                    //r_ip_brch1_reg_wr_valid  <= 1'b0;                  
                end 
           end

    end   
    
     always @(posedge sbus_clk or posedge sbus_rst)    begin
           if(sbus_rst) begin 
               r_ip_brch2_reg_addr      <= {REG_ADDR_WIDTH{1'b0}};
               r_ip_brch2_reg_wr_en     <= 1'b0;
               r_ip_brch2_reg_rd_en     <= 1'b0;
               r_ip_brch2_reg_wr_data   <= {REG_DATA_WIDTH{1'b0}};
               //r_ip_brch2_reg_wr_valid  <= 1'b0;                  
           end else begin          
                if(r_reg_wr_en | r_reg_rd_en) begin
                    if((r_reg_addr >= branch_addr)||(r_reg_addr <= 32'h10))begin
                        r_ip_brch2_reg_addr      <= r_reg_addr  ;
                        r_ip_brch2_reg_wr_en     <= r_reg_wr_en ;
                        r_ip_brch2_reg_rd_en     <= r_reg_rd_en;
                        r_ip_brch2_reg_wr_data   <= r_reg_wr_data ;
                        //r_ip_brch2_reg_wr_valid  <= reg_wr_valid;
                    end else begin 
                        r_ip_brch2_reg_addr      <= {REG_ADDR_WIDTH{1'b0}};
                        r_ip_brch2_reg_wr_en     <= 1'b0;
                        r_ip_brch2_reg_rd_en     <= 1'b0;
                        r_ip_brch2_reg_wr_data   <= {REG_DATA_WIDTH{1'b0}};
                        //r_ip_brch2_reg_wr_valid  <= 1'b0;                      
                    end
                end else begin 
                    r_ip_brch2_reg_addr      <= {REG_ADDR_WIDTH{1'b0}};
                    r_ip_brch2_reg_wr_en     <= 1'b0;
                    r_ip_brch2_reg_rd_en     <= 1'b0;
                    r_ip_brch2_reg_wr_data   <= {REG_DATA_WIDTH{1'b0}};
                    //r_ip_brch2_reg_wr_valid  <= 1'b0;                  
                end 
           end

    end            
    
   
     always @(posedge sbus_clk )    begin
                r_reg_rd_data            <=       r_ip_brch1_reg_rd_data | r_ip_brch2_reg_rd_data;
                r_reg_rd_valid           <=       r_ip_brch1_reg_rd_valid| r_ip_brch2_reg_rd_valid;    
                r_reg_wr_valid           <=       r_ip_brch1_reg_wr_valid| r_ip_brch2_reg_wr_valid;                 
    end     

     always @(posedge sbus_clk or posedge sbus_rst)    begin
           if(sbus_rst) begin    
                r_ip_brch1_reg_rd_data   <=       {REG_DATA_WIDTH{1'b0}};
                r_ip_brch1_reg_rd_valid  <=       1'b0                  ;
                r_ip_brch1_reg_wr_valid  <=       1'b0                  ;                
           end else begin           
                r_ip_brch1_reg_rd_valid  <=       rr_ip_brch1_reg_rd_valid[BARNCH1_DEL-1];
                r_ip_brch1_reg_wr_valid  <=       rr_ip_brch1_reg_wr_valid[BARNCH1_DEL-1];  
                if(rr_ip_brch1_reg_rd_valid[BARNCH1_DEL-1])
                r_ip_brch1_reg_rd_data   <=       rr_ip_brch1_reg_rd_data[(BARNCH1_DEL-1)*REG_DATA_WIDTH +:REG_DATA_WIDTH];
                else                 
                r_ip_brch1_reg_rd_data   <=       {REG_DATA_WIDTH{1'b0}};            
           end
    end  

     always @(posedge sbus_clk or posedge sbus_rst)    begin
           if(sbus_rst) begin 
                r_ip_brch2_reg_rd_data   <=       {REG_DATA_WIDTH{1'b0}};
                r_ip_brch2_reg_rd_valid  <=       1'b0                  ;
                r_ip_brch2_reg_wr_valid  <=       1'b0                  ;                    
           end else begin           
                r_ip_brch2_reg_rd_valid  <=       rr_ip_brch2_reg_rd_valid[BARNCH2_DEL-1]; 
                r_ip_brch2_reg_wr_valid  <=       rr_ip_brch2_reg_wr_valid[BARNCH2_DEL-1]; 
                 if(rr_ip_brch2_reg_rd_valid[BARNCH2_DEL-1]) 
                r_ip_brch2_reg_rd_data   <=       rr_ip_brch2_reg_rd_data[(BARNCH2_DEL-1)*REG_DATA_WIDTH +:REG_DATA_WIDTH]  ;
                else                 
                r_ip_brch2_reg_rd_data   <=       {REG_DATA_WIDTH{1'b0}};                
           end
    end  



     always @(posedge sbus_clk )    begin
               rr_ip_brch1_reg_wr_valid       <= {rr_ip_brch1_reg_wr_valid,ip_brch1_reg_wr_valid  };      
               rr_ip_brch1_reg_rd_data        <= {rr_ip_brch1_reg_rd_data ,ip_brch1_reg_rd_data   };
               rr_ip_brch1_reg_rd_valid       <= {rr_ip_brch1_reg_rd_valid,ip_brch1_reg_rd_valid  };  
               rr_ip_brch2_reg_wr_valid       <= {rr_ip_brch2_reg_wr_valid,ip_brch2_reg_wr_valid  };      
               rr_ip_brch2_reg_rd_data        <= {rr_ip_brch2_reg_rd_data ,ip_brch2_reg_rd_data   };
               rr_ip_brch2_reg_rd_valid       <= {rr_ip_brch2_reg_rd_valid,ip_brch2_reg_rd_valid  };              
    end
endmodule
