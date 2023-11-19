module test;

wire [31:0] y;
reg [31:0] a,b;
 
assign y = a*b;

initial
begin
	$monitor("a = %h, b = %h, y = %h",a,b,y);
	a = 32'b00010110110100011011011100010111;
	b = 32'b00001001101101110001011101011001;
end


endmodule
