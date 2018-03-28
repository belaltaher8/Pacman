//look at mult (exceptions) for reason why this doesn't function properly

module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, reset, 
					data_result, data_exception, data_resultRDY);
					//is_mult, is_div, data_resultRDY_mult, data_resultRDY_div, iter_div);

	 
    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock, reset;
	 
	 //test mult
	 /*output adder_opcode_mult, reg_clr_mult, reg_ena_mult;
	 output [1:0] sla_ena_mult;
	 output [31:0] sla_out_mult, adder_out_mult, lower32_in_mult;
	 output [63:0] prod_shift_mult, prod_out_mult;
	 output [2:0] lower3_out_mult;
	 output [4:0] iter_mult;*/
					//sla_ena_mult, sla_out_mult, prod_shift_mult, adder_opcode_mult, adder_out_mult, lower32_in_mult, 
					//reg_clr_mult, reg_ena_mult, prod_out_mult, iter_mult, lower3_out_mult);
	 
	 //test div
	 /*output [63:0] prod_shift_div, prod_out_div;
	 output [31:0] adder_out_div, lower32_in_div, upper32_in_div;
	 output reg_clr_div, reg_ena_div, lessThan_div;
	 output [5:0] iter_div;
	 output [31:0] adder_in_upper, adder_in_lower;*/
					//lessThan_div, adder_out_div, lower32_in_div, upper32_in_div, iter_div, adder_in_upper, adder_in_lower,
					//prod_out_div, prod_shift_div, reg_clr_div, reg_ena_div);

    output [31:0] data_result;
    output data_exception, data_resultRDY;
	 
	 wire [31:0] data_result_mult;
    wire data_exception_mult, data_resultRDY_mult;
	 wire op_done_mult;
	 
	 wire [31:0] data_result_div;
    wire data_exception_div, data_resultRDY_div;
	 wire op_done_div;
	 
	 //do math
	 mult multiplier(data_operandA, data_operandB, ctrl_MULT, clock, data_result_mult, data_exception_mult, data_resultRDY_mult, op_done_mult);
						  //sla_ena_mult, sla_out_mult, prod_shift_mult, adder_opcode_mult, adder_out_mult, lower32_in_mult, reg_clr_mult, reg_ena_mult, prod_out_mult, iter_mult, lower3_out_mult);
	 div divider(data_operandA, data_operandB, ctrl_DIV, clock, data_result_div, data_exception_div, data_resultRDY_div, op_done_div);
					 //prod_shift_div, adder_out_div, lower32_in_div, upper32_in_div, reg_clr_div, reg_ena_div, prod_out_div, lessThan_div, iter_div, adder_in_upper, adder_in_lower);
	 
	 //set correct value
	 wire ctrl_en, is_mult, is_div;
	 or start_op(ctrl_ena, ctrl_MULT, ctrl_DIV);
	 dflipflop dff_mult(ctrl_MULT, ~clock, (op_done_mult || reset), ctrl_ena, is_mult);
	 dflipflop dff_div(ctrl_DIV, ~clock, (op_done_div || reset), ctrl_ena, is_div);
	 
	 tri_state32 tri_0(data_result_mult, is_mult, data_result);
	 tri_state32 tri_1(data_result_div, is_div, data_result);
	 tri_state32 tri_6(32'd0, ~(is_mult || is_div), data_result);
	 
	 tri_state tri_2(data_resultRDY_mult, is_mult, data_resultRDY);
	 tri_state tri_3(data_resultRDY_div, is_div, data_resultRDY);
	 tri_state tri_7(1'b0, ~(is_mult || is_div), data_resultRDY);
	 
	 tri_state tri_4(data_exception_mult, is_mult, data_exception);
	 tri_state tri_5(data_exception_div, is_div, data_exception);
	 tri_state tri_8(1'b0, ~(is_mult || is_div), data_exception);
	 
endmodule
