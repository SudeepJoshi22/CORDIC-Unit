////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 25/08/2023
// Description: Test-Bench for CORDIC UNIT MODULE.
// N - data size, I - number of iterations(maximum 28)
////////////////////////////////////////////////////////////////////////////////

module test_cordic_unit;

reg clk;
reg trig_rot;
reg signed [31:0] angle;
reg signed [31:0] Xi;
reg signed [31:0] Yi;
wire signed [31:0] sin;
wire signed [31:0] cos;
wire signed [31:0] Xr;
wire signed [31:0] Yr;

CORDIC_UNIT #(32, 10) dut (
    .clk(clk),
    .trig_rot(trig_rot),
    .angle(angle),
    .Xi(Xi),
    .Yi(Yi),
    .sin(sin),
    .cos(cos),
    .Xr(Xr),
    .Yr(Yr)
);

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, dut);
    $monitor("Time = %0t: angle = %b, Xi = %b, Yi = %b, sin = %b, cos = %b, Xr = %b, Yr = %b", $time, angle, Xi, Yi, sin, cos, Xr, Yr);
    
    clk = 0;
    trig_rot = 0;
    trig_rot = 1;
    angle = 32'b001_00001100000101010010001110000;
    Xi = 32'b001_00000000000000000000000000000;
    Yi = 32'b000_00000000000000000000000000000;
    
    #200;
    $finish;
end

always #5 clk = ~clk;

endmodule

