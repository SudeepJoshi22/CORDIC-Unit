////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 25/08/2023
// Description: CORDIC UNIT MODULE.
// N - data size, I - number of iterations(maximum 28)
// trig_rot: '0' - compute sine and cosine of the angle, '1' - rotate the vector (Xi,Yi) by the input angle
// Q3.29 fixed-point representation is used. Range: -4 to 3.999999998137355
////////////////////////////////////////////////////////////////////////////////

module CORDIC_UNIT 
#(
parameter N = 32,
parameter I = 10)
(
input trig_rot, // '1' - find sine and cosine of the angle, '0' - rotate (Xi,Yi) by the angle provided
input signed [N-1:0] angle,
input signed [N-1:0] Xi,
input signed [N-1:0] Yi,
output signed [N-1:0] sin,
output signed [N-1:0] cos,
output signed [N-1:0] Xr,
output signed [N-1:0] Yr
);

wire signed [N-1:0] X [0:I-1];
wire signed [N-1:0] Y [0:I-1];
wire signed [N-1:0] Z [0:I-1];

wire [N-1:0] lookup_table[0:31];

assign lookup_table[0]  = 32'b0000_1100100100001111110110101010;
assign lookup_table[1]  = 32'b0000_0111011010110001100111000001;
assign lookup_table[2]  = 32'b0000_0011111010110110111010111111;
assign lookup_table[3]  = 32'b0000_0001111111010101101110101001;
assign lookup_table[4]  = 32'b0000_0000111111111010101011011101;
assign lookup_table[5]  = 32'b0000_0000011111111111010101010110;
assign lookup_table[6]  = 32'b0000_0000001111111111111010101010;
assign lookup_table[7]  = 32'b0000_0000000111111111111111010101;
assign lookup_table[8]  = 32'b0000_0000000011111111111111111010;
assign lookup_table[9]  = 32'b0000_0000000001111111111111111111;
assign lookup_table[10] = 32'b0000_0000000000111111111111111111;
assign lookup_table[11] = 32'b0000_0000000000011111111111111111;
assign lookup_table[12] = 32'b0000_0000000000001111111111111111;
assign lookup_table[13] = 32'b0000_0000000000000111111111111111;
assign lookup_table[14] = 32'b0000_0000000000000011111111111111;
assign lookup_table[15] = 32'b0000_0000000000000001111111111111;
assign lookup_table[16] = 32'b0000_0000000000000000111111111111;
assign lookup_table[17] = 32'b0000_0000000000000000011111111111;
assign lookup_table[18] = 32'b0000_0000000000000000001111111111;
assign lookup_table[19] = 32'b0000_0000000000000000000111111111;
assign lookup_table[20] = 32'b0000_0000000000000000000011111111;
assign lookup_table[21] = 32'b0000_0000000000000000000001111111;
assign lookup_table[22] = 32'b0000_0000000000000000000000111111;
assign lookup_table[23] = 32'b0000_0000000000000000000000011111;
assign lookup_table[24] = 32'b0000_0000000000000000000000001111;
assign lookup_table[25] = 32'b0000_0000000000000000000000000111;
assign lookup_table[26] = 32'b0000_0000000000000000000000000011;
assign lookup_table[27] = 32'b0000_0000000000000000000000000001;	

assign X[0] = trig_rot? 32'b0001_0000000000000000000000000000 : Xi;
assign Y[0] = trig_rot? 32'b0000_0000000000000000000000000000 : Yi;
assign Z[0] = angle;


genvar i;

generate
for(i = 0;i < I-1;i = i+1)
begin
	wire sign;
	wire [N-1:0] X_sft,Y_sft;

	assign sign = Z[i][N-1];	
	assign X_sft = X[i] >>> i;
	assign Y_sft = Y[i] >>> i;
	
	add_sub #(N) add_sub_X(X[i],Y_sft,~sign,X[i+1]);
	add_sub #(N) add_sub_Y(Y[i],X_sft,sign,Y[i+1]);
	add_sub #(N) add_sub_Z(Z[i],lookup_table[i],~sign,Z[i+1]);
	
	
end
endgenerate

assign Xr = (trig_rot)? 32'dz : ( X[I-1][N-1] ? -((~X[I-1] + 1)*(0.6071)) : (X[I-1]*0.6072) );
assign Yr = (trig_rot)? 32'dz : ( Y[I-1][N-1] ? -((~Y[I-1] + 1)*(0.6072)) : (Y[I-1]*0.6072) );
assign sin = (trig_rot)? ( Y[I-1][N-1] ? -((~Y[I-1] + 1)*(0.6072)) : (Y[I-1]*0.6072) ) : 32'dz;
assign cos = (trig_rot)? ( X[I-1][N-1] ? -((~X[I-1] + 1)*(0.6071)) : (X[I-1]*0.6072) ) : 32'dz;

endmodule
