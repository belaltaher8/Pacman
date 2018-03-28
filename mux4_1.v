module mux4_1(sel, reg0, reg1, reg2, reg3, out);

	input [1:0] sel;
	input [31:0] reg0, reg1, reg2, reg3;
	output [31:0] out;
		
	wire [31:0] w1, w2;
	
	mux2_1 m1 (sel[0], reg0, reg1, w1);
	mux2_1 m2 (sel[0], reg2, reg3, w2);
	mux2_1 m3 (sel[1], w1, w2, out); 

endmodule