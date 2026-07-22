
`ifndef SYNTHESIS
`ifdef DIFFTEST
`include "DifftestMacros.svh"
`endif // DIFFTEST
`endif // SYNTHESIS
module SquashControl(
  input clock,
  input reset,
  output enable
);

`ifndef SYNTHESIS
`ifndef CONFIG_DIFFTEST_FPGA
`define SQUASH_CTRL
`endif // CONFIG_DIFFTEST_FPGA
`endif // SYNTHESIS

`ifndef SQUASH_CTRL
  assign enable = 1;
`else
`ifdef DIFFTEST
import "DPI-C" context function void set_squash_scope();
  reg _enable;
  assign enable = _enable;
initial begin
  _enable = 1;
  set_squash_scope();
end

// For the C/C++ interface
export "DPI-C" function set_squash_enable;
function void set_squash_enable(int en);
  _enable = en;
endfunction

// For the simulation argument +squash_cycles=N
reg [63:0] squash_cycles;
initial begin
  if ($test$plusargs("squash-cycles")) begin
    $value$plusargs("squash-cycles=%d", squash_cycles);
    $display("set squash cycles: %d", squash_cycles);
  end
end

reg [63:0] n_cycles;
always @(posedge clock) begin
  if (reset) begin
    n_cycles <= 64'h0;
  end
  else begin
    n_cycles <= n_cycles + 64'h1;
    if (squash_cycles > 0 && n_cycles >= squash_cycles) begin
      _enable = 0;
    end
  end
end
`endif // DIFFTEST
`endif // SQUASH_CTRL

endmodule

