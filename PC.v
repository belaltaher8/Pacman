module PC(
			 //inputs
			 clock, iaddr, clr, ena, 
			 //outputs
			 iaddr_PC
	);
	
	input clock, clr, ena;
	input [11:0] iaddr;
	output [11:0] iaddr_PC;
	
	dflipflop dffs [11:0] (iaddr, clock, clr, ena, iaddr_PC);
	
endmodule