////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 25/08/2023
// Description: Test-Bench for CORDIC UNIT MODULE.
// N - data size, I - number of iterations(maximum 28)
////////////////////////////////////////////////////////////////////////////////

module test_cordic_unit;

reg trig_rot;
reg signed [31:0] angle;
reg signed [31:0] Xi;
reg signed [31:0] Yi;
wire signed [31:0] sin;
wire signed [31:0] cos;
wire signed [31:0] Xr;
wire signed [31:0] Yr;

CORDIC_UNIT #(32, 28) dut (
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
    
    trig_rot = 1;
    angle = 32'b0001_0000110000010101001000111000; // pi/3(60 degrees)
    
    #10
    trig_rot = 0; 
    Xi = 32'b0000_1011010100000100111100110011; // 1/sqrt(2)
    Yi = 32'b0000_1011010100000100111100110011; // 1/sqrt(2)
    #10
    angle = 32'b0000_1000011000001010100001001011; // pi/6
    Xi = 32'b0000_0000000000000000000000000000;
    Yi = 32'b0001_0000000000000000000000000000;
    #10
    angle = 32'b0011_0010010000111111011010101000;
    $finish;
end

endmodule

