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
input clk,
input trig_rot,
input signed [N-1:0] angle,
input signed [N-1:0] Xi,
input signed [N-1:0] Yi,
output signed [N-1:0] sin,
output signed [N-1:0] cos,
output signed [N-1:0] Xr,
output signed [N-1:0] Yr
);
reg [4:0] j;
wire [N-1:0] arctan;

reg signed [N-1:0] X [0:I-1];
reg signed [N-1:0] Y [0:I-1];
reg signed [N-1:0] Z [0:I-1];

arctan_lookup #(N) ARCTAN_TABLE(
.j(j),
.arctan(arctan)
);

initial
	j = 0;
	
always @(posedge clk)
begin
	X[0] <= Xi;
	Y[0] <= Yi;
	Z[0] <= angle;
end


genvar i;

generate
for(i = 0;i < I;i = i+1)
begin
	wire sign;
	wire [N-1:0] X_sft,Y_sft,X_in,Y_in,Z_in,X_out,Y_out,Z_out;
	always @(posedge clk)
	begin
		j <= j+1;
		X[j+1] <= X_out;
		Y[j+1] <= Y_out;
		Z[j+1] <= Z_out;
	end
	
	shift #(N) sftX(X[j],j,X_sft);
	shift #(N) sftY(Y[j],j,Y_sft);
	
	assign sign = Z[j][31];
	assign X_in = X[j];
	assign Y_in = Y[j];
	assign Z_in = Z[j];
	
	add_sub #(N) add_sub_X(X_in,Y_sft,~sign,X_out);
	add_sub #(N) add_sub_Y(Y_in,X_sft,sign,Y_out);
	add_sub #(N) add_sub_Z(Z_in,arctan,~sign,Z_out);

end
endgenerate

assign Xr = X[I-1];
assign Yr = Y[I-1];

endmodule
