module mux2_1(sel, reg0, reg1, out);

	input sel;
	input [31:0] reg0, reg1;
	output [31:0] out;
		
	assign out = sel ? reg1 : reg0;

endmodule