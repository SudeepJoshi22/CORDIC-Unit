////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 24/08/2023
// Description: Addition and Substraction module for CORDIC unit.
////////////////////////////////////////////////////////////////////////////////

module add_sub #(parameter N = 32) 
(
input clk,
input signed [N-1:0] X,
input signed [N-1:0] Y,
input a_s, //1 for subtraction, 0 for addition
output reg signed [N-1:0] result
);

always @(posedge clk)
begin
	if(a_s)
		result <= X - Y;
	else
		result <= X + Y;
	//result <= (a_s) ? (X - Y) : (X + Y);
end

endmodule
