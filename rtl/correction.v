////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 11/09/2023
// Description: CORRECTION UNIT FOR CORDIC UNIT.
// Q4.28 fixed-point representation is used. Range: -8 to 7.99999999627471
////////////////////////////////////////////////////////////////////////////////

module correction
#(
parameter N = 32)
(
input signed [N-1:0] X,
output signed [N-1:0] Y
);
parameter signed K = 32'b00001001101101110100111011011011;
wire [2*N-1:0] M;

assign M = X * K;
assign Y = {{M[2*N-5:2*N-8]},{M[2*N-9:2*N-36]}};

endmodule
