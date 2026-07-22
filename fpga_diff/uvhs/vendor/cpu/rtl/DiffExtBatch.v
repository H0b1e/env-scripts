
`ifndef SYNTHESIS
`ifdef DIFFTEST
`include "DifftestMacros.svh"
`endif // DIFFTEST
`endif // SYNTHESIS
module DiffExtBatch(
  input         clock,
  input         enable,
  input  [511:0] io
);
  wire _dummy_unused = 1'b1;
`ifndef SYNTHESIS
`ifdef DIFFTEST
`ifndef CONFIG_DIFFTEST_FPGA

import "DPI-C" function void v_difftest_Batch (
  input  bit[511:0] io
);


  always @(posedge clock) begin
    if (enable)
      v_difftest_Batch (io);
  end
`endif // CONFIG_DIFFTEST_FPGA
`endif // DIFFTEST
`endif // SYNTHESIS
endmodule

