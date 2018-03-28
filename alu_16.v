module alu_16(data_operandA, data_operandB, ctrl_ALUopcode, data_result, isNotEqual, isLessThan, overflow);

   input [15:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode;

   output [15:0] data_result;
   output isNotEqual, isLessThan, overflow;
	
	wire cout;
	wire [15:0] w_and, w_or, w_add_sub, w_sum, w_sll, w_sra, G_and, P_or;
	wire LT_in0, LT_in1, LT_in2, ovf_in0, ovf_in1;
	
	mux8_1 opcode_mux(ctrl_ALUopcode[2:0], w_sum, w_sum, w_and, w_or, w_sll, w_sra, 0, 0, data_result);
	
	//add and subtract is 00000 and 00001, so out0 and out1
	mux2_1 add_sub_mux(ctrl_ALUopcode[0], data_operandB, ~data_operandB, w_add_sub);
	sum_16 sum_op(data_operandA, w_add_sub, ctrl_ALUopcode[0],P_or, G_and, w_sum, cout);
	
	//and is 00010, so out2
   //and_32 and_op(data_operandA, data_operandB, w_and);
	
	//or is 00011, so out3
	//or_32 or_op(data_operandA, data_operandB, w_or);
	
	//G calculations need an and of inverted B
   and_16 G_op(data_operandA, w_add_sub, G_and);
	
	//P calculations need an or of inverted B
	or_16 P_op(data_operandA, w_add_sub, P_or);
	
	//sll is 00100, so out4
	//sll_32 sll_op(data_operandA, ctrl_shiftamt, w_sll);
	
	//sra is 00101, so out5
	//sra_32 sra_op(data_operandA, ctrl_shiftamt, w_sra);
	
	//isNotEqual
	or or_notEqual(isNotEqual, data_result[0], data_result[1], data_result[2], data_result[3], 
										data_result[4], data_result[5], data_result[6], data_result[7], 
										data_result[8], data_result[9], data_result[10], data_result[11], 
										data_result[12], data_result[13], data_result[14], data_result[15]);
	
	//isLessThan
	and and_LT0(LT_in0, data_operandA[15], ~data_operandB[15]);
	and and_LT1(LT_in1, ~data_operandA[15], ~data_operandB[15], data_result[15]);
	and and_LT2(LT_in2, data_operandA[15], data_operandB[15], ~data_result[15]);
	or or_LT(isLessThan, LT_in0, LT_in1, LT_in2);
	
	//overflow
	and and_ovfAdd0(ovf_in0, data_operandA[15], w_add_sub[15], ~data_result[15]);
	and and_ovfAdd1(ovf_in1, ~data_operandA[15], ~w_add_sub[15], data_result[15]);
	
	or or_ovf(overflow, ovf_in0, ovf_in1);
	

endmodule
