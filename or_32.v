module or_32(a, b, out);

	input [31:0] a, b;
	output [31:0] out;
	
	or ors [31:0](out, a, b);


endmodule