//this code was grabbed from the ECE 350 Lecture Set 3a

module tri_state32(in, oe, out);

	input [31:0] in;
	input oe;
	output [31:0] out;
	
	assign out = oe ? in : 32'dz;


endmodule