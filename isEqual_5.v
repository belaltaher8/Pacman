module isEqual_5(in0, in1, equal);
	input [4:0] in0, in1;
	output equal;
	
	wire [4:0] result;
	
	xor xor0(result[0], in0[0], in1[0]);
	xor xor1(result[1], in0[1], in1[1]);
	xor xor2(result[2], in0[2], in1[2]);
	xor xor3(result[3], in0[3], in1[3]);
	xor xor4(result[4], in0[4], in1[4]);
	
	assign equal = ~(|result);
	
endmodule