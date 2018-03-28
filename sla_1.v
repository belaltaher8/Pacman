module sla_1(in, ena, out);

	input [31:0] in;
	input [1:0] ena;
	output [31:0] out;
	
	wire [31:0] shifted;
	
	mux4_1 mux(ena, 32'd0, in, shifted, 32'dz, out);
	
	assign shifted[31:1] = in[30:0];
	assign shifted[0] = 1'b0;

endmodule