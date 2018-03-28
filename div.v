module div(data_operandA, data_operandB, ctrl_DIV, clock, data_result, data_exception, data_resultRDY, op_done);
			  //div_shift_, adder_out_, lower32_in_, upper32_in_, reg_clr_, reg_ena_, div_out_, lessThan_, iter_,
			  //adder_in_upper, adder_in_lower);
			  
	 input [31:0] data_operandA, data_operandB;
    input ctrl_DIV, clock;

	 //test
	 /*output reg_clr_, reg_ena_, lessThan_;
	 output [31:0] adder_out_, lower32_in_, upper32_in_;
	 output [63:0] div_shift_, div_out_;
	 output [5:0] iter_;
	 output [31:0] adder_in_upper, adder_in_lower;*/
	 
    output [31:0] data_result;
    output data_exception, data_resultRDY;
	 output op_done;
	 
	 wire [5:0] iter;
	 
	 wire [31:0] inv_opB, data_operandB_adj;
	 wire inv0_notEqual, inv0_lessThan, inv0_ovf;
	 wire [31:0] inv_opA, data_operandA_adj;
	 wire inv1_notEqual, inv1_lessThan, inv1_ovf;
	 
	 wire [31:0] result_unadjusted, inv_result;
	 wire inv2_notEqual, inv2_lessThan, inv2_ovf;
	 wire inv3_notEqual, inv3_lessThan, inv3_ovf;
	 
	 wire [31:0] adder_out, lower32_in, upper32_in;
	 wire notEqual, lessThan, ovf;
	 
	 wire [63:0] div_out;
	 
	 wire [63:0] div_shift;
	 
	 wire reg_clr, reg_ena, one_op_neg;
	 
	 wire wrong_signs, opA_is_zero, iter_is_zero, opB_is_zero;
	 
	 //test
	 /*assign div_shift_ = div_shift;
	 assign adder_out_ = adder_out;
	 assign lower32_in_ = lower32_in;
	 assign upper32_in_ = upper32_in;
	 assign reg_clr_ = reg_clr;
	 assign reg_ena_ = reg_ena;
	 assign div_out_ = div_out;
	 assign lessThan_ = lessThan;
	 assign iter_ = iter;*/

	 //invert divider/dividend and see if it's negative
	 alu invert_divider(32'd0, data_operandB, 5'b00001,  5'd0, inv_opB, inv0_notEqual, inv0_lessThan, inv0_ovf);
	 assign data_operandB_adj = data_operandB[31] ? inv_opB : data_operandB;
	 alu invert_dividedend(32'd0, data_operandA, 5'b00001,  5'd0, inv_opA, inv1_notEqual, inv1_lessThan, inv1_ovf);
	 assign data_operandA_adj = data_operandA[31] ? inv_opA : data_operandA;
	 
	 //ALU subtracts shift output from divisor
	 assign adder_in_upper = div_shift[63:32]; //test
	 assign adder_in_lower = data_operandB_adj; //test
	 alu adder(div_shift[63:32], data_operandB_adj, 5'b00001, 5'd0, adder_out, notEqual, lessThan, ovf);
	 
	 //ALU into RQB register upper32, writes only happen when rem>=divisor
	 assign iter_is_zero = ~(iter[5] || iter[4] || iter[3] || iter[2] || iter[1] || iter[0]);
	 assign lower32_in[31:0] = (ctrl_DIV || iter_is_zero) ? data_operandA_adj[31:0] : {div_shift[31:1], ~lessThan};
	 assign upper32_in = ~lessThan ? adder_out : div_shift[63:32];
	 RQBreg RQB(upper32_in, lower32_in, clock, reg_clr, reg_ena, div_out);
	 
	 //RQB register into Auto-shift left by 1
	 sla64_1 sla(div_out, div_shift);
	 
	 //control block (lessthan)
	 div_control div(ctrl_DIV, clock, lessThan, reg_clr, reg_ena, data_resultRDY, iter);
	 isEqual_6(6'b100010, iter[5:0], op_done);
	 
	 //if multiplier was negative, invert product 
	 alu invert_result(32'd0, div_out[31:0], 5'b00001,  5'd0, inv_result, inv2_notEqual, inv2_lessThan, inv2_ovf);
	 xor xor_op_neg(one_op_neg, data_operandA[31], data_operandB[31]);
	 assign data_result = one_op_neg ? inv_result : div_out[31:0];
	 
	 //exception handling
	 assign opA_is_zero = ~(data_operandA[31] || data_operandA[30] || data_operandA[29] || data_operandA[28] || data_operandA[27] || 
									data_operandA[26] || data_operandA[25] || data_operandA[24] || data_operandA[23] || data_operandA[22] || 
									data_operandA[21] || data_operandA[20] || data_operandA[19] || data_operandA[18] || data_operandA[17] || 
									data_operandA[16] || data_operandA[15] || data_operandA[14] || data_operandA[13] || data_operandA[12] || 
									data_operandA[11] || data_operandA[10] || data_operandA[9] || data_operandA[8] || data_operandA[7] || 
									data_operandA[6] || data_operandA[5] || data_operandA[4] || data_operandA[3] || data_operandA[2] || 
									data_operandA[1] || data_operandA[0]);
	 assign wrong_signs = ( (~data_operandA[31] && ~data_operandB[31] && data_result[31]) ||
									(~data_operandA[31] && data_operandB[31] && ~data_result[31] && ~opA_is_zero) ||
									(data_operandA[31] && ~data_operandB[31] && ~data_result[31]) ||
									(data_operandA[31] && data_operandB[31] && data_result[31]) );
	 assign opB_is_zero = ~(data_operandB[31] || data_operandB[30] || data_operandB[29] || data_operandB[28] || data_operandB[27] || 
									data_operandB[26] || data_operandB[25] || data_operandB[24] || data_operandB[23] || data_operandB[22] || 
									data_operandB[21] || data_operandB[20] || data_operandB[19] || data_operandB[18] || data_operandB[17] || 
									data_operandB[16] || data_operandB[15] || data_operandB[14] || data_operandB[13] || data_operandB[12] || 
									data_operandB[11] || data_operandB[10] || data_operandB[9] || data_operandB[8] || data_operandB[7] || 
									data_operandB[6] || data_operandB[5] || data_operandB[4] || data_operandB[3] || data_operandB[2] || 
									data_operandB[1] || data_operandB[0]);
			
	 assign data_exception = (wrong_signs || opB_is_zero);
	 
endmodule