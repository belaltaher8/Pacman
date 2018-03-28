module mux16_1(sel, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
					reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, out);

	input [3:0] sel;
	input [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
					reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15;
	output [31:0] out;
	
	wire [31:0] w1, w2;
	
	mux8_1 m1 (sel[2:0], reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, w1);
	mux8_1 m2 (sel[2:0], reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, w2);
	mux2_1 m3 (sel[3], w1, w2, out);

endmodule