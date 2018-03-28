module decoder4_16(ctrl, ena, out);

	input [3:0] ctrl;
	input ena;
	output [15:0] out;
	
	wire w0, w1;
	
	and and0(w0, ~ctrl[3], ena);
	and and1(w1, ctrl[3], ena);
	
	decoder3_8 d0(ctrl[2:0], w0, out[7:0]);
	decoder3_8 d1(ctrl[2:0], w1, out[15:8]);

	

endmodule