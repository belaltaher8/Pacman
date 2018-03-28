module D_X(
				//inputs
				clock, next_iaddr_d, rd_out0_d, rd_out1_d, 
				opcode_d, rd_d, rs_d, rt_d, shamt_d, alu_op_d, target_d, imm_d, clr, ena,
				isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
				isJal, isJr, isBex, isSetx, NOP_d,
				//outputs
				next_iaddr_dx, rd_out0_dx, rd_out1_dx, 
				opcode_dx, rd_dx, rs_dx, rt_dx, shamt_dx, alu_op_dx, target_dx, imm_dx,
				isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
				isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out, NOP_dx
	);
	
	input clock, clr, ena, NOP_d;
	input [11:0] next_iaddr_d;
	input [31:0] rd_out0_d, rd_out1_d, imm_d;
	input [4:0] opcode_d, rd_d, rs_d, rt_d, shamt_d, alu_op_d;
	input [26:0] target_d;
	input isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		  isJal, isJr, isBex, isSetx;	
	
	output [11:0] next_iaddr_dx;
	output [31:0] rd_out0_dx, rd_out1_dx, imm_dx;
	output [4:0] opcode_dx, rd_dx, rs_dx, rt_dx, shamt_dx, alu_op_dx;
	output [26:0] target_dx;
	output isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
				isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out;
	output NOP_dx;
	
	dflipflop dffs_iaddr [11:0] (next_iaddr_d, clock, clr, ena, next_iaddr_dx);
	dflipflop dffs_rd0 [31:0] (rd_out0_d, clock, clr, ena, rd_out0_dx);
	dflipflop dffs_rd1 [31:0] (rd_out1_d, clock, clr, ena, rd_out1_dx);
	dflipflop dffs_imm [31:0] (imm_d, clock, clr, ena, imm_dx);
	
	dflipflop dffs_opcode [4:0] (opcode_d, clock, clr, ena, opcode_dx);
	dflipflop dffs_rd [4:0] (rd_d, clock, clr, ena, rd_dx);
	dflipflop dffs_rs [4:0] (rs_d, clock, clr, ena, rs_dx);
	dflipflop dffs_rt [4:0] (rt_d, clock, clr, ena, rt_dx);
	dflipflop dffs_shamt [4:0] (shamt_d, clock, clr, ena, shamt_dx);
	dflipflop dffs_alu_op [4:0] (alu_op_d, clock, clr, ena, alu_op_dx);
	dflipflop dffs_target [26:0] (target_d, clock, clr, ena, target_dx);
	
	dflipflop dff_nop(NOP_d, clock, clr, ena, NOP_dx);
	
	dflipflop dffs_is [17:0] (
		{isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		 isJal, isJr, isBex, isSetx}, 
		 clock, clr, ena, 
		{isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
		 isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out});	
	
	
endmodule