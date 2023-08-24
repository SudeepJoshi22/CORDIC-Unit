////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 24/08/2023
// Description: (Right) Shifting module for CORDIC unit.
////////////////////////////////////////////////////////////////////////////////

module shift #(parameter N = 32)
(
input signed [N-1:0] A,
input [4:0] amt, //shift amount (maximum of 2^5 = 32 shifts can be done)
output signed [N-1:0] Y
);

assign Y = A >> amt;

endmodule
