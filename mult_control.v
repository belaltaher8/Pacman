module mult_control(ctrl_MULT, clk, l2, sla_ena, adder_opcode, reg_clr, reg_ena, data_resultRDY, iter_);
						  //l3_);
	input ctrl_MULT, clk;
	input[1:0] l2;
	
	output [1:0] sla_ena;
	output adder_opcode, reg_clr, reg_ena, data_resultRDY;
	output [4:0] iter_;
	
	wire lowest_bit_out;
	wire [2:0] l3;
	wire iter_is_zero;
	wire [31:0] iter_out, increm_out, iter_in;
	assign iter_is_zero = ~(iter_out[4] || iter_out[3] || iter_out[2] || iter_out[1] || iter_out[0]);
	assign l3[2] = iter_is_zero ? 1'b0 : l2[1];
	assign l3[1] = iter_is_zero ? 1'b0 : l2[0];
	assign l3[0] = iter_is_zero ? 1'b0 : lowest_bit_out;
	
	assign iter_ = iter_out[4:0];
	
	//test
	/*output [2:0] l3_;
	assign l3_ = l3;*/
	
	//at ctrl_MULT high, clear regs and prepare
	assign reg_clr = ctrl_MULT ? 1'b1 : 1'b0;
	
	//timer counting to 10011
	dflipflop iter_blks [4:0](iter_in[4:0], clk, ctrl_MULT, 1'b1, iter_out[4:0]);
	
	wire max_counter;
	isEqual_5(5'b11111, increm_out[4:0], max_counter);
	assign iter_in = max_counter ?  5'b11000 : increm_out[4:0];
	alu iter_alu(iter_out, 32'd1, 5'b00000, 32'd0, increm_out);
	and and0(data_resultRDY, iter_out[4], ~iter_out[3], ~iter_out[2], iter_out[1], ~iter_out[0]);
	
	//saving lowest bit
	dflipflop lowest_bit(l3[2], clk, ctrl_MULT, 1'b1, lowest_bit_out);
	
	//output reg_ena
	nand nand0(reg_ena, iter_out[4], ~iter_out[3], ~iter_out[2], iter_out[1], ~iter_out[0]);
		
	//add/sub decision
	assign adder_opcode = ((l3[2] && ~l3[1]) || (l3[2] && ~l3[0])) ? 1'b1 : 1'b0;
		
	//shift decision
	assign sla_ena[1] = ((~l3[2] && l3[1] && l3[0]) || (l3[2] && ~l3[1] && ~l3[0])) ? 1'b1 : 1'b0;
	assign sla_ena[0] = ((~l3[1] && l3[0]) || (l3[1] && ~l3[0])) ? 1'b1 : 1'b0;


endmodule