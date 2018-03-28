module decoder5_32(ctrl, ena, out);

	input [4:0] ctrl;
	input ena;
	output [31:0] out;
	
	wire w0, w1;
	
	and and0(w0, ~ctrl[4], ena);
	and and1(w1, ctrl[4], ena);
	
	decoder4_16 d0(ctrl[3:0], w0, out[15:0]);
	decoder4_16 d1(ctrl[3:0], w1, out[31:16]);

	

endmodule