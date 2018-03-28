module mux32_1 (sel, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
					reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, 
					reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23,
					reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31, out);
					
	input [4:0] sel;
	input [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
					reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15,
					reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23,
					reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31;
	output [31:0] out;
	
	wire [31:0] w1, w2;
	
	mux16_1 m1 (sel[3:0], reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, w1);
	mux16_1 m2 (sel[3:0], reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31, w2);
	mux2_1 m3 (sel[4], w1, w2, out);

endmodule