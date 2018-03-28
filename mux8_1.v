module mux8_1(sel, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, out);

	input [2:0] sel;
	input [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
	output [31:0] out;
	
	wire [31:0] w1, w2;
	
	mux4_1 m1 (sel[1:0], reg0, reg1, reg2, reg3, w1);
	mux4_1 m2 (sel[1:0], reg4, reg5, reg6, reg7, w2);
	mux2_1 m3 (sel[2], w1, w2, out);

endmodule