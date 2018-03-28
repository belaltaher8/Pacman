module and_16(a, b, out);

	input [15:0] a, b;
	output [15:0] out;
	
	and ands [15:0](out, a, b);


endmodule