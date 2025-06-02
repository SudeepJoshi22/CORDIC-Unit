////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 11/09/2023
// Description: Test Bench for CORRECTION UNIT FOR CORDIC UNIT.
// Q4.28 fixed-point representation is used. Range: -8 to 7.99999999627471
////////////////////////////////////////////////////////////////////////////////

module tb_correction;
reg [31:0] X;
wire [31:0] Y;

correction #(32) dut(X,Y);

initial
begin
	$dumpfile("waveform.vcd");
    	$dumpvars(0, dut);
	$monitor("\nX = %h, Y = %h",X,Y);
	
	X = 32'h08000000;
	#10
	X = 32'h12a1ea36;
	#10
	X = 32'hed5e15ca;
end

endmodule
