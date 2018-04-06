module regfile (
    clock,
    ctrl_writeEnable,
    ctrl_reset, ctrl_writeReg,
    ctrl_readRegA, ctrl_readRegB, data_writeReg,
    data_readRegA, data_readRegB
);

   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;

   output [31:0] data_readRegA, data_readRegB;
	//I THINK YOU MIGHT HAVE TO SWITCH THE ORDER OF THE REGS TO ENSURE BITS ARE IN THE RIGHT DIRECTION
	wire output_ena;
	wire [31:0] dec_to_reg;
	wire [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
					reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, 
					reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23,
					reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31;

	assign output_ena = 1'b1;
	
	decoder5_32 dec(ctrl_writeReg, ctrl_writeEnable, dec_to_reg);
	mux32_1 muxA(ctrl_readRegA, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
					reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, 
					reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23,
					reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31, data_readRegA);
	mux32_1 muxB(ctrl_readRegB, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
					reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, 
					reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23,
					reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31, data_readRegB);
	
	register_module register0(data_writeReg, clock, dec_to_reg[0], 1'b0, 1'b1, reg0);
	register_module register1(data_writeReg, clock, dec_to_reg[1], output_ena, ctrl_reset, reg1);
	register_module register2(data_writeReg, clock, dec_to_reg[2], output_ena, ctrl_reset, reg2);
	register_module register3(data_writeReg, clock, dec_to_reg[3], output_ena, ctrl_reset, reg3);
	register_module register4(data_writeReg, clock, dec_to_reg[4], output_ena, ctrl_reset, reg4);
	register_module register5(data_writeReg, clock, dec_to_reg[5], output_ena, ctrl_reset, reg5);
	register_module register6(data_writeReg, clock, dec_to_reg[6], output_ena, ctrl_reset, reg6);
	register_module register7(data_writeReg, clock, dec_to_reg[7], output_ena, ctrl_reset, reg7);
	register_module register8(data_writeReg, clock, dec_to_reg[8], output_ena, ctrl_reset, reg8);
	register_module register9(data_writeReg, clock, dec_to_reg[9], output_ena, ctrl_reset, reg9);
	register_module register10(data_writeReg, clock, dec_to_reg[10], output_ena, ctrl_reset, reg10);
	register_module register11(data_writeReg, clock, dec_to_reg[11], output_ena, ctrl_reset, reg11);
	register_module register12(data_writeReg, clock, dec_to_reg[12], output_ena, ctrl_reset, reg12);
	register_module register13(data_writeReg, clock, dec_to_reg[13], output_ena, ctrl_reset, reg13);
	register_module register14(data_writeReg, clock, dec_to_reg[14], output_ena, ctrl_reset, reg14);
	register_module register15(data_writeReg, clock, dec_to_reg[15], output_ena, ctrl_reset, reg15);
	register_module register16(data_writeReg, clock, dec_to_reg[16], output_ena, ctrl_reset, reg16);
	register_module register17(data_writeReg, clock, dec_to_reg[17], output_ena, ctrl_reset, reg17);
	register_module register18(data_writeReg, clock, dec_to_reg[18], output_ena, ctrl_reset, reg18);
	register_module register19(data_writeReg, clock, dec_to_reg[19], output_ena, ctrl_reset, reg19);
	register_module register20(data_writeReg, clock, dec_to_reg[20], output_ena, ctrl_reset, reg20);
	register_module register21(data_writeReg, clock, dec_to_reg[21], output_ena, ctrl_reset, reg21);
	register_module register22(data_writeReg, clock, dec_to_reg[22], output_ena, ctrl_reset, reg22);
	register_module register23(data_writeReg, clock, dec_to_reg[23], output_ena, ctrl_reset, reg23);
	register_module register24(data_writeReg, clock, dec_to_reg[24], output_ena, ctrl_reset, reg24);
	register_module register25(data_writeReg, clock, dec_to_reg[25], output_ena, ctrl_reset, reg25);
	register_module register26(data_writeReg, clock, dec_to_reg[26], output_ena, ctrl_reset, reg26);
	register_module register27(data_writeReg, clock, dec_to_reg[27], output_ena, ctrl_reset, reg27);
	register_module register28(data_writeReg, clock, dec_to_reg[28], output_ena, ctrl_reset, reg28);
	register_module register29(data_writeReg, clock, dec_to_reg[29], output_ena, ctrl_reset, reg29);
	register_module register30(data_writeReg, clock, dec_to_reg[30], output_ena, ctrl_reset, reg30);
	register_module register31(data_writeReg, clock, dec_to_reg[31], output_ena, ctrl_reset, reg31);

endmodule
