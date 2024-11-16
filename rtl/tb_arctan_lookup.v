////////////////////////////////////////////////////////////////////////////////
// Author: Sudeep Joshi
// Date: 24/08/2023
// Description: Test bench for Arctan Look-Up table for CORDIC Unit ( Q3.29 representation is chosen)
////////////////////////////////////////////////////////////////////////////////

module test_arctan_lookup;

reg [4:0] j;
wire [31:0] arctan;

arctan_lookup #(32) dut (
    .j(j),
    .arctan(arctan)
);

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, dut);

    for (j = 0; j <= 28; j = j + 1) begin
        #5;
        $display("j = %d, arctan = %b", j, arctan);
    end
    $finish;
end

endmodule

