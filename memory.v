module memory(
				  //inputs
				  clock, q_dmem, exec_out_xm, rd_out1_xm, reset, 
				  rd_xm, target_xm, exception_xm,
				  isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
			     isJal, isJr, isBex, isSetx,
				  //outputs
				  address_dmem, data, wren, exec_out_m, mem_out_m,
				  rd_m, target_m, exception_m,
				  isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
			     isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out
	);
	
	input clock, reset, exception_xm;
	input [31:0] q_dmem, exec_out_xm, rd_out1_xm;
	input [4:0] rd_xm;
	input [26:0] target_xm;
	input isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		   isJal, isJr, isBex, isSetx;
			
	output [31:0] exec_out_m, mem_out_m, data;
	output [16:0] address_dmem;
   output wren, exception_m;
	output [4:0] rd_m;
	output [26:0] target_m;
	output isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
			 isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out;
	
	assign address_dmem = exec_out_xm[16:0];
	assign data = rd_out1_xm;
	assign exec_out_m = exec_out_xm;
	assign mem_out_m = q_dmem;
	assign exception_m = exception_xm;
	
	assign rd_m = rd_xm;
	assign target_m = target_xm;
	
	assign isAdd_out = isAdd;
	assign isAddi_out = isAddi;
	assign isSub_out = isSub;
	assign isAnd_out = isAnd;
	assign isOr_out = isOr;
	assign isSll_out = isSll;
	assign isSra_out = isSra;
	assign isMul_out = isMul;
	assign isDiv_out  = isDiv;
	assign isSw_out = isSw;
	assign isLw_out = isLw;
	assign isJ_out = isJ;
	assign isBne_out = isBne;
	assign isBlt_out = isBlt;
	assign isJal_out = isJal;
	assign isJr_out = isJr;
	assign isBex_out = isBex;
	assign isSetx_out = isSetx;
	
	assign wren = reset ? 1'b0 : isSw;
	
	
endmodule