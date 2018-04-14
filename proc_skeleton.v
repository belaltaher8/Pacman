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

module proc_skeleton(clock, reset, ps2_key_pressed, ps2_out,
                    player0_x, player0_y,
                    //address_imem, q_imem, address_dmem, data, wren, q_dmem, ctrl_writeEnable, ctrl_writeReg, ctrl_readRegA, 
					//ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB
                    //test
                     isKeyboardLoad, q_imem, address_dmem, proc_data_in, upSig, rightSig, downSig, leftSig, reg1, powerup0_x, powerup0_y
					 
					 );
                     
    //test
  
    input clock, reset, ps2_key_pressed;
	 input [7:0]	 ps2_out;	
    input leftSig, rightSig, upSig, downSig;
	 
	 
    /** IMEM **/
    wire [11:0] address_imem;
    output [31:0] q_imem;
    imem my_imem(
        .address    (address_imem),            // address of data
        .clock      (~clock),                  // you may need to invert the clock
        .q          (q_imem),                  // the raw instruction
		  .clken      (1'b1)
    );

    /** DMEM **/
    output [16:0] address_dmem;
    wire [31:0] data;
    wire wren;
    wire real_wren;
    wire [31:0] q_dmem;
    dmem my_dmem(
        .address_a  (address_dmem[11:0]),       // address of data
        .address_b  (12'd0),
        .clock_a    (~clock),                  // may need to invert the clock
        .clock_b    (clock),
        .data_a	  (data),    // data you want to write
        .data_b     (32'b0),
        .wren_a	  (real_wren),      // write enable
        .wren_b     (1'b0),
        .q_a        (q_dmem),    // data from dmem
        .q_b        ()
    );
    
    assign real_wren = (address_dmem < 17'd4096) ? wren : 1'b0;

    /** REGFILE **/
    wire ctrl_writeEnable;
    wire [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    wire [31:0] data_writeReg;
    wire [31:0] data_readRegA, data_readRegB;
    output reg [31:0] proc_data_in;
    
    output [31:0] reg1;
    
    regfile my_regfile(
        ~clock,
        ctrl_writeEnable,
        reset,
        ctrl_writeReg,
        ctrl_readRegA,
        ctrl_readRegB,
        data_writeReg,
        data_readRegA,
        data_readRegB, reg1
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
        data,                           // O: The data to write to dmem
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
    
    
    //Characters Data
    output reg [31:0] player0_x, player0_y; 
	 output reg [31:0] powerup0_x, powerup0_y;
	 reg [31:0] powerupRegister;
	 
	 wire [31:0] width, height;
	 assign width = 32'd32;
	 assign height = 32'd32;
	 
	 
	 
	// reg [31:0] highestStartPoint;
	// reg [31:0] lowestEndPoint;
	 
    output reg isKeyboardLoad;
    
    // On positive edge of the clock cycle
    always @(negedge clock) begin
       
        
        
        // 1 means up
        if(address_dmem == 17'd4100 && upSig == 1'b1 && downSig == 1'b0 && leftSig == 1'b0 && rightSig == 1'b0) begin
            proc_data_in <= 32'd1;
        end
        
        // 2 means right 
        else if (address_dmem == 17'd4100 && upSig == 1'b0 && downSig == 1'b0 && leftSig == 1'b0 && rightSig == 1'b1) begin
            proc_data_in <= 32'd2;
        end
        
        // 3 means down
        else if (address_dmem == 17'd4100 && upSig == 1'b0 && downSig == 1'b1 && leftSig == 1'b0 && rightSig == 1'b0) begin
            proc_data_in <= 32'd3;
        end
        
        // 4 means left
        else if (address_dmem == 17'd4100 && upSig == 1'b0 && downSig == 1'b0 && leftSig == 1'b1 && rightSig == 1'b0) begin
            proc_data_in <= 32'd4;
        end
        
        else if (address_dmem == 17'd4100 && upSig == 1'b0 && downSig == 1'b0 && leftSig == 1'b0 && rightSig == 1'b0) begin
            proc_data_in <= 32'd0;
        end
        
        else if(address_dmem == 17'd4200 && wren == 1'b0) begin
            proc_data_in <= player0_x;
        end
        
        else if(address_dmem == 17'd4201 && wren == 1'b0) begin
            proc_data_in <= player0_y;
        end
		  
		  else if(address_dmem == 17'd4203 && wren == 1'b0) begin
				proc_data_in <= powerupRegister;
		  end
	  
		  //Collision with powerup0
        if(((player0_x +  width >= powerup0_x && player0_x + width <= powerup0_x + width) || 
			   (player0_x >= powerup0_x && player0_x <= powerup0_x + width)) &&
			  ((player0_y +  height >= powerup0_y && player0_y + height <= powerup0_y + height) ||
			   (player0_y >= powerup0_y && player0_y <= powerup0_y + height))) begin
					powerup0_x <= 32'b11111111111111111111111111111111;
			      powerup0_y <= 32'b11111111111111111111111111111111;
					powerupRegister <= 32'd1;
		  end
    end
	 
	 
	 
	 always @(negedge clock) begin
	 	  if (address_dmem == 17'd4200 && wren == 1'b1) begin
            player0_x <= data;
        end
	 end
     
	 always @(negedge clock) begin
        if (address_dmem == 17'd4201 && wren == 1'b1) begin
            player0_y <= data;
        end
	 end
	 
    
    //Player Instantiation
    initial begin
        player0_x <= 32'd240;
        player0_y <= 32'd240;
		  
		  powerup0_x <= 32'd300;
		  powerup0_y <= 32'd300;
		  
		  powerupRegister <= 32'd0;
		  
        isKeyboardLoad = 1'b0;
	 end
    



endmodule
