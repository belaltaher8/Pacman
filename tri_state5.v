//this code was grabbed from the ECE 350 Lecture Set 3a

module tri_state5(in, oe, out);

	input [4:0] in;
	input oe;
	output [4:0] out;
	
	assign out = oe ? in : 5'dz;


endmodule