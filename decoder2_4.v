module decoder2_4 (ctrl, ena, out);

	input [1:0] ctrl;
	input ena;
	output [3:0] out;
	
	and and0(out[0], ~ctrl[1], ~ctrl[0], ena);
	and and1(out[1], ~ctrl[1], ctrl[0], ena);
	and and2(out[2], ctrl[1], ~ctrl[0], ena);
	and and3(out[3], ctrl[1], ctrl[0], ena);


endmodule