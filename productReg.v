module productReg(upper32, lower32, clk, clr, ena, prod_out, lower2_out);
	//this has to hold 64 bits
	//writeable at upper 32-bits (on clock down)
	//writeable at lower 32-bits (multiplier once, lower32 after that)
	//lower 3-bits outputted to control
	//clock input from control to determine number of times to shift (by 2)
	//upper 32 bits should constantly output bits (to go into shifter then ALU)
	
	input [31:0] upper32, lower32;
	input clk, clr, ena;
	output [63:0] prod_out;
	output [1:0] lower2_out;
	
	wire [63:0] q;
	
	genvar c;
	generate
		for (c=0; c<=31; c=c+1) begin : loop1
			dflipflop dffs0(lower32[c], clk, clr, ena, q[c]);
			dflipflop dffs1(upper32[c], clk, clr, ena, q[c+32]);
		end
	endgenerate
	
	assign prod_out = q[63:0];
	assign lower2_out = q[1:0];


endmodule