
module DifftestResetSync #(
  parameter INIT = 1'b0,
  parameter STAGES = 3
) (
  input  clk,
  input  async_in,
  output sync_out
);

  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [STAGES-1:0] sreg = {STAGES{INIT[0]}};

  always @(posedge clk) begin
    sreg <= {sreg[STAGES-2:0], async_in};
  end

  assign sync_out = sreg[STAGES-1];

endmodule

