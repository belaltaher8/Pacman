module bypassControl(
							//inputs
							ctrl_writeEnable, ctrl_writeReg, rd_dx, rs_dx, rt_dx, rd_xm, rs_xm, rt_xm, rd_mw, rs_mw, rt_mw,
							isAdd_dx, isAddi_dx, isSub_dx, isAnd_dx, isOr_dx, isSll_dx, isSra_dx, isMul_dx, isDiv_dx, isSw_dx, isLw_dx,
							isJ_dx, isBne_dx, isBlt_dx, isJal_dx, isJr_dx, isBex_dx, isSetx_dx,
							isAdd_xm, isAddi_xm, isSub_xm, isAnd_xm, isOr_xm, isSll_xm, isSra_xm, isMul_xm, isDiv_xm, isSw_xm, isLw_xm,
							isJ_xm, isBne_xm, isBlt_xm, isJal_xm, isJr_xm, isBex_xm, isSetx_xm, exception_xm,
							reset,
							//outputs
							write2mem_b, write2alu0_b, write2alu1_b, exec_out_xm2alu0_b, exec_out_xm2alu1_b 
							);

	input ctrl_writeEnable, exception_xm, reset;
	input [4:0] ctrl_writeReg, rd_dx, rs_dx, rt_dx, rd_xm, rs_xm, rt_xm, rd_mw, rs_mw, rt_mw;
	input isAdd_dx, isAddi_dx, isSub_dx, isAnd_dx, isOr_dx, isSll_dx, isSra_dx, isMul_dx, isDiv_dx, isSw_dx, isLw_dx,
			isJ_dx, isBne_dx, isBlt_dx, isJal_dx, isJr_dx, isBex_dx, isSetx_dx;
	input isAdd_xm, isAddi_xm, isSub_xm, isAnd_xm, isOr_xm, isSll_xm, isSra_xm, isMul_xm, isDiv_xm, isSw_xm, isLw_xm,
			isJ_xm, isBne_xm, isBlt_xm, isJal_xm, isJr_xm, isBex_xm, isSetx_xm;
	
	output write2mem_b, write2alu0_b, write2alu1_b, exec_out_xm2alu0_b, exec_out_xm2alu1_b;
	
	wire writeReg_is_zero;
	isEqual_5(ctrl_writeReg, 5'd0, writeReg_is_zero);
	
	//WM bypass
	wire writeReg_is_rd;
	isEqual_5(ctrl_writeReg, rd_xm, writeReg_is_rd);
	assign write2mem_b = (ctrl_writeEnable && writeReg_is_rd && isSw_xm && ~writeReg_is_zero);
	
	//WX bypass
	
	wire alu_R, alu_B, alu_BEX, alu_SW;
	assign alu_R = (isAdd_dx || isAddi_dx || isSub_dx || isAnd_dx || isOr_dx || isSll_dx || 
						 isSra_dx || isMul_dx || isDiv_dx || isSw_dx || isLw_dx);
	assign alu_B = (isBne_dx || isBlt_dx);
	assign alu_BEX = (isBex_dx);
	assign alu_SW = (isSw_dx);
	
	//write to alu0
	wire writeReg_is_alu0_R, writeReg_is_alu0_B, writeReg_is_alu0_BEX, write2alu0_R, write2alu0_B, write2alu0_BEX;
	
	isEqual_5(ctrl_writeReg, rs_dx, writeReg_is_alu0_R);
	assign write2alu0_R = (ctrl_writeEnable && writeReg_is_alu0_R && alu_R && ~writeReg_is_zero);
	isEqual_5(ctrl_writeReg, rd_dx, writeReg_is_alu0_B);
	assign write2alu0_B = (ctrl_writeEnable && writeReg_is_alu0_B && alu_B && ~writeReg_is_zero);
	isEqual_5(ctrl_writeReg, 5'b11110, writeReg_is_alu0_BEX);
	assign write2alu0_BEX = (ctrl_writeEnable && writeReg_is_alu0_BEX && alu_BEX && ~writeReg_is_zero);
	
	assign write2alu0_b = (write2alu0_R || write2alu0_B || write2alu0_BEX);
	
	//write to alu1
	wire writeReg_is_alu1_R, writeReg_is_alu1_SW, writeReg_is_alu1_B, write2alu1_R, write2alu1_SW, write2alu1_B;
	
	isEqual_5(ctrl_writeReg, rt_dx, writeReg_is_alu1_R);
	assign write2alu1_R = (ctrl_writeEnable && writeReg_is_alu1_R && alu_R && ~writeReg_is_zero);
	isEqual_5(ctrl_writeReg, rd_dx, writeReg_is_alu1_SW);
	assign write2alu1_SW = (ctrl_writeEnable && writeReg_is_alu1_SW && alu_SW && ~writeReg_is_zero);
	isEqual_5(ctrl_writeReg, rs_dx, writeReg_is_alu1_B);
	assign write2alu1_B = (ctrl_writeEnable && writeReg_is_alu1_B && alu_B && ~writeReg_is_zero);
	
	assign write2alu1_b = (write2alu1_R || write2alu1_SW || write2alu1_B);
	
	//determine which register execute_out is going to be written to in the memory stage and do same as above
	wire predicted_writeEnable;
	wire [4:0] predicted_reg;
	tri_state5(rd_xm, ((isAdd_xm || isSu_xmb || isAddi_xm || isMul_xm || isDiv_xm) && ~exception_xm), predicted_reg);
	tri_state5(5'b11110, ((isAdd_xm || isSub_xm || isAddi_xm || isMul_xm || isDiv_xm) && exception_xm), predicted_reg); //ovf
	tri_state5(rd_xm, (isAnd_xm || isOr_xm || isSll_xm || isSra_xm || isLw_xm), predicted_reg);
	tri_state5(5'b11111, (isJal_xm), predicted_reg);
	tri_state5(5'b11110, (isSetx_xm), predicted_reg);
	
	assign predicted_writeEnable = reset ? 1'b0 : (isAdd_xm || isSub_xm || isAnd_xm || isOr_xm || isSll_xm || 
																  isSra_xm || isAddi_xm || isMul_xm || isDiv_xm || isLw_xm || 
																  isJal_xm || isSetx_xm);
	wire predictedReg_is_zero;
	isEqual_5(predicted_reg, 5'd0, predictedReg_is_zero);
	
	//exec_out_xm to alu0
	wire exec_out_xm_is_alu0;
	wire exec_out_xm_is_alu0_R, exec_out_xm_is_alu0_B, exec_out_xm_is_alu0_BEX, exec_out_xm2alu0_R, 
		  exec_out_xm2alu0_B, exec_out_xm2alu0_BEX;
	
	isEqual_5(predicted_reg, rs_dx, exec_out_xm_is_alu0_R);
	assign exec_out_xm2alu0_R = (predicted_writeEnable && exec_out_xm_is_alu0_R && alu_R && ~predictedReg_is_zero);
	isEqual_5(predicted_reg, rd_dx, exec_out_xm_is_alu0_B);
	assign exec_out_xm2alu0_B = (predicted_writeEnable && exec_out_xm_is_alu0_B && alu_B && ~predictedReg_is_zero);
	isEqual_5(predicted_reg, 5'b11110, exec_out_xm_is_alu0_BEX);
	assign exec_out_xm2alu0_BEX = (predicted_writeEnable && exec_out_xm_is_alu0_BEX && alu_BEX && ~predictedReg_is_zero);
	
	assign exec_out_xm2alu0_b = (exec_out_xm2alu0_R || exec_out_xm2alu0_B || exec_out_xm2alu0_BEX);
	
	//exec_out_xm to alu1
	wire exec_out_xm_is_alu1;
	wire exec_out_xm_is_alu1_R, exec_out_xm_is_alu1_SW, exec_out_xm_is_alu1_B, exec_out_xm2alu1_R, 
		  exec_out_xm2alu1_SW, exec_out_xm2alu1_B;
	
	isEqual_5(predicted_reg, rt_dx, exec_out_xm_is_alu1_R);
	assign exec_out_xm2alu1_R = (predicted_writeEnable && exec_out_xm_is_alu1_R && alu_R && ~predictedReg_is_zero);
	isEqual_5(predicted_reg, rd_dx, exec_out_xm_is_alu1_SW);
	assign exec_out_xm2alu1_SW = (predicted_writeEnable && exec_out_xm_is_alu1_SW && alu_SW && ~predictedReg_is_zero);
	isEqual_5(predicted_reg, rs_dx, exec_out_xm_is_alu1_B);
	assign exec_out_xm2alu1_B = (predicted_writeEnable && exec_out_xm_is_alu1_B && alu_B && ~predictedReg_is_zero);
	
	assign exec_out_xm2alu1_b = (exec_out_xm2alu1_R || exec_out_xm2alu1_SW || exec_out_xm2alu1_B);
	
	

endmodule