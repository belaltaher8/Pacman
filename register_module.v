module register_module(d, clk, ena_in, ena_out, sclr, out);

	input [31:0] d;
	input clk, ena_in, ena_out, sclr;
	output [31:0] out;
	
	wire [31:0] q;
	
	genvar c;
	generate
		for (c = 0; c <= 31; c = c + 1) begin: DFF_generate
			dff_module DFF(d[c], clk, ena_in, sclr, q[c]);
			tri_state tri_states(q[c], ena_out, out[c]);
		end
	endgenerate


endmodule