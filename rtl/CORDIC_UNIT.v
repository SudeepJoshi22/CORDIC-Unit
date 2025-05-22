////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Description: CORDIC UNIT MODULE.
// N - data size, I - number of iterations(maximum 28)
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module CORDIC_UNIT 
#(
	parameter N = 32,
	parameter I = 10)
(
	input	wire				clk,
	input	wire				rst_n,
	input	wire				start,
	input 	wire	signed 	[N-1:0] 	Xi,
	input 	wire	signed 	[N-1:0] 	Yi,
	input 	wire	signed 	[N-1:0] 	Zi,
	input	wire				rot_vec,		
	output 	wire	signed 	[N-1:0] 	Xr,
	output 	wire	signed 	[N-1:0] 	Yr,
	output	wire	signed 	[N-1:0]		Zr,
	output	wire				done
);

/** Internal Wires **/


/** Internal Registers **/

	reg signed 	[N-1:0] 	X [0:I-1];
	reg signed 	[N-1:0] 	Y [0:I-1];
	reg signed 	[N-1:0] 	Z [0:I-1];

    // delay line for 'start' to generate 'done'
    reg start_d [0:I];

    integer k;
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
        for (j = 0; j < I; j = j + 1) begin : cordic_stages
            wire signed [N-1:0] angle;
            // lookup arctan(2^-j)
            arctan_lookup #(
                .N   (N),
                .I   (I)
            ) lut (
                .clk    (clk),
                .rst_n  (rst_n),
                .j      (j[$clog2(I)-1:0]),
                .arctan (angle)
            );

            // one-stage shift-add rotation/vectoring
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    X[j+1]     <= 0;
                    Y[j+1]     <= 0;
                    Z[j+1]     <= 0;
                    start_d[j+1] <= 1'b0;
                end else begin
                    // propagate start
                    start_d[j+1] <= start_d[j];

                    // choose direction: in rotation mode, based on Z; in vectoring, based on X, Y signs
                    if (rot_vec) begin
                        // vectoring mode: rotate to drive X,Y to zero: direction = sign(X)*sign(Y)
                        if (Y[j] >= 0) begin
                            X[j+1] <= X[j] + (Y[j] >>> j);
                            Y[j+1] <= Y[j] - (X[j] >>> j);
                            Z[j+1] <= Z[j] + angle;
                        end else begin
                            X[j+1] <= X[j] - (Y[j] >>> j);
                            Y[j+1] <= Y[j] + (X[j] >>> j);
                            Z[j+1] <= Z[j] - angle;
                        end
                    end else begin
                        // rotation mode: rotate by +angle if Z<0, else -angle
                        if (Z[j] >= 0) begin
                            X[j+1] <= X[j] - (Y[j] >>> j);
                            Y[j+1] <= Y[j] + (X[j] >>> j);
                            Z[j+1] <= Z[j] - angle;
                        end else begin
                            X[j+1] <= X[j] + (Y[j] >>> j);
                            Y[j+1] <= Y[j] - (X[j] >>> j);
                            Z[j+1] <= Z[j] + angle;
                        end
                    end
                end
            end
        end
    endgenerate

    // Output assignments
    assign Xr = X[I];
    assign Yr = Y[I];
    assign Zr = Z[I];

    // done pulse when the delayed start emerges after I stages
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            done <= 1'b0;
        else
            done <= start_d[I];
    end

endmodule
