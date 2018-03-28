//this code was grabbed from the ECE 350 Lecture Set 3a

module tri_state(in, oe, out);

	input in, oe;
	output out;
	
	assign out = oe ? in : 1'bz;


endmodule