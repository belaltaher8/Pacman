module writeback(
					  //inputs
					  exec_out_mw, mem_out_mw, reset,
					  rd_mw, target_mw, exception_mw,
					  isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
					  isJal, isJr, isBex, isSetx,
					  //outputs
					  data_writeReg, ctrl_writeEnable, ctrl_writeReg
	);
	
	input reset, exception_mw;
	input [31:0] exec_out_mw, mem_out_mw;
	input [4:0] rd_mw;
	input [26:0] target_mw;
	input isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		   isJal, isJr, isBex, isSetx;
	
	output [31:0] data_writeReg;
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg;
	
	wire [4:0] jal_reg2write,setx_reg2write;
	
	//alu exception
	assign exc_reg2write = 5'b11110;
	
	//jal 
	assign jal_reg2write = 5'b11111;
	
	//setx 
	assign setx_reg2write = 5'b11110;
	
	//writeback logic (R-type, addi, lw, jal, setx)
	assign ctrl_writeEnable = reset ? 1'b0 : (isAdd || isSub || isAnd || isOr || isSll || isSra || isAddi || 
															isMul || isDiv || isLw || isJal || isSetx);
	
	//write cntrl
	tri_state5(rd_mw, (isAdd || isSub || isAddi || isMul || isDiv), ctrl_writeReg);
	tri_state5(rd_mw, (isAnd || isOr || isSll || isSra || isLw), ctrl_writeReg);
	tri_state5(jal_reg2write, (isJal), ctrl_writeReg);
	tri_state5(setx_reg2write, (isSetx), ctrl_writeReg);
	
	//write data
	tri_state32(exec_out_mw, (isAdd || isSub || isAnd || isOr || isSll || isSra || isAddi || isMul || isDiv || isJal), data_writeReg);
	tri_state32({5'b0, target_mw}, (isSetx), data_writeReg);
	tri_state32(mem_out_mw, (isLw), data_writeReg);
	
endmodule