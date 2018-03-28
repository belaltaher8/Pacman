module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);

   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

   output [31:0] data_result;
   output isNotEqual, isLessThan, overflow;
	
	wire cout;
	wire [31:0] w_and, w_or, w_add_sub, w_sum, w_sll, w_sra, G_and, P_or;
	wire LT_in0, LT_in1, LT_in2, ovf_in0, ovf_in1;
	
	mux8_1 opcode_mux(ctrl_ALUopcode[2:0], w_sum, w_sum, w_and, w_or, w_sll, w_sra, 0, 0, data_result);
	
	//add and subtract is 00000 and 00001, so out0 and out1
	mux2_1 add_sub_mux(ctrl_ALUopcode[0], data_operandB, ~data_operandB, w_add_sub);
	sum_32 sum_op(data_operandA, w_add_sub, ctrl_ALUopcode[0],P_or, G_and, w_sum, cout);
	
	//and is 00010, so out2
   and_32 and_op(data_operandA, data_operandB, w_and);
	
	//or is 00011, so out3
	or_32 or_op(data_operandA, data_operandB, w_or);
	
	//G calculations need an and of inverted B
   and_32 G_op(data_operandA, w_add_sub, G_and);
	
	//P calculations need an or of inverted B
	or_32 P_op(data_operandA, w_add_sub, P_or);
	
	//sll is 00100, so out4
	sll_32 sll_op(data_operandA, ctrl_shiftamt, w_sll);
	
	//sra is 00101, so out5
	sra_32 sra_op(data_operandA, ctrl_shiftamt, w_sra);
	
	//isNotEqual
	or or_notEqual(isNotEqual, data_result[0], data_result[1], data_result[2], data_result[3], 
										data_result[4], data_result[5], data_result[6], data_result[7], 
										data_result[8], data_result[9], data_result[10], data_result[11], 
										data_result[12], data_result[13], data_result[14], data_result[15],
										data_result[16], data_result[17], data_result[18], data_result[19], 
										data_result[20], data_result[21], data_result[22], data_result[23],
										data_result[24], data_result[25], data_result[26], data_result[27], 
										data_result[28], data_result[29], data_result[30], data_result[31]);
	/*wire [31:0] check_xor;
	xor_32 xors(check_xor, data_operandA, data_operandB);
	or or_notEqual(isNotEqual, check_xor[0], check_xor[1], check_xor[2], check_xor[3], 
										check_xor[4], check_xor[5], check_xor[6], check_xor[7], 
										check_xor[8], check_xor[9], check_xor[10], check_xor[11], 
										check_xor[12], check_xor[13], check_xor[14], check_xor[15],
										check_xor[16], check_xor[17], check_xor[18], check_xor[19], 
										check_xor[20], check_xor[21], check_xor[22], check_xor[23],
										check_xor[24], check_xor[25], check_xor[26], check_xor[27], 
										check_xor[28], check_xor[29], check_xor[30], check_xor[31]);*/
	
	//isLessThan
	and and_LT0(LT_in0, data_operandA[31], ~data_operandB[31]);
	and and_LT1(LT_in1, ~data_operandA[31], ~data_operandB[31], data_result[31]);
	and and_LT2(LT_in2, data_operandA[31], data_operandB[31], data_result[31]);
	or or_LT(isLessThan, LT_in0, LT_in1, LT_in2);
	
	//overflow
	and and_ovfAdd0(ovf_in0, data_operandA[31], w_add_sub[31], ~data_result[31]);
	and and_ovfAdd1(ovf_in1, ~data_operandA[31], ~w_add_sub[31], data_result[31]);
	
	or or_ovf(overflow, ovf_in0, ovf_in1);
	

endmodule
