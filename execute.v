module execute(
					//inputs
					clock, next_iaddr_dx, rd_out0_dx, rd_out1_dx, reset,
					opcode_dx, rd_dx, rs_dx, rt_dx, shamt_dx, alu_op_dx, target_dx, imm_dx,
					isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
					isJal, isJr, isBex, isSetx, NOP_dx,
					//outputs
					next_iaddr_adj, exec_out_x, rd_out1_x, exception_out_x, jump_x,
					rd_x, target_x, exception, MD_resultRDY, MD_inProg,
					isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
					isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out,
					//test
					//ovf_R, ovf_I, MD_exception, in0_stored, in1_stored, MD_result
	);
	
	//test
	/*output ena_store, isMul, isDiv, is_mult, is_div;*/
	//output [31:0] in0_stored, in1_stored;
	
	input clock, reset, NOP_dx;
	input [11:0] next_iaddr_dx;
	input [31:0] rd_out0_dx, rd_out1_dx;
	input [4:0] opcode_dx, rd_dx, rs_dx, rt_dx, shamt_dx, alu_op_dx;
	input [26:0] target_dx;
	input [31:0] imm_dx;
	input isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
		   isJal, isJr, isBex, isSetx;	
	
	output [31:0] exec_out_x, rd_out1_x, exception_out_x;
	output [11:0] next_iaddr_adj;
	output jump_x, exception, MD_resultRDY, MD_inProg;
	output [4:0] rd_x;
	output [26:0] target_x;
	output isAdd_out, isAddi_out, isSub_out, isAnd_out, isOr_out, isSll_out, isSra_out, isMul_out, isDiv_out, 
			 isSw_out, isLw_out, isJ_out, isBne_out, isBlt_out, isJal_out, isJr_out, isBex_out, isSetx_out;
	
	assign rd_out1_x = rd_out1_dx;
	assign MD_inProg = is_mult || is_div;
	
	assign rd_x = (isMul_out || isDiv_out) ? ctrl_writeReg_mdc : rd_dx;
	assign target_x = target_dx;
	
	assign isAdd_out = isAdd;
	assign isAddi_out = isAddi;
	assign isSub_out = isSub;
	assign isAnd_out = isAnd;
	assign isOr_out = isOr;
	assign isSll_out = isSll;
	assign isSra_out = isSra;
	assign isMul_out = (MD_resultRDY && is_mult); //only set mult when result done
	assign isDiv_out  = (MD_resultRDY && is_div);//only set div when result done
	assign isSw_out = isSw;
	assign isLw_out = isLw;
	assign isJ_out = isJ;
	assign isBne_out = isBne;
	assign isBlt_out = isBlt;
	assign isJal_out = isJal;
	assign isJr_out = isJr;
	assign isBex_out = isBex;
	assign isSetx_out = isSetx;
						  
	wire ne_R, lt_R;
	wire ovf_R;
	wire [31:0] ALU_R_out; 
	
	wire ne_I, lt_I;
	wire ovf_I;
	wire [31:0] ALU_I_out; 
	
	wire MD_exception;
	wire [31:0] MD_result; 
	wire [4:0] ctrl_writeReg_mdc;
	
	wire ne_B, lt_B, ovf_B, ne_PC, lt_PC, ovf_PC, PC_exc;
	wire [31:0] B_val;
	wire [31:0] PC_added;
	
	wire [11:0] jPC_out;
	
	wire [11:0] jrPC_out;
	
	wire [11:0] bexPC_out;
	
	//add,sub,and,or,sra,sll
	alu ALU_R(rd_out0_dx, rd_out1_dx, alu_op_dx, shamt_dx, ALU_R_out, ne_R, lt_R, ovf_R);
	
	//addi,sw,lw
	alu ALU_I(rd_out0_dx, imm_dx, 5'b00000, 5'd0, ALU_I_out, ne_I, lt_I, ovf_I);
	
	//mul,div (all following instructions should be 32'do until resultRDY)
	multdiv_cycles mdc(clock, rd_out0_dx, rd_out1_dx, reset, isMul, isDiv, rd_dx, 
							 MD_result, MD_exception, MD_resultRDY, is_mult, is_div, ctrl_writeReg_mdc, in0_stored, in1_stored);
	
	
	//bne,blt (reg0=rd and reg1=rs)
	alu ALU_B(rd_out0_dx, rd_out1_dx, 5'b00001, 5'd0, B_val, ne_B, lt_B, ovf_B);
	alu ALU_PC_add({20'd0, next_iaddr_dx}, imm_dx, 5'b00000, 5'd0, PC_added, ne_PC, lt_PC, ovf_PC);
	assign PC_exc = (|PC_added[31:12] || ovf_PC); //if upper 20 of result has 1, then this addr dne in imem
	
	//j,jal 
	assign jPC_out = target_dx[11:0];
	
	//jr (if upper 20 of rd0 has 1, then addre dne in imem)
	assign jrPC_out = rd_out0_dx[11:0];
	
	//bex (if upper 15 of target has 1, then addr dne in imem)
	assign bexPC_out = target_dx[11:0];
	
	wire [31:0] jal_writeback;
	wire [31:0] setx_writeback;
	
	//jal 
	assign jal_writeback = {20'd0, next_iaddr_dx};
	
	//setx
	assign setx_writeback = {5'd0, target_dx};
	
	//execute-out logic (add, addi, sub, and, or, sll, sra, mul, div, sw, lw, jal, setx)
	tri_state32 tri_0(ALU_R_out, ((isAnd || isOr || isSll || isSra) && ~MD_inProg), exec_out_x);
	tri_state32 tri_1(ALU_R_out, (isAdd && ~MD_inProg && ~ovf_R), exec_out_x);
	tri_state32 tri_5(ALU_R_out, (isSub && ~MD_inProg && ~ovf_R), exec_out_x);
	
	tri_state32 tri_16(ALU_I_out, (isSw || isLw), exec_out_x);
	tri_state32 tri_4(ALU_I_out, (isAddi && ~ovf_I), exec_out_x);
	
	tri_state32 tri_7(MD_result, (MD_inProg && ~MD_exception), exec_out_x);
	
	tri_state32 tri_10(jal_writeback, (isJal), exec_out_x);
	tri_state32 tri_11(setx_writeback, (isSetx), exec_out_x);
	
	//PC-out logic (j, jal, jr, ?bne, ?blt, ?bex)
	tri_state12 tri_12(jPC_out, (isJ || isJal), next_iaddr_adj);
	tri_state12 tri_13(jrPC_out, (isJr), next_iaddr_adj);
	tri_state12 tri_14(PC_added[11:0], ((isBne && ne_B) || (isBlt && lt_B)), next_iaddr_adj); 
	tri_state12 tri_15(bexPC_out, (isBex && |rd_out0_dx), next_iaddr_adj);
	assign jump_x = reset ? 1'b0 : (isJ || isJal || isJr || (isBne && ne_B) || (isBlt && lt_B) || (isBex && |rd_out0_dx));
	
	//ovf out
	tri_state32 tri_2(32'd1, (isAdd && ovf_R), exception_out_x); //add ovf
	tri_state32 tri_6(32'd2, (isAddi && ovf_I), exception_out_x); //addi ovf
	tri_state32 tri_3(32'd3, (isSub && ovf_R), exception_out_x); //sub ovf
	tri_state32 tri_8(32'd4, (MD_resultRDY && is_mult && MD_exception), exception_out_x); //mult ovf
	tri_state32 tri_9(32'd5, (MD_resultRDY && is_div && MD_exception), exception_out_x); //div ovf
	
	assign exception = (~NOP_dx && ((isAdd && ovf_R) || (isSub && ovf_R) || (isAddi && ovf_I) ||
							 (MD_resultRDY && isMul_out && MD_exception) || (MD_resultRDY && isDiv_out && MD_exception)));
	
endmodule