module mult(data_operandA, data_operandB, ctrl_MULT, clock, data_result, data_exception, data_resultRDY, op_done);
				//sla_ena_, sla_out_, prod_shift_, adder_opcode_, adder_out_, lower32_in_, reg_clr_, reg_ena_,
				//prod_out_, iter_, lower3_out);
	 
	 input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, clock;

	 //test
	 /*output adder_opcode_, reg_clr_, reg_ena_;
	 output [1:0] sla_ena_;
	 output [31:0] sla_out_, adder_out_, lower32_in_;
	 output [63:0] prod_shift_, prod_out_;
	 output [4:0] iter_;
	 output [2:0] lower3_out;*/
	 
    output [31:0] data_result;
    output data_exception, data_resultRDY;
	 output op_done;
	 
	 wire [31:0] inv_opB, data_operandB_adj;
	 wire inv0_notEqual, inv0_lessThan, inv0_ovf;
	 
	 wire [31:0] result_unadjusted, inv_result;
	 wire inv1_notEqual, inv1_lessThan, inv1_ovf;
	 
	 wire [31:0] sla_out;
	 
	 wire [31:0] adder_out, lower32_in;
	 wire notEqual, lessThan, ovf;
	 
	 wire [63:0] prod_out;
	 wire [1:0] lower2_out;
	 
	 wire [63:0] prod_shift;
	 
	 wire reg_clr, reg_ena, adder_opcode;
	 wire [1:0] sla_ena;
	 
	 wire wrong_signs, result_64_bit;
	 
	 //test
	 /*assign sla_ena_ = sla_ena;
	 assign sla_out_ = sla_out;
	 assign prod_shift_ = prod_shift;
	 assign adder_opcode_ = adder_opcode;
	 assign adder_out_ = adder_out;
	 assign lower32_in_ = lower32_in;
	 assign reg_clr_ = reg_clr;
	 assign reg_ena_ = reg_ena;
	 assign prod_out_ = prod_out;
	 assign iter_ = iter;*/
	 
	 //invert multiplier and see if it's negative
	 alu invert_multiplier(32'd0, data_operandB, 5'b00001,  5'd0, inv_opB, inv0_notEqual, inv0_lessThan, inv0_ovf);
	 assign data_operandB_adj = data_operandB[31] ? inv_opB : data_operandB;
	 
	 //shift multiplicand left by 1, dependent on control
	 //ena: 00 is 0, 01 is no shift, 10 is shift
    sla_1 sla(data_operandA, sla_ena, sla_out);
	 
	 //ALU adds shift output and upper32 shifted
	 alu adder(prod_shift[63:32], sla_out, {4'b0, adder_opcode}, 5'd0, adder_out, notEqual, lessThan, ovf);
	 
	 //ALU into product register upper32
	 wire [4:0] iter;
	 wire iter_is_zero;
	 assign iter_is_zero = ~(iter[4] || iter[3] || iter[2] || iter[1] || iter[0]);
	 assign lower32_in = (ctrl_MULT || iter_is_zero) ? data_operandB_adj : prod_shift[31:0];
	 productReg prod(adder_out, lower32_in, clock, reg_clr, reg_ena, prod_out, lower2_out);
	 
	 //Product register into Auot-shift right by 2
	 sra64_2 sra(prod_out, prod_shift);
	 
	 //control block
	 mult_control control(ctrl_MULT, clock, lower2_out, sla_ena, adder_opcode, reg_clr, reg_ena, data_resultRDY, iter);
								 //lower3_out);
	 isEqual_5(5'b10011, iter[4:0], op_done);
	 
	 //if multiplier was negative, invert product
	 alu invert_result(32'd0, prod_out[31:0], 5'b00001,  5'd0, inv_result, inv1_notEqual, inv1_lessThan, inv1_ovf);
	 assign data_result = data_operandB[31] ? inv_result : prod_out[31:0];
	 
	 //exception handling
	 //NOT WORKING: exception handling on this doesn't work because whenever a mult has the 101 sla_ena code,
	 //				 there is a rogue 1 added up in the remainder bits, which disallows me from being able to 
	 //				 use the "result_64_bit" overflow flag below.
	 //				 Examples of this are 1234*-2579 and 13001*18064
	 //ALSO: This also doesn't catch the exception where 2147483647*2147483647 overflows but all upper bits are 0
	 wire opA_is_zero;
	 assign opA_is_zero = ~(data_operandA[31] || data_operandA[30] || data_operandA[29] || data_operandA[28] || data_operandA[27] || 
									data_operandA[26] || data_operandA[25] || data_operandA[24] || data_operandA[23] || data_operandA[22] || 
									data_operandA[21] || data_operandA[20] || data_operandA[19] || data_operandA[18] || data_operandA[17] || 
									data_operandA[16] || data_operandA[15] || data_operandA[14] || data_operandA[13] || data_operandA[12] || 
									data_operandA[11] || data_operandA[10] || data_operandA[9] || data_operandA[8] || data_operandA[7] || 
									data_operandA[6] || data_operandA[5] || data_operandA[4] || data_operandA[3] || data_operandA[2] || 
									data_operandA[1] || data_operandA[0]);
	 wire opB_is_zero;
	 assign opB_is_zero = ~(data_operandB[31] || data_operandB[30] || data_operandB[29] || data_operandB[28] || data_operandB[27] || 
									data_operandB[26] || data_operandB[25] || data_operandB[24] || data_operandB[23] || data_operandB[22] || 
									data_operandB[21] || data_operandB[20] || data_operandB[19] || data_operandB[18] || data_operandB[17] || 
									data_operandB[16] || data_operandB[15] || data_operandB[14] || data_operandB[13] || data_operandB[12] || 
									data_operandB[11] || data_operandB[10] || data_operandB[9] || data_operandB[8] || data_operandB[7] || 
									data_operandB[6] || data_operandB[5] || data_operandB[4] || data_operandB[3] || data_operandB[2] || 
									data_operandB[1] || data_operandB[0]);
	 assign wrong_signs = ( (~data_operandA[31] && ~data_operandB[31] && data_result[31]) ||
									(~data_operandA[31] && data_operandB[31] && ~data_result[31] && ~opA_is_zero) ||
									(data_operandA[31] && ~data_operandB[31] && ~data_result[31] && ~opB_is_zero) ||
									(data_operandA[31] && data_operandB[31] && data_result[31]) );
	 wire upper32_is_zero;
	 assign upper32_is_zero = ~(prod_out[63] || prod_out[62] || prod_out[61] || prod_out[60] || prod_out[59] || 
										 prod_out[58] || prod_out[57] || prod_out[56] || prod_out[55] || prod_out[54] || 
										 prod_out[53] || prod_out[52] || prod_out[51] || prod_out[50] || prod_out[49] || 
										 prod_out[48] || prod_out[47] || prod_out[46] || prod_out[45] || prod_out[44] || 
										 prod_out[43] || prod_out[42] || prod_out[41] || prod_out[40] || prod_out[39] || 
										 prod_out[38] || prod_out[37] || prod_out[36] || prod_out[35] || prod_out[34] || 
										 prod_out[33] || prod_out[32]);
	 wire upper32_is_FFFFFFFF;
	 assign upper32_is_FFFFFFFF = ~(~prod_out[63] || ~prod_out[62] || ~prod_out[61] || ~prod_out[60] || ~prod_out[59] || 
											  ~prod_out[58] || ~prod_out[57] || ~prod_out[56] || ~prod_out[55] || ~prod_out[54] || 
											  ~prod_out[53] || ~prod_out[52] || ~prod_out[51] || ~prod_out[50] || ~prod_out[49] || 
											  ~prod_out[48] || ~prod_out[47] || ~prod_out[46] || ~prod_out[45] || ~prod_out[44] || 
											  ~prod_out[43] || ~prod_out[42] || ~prod_out[41] || ~prod_out[40] || ~prod_out[39] || 
											  ~prod_out[38] || ~prod_out[37] || ~prod_out[36] || ~prod_out[35] || ~prod_out[34] || 
											  ~prod_out[33] || ~prod_out[32]);
	 assign result_64_bit = ~(upper32_is_zero || upper32_is_FFFFFFFF);
			
	 assign data_exception = (wrong_signs);// || result_64_bit);


endmodule