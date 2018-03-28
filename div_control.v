module div_control(ctrl_DIV, clk, lessThan, reg_clr, reg_ena, data_resultRDY, iter);
	input ctrl_DIV, clk, lessThan;
	
	output reg_clr, reg_ena, data_resultRDY;
	
	output [5:0] iter;
	wire [31:0] iter_out, increm_out, iter_in;
	
	assign iter = iter_out[5:0];
	
	//at ctrl_MULT high, clear regs and prepare
	assign reg_clr = ctrl_DIV ? 1'b1 : 1'b0;
	
	//timer counting to 10011
	dflipflop iter_blks [5:0](iter_in[5:0], clk, ctrl_DIV, 1'b1, iter_out[5:0]);
	
	wire max_counter;
	isEqual_6(6'b111111, increm_out[5:0], max_counter);
	assign iter_in = max_counter ?  6'b110000 : increm_out[5:0];
	alu iter_alu(iter_out, 32'd1, 5'b00000, 32'd0, increm_out);
	and and3(data_resultRDY, iter_out[5], ~iter_out[4], ~iter_out[3], ~iter_out[2], ~iter_out[1], iter_out[0]);
	
	//output reg_ena
	nand nand3(reg_ena, iter_out[5], ~iter_out[4], ~iter_out[3], ~iter_out[2], ~iter_out[1], iter_out[0]);
	

endmodule