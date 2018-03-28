//this code was grabbed from the ECE 350 Lecture Set 3a

module tri_state12(in, oe, out);

	input [11:0] in;
	input oe;
	output [11:0] out;
	
	assign out = oe ? in : 12'dz;


endmodule