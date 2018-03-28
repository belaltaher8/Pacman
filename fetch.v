module fetch (
				  //inputs
				  clock, q_imem, iaddr_PC, reset,
				  //outputs
				  address_imem, next_iaddr_f, q_imem_f
				  );
	input clock, reset;
	input [31:0] q_imem;
	input [11:0] iaddr_PC;
	output [11:0] address_imem, next_iaddr_f;
	output [31:0] q_imem_f;
	
	
	assign q_imem_f = reset ? 32'd0 : q_imem;
	assign address_imem = reset ? 32'd0 : iaddr_PC;
	alu ALU(iaddr_PC, 32'd1, 5'b00000, 5'd0, next_iaddr_f);
	

endmodule