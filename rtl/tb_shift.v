////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 24/08/2023
// Description: Test bench (Right) Shifting module for CORDIC unit.
////////////////////////////////////////////////////////////////////////////////

module tb_shift;

  parameter N = 32;

  reg signed [N-1:0] A;
  reg [4:0] amt;

  wire signed [N-1:0] Y;

  shift #(N) dut (
    .A(A),
    .amt(amt),
    .Y(Y)
  );

  initial begin
    $monitor("%d A=%b amt=%d Y=%b", $time, A, amt, Y);
    $dumpfile("tb_shift.vcd");
    $dumpvars(0, tb_shift);

    A = 123;
    amt = 2;
    #10;
    
    A = -456;
    amt = 3;
    #10;

    $finish;
  end

endmodule


