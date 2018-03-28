module decoder3_8(ctrl, ena, out);

	input [2:0] ctrl;
	input ena;
	output [7:0] out;
	
	wire w0, w1;
	
	and and0(w0, ~ctrl[2], ena);
	and and1(w1, ctrl[2], ena);
	
	decoder2_4 d0 (ctrl[1:0], w0, out[3:0]);
	decoder2_4 d1 (ctrl[1:0], w1, out[7:4]);
	


endmodule