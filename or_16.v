module or_16(a, b, out);

	input [15:0] a, b;
	output [15:0] out;
	
	or ors [15:0](out, a, b);


endmodule