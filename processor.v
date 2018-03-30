/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                  // I: Data from port B of regfile
	 
	 //testing
);
	 //test

    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [16:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;
	 
	 //BC
	 wire write2mem_b, write2alu0_b, write2alu1_b, exec_out_xm2alu0_b, exec_out_xm2alu1_b;
	 
	 //SC
	 wire stall;
	 
	 //PC
	 wire [11:0] iaddr;
	 wire [11:0] iaddr_PC;
	 
	 //Fetch
	 wire [11:0] next_iaddr_f;
	 wire [31:0] q_imem_f;
	 
	 //FD
	 wire [11:0] next_iaddr_fd;
	 wire [31:0] q_imem_fd;
	 wire flush;
	 
	 //Decode
	 wire [11:0] next_iaddr_d;
	 wire [31:0] rd_out0_d, rd_out1_d;
	 wire [4:0] opcode_d, rd_d, rs_d, rt_d, shamt_d, alu_op_d;
	 wire [26:0] target_d;
	 wire [31:0] imm_d;
	 wire isAdd_d, isAddi_d, isSub_d, isAnd_d, isOr_d, isSll_d, isSra_d, isMul_d, isDiv_d, isSw_d, isLw_d,
			isJ_d, isBne_d, isBlt_d, isJal_d, isJr_d, isBex_d, isSetx_d;	
	 wire NOP_d;
	 
	 //DX
	 wire [11:0] next_iaddr_dx;
	 wire [31:0] rd_out0_dx, rd_out1_dx;
	 wire [4:0] shamt_dx;
	 wire [4:0] opcode_dx, rd_dx, rs_dx, rt_dx, alu_op_dx;
	 wire [26:0] target_dx;
	 wire [31:0] imm_dx;
	 wire isAdd_dx, isAddi_dx, isSub_dx, isAnd_dx, isOr_dx, isSll_dx, isSra_dx, isMul_dx, isDiv_dx, isSw_dx, isLw_dx,
			isJ_dx, isBne_dx, isBlt_dx, isJal_dx, isJr_dx, isBex_dx, isSetx_dx;
	 wire NOP_dx;	
	 
	 //Execute
	 wire [11:0] next_iaddr_adj;
	 wire [31:0] exec_out_x;
	 wire [31:0] rd_out1_x, exception_out_x;
	 wire jump_x;
	 wire MD_inProg_x;
	 wire exception_x;
	 wire MD_resultRDY_x;
	 wire [4:0] rd_x;
	 wire [26:0] target_x;
	 wire isAdd_x, isAddi_x, isSub_x, isAnd_x, isOr_x, isSll_x, isSra_x, isMul_x, isDiv_x, isSw_x, isLw_x,
			isJ_x, isBne_x, isBlt_x, isJal_x, isJr_x, isBex_x, isSetx_x;	
	 
	 //XM
	 wire [31:0] exec_out_xm;
	 wire [31:0] rd_out1_xm;
	 wire exception_xm;
	 wire [4:0] rd_xm;
	 wire [26:0] target_xm;
	 wire isAdd_xm, isAddi_xm, isSub_xm, isAnd_xm, isOr_xm, isSll_xm, isSra_xm, isMul_xm, isDiv_xm, isSw_xm, isLw_xm,
			isJ_xm, isBne_xm, isBlt_xm, isJal_xm, isJr_xm, isBex_xm, isSetx_xm;	
	 
	 //Memory
	 wire [31:0] exec_out_m;
	 wire [31:0] mem_out_m;
	 wire exception_m;
	 wire [4:0] rd_m;
	 wire [26:0] target_m;
	 wire isAdd_m, isAddi_m, isSub_m, isAnd_m, isOr_m, isSll_m, isSra_m, isMul_m, isDiv_m, isSw_m, isLw_m,
			isJ_m, isBne_m, isBlt_m, isJal_m, isJr_m, isBex_m, isSetx_m;	
	 
	 //MW
	 wire [31:0] exec_out_mw, mem_out_mw;
	 wire exception_mw;
	 wire [4:0] rd_mw;
	 wire [26:0] target_mw;
	 wire isAdd_mw, isAddi_mw, isSub_mw, isAnd_mw, isOr_mw, isSll_mw, isSra_mw, isMul_mw, isDiv_mw, isSw_mw, isLw_mw,
			isJ_mw, isBne_mw, isBlt_mw, isJal_mw, isJr_mw, isBex_mw, isSetx_mw;
	 
	 //Writeback
	 wire [4:0] ctrl_writeReg_w;
	 wire [31:0] data_writeReg_w;
	 wire ctrl_writeEnable_w;
	 
	 
	 bypassControl BC(
							.ctrl_writeEnable(ctrl_writeEnable_w), 
							.ctrl_writeReg(ctrl_writeReg), 
							.rd_dx(rd_dx), .rs_dx(rs_dx), .rt_dx(rt_dx), 
							.rd_xm(rd_xm), .rs_xm(rs_xm), .rt_xm(rt_xm), 
							.rd_mw(rd_mw), .rs_mw(rs_mw), .rt_mw(rt_mw),
							.isAdd_dx(isAdd_dx), 
				  		   .isAddi_dx(isAddi_dx), 
				  		   .isSub_dx(isSub_dx), 
				  		   .isAnd_dx(isAnd_dx), 
				  		   .isOr_dx(isOr_dx), 
				  		   .isSll_dx(isSll_dx), 
				  		   .isSra_dx(isSra_dx), 
				  		   .isMul_dx(isMul_dx), 
				  		   .isDiv_dx(isDiv_dx), 
				  		   .isSw_dx(isSw_dx), 
				  		   .isLw_dx(isLw_dx), 
				  		   .isJ_dx(isJ_dx), 
				  		   .isBne_dx(isBne_dx), 
				  		   .isBlt_dx(isBlt_dx),
				  		   .isJal_dx(isJal_dx), 
				  		   .isJr_dx(isJr_dx), 
				  		   .isBex_dx(isBex_dx), 
				  		   .isSetx_dx(isSetx_dx),
							.isAdd_xm(isAdd_xm), 
							.isAddi_xm(isAddi_xm), 
							.isSub_xm(isSub_xm), 
							.isAnd_xm(isAnd_xm), 
							.isOr_xm(isOr_xm), 
							.isSll_xm(isSll_xm), 
							.isSra_xm(isSra_xm), 
							.isMul_xm(isMul_xm), 
							.isDiv_xm(isDiv_xm), 
							.isSw_xm(isSw_xm), 
							.isLw_xm(isLw_xm), 
							.isJ_xm(isJ_xm), 
							.isBne_xm(isBne_xm), 
							.isBlt_xm(isBlt_xm),
							.isJal_xm(isJal_xm), 
							.isJr_xm(isJr_xm), 
							.isBex_xm(isBex_xm), 
							.isSetx_xm(isSetx_xm),
							.exception_xm(exception_xm),
							.reset(reset),
							//outputs
							.write2mem_b(write2mem_b), 
							.write2alu0_b(write2alu0_b), 
							.write2alu1_b(write2alu1_b), 
							.exec_out_xm2alu0_b(exec_out_xm2alu0_b), 
							.exec_out_xm2alu1_b(exec_out_xm2alu1_b) 
							);
	 
	 stallControl(
					  //inputs
					  .rd_d(rd_d), .rs_d(rs_d), .rt_d(rt_d), 
					  .rd_dx(rd_dx), .rs_dx(rs_dx), .rt_dx(rt_dx), 
					  .MD_resultRDY_x(MD_resultRDY_x),
					  .MD_inProg_x(MD_inProg_x),
					  .isSw_d(isSw_d),
					  .isLw_dx(isLw_dx),
					  .isMul_dx(isMul_dx),
					  .isDiv_dx(isDiv_dx),
					  .reset(reset),
					  //outputs
					  .stall(stall)
					  );
	 
	 assign iaddr = jump_x ? next_iaddr_adj : next_iaddr_f;
	 
    PC pc(
			 //inputs
			 .clock(clock), 
			 .iaddr(iaddr),
			 .clr(reset),
			 .ena(~stall),
			 //outputs
			 .iaddr_PC(iaddr_PC)
			 );
			 
	 fetch Fetch(
					 //inputs
					 .clock(clock), 
					 .q_imem(q_imem), 
					 .iaddr_PC(iaddr_PC),
					 .reset(reset),
					 //outputs
					 .address_imem(address_imem), 
					 .next_iaddr_f(next_iaddr_f), 
					 .q_imem_f(q_imem_f)
					 );
    assign flush = jump_x || exception_x;
	 F_D f_d(
				//inputs
				.clock(clock), 
				.q_imem_f(q_imem_f), 
				.next_iaddr_f(next_iaddr_f), 
				.clr(reset || flush), 
				.ena(~stall),
				//outputs
				.q_imem_fd(q_imem_fd), 
				.next_iaddr_fd(next_iaddr_fd)
				);
	 decode Decode(
						//inputs
						.clock(clock), 
						.q_imem_fd(q_imem_fd), 
						.next_iaddr_fd(next_iaddr_fd),
						.data_readRegA(data_readRegA),
						.data_readRegB(data_readRegB),
						.reset(reset),
						//outputs
						.next_iaddr_d(next_iaddr_d),
						.ctrl_readRegA(ctrl_readRegA), 
						.ctrl_readRegB(ctrl_readRegB),
						.rd_out0_d(rd_out0_d), 
						.rd_out1_d(rd_out1_d), 
						.isAdd(isAdd_d), 
						.isAddi(isAddi_d), 
						.isSub(isSub_d), 
						.isAnd(isAnd_d), 
						.isOr(isOr_d), 
						.isSll(isSll_d), 
						.isSra(isSra_d), 
						.isMul(isMul_d), 
						.isDiv(isDiv_d), 
						.isSw(isSw_d), 
						.isLw(isLw_d), 
						.isJ(isJ_d), 
						.isBne(isBne_d), 
						.isBlt(isBlt_d),
						.isJal(isJal_d), 
						.isJr(isJr_d), 
						.isBex(isBex_d), 
						.isSetx(isSetx_d),
						.opcode_d(opcode_d), 
						.rd_d(rd_d), 
						.rs_d(rs_d), 
						.rt_d(rt_d), 
						.shamt_d(shamt_d), 
						.alu_op_d(alu_op_d), 
						.target_d(target_d), 
						.imm_d(imm_d),
						.NOP(NOP_d)
						);
	 //NOP logic dx		
	 wire [11:0] next_iaddr_d_s;
	 wire [31:0] rd_out0_d_s, rd_out1_d_s;
	 wire [4:0] opcode_d_s, rd_d_s, rs_d_s, rt_d_s, shamt_d_s, alu_op_d_s;
	 wire [26:0] target_d_s;
	 wire [31:0] imm_d_s;
	 wire isAdd_d_s, isAddi_d_s, isSub_d_s, isAnd_d_s, isOr_d_s, isSll_d_s, isSra_d_s, isMul_d_s, isDiv_d_s, 
			isSw_d_s, isLw_d_s, isJ_d_s, isBne_d_s, isBlt_d_s, isJal_d_s, isJr_d_s, isBex_d_s, isSetx_d_s;
			
	 assign next_iaddr_d_s = (stall || flush) ? 12'd0 : next_iaddr_d;
	 assign rd_out0_d_s = (stall || flush) ? 32'd0 : rd_out0_d;
	 assign rd_out1_d_s = (stall || flush) ? 32'd0 : rd_out1_d;
	 assign opcode_d_s = (stall || flush) ? 5'd0 : opcode_d;
	 assign rd_d_s = (stall || flush) ? 5'd0 : rd_d;
	 assign rs_d_s = (stall || flush) ? 5'd0 : rs_d;
	 assign rt_d_s = (stall || flush) ? 5'd0 : rt_d;
	 assign shamt_d_s = (stall || flush) ? 5'd0 : shamt_d;
	 assign alu_op_d_s = (stall || flush) ? 5'd0 : alu_op_d;
	 assign target_d_s = (stall || flush) ? 27'd0 : target_d;
	 assign imm_d_s = (stall || flush) ? 32'd0 : imm_d;
	 assign isAdd_d_s = (stall || flush) ? 1'd1 : isAdd_d;
	 assign isAddi_d_s = (stall || flush) ? 1'd0 : isAddi_d;
	 assign isSub_d_s = (stall || flush) ? 1'd0 : isSub_d;
	 assign isAnd_d_s = (stall || flush) ? 1'd0 : isAnd_d;
	 assign isOr_d_s = (stall || flush) ? 1'd0 : isOr_d;
	 assign isSll_d_s = (stall || flush) ? 1'd0 : isSll_d;
	 assign isSra_d_s = (stall || flush) ? 1'd0 : isSra_d;
	 assign isMul_d_s = (stall || flush) ? 1'd0 : isMul_d;
	 assign isDiv_d_s = (stall || flush) ? 1'd0 : isDiv_d;
	 assign isSw_d_s = (stall || flush) ? 1'd0 : isSw_d;
	 assign isLw_d_s = (stall || flush) ? 1'd0 : isLw_d;
	 assign isJ_d_s = (stall || flush) ? 1'd0 : isJ_d;
	 assign isBne_d_s = (stall || flush) ? 1'd0 : isBne_d;
	 assign isBlt_d_s = (stall || flush) ? 1'd0 : isBlt_d;
	 assign isJal_d_s = (stall || flush) ? 1'd0 : isJal_d;
	 assign isJr_d_s = (stall || flush) ? 1'd0 : isJr_d;
	 assign isBex_d_s = (stall || flush) ? 1'd0 : isBex_d;
	 assign isSetx_d_s = (stall || flush) ? 1'd0 : isSetx_d;
	 
	 D_X d_x(
				//inputs
				.clock(clock),
				.next_iaddr_d(next_iaddr_d_s),
				.rd_out0_d(rd_out0_d_s), 
				.rd_out1_d(rd_out1_d_s),
				.isAdd(isAdd_d_s), 
				.isAddi(isAddi_d_s), 
				.isSub(isSub_d_s), 
				.isAnd(isAnd_d_s), 
				.isOr(isOr_d_s), 
				.isSll(isSll_d_s), 
				.isSra(isSra_d_s), 
				.isMul(isMul_d_s), 
				.isDiv(isDiv_d_s), 
				.isSw(isSw_d_s), 
				.isLw(isLw_d_s), 
				.isJ(isJ_d_s), 
				.isBne(isBne_d_s), 
				.isBlt(isBlt_d_s),
				.isJal(isJal_d_s), 
				.isJr(isJr_d_s), 
				.isBex(isBex_d_s), 
				.isSetx(isSetx_d_s),
				.opcode_d(opcode_d_s), 
				.rd_d(rd_d_s), 
				.rs_d(rs_d_s), 
				.rt_d(rt_d_s), 
				.shamt_d(shamt_d_s), 
				.alu_op_d(alu_op_d_s), 
				.target_d(target_d_s), 
				.imm_d(imm_d_s),	
				.NOP_d(NOP_d),
				.clr(reset), 
				.ena(1'b1),
				//outputs
				.next_iaddr_dx(next_iaddr_dx),
				.rd_out0_dx(rd_out0_dx), 
				.rd_out1_dx(rd_out1_dx), 
				.isAdd_out(isAdd_dx), 
				.isAddi_out(isAddi_dx), 
				.isSub_out(isSub_dx), 
				.isAnd_out(isAnd_dx), 
				.isOr_out(isOr_dx), 
				.isSll_out(isSll_dx), 
				.isSra_out(isSra_dx), 
				.isMul_out(isMul_dx), 
				.isDiv_out(isDiv_dx), 
				.isSw_out(isSw_dx), 
				.isLw_out(isLw_dx), 
				.isJ_out(isJ_dx), 
				.isBne_out(isBne_dx), 
				.isBlt_out(isBlt_dx),
				.isJal_out(isJal_dx), 
				.isJr_out(isJr_dx), 
				.isBex_out(isBex_dx), 
				.isSetx_out(isSetx_dx),
				.opcode_dx(opcode_dx), 
				.rd_dx(rd_dx), 
				.rs_dx(rs_dx), 
				.rt_dx(rt_dx), 
				.shamt_dx(shamt_dx), 
				.alu_op_dx(alu_op_dx), 
				.target_dx(target_dx), 
				.imm_dx(imm_dx),
				.NOP_dx(NOP_dx)
				);
	 //wx/mx bypass logic
	 wire [31:0] x_bypass0, x_bypass1;
	 tri_state32(data_writeReg, (write2alu0_b && ~exec_out_xm2alu0_b), x_bypass0);
	 tri_state32(exec_out_xm, (exec_out_xm2alu0_b), x_bypass0);
	 tri_state32(rd_out0_dx, (~write2alu0_b && ~exec_out_xm2alu0_b), x_bypass0);
	 
	 tri_state32(data_writeReg, (write2alu1_b && ~exec_out_xm2alu1_b), x_bypass1);
	 tri_state32(exec_out_xm, (exec_out_xm2alu1_b), x_bypass1);
	 tri_state32(rd_out1_dx, (~write2alu1_b && ~exec_out_xm2alu1_b), x_bypass1);
	 
	 execute Execute(
						  //inputs
						  .clock(clock), 
						  .next_iaddr_dx(next_iaddr_dx),
						  .rd_out0_dx(x_bypass0), 
						  .rd_out1_dx(x_bypass1), 
						  .isAdd(isAdd_dx), 
				  		  .isAddi(isAddi_dx), 
				  		  .isSub(isSub_dx), 
				  		  .isAnd(isAnd_dx), 
				  		  .isOr(isOr_dx), 
				  		  .isSll(isSll_dx), 
				  		  .isSra(isSra_dx), 
				  		  .isMul(isMul_dx), 
				  		  .isDiv(isDiv_dx), 
				  		  .isSw(isSw_dx), 
				  		  .isLw(isLw_dx), 
				  		  .isJ(isJ_dx), 
				  		  .isBne(isBne_dx), 
				  		  .isBlt(isBlt_dx),
				  		  .isJal(isJal_dx), 
				  		  .isJr(isJr_dx), 
				  		  .isBex(isBex_dx), 
				  		  .isSetx(isSetx_dx),
				  		  .opcode_dx(opcode_dx), 
				  		  .rd_dx(rd_dx), 
				  		  .rs_dx(rs_dx), 
				  		  .rt_dx(rt_dx), 
				  		  .shamt_dx(shamt_dx), 
				  		  .alu_op_dx(alu_op_dx), 
				  		  .target_dx(target_dx), 
				  		  .imm_dx(imm_dx),
						  .NOP_dx(NOP_dx),
						  .reset(reset),
						  //outputs
						  .next_iaddr_adj(next_iaddr_adj), 
						  .exec_out_x(exec_out_x), 
						  .rd_out1_x(rd_out1_x),
						  .exception_out_x(exception_out_x),
						  .jump_x(jump_x),
						  .rd_x(rd_x),
						  .exception(exception_x),
						  .MD_resultRDY(MD_resultRDY_x),
						  .MD_inProg(MD_inProg_x),
						  .isAdd_out(isAdd_x), 
						  .isAddi_out(isAddi_x), 
						  .isSub_out(isSub_x), 
						  .isAnd_out(isAnd_x), 
						  .isOr_out(isOr_x), 
						  .isSll_out(isSll_x), 
						  .isSra_out(isSra_x), 
						  .isMul_out(isMul_x), 
						  .isDiv_out(isDiv_x), 
						  .isSw_out(isSw_x), 
						  .isLw_out(isLw_x), 
						  .isJ_out(isJ_x), 
						  .isBne_out(isBne_x), 
						  .isBlt_out(isBlt_x),
						  .isJal_out(isJal_x), 
						  .isJr_out(isJr_x), 
						  .isBex_out(isBex_x), 
						  .isSetx_out(isSetx_x), 
						  .target_x(target_x)
						  //test
						  );
	 X_M x_m(
				//inputs
				.clock(clock),
				.exec_out_x(exec_out_x), 
				.rd_out1_x(rd_out1_x),
				.exception_x(exception_x),
				.isAdd(isAdd_x), 
				.isAddi(isAddi_x), 
				.isSub(isSub_x), 
				.isAnd(isAnd_x), 
				.isOr(isOr_x), 
				.isSll(isSll_x), 
			   .isSra(isSra_x), 
				.isMul(isMul_x), 
				.isDiv(isDiv_x), 
				.isSw(isSw_x), 
				.isLw(isLw_x), 
				.isJ(isJ_x), 
				.isBne(isBne_x), 
	  		   .isBlt(isBlt_x),
				.isJal(isJal_x), 
				.isJr(isJr_x), 
				.isBex(isBex_x), 
				.isSetx(isSetx_x),
				.rd_x(rd_x), 
				.target_x(target_x), 
				.clr(reset), 
				.ena(1'b1),
				//outputs
				.exec_out_xm(exec_out_xm), 
				.rd_out1_xm(rd_out1_xm),
				.exception_xm(exception_xm),
				.isAdd_out(isAdd_xm), 
				.isAddi_out(isAddi_xm), 
				.isSub_out(isSub_xm), 
				.isAnd_out(isAnd_xm), 
				.isOr_out(isOr_xm), 
				.isSll_out(isSll_xm), 
				.isSra_out(isSra_xm), 
				.isMul_out(isMul_xm), 
				.isDiv_out(isDiv_xm), 
				.isSw_out(isSw_xm), 
				.isLw_out(isLw_xm), 
				.isJ_out(isJ_xm), 
				.isBne_out(isBne_xm), 
				.isBlt_out(isBlt_xm),
				.isJal_out(isJal_xm), 
				.isJr_out(isJr_xm), 
				.isBex_out(isBex_xm), 
				.isSetx_out(isSetx_xm),
				.rd_xm(rd_xm), 
				.target_xm(target_xm)
				);
	 //wm bypass logic
	 wire [31:0] wm_bypass;
	 tri_state32 tri_wm0(data_writeReg, write2mem_b, wm_bypass);
	 tri_state32 tri_wm1(rd_out1_xm, ~write2mem_b, wm_bypass);
	 
	 memory Memory(
						//inputs
						.clock(clock), 
						.exec_out_xm(exec_out_xm), 
						.rd_out1_xm(wm_bypass),
						.exception_xm(exception_xm),
						.q_dmem(q_dmem),
						.isAdd(isAdd_xm), 
						.isAddi(isAddi_xm), 
						.isSub(isSub_xm), 
						.isAnd(isAnd_xm), 
						.isOr(isOr_xm), 
						.isSll(isSll_xm), 
						.isSra(isSra_xm), 
						.isMul(isMul_xm), 
						.isDiv(isDiv_xm), 
						.isSw(isSw_xm), 
						.isLw(isLw_xm), 
						.isJ(isJ_xm), 
						.isBne(isBne_xm), 
						.isBlt(isBlt_xm),
						.isJal(isJal_xm), 
						.isJr(isJr_xm), 
						.isBex(isBex_xm), 
						.isSetx(isSetx_xm),
						.rd_xm(rd_xm),  
						.target_xm(target_xm),
						.reset(reset),
						//outputs
						.address_dmem(address_dmem),
						.data(data),
						.wren(wren),
						.exec_out_m(exec_out_m), 
						.exception_m(exception_m),
						.mem_out_m(mem_out_m),
						.isAdd_out(isAdd_m), 
						.isAddi_out(isAddi_m), 
						.isSub_out(isSub_m), 
						.isAnd_out(isAnd_m), 
						.isOr_out(isOr_m), 
						.isSll_out(isSll_m), 
						.isSra_out(isSra_m), 
						.isMul_out(isMul_m), 
						.isDiv_out(isDiv_m), 
						.isSw_out(isSw_m), 
						.isLw_out(isLw_m), 
						.isJ_out(isJ_m), 
						.isBne_out(isBne_m), 
						.isBlt_out(isBlt_m),
						.isJal_out(isJal_m), 
						.isJr_out(isJr_m), 
						.isBex_out(isBex_m), 
						.isSetx_out(isSetx_m),
						.rd_m(rd_m), 
						.target_m(target_m)
						);
	 M_W m_w(
				//inputs
				.clock(clock), 
				.exec_out_m(exec_out_m), 
				.mem_out_m(mem_out_m),
				.exception_m(exception_m),
				.isAdd(isAdd_m), 
				.isAddi(isAddi_m), 
				.isSub(isSub_m), 
				.isAnd(isAnd_m), 
				.isOr(isOr_m), 
				.isSll(isSll_m), 
				.isSra(isSra_m), 
				.isMul(isMul_m), 
				.isDiv(isDiv_m), 
				.isSw(isSw_m), 
				.isLw(isLw_m), 
				.isJ(isJ_m), 
				.isBne(isBne_m), 
				.isBlt(isBlt_m),
				.isJal(isJal_m), 
				.isJr(isJr_m), 
				.isBex(isBex_m), 
				.isSetx(isSetx_m),
				.rd_m(rd_m),  
				.target_m(target_m),
				.clr(reset), 
				.ena(1'b1),
				//outputs
				.exec_out_mw(exec_out_mw), 
				.mem_out_mw(mem_out_mw),
				.exception_mw(exception_mw),
				.isAdd_out(isAdd_mw), 
				.isAddi_out(isAddi_mw), 
				.isSub_out(isSub_mw), 
				.isAnd_out(isAnd_mw), 
				.isOr_out(isOr_mw), 
				.isSll_out(isSll_mw), 
				.isSra_out(isSra_mw), 
				.isMul_out(isMul_mw), 
				.isDiv_out(isDiv_mw), 
				.isSw_out(isSw_mw), 
				.isLw_out(isLw_mw), 
				.isJ_out(isJ_mw), 
				.isBne_out(isBne_mw), 
				.isBlt_out(isBlt_mw),
				.isJal_out(isJal_mw), 
				.isJr_out(isJr_mw), 
				.isBex_out(isBex_mw), 
				.isSetx_out(isSetx_mw),
				.rd_mw(rd_mw),
				.target_mw(target_mw),
				);
	 writeback WriteBack(
								//inputs
								.exec_out_mw(exec_out_mw), 
								.mem_out_mw(mem_out_mw),
								.exception_mw(exception_mw),
								.isAdd(isAdd_mw), 
								.isAddi(isAddi_mw), 
								.isSub(isSub_mw), 
								.isAnd(isAnd_mw), 
								.isOr(isOr_mw), 
								.isSll(isSll_mw), 
								.isSra(isSra_mw), 
								.isMul(isMul_mw), 
								.isDiv(isDiv_mw), 
								.isSw(isSw_mw), 
								.isLw(isLw_mw), 
								.isJ(isJ_mw), 
								.isBne(isBne_mw), 
								.isBlt(isBlt_mw),
								.isJal(isJal_mw), 
								.isJr(isJr_mw), 
								.isBex(isBex_mw), 
								.isSetx(isSetx_mw),
								.rd_mw(rd_mw),
								.target_mw(target_mw),
								.reset(reset),
								//outputs
								.data_writeReg(data_writeReg_w), 
								.ctrl_writeEnable(ctrl_writeEnable_w),
								.ctrl_writeReg(ctrl_writeReg_w)
								);
								
	 //exception writeback logic
	 assign ctrl_writeReg = exception_x ? 5'b11110 : ctrl_writeReg_w;
	 assign data_writeReg = exception_x ? exception_out_x : data_writeReg_w;
	 assign ctrl_writeEnable = exception_x ? 1'b1 : ctrl_writeEnable_w;

endmodule
