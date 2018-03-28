module sll_2(in, out);

	input [31:0] in;
	output [31:0] out;
	
	assign out[1:0] = 2'b00;
	assign out[31:2] = in[29:0];

endmodule