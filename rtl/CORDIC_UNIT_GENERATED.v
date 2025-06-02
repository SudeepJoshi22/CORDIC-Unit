////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Description: CORDIC UNIT MODULE.
// N - data size, I - number of iterations(maximum 28)
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module CORDIC_UNIT 
#(
parameter N = 32,
parameter I = 20)
(
	input	wire						clk,
	input	wire						rst_n,
	input	wire						start,		// Signal to indicate the start of CORDIC interation
	input 	wire	signed 	[N-1:0] 	Xi,
	input 	wire	signed 	[N-1:0] 	Yi,
	input 	wire	signed 	[N-1:0] 	Zi,
	input	wire						rot_vec,	// rot_vec = 0: Rotation mode, rot_vec = 1: Vectoring mode 
	output 	wire	signed 	[N-1:0] 	Xr,
	output 	wire	signed 	[N-1:0] 	Yr,
	output	wire	signed 	[N-1:0]		Zr,
	output	wire						done
);

/*** PYTHON WILL AUTOGENERATE HERE ***/
	reg [N-1:0] lookup_table[0:I];

	// Initialize the Lookup Table
	always @(posedge clk) begin
		if(~rst_n) begin
			lookup_table[0] <= 32'h3243F6A9;
			lookup_table[1] <= 32'h1DAC6705;
			lookup_table[2] <= 32'h0FADBAFD;
			lookup_table[3] <= 32'h07F56EA7;
			lookup_table[4] <= 32'h03FEAB77;
			lookup_table[5] <= 32'h01FFD55C;
			lookup_table[6] <= 32'h00FFFAAB;
			lookup_table[7] <= 32'h007FFF55;
			lookup_table[8] <= 32'h003FFFEB;
			lookup_table[9] <= 32'h001FFFFD;
			lookup_table[10] <= 32'h00100000;
			lookup_table[11] <= 32'h00080000;
			lookup_table[12] <= 32'h00040000;
			lookup_table[13] <= 32'h00020000;
			lookup_table[14] <= 32'h00010000;
			lookup_table[15] <= 32'h00008000;
			lookup_table[16] <= 32'h00004000;
			lookup_table[17] <= 32'h00002000;
			lookup_table[18] <= 32'h00001000;
			lookup_table[19] <= 32'h00000800;

		end
	end
/*** PYTHON AUTO-GEN ENDS HERE ***/

	/* Internal Wires */
		
	/* Internal Regs */
    reg signed 	[N-1:0] 	X [0:I-1];
    reg signed 	[N-1:0] 	Y [0:I-1];
    reg signed 	[N-1:0] 	Z [0:I-1];

    // Delay line for 'start' to generate 'done'
    reg start_d [0:I-1];

    genvar j;
	
    // Stage-0: capture inputs
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            X[0]     <= 0;
            Y[0]     <= 0;
            Z[0]     <= 0;
            start_d[0] <= 1'b0;
        end else begin
            X[0]     <= Xi;
            Y[0]     <= Yi;
            Z[0]     <= Zi;
            start_d[0] <= start;
        end
    end

    // CORDIC pipeline stages
    generate
        for (j = 0; j < I-1; j = j + 1) begin : cordic_stages
            
			// one-stage shift-add rotation/vectoring
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    X[j+1]     <= 0;
                    Y[j+1]     <= 0;
                    Z[j+1]     <= 0;
                    start_d[j+1] <= 1'b0;
                end 
				else begin
                    // propagate start
                    start_d[j+1] <= start_d[j];

                    // choose direction: in rotation mode, based on Z; in vectoring, based on X, Y signs
                    if (rot_vec) begin
                        // vectoring mode: rotate to drive X,Y to zero: direction = sign(X)*sign(Y)
                        if (Y[j] >= 0) begin
                            X[j+1] <= X[j] + (Y[j] >>> j);
                            Y[j+1] <= Y[j] - (X[j] >>> j);
                            Z[j+1] <= Z[j] + lookup_table[j];
                        end else begin
                            X[j+1] <= X[j] - (Y[j] >>> j);
                            Y[j+1] <= Y[j] + (X[j] >>> j);
                            Z[j+1] <= Z[j] - lookup_table[j];
                        end
                    end else begin
                        // rotation mode: rotate by +angle if Z<0, else -angle
                        if (Z[j] >= 0) begin
                            X[j+1] <= X[j] - (Y[j] >>> j);
                            Y[j+1] <= Y[j] + (X[j] >>> j);
                            Z[j+1] <= Z[j] - lookup_table[j];
                        end else begin
                            X[j+1] <= X[j] + (Y[j] >>> j);
                            Y[j+1] <= Y[j] - (X[j] >>> j);
                            Z[j+1] <= Z[j] + lookup_table[j];
                        end
                    end
                end
            end
        end
    endgenerate

	assign	done	=	start_d[I-1];

	assign	Xr		=	done ? X[I-1]	: 'dZ;
	assign	Yr		=	done ? Y[I-1]	: 'dZ;
	assign	Zr		=	done ? Z[I-1]	: 'dZ;

endmodule
