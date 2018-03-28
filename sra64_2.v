module sra64_2(in, out);

	input [63:0] in;
	output [63:0] out;
	
	assign out[61:0] = in[63:2];
	assign out[63:62] = 2'b00;

endmodule