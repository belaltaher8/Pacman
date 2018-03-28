module sla64_1(in, out);

	input [63:0] in;
	output [63:0] out;
	
	assign out[63:1] = in[62:0];
	assign out[0] = 1'b0;

endmodule