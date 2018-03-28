module isEqual_32(in0, in1, equal);
	input [31:0] in0, in1;
	output equal;
	
	wire [31:0] result;
	
	xor xors [31:0] (result[31:0], in0[31:0], in1[31:0]);
	
	assign equal = ~(|result);
	
endmodule