module signExtend17_32(in, out);
	input [16:0] in;
	output [31:0] out;
	
	assign out[16:0] = in;
	assign out[31:17] = in[15] ? 15'hFFFF : 15'd0;


endmodule