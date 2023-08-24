////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 24/08/2023
// Description: Test Bench for Addition and Substraction module. In the CORDIC unit (Q3.29 fixed-point representation is chosen)
////////////////////////////////////////////////////////////////////////////////

module tb_add_sub;

// Parameters
localparam N = 32;

// Signals
reg signed [N-1:0] X;
reg signed [N-1:0] Y;
reg a_s;
wire signed [N-1:0] result;

//Instantiation
add_sub #(N) dut (
.X(X),
.Y(Y),
.a_s(a_s),
.result(result)
);



initial begin
        $dumpfile("tb_add_sub.vcd");
        $dumpvars(0, tb_add_sub);
       	$monitor("Result: %b +/- %b = %b (add/sub = %b)", X, Y, result,a_s); 
       
        X = 32'b111_10101111100111011011001000110; //-0.314 in Q3.29
        Y = 32'b000_11101000111101011100001010001; //0.91 in Q3.29
        a_s = 0; 
        #10;
        a_s = 1; 
        #10;
        
        $finish;
    end

endmodule
