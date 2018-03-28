module multdiv_cycles(
							 //inputs
							 clock, rd_out0_dx, rd_out1_dx, reset, isMul, isDiv, rd_dx,
							 //outputs
							 MD_result, MD_exception, MD_resultRDY, is_mult, is_div, ctrl_writeReg_mdc,
							 //test
							 in0_stored, in1_stored
							 );
							 
	input clock, reset, isMul, isDiv;
	input [31:0] rd_out0_dx, rd_out1_dx;
	input [4:0] rd_dx;
	
	output MD_exception, MD_resultRDY;
	output [31:0] MD_result;
	output is_mult, is_div;
	output [4:0] ctrl_writeReg_mdc;
	
	wire ena_store;
	or or_ena(ena_store, isMul, isDiv);
	output [31:0] in0_stored, in1_stored;
	
	dflipflop current_mul(isMul, clock, (MD_resultRDY || reset), ena_store, is_mult);
	dflipflop current_div(isDiv, clock, (MD_resultRDY || reset), ena_store, is_div);
	
	dflipflop writeReg [4:0] (rd_dx, clock, (MD_resultRDY || reset), ena_store, ctrl_writeReg_mdc);
	
	dflipflop MD_in0 [31:0] (rd_out0_dx, clock, (MD_resultRDY || reset), ena_store, in0_stored);
	dflipflop MD_in1 [31:0] (rd_out1_dx, clock, (MD_resultRDY || reset), ena_store, in1_stored);
	multdiv MD(in0_stored, in1_stored, isMul, isDiv, clock, reset, MD_result, MD_exception, MD_resultRDY);


endmodule