module F_D(
			  //inputs
			  clock, 
			  q_imem_f, 
			  next_iaddr_f, 
			  clr, 
			  ena,
			  //outputs
			  q_imem_fd, 
			  next_iaddr_fd
	);
	
	input clock, clr, ena;
	input [31:0] q_imem_f;
	input [11:0] next_iaddr_f;
	output [31:0] q_imem_fd;
	output [11:0] next_iaddr_fd;
	
	dflipflop dffs_q [31:0] (q_imem_f, clock, clr, ena, q_imem_fd);
	
	dflipflop dffs_i [11:0] (next_iaddr_f, clock, clr, ena, next_iaddr_fd);
	
	
endmodule