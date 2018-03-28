module stallControl(
							//inputs
							rd_d, rs_d, rt_d, rd_dx, rs_dx, rt_dx, MD_resultRDY_x, MD_inProg_x,
							isSw_d, isLw_dx, isMul_dx, isDiv_dx,
							reset,
							//outputs
							stall
							);

	input reset, MD_resultRDY_x, MD_inProg_x;
	input [4:0] rd_d, rs_d, rt_d, rd_dx, rs_dx, rt_dx;
	input isSw_d, isLw_dx, isMul_dx, isDiv_dx;
	
	output stall;
	
	//load stall
	wire load_stall, alu_needs_load, alu_needs_load_rs, alu_needs_load_rt;
	isEqual_5(rd_dx, rs_d, alu_needs_load_rs);
	isEqual_5(rd_dx, rt_d, alu_needs_load_rt);
	assign alu_needs_load = alu_needs_load_rs || alu_needs_load_rt;
	assign load_stall = (isLw_dx && alu_needs_load && ~isSw_d);
	
	//multdiv stall
	wire multdiv_stall;
	assign multdiv_stall = (MD_inProg_x || isMul_dx || isDiv_dx) && ~MD_resultRDY_x;
	
	assign stall = load_stall || multdiv_stall;
	
endmodule