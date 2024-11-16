////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 25/08/2023
// Description: CORDIC UNIT MODULE.
// N - data size, I - number of iterations(maximum 28)
// trig_rot: '0' - compute sine and cosine of the angle, '1' - rotate the vector (Xi,Yi) by the input angle
// Q4.28 fixed-point representation is used. Range: -8 to 7.99999999627471
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

parameter signed pi2 = 32'b0001_1001001000011111101101010100; // pi/2
parameter signed npi2 = 32'b1110_0110110111100000010010101100; // -pi/2
parameter signed pi = 32'b0011_0010010000111111011010101000; // pi 
parameter signed npi = 32'b1100_1101101111000000100101011000; // -pi
parameter signed p3pi2 = 32'b0100_1011011001011111000111111100; // 3pi/2
parameter signed n3pi2 = 32'b1011_0100100110100000111000000100; // -3pi/2
parameter signed p2pi = 32'b0110_0100100001111110110101010001; // 2pi
//parameter signed n2pi = 32'b10011011011110000001001010101111; // -2pi


wire signed [N-1:0] X [0:I-1];
wire signed [N-1:0] Y [0:I-1];
wire signed [N-1:0] Z [0:I-1];

wire signed [N-1:0] X_cor, Y_cor;

reg signed [N-1:0] X0,Y0,Z0;

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

always @(*)
begin
	if( ((angle >= pi2) && (angle < pi)) || ((angle <= npi2) && (angle > npi)) )
		begin
			//$display("condition1");
			if(trig_rot) begin //calculate trig functions
				if(angle[N-1]) begin // if angle is negative
					X0 = 32'b0000_0000000000000000000000000000;
					Y0 = 32'b1111_0000000000000000000000000000;
					Z0 = angle + pi2;
				end
				else begin // if angle is positive
					X0 = 32'b0000_0000000000000000000000000000;
					Y0 = 32'b0001_0000000000000000000000000000;
					Z0 = angle - pi2;
				end
			end
			else begin // calculate rotation
				if(angle[N-1]) begin // if angle is negative
					X0 = Yi;
					Y0 = -Xi;
					Z0 = angle + pi2;
				end
				else begin // if angle is positive
					X0 = -Yi;
					Y0 = Xi;
					Z0 = angle - pi2;
				end			
			end
		end
	else if( ((angle >= pi) && (angle < p3pi2)) || ((angle <= npi) && (angle > n3pi2)) )
		begin
		//$display("condition2");
			if(trig_rot) begin //calculate trig functions
				if(angle[N-1]) begin // if angle is negative
					X0 = 32'b1111_0000000000000000000000000000;
					Y0 = 32'b0000_0000000000000000000000000000;
					Z0 = angle + pi;
				end
				else begin // if angle is positive
					X0 = 32'b1111_0000000000000000000000000000;
					Y0 = 32'b0000_0000000000000000000000000000;
					Z0 = angle - pi;
				end
			end
			else begin // calculate rotation
				if(angle[N-1]) begin // if angle is negative
					X0 = -Xi;
					Y0 = -Yi;
					Z0 = angle + pi;
				end
				else begin // if angle is positive
					X0 = -Xi;
					Y0 = -Yi;
					Z0 = angle - pi;
				end			
			end
		end
	else if( (angle >= p3pi2) || (angle <= n3pi2) )
		begin
		//$display("condition3");
			if(trig_rot) begin //calculate trig functions
				if(angle[N-1]) begin // if angle is negative
					X0 = 32'b0000_0000000000000000000000000000;
					Y0 = 32'b0001_0000000000000000000000000000;
					Z0 = angle + p3pi2;
				end
				else begin // if angle is positive
					X0 = 32'b0000_0000000000000000000000000000;
					Y0 = 32'b1111_0000000000000000000000000000;
					Z0 = angle - p3pi2;
				end
			end
			else begin // calculate rotation
				if(angle[N-1]) begin // if angle is negative
					X0 = Xi;
					Y0 = Yi;
					Z0 = angle + p2pi;
				end
				else begin // if angle is positive
					X0 = Xi;
					Y0 = Yi;
					Z0 = angle - p2pi;
				end			
			end
		end
	else
		begin
		//$display("condition4");
			if(trig_rot) begin //calculate trig functions
				if(angle[N-1]) begin // if angle is negative
					X0 = 32'b0001_0000000000000000000000000000;
					Y0 = 32'b0000_0000000000000000000000000000;
					Z0 = angle;
				end
				else begin // if angle is positive
					X0 = 32'b0001_0000000000000000000000000000;
					Y0 = 32'b0000_0000000000000000000000000000;
					Z0 = angle;
				end
			end
			else begin // calculate rotation
				if(angle[N-1]) begin // if angle is negative
					X0 = Xi;
					Y0 = Yi;
					Z0 = angle;
				end
				else begin // if angle is positive
					X0 = Xi;
					Y0 = Yi;
					Z0 = angle;
				end			
			end		
		end

end


assign X[0] = X0;
assign Y[0] = Y0;
assign Z[0] = Z0;


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

correction #(N) correction_X(X[I-1], X_cor);
correction #(N) correction_Y(Y[I-1], Y_cor);

/*
assign Xr = (trig_rot)? 32'dz : ( X[I-1][N-1] ? -((~X[I-1] + 1)*(0.6072)) : (X[I-1]*0.6072) );
assign Yr = (trig_rot)? 32'dz : ( Y[I-1][N-1] ? -((~Y[I-1] + 1)*(0.6072)) : (Y[I-1]*0.6072) );
assign sin = (trig_rot)? ( Y[I-1][N-1] ? -((~Y[I-1] + 1)*(0.6072)) : (Y[I-1]*0.6072) ) : 32'dz;
assign cos = (trig_rot)? ( X[I-1][N-1] ? -((~X[I-1] + 1)*(0.6072)) : (X[I-1]*0.6072) ) : 32'dz;
*/

assign Xr = (trig_rot)? 32'dz : X_cor;
assign Yr = (trig_rot)? 32'dz : Y_cor;
assign sin = (trig_rot)? Y_cor : 32'dz;
assign cos = (trig_rot)? X_cor : 32'dz;

endmodule
