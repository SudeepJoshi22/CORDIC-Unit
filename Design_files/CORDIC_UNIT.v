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
input trig_rot, // '1' - calculate trig functions, '0' - rotate Xi,Yi by the input angle
input signed [N-1:0] angle,
input signed [N-1:0] Xi,
input signed [N-1:0] Yi,
output signed [N-1:0] sin,
output signed [N-1:0] cos,
output signed [N-1:0] Xr,
output signed [N-1:0] Yr
);

wire [N-1:0] arctan;

reg signed [N-1:0] X [0:I-1];
reg signed [N-1:0] Y [0:I-1];
reg signed [N-1:0] Z [0:I-1];

reg [N-1:0] lookup_table[0:31];

initial
begin
	lookup_table[0]  <= 32'b000_11001001000011111101101010100;
	lookup_table[1]  <= 32'b000_01110110101100011001110000010;
	lookup_table[2]  <= 32'b000_00111110101101101110101111110;
	lookup_table[3]  <= 32'b000_00011111110101011011101010011;
	lookup_table[4]  <= 32'b000_00001111111110101010110111011;
	lookup_table[5]  <= 32'b000_00000111111111110101010101101;
	lookup_table[6]  <= 32'b000_00000011111111111110101010101;
	lookup_table[7]  <= 32'b000_00000001111111111111110101010;
	lookup_table[8]  <= 32'b000_00000000111111111111111110101;
	lookup_table[9]  <= 32'b000_00000000011111111111111111110;
	lookup_table[10] <= 32'b000_00000000001111111111111111111;
	lookup_table[11] <= 32'b000_00000000000111111111111111111;
	lookup_table[12] <= 32'b000_00000000000011111111111111111;
	lookup_table[13] <= 32'b000_00000000000000111111111111111;
	lookup_table[14] <= 32'b000_00000000000000011111111111111;
	lookup_table[15] <= 32'b000_00000000000000001111111111111;
	lookup_table[16] <= 32'b000_00000000000000000111111111111;
	lookup_table[17] <= 32'b000_00000000000000000011111111111;
	lookup_table[18] <= 32'b000_00000000000000000001111111111;
	lookup_table[19] <= 32'b000_00000000000000000000111111111;
	lookup_table[20] <= 32'b000_00000000000000000000011111111;
	lookup_table[21] <= 32'b000_00000000000000000000001111111;
	lookup_table[22] <= 32'b000_00000000000000000000000111111;
	lookup_table[23] <= 32'b000_00000000000000000000000011111;
	lookup_table[24] <= 32'b000_00000000000000000000000001111;
	lookup_table[25] <= 32'b000_00000000000000000000000000111;
	lookup_table[26] <= 32'b000_00000000000000000000000000011;
	lookup_table[27] <= 32'b000_00000000000000000000000000001;
	lookup_table[28] <= 32'b000_00000000000000000000000000000;
end

always @(posedge clk)
begin
	if(~trig_rot) //If rotation of the vector is needed
	begin
		X[0] <= Xi;
		Y[0] <= Yi;
		Z[0] <= angle;
	end
	else //If sine and cos of the angle is needed
	begin
		X[0] <= 1;
		Y[0] <= 0;
		Z[0] <= angle;
	end
end

genvar i;
reg [4:0] j;

generate
for(i = 0;i < I-1;i = i+1)
begin
	wire sign;
	wire [N-1:0] X_sft,Y_sft,X_in,Y_in,Z_in,X_out,Y_out,Z_out;

	assign sign = Z[i][N-1];	
	
	always @(X_out,Y_out,Z_out)
		j <= i[4:0];
	
	always @(posedge clk)
	begin
		X[i+1] <= X_out;
		Y[i+1] <= Y_out;
		Z[i+1] <= Z_out;
		//$display("j = %d, i = %d, X_in = %b, Y_in = %b, Z_in = %b, X_sft = %b, Y_sft = %b, X_out = %b, Y_out = %b, Z_out = %b",j,i,X_in,Y_in,Z_in,X_sft,Y_sft,X_out,Y_out,Z_out);
	end
	
	assign X_in = X[i];
	assign Y_in = Y[i];
	assign Z_in = Z[i];
	assign arctan = lookup_table[j];
	
	  
	
	shift #(N) sftX(X[i],j,X_sft);
	shift #(N) sftY(Y[i],j,Y_sft);
	
	add_sub #(N) add_sub_X(clk,X_in,Y_sft,~sign,X_out);
	add_sub #(N) add_sub_Y(clk,Y_in,X_sft,sign,Y_out);
	add_sub #(N) add_sub_Z(clk,Z_in,arctan,~sign,Z_out);

end
endgenerate

assign Xr = (trig_rot)? 32'dz : X[I-1];
assign Yr = (trig_rot)? 32'dz : Y[I-1];
assign sin = (trig_rot)? X[I-1] : 32'dz;
assign cos = (trig_rot)? Y[I-1] : 32'dz;

endmodule
