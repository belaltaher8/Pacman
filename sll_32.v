module sll_32(in, shiftAmt, out);

	input [31:0] in;
	input [4:0] shiftAmt;
	output [31:0] out;
	
	wire [31:0] out_16, out_8, out_4, out_2, out_1, in_8, in_4, in_2, in_1;
	
	sll_16 sll16(in, out_16);
	mux2_1 mux_16(shiftAmt[4], in, out_16, in_8);
	
	sll_8 sll8(in_8, out_8);
	mux2_1 mux_8(shiftAmt[3], in_8, out_8, in_4);
	
	sll_4 sll4(in_4, out_4);
	mux2_1 mux_4(shiftAmt[2], in_4, out_4, in_2);
	
	sll_2 sll2(in_2, out_2);
	mux2_1 mux_2(shiftAmt[1], in_2, out_2, in_1);
	
	sll_1 sll1(in_1, out_1);
	mux2_1 mux_1(shiftAmt[0], in_1, out_1, out);


endmodule