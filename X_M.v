module X_M(
			  //inputs
			  clock, exec_out_x, rd_out1_x, clr, ena,
			  rd_x, target_x, exception_x, 
			  isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
			  isJal, isJr, isBex, isSetx,
			  //outputs
			  exec_out_xm, rd_out1_xm,
			  rd_xm, target_xm, exception_xm,
			  isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
			  isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out,
	);
	
	input clock, clr, ena, exception_x;
	input [31:0] exec_out_x, rd_out1_x;
	input [4:0] rd_x;
	input [26:0] target_x;
	input isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		   isJal, isJr, isBex, isSetx;
	
	output [31:0] exec_out_xm, rd_out1_xm;
	output exception_xm;
	output [4:0] rd_xm;
	output [26:0] target_xm;
	output isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
			 isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out;
	
	dflipflop dffs_exc (exception_x, clock, clr, ena, exception_xm);
	
	dflipflop dffs_exec [31:0] (exec_out_x, clock, clr, ena, exec_out_xm);
	dflipflop dffs_red [31:0] (rd_out1_x, clock, clr, ena, rd_out1_xm);
	
	dflipflop dffs_rd [4:0] (rd_x, clock, clr, ena, rd_xm);
	dflipflop dffs_target [26:0] (target_x, clock, clr, ena, target_xm);
	
	dflipflop dffs_is [17:0] (
		{isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		 isJal, isJr, isBex, isSetx}, 
		 clock, clr, ena, 
		{isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
		 isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out});
	
	
endmodule