////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 24/08/2023
// Description: Test Bench for Addition and Substraction module. In the CORDIC unit Q8.24 fixed-point representation is chosen
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
       
        X = 32'b11110110_001000000000000000000000; //-10.125 in Q7.25
        Y = 32'b00010100_000111001010110000010000; //20.112 in Q7.25
        a_s = 0; 
        #10;
        a_s = 1; 
        #10;
        
        $finish;
    end

endmodule
