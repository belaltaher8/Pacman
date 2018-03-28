module decode(
				  //inputs
				  clock, q_imem_fd, next_iaddr_fd, data_readRegA, data_readRegB, reset,
				  //outputs
				  next_iaddr_d, ctrl_readRegA, ctrl_readRegB, rd_out0_d, rd_out1_d,
				  opcode_d, rd_d, rs_d, rt_d, shamt_d, alu_op_d, target_d, imm_d,
				  isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
				  isJal, isJr, isBex, isSetx, NOP
	);
	
	input clock, reset;
	input [31:0] q_imem_fd;
	input [11:0] next_iaddr_fd;
	input [31:0] data_readRegA, data_readRegB;
	
	output [31:0] rd_out0_d, rd_out1_d;
	output [11:0] next_iaddr_d;
	output [4:0] ctrl_readRegA, ctrl_readRegB;
	
	output [4:0] opcode_d, rd_d, rs_d, rt_d, shamt_d, alu_op_d;
	output [26:0] target_d;
	output [31:0] imm_d;
	output NOP;
	
	output isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		  isJal, isJr, isBex, isSetx;	
	
	assign next_iaddr_d = next_iaddr_fd;
	assign NOP = ~(|q_imem_fd);
	
	//if bne or blt, regA=rd and regB=rs
	//if bex, regA=$31
	//if sw, regB=rd
	
	assign ctrl_readRegA = isBex ? 5'b11110 : ((isBne || isBlt) ? rd_d : rs_d);
	assign ctrl_readRegB = isSw ? rd_d : ((isBne || isBlt) ? rs_d : rt_d);
	
	assign rd_out0_d = data_readRegA;
	assign rd_out1_d = data_readRegB;
	
	instr_decoder ID(
						  //inputs
						  .instruction(q_imem_fd), 
						  //outputs
						  .isAdd(isAdd), 
						  .isAddi(isAddi), 
						  .isSub(isSub), 
						  .isAnd(isAnd), 
						  .isOr(isOr), 
						  .isSll(isSll), 
						  .isSra(isSra), 
						  .isMul(isMul), 
						  .isDiv(isDiv), 
						  .isSw(isSw), 
						  .isLw(isLw), 
						  .isJ(isJ), 
						  .isBne(isBne), 
						  .isBlt(isBlt),
						  .isJal(isJal), 
						  .isJr(isJr), 
						  .isBex(isBex), 
						  .isSetx(isSetx),
						  .opcode(opcode_d), 
						  .rd(rd_d), 
						  .rs(rs_d), 
						  .rt(rt_d), 
						  .shamt(shamt_d), 
						  .alu_op(alu_op_d), 
						  .target(target_d), 
						  .imm(imm_d)
						  );
	
endmodule