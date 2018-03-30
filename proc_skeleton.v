/**
 * NOTE: you should not need to change this file! This file will be swapped out for a grading
 * "skeleton" for testing. We will also remove your imem and dmem file.
 *
 * NOTE: skeleton should be your top-level module!
 *
 * This skeleton file serves as a wrapper around the processor to provide certain control signals
 * and interfaces to memory elements. This structure allows for easier testing, as it is easier to
 * inspect which signals the processor tries to assert when.
 */

module proc_skeleton(clock, reset, VGA_address_dmem, VGA_q_dmem, ps2_key_pressed, ps2_out
					 //address_imem, q_imem, address_dmem, data, wren, q_dmem, ctrl_writeEnable, ctrl_writeReg, ctrl_readRegA, 
					 //ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB
					 );
  
  
    input clock, reset, ps2_key_pressed;
    input [11:0] VGA_address_dmem;
	input [7:0]	 ps2_out;	
    output [31:0] VGA_q_dmem;
    
	 //test
	 
    /** IMEM **/
    wire [11:0] address_imem;
    wire [31:0] q_imem;
    imem my_imem(
        .address    (address_imem),            // address of data
        .clock      (~clock),                  // you may need to invert the clock
        .q          (q_imem),                  // the raw instruction
		  .clken      (1'b1)
    );

    /** DMEM **/
    wire [11:0] address_dmem;
    wire [31:0] data;
    wire wren;
    wire [31:0] q_dmem;
    dmem my_dmem(
        .address_a    (address_dmem),       // address of data
        .address_b   (VGA_address_dmem),
        .clock_a     (~clock),                  // may need to invert the clock
        .clock_b    (clock),
        .data_a	    (data),    // data you want to write
        .data_b     (32'b0),
        .wren_a	    (wren),      // write enable
        .wren_b     (1'b0),
        .q_a        (q_dmem),    // data from dmem
        .q_b        (VGA_q_dmem)
    );

    /** REGFILE **/
    wire ctrl_writeEnable;
    wire [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    wire [31:0] data_writeReg, proc_data_in, proc_data_out;
    wire [31:0] data_readRegA, data_readRegB;
    regfile my_regfile(
        ~clock,
        ctrl_writeEnable,
        reset,
        ctrl_writeReg,
        ctrl_readRegA,
        ctrl_readRegB,
        data_writeReg,
        data_readRegA,
        data_readRegB
    );

    /** PROCESSOR **/
    processor my_processor(
        // Control signals
        clock,                          // I: The master clock
        reset,                          // I: A reset signal

        // Imem
        address_imem,                   // O: The address of the data to get from imem
        q_imem,                         // I: The data from imem

        // Dmem
        address_dmem,                   // O: The address of the data to get or put from/to dmem
        proc_data_out,                  // O: The data to write to dmem
        wren,                           // O: Write enable for dmem
        proc_data_in,                   // I: The data from dmem/keyboard

        // Regfile
        ctrl_writeEnable,               // O: Write enable for regfile
        ctrl_writeReg,                  // O: Register to write to in regfile
        ctrl_readRegA,                  // O: Register to read from port A of regfile
        ctrl_readRegB,                  // O: Register to read from port B of regfile
        data_writeReg,                  // O: Data to write to for regfile
        data_readRegA,                  // I: Data from port A of regfile
        data_readRegB                   // I: Data from port B of regfile
		  
		  //test
    );
    
    
    //* This code is George's solution, involving an abstract extension to the DMEM (Virtual Memory)
    //* 4100+ is for loading information from Virtual Memory, 4200+ is for storing information to Virtual Memory
    
    //lw mux
    tri_state32 lw0 ({24'd0, ps2_out}, ~(isKeyboardLoad), proc_data_in);
    
    wire isKeyboardLoad;
    isEqual_32 lw1 (address_dmem, 32'd4100, isKeyboardLoad);
    tri_state32 lw1a ({24'd0, ps2_out}, isKeyboardLoad, proc_data_in);
    
    //sw/lw mux
    tri_state32 sw0a (data, ~(isP0x || isP0y || isP0v), proc_data_out);
    tri_state32 sw0b (data, ~(isP0x || isP0y || isP0v), proc_data_in);
    
    //Characters Data
    reg [31:0] player0_x, player0_y, player0_vel;
    
    wire isP0x;
    isEqual_32 sw1 (address_dmem, 32'd4200, isP0x);
    tri_state32 sw1a (player0_x, isP0x, proc_data_out);
    tri_state32 sw1b (player0_x, isP0x, proc_data_in);
    
    wire isP0y;
    isEqual_32 sw2 (address_dmem, 32'd4201, isP0y);
    tri_state32 sw2a (player0_y, isP0y, proc_data_out);
    tri_state32 sw2b (player0_y, isP0y, proc_data_in);
    
    wire isP0v;
    isEqual_32 sw3 (address_dmem, 32'd4202, isP0v);
    tri_state32 sw3a (player0_vel, isP0v, proc_data_out);
    tri_state32 sw3b (player0_vel, isP0v, proc_data_in);
    
    
    //Player Instantiation
    initial begin
        player0_x = 32'd240;
        player0_y = 32'd240;
        player0_vel = 32'd0;
	end
    


endmodule
