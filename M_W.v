module M_W(
			  //inputs
			  clock, exec_out_m, mem_out_m, clr, ena,
			  rd_m, target_m, exception_m,
			  isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
			  isJal, isJr, isBex, isSetx,
			  //outputs
			  exec_out_mw, mem_out_mw,
			  rd_mw, target_mw, exception_mw,
			  isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
			  isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out
	);
	
	input clock, clr, ena, exception_m;
	input [31:0] exec_out_m, mem_out_m;
	input [4:0] rd_m;
	input [26:0] target_m;
	input isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		   isJal, isJr, isBex, isSetx;
	output exception_mw;
	output [31:0] exec_out_mw, mem_out_mw;
	output [4:0] rd_mw;
	output [26:0] target_mw;
	output isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
			 isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out;
	
	dflipflop dffs_exc (exception_m, clock, clr, ena, exception_mw);
	
	dflipflop dffs_exec [31:0] (exec_out_m, clock, clr, ena, exec_out_mw);
	dflipflop dffs_mem [31:0] (mem_out_m, clock, clr, ena, mem_out_mw);
	
	dflipflop dffs_rd [4:0] (rd_m, clock, clr, ena, rd_mw);
	dflipflop dffs_target [26:0] (target_m, clock, clr, ena, target_mw);
	
	dflipflop dffs_is [17:0] (
		{isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		 isJal, isJr, isBex, isSetx}, 
		 clock, clr, ena, 
		{isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
		 isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out});
	
	
endmodule