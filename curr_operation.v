module curr_operation(
							//inputs
							opcode, alu_op,
							//outputs
							isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
							isJal, isJr, isBex, isSetx
							);
	input [4:0] opcode, alu_op;
	output isAdd, isAddi, isSub, isAnd, isOr, isSll, isSra, isMul, isDiv, isSw, isLw, isJ, isBne, isBlt,
			 isJal, isJr, isBex, isSetx;
	
	wire typeR, Add, Sub, And, Or, Sll, Sra, Mul, Div;
	
	isEqual_5(5'b00000, opcode, typeR);
	isEqual_5(5'b00000, alu_op, Add);
	and and0(isAdd, Add, typeR);
	isEqual_5(5'b00101, opcode, isAddi);
	isEqual_5(5'b00001, alu_op, Sub);
	and and1(isSub, Sub, typeR);
	isEqual_5(5'b00010, alu_op, And);
	and and2(isAnd, And, typeR);
	isEqual_5(5'b00011, alu_op, Or);
	and and3(isOr, Or, typeR);
	isEqual_5(5'b00100, alu_op, Sll);
	and and4(isSll, Sll, typeR);
	isEqual_5(5'b00101, alu_op, Sra);
	and and5(isSra, Sra, typeR);
	isEqual_5(5'b00110, alu_op, Mul);
	and and6(isMul, Mul, typeR);
	isEqual_5(5'b00111, alu_op, Div);
	and and7(isDiv, Div, typeR);
	isEqual_5(5'b00111, opcode, isSw);
	isEqual_5(5'b01000, opcode, isLw);
	isEqual_5(5'b00001, opcode, isJ);
	isEqual_5(5'b00011, opcode, isJal);
	isEqual_5(5'b00100, opcode, isJr);
	isEqual_5(5'b00010, opcode, isBne);
	isEqual_5(5'b00110, opcode, isBlt);
	isEqual_5(5'b10110, opcode, isBex);
	isEqual_5(5'b10101, opcode, isSetx);

endmodule