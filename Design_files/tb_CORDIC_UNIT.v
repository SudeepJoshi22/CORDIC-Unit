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
    $monitor("Time = %0t: trig_rot = %b, angle = %b, Xi = %b, Yi = %b, sin = %b, cos = %b, Xr = %b, Yr = %b", $time,trig_rot, angle, Xi, Yi, sin, cos, Xr, Yr);
    
    clk = 0;
    trig_rot = 1;
    angle = 32'b001_00001100000101010010001110000; // pi/3(60 degrees)
    
    #200
    trig_rot = 0; 
    angle = 32'b000_10000110000001000001100010010; // pi/6(30 degrees)
    Xi = 32'b000_10110101000001001110011000011;
    Yi = 32'b000_10110101000001001110011000011;
    #185
    $finish;
end

always #5 clk = ~clk;

endmodule

