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
                    player0_x, player0_y, player1_x, player1_y, address_dmem, q_dmem,

                     q_imem, 
							upSig, rightSig, downSig, leftSig, upSig2, rightSig2, downSig2, leftSig2,
							reg1, powerup0_x, powerup0_y
					 
					 );
                     
    //test
  
    input clock, reset, ps2_key_pressed;
	 input [7:0]	 ps2_out;	
    input leftSig, rightSig, upSig, downSig, leftSig2, rightSig2, upSig2, downSig2;
	 
	 
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
    output wire [16:0] address_dmem;
	 
    wire [31:0] data;
    wire wren;
    wire real_wren;
    output wire [31:0] q_dmem;
    dmem my_dmem(
        .address  (address_dmem[11:0]),       // address of data
        .clock    (~clock),                   // may need to invert the clock
        .data	   (data),                     // data you want to write
        .wren	   (real_wren),                // write enable
        .q        (q_dmem),                   // data from dmem
    );
    
    assign real_wren = (address_dmem < 17'd4096) ? wren : 1'b0;

    /** REGFILE **/
    wire ctrl_writeEnable;
    wire [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    wire [31:0] data_writeReg;
    wire [31:0] data_readRegA, data_readRegB;
    reg [31:0] proc_data_in;
    
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
    
    
    
    //Player 0 x & y
    output reg [31:0] player0_x, player0_y;
	 
	 
	 //Player 1 x & y
	 output reg [31:0] player1_x, player1_y;
	 
	 
	 //Powerup 0 location
	 output reg [31:0] powerup0_x, powerup0_y;
	 
	 
	 //Powerup memory
	 reg [31:0] powerup0Register, powerup1Register;
	 reg [31:0] powerup0DurationReg, powerup1DurationReg;
	 reg [31:0] powerup0DurationStageReg, powerup1DurationStageReg;
	 
	 
	 //Width and height
	 wire [31:0] width, height;
	 assign width = 32'd32;
	 assign height = 32'd32;
	 
    
	 // PLAYER 0 DEDICATED ADDRESSES
    // 4100 -> Player 0 input
	 // 4200 -> Player 0 x location
	 // 4201 -> Player 0 y Location
	 // 4202 -> Player 0 powerup
	 
	 //PLAYER 1 DEDICATED ADDRESSES
	 // 4101 -> Player 1 input
	 // 4203 -> Player 1 x location
	 // 4204 -> Player 1 y location
	 // 4205 -> Player 1 powerup
    always @(negedge clock) begin
		
       
		  //Default case (not accessing "dedicated" memory)
		  if(address_dmem < 17'd4096) begin
			   proc_data_in <= q_dmem;
		  end
        
        // PLAYER 0 Functionality
        // 1 means up
        else if(address_dmem == 17'd4100 && upSig == 1'b1 && downSig == 1'b0 && leftSig == 1'b0 && rightSig == 1'b0) begin
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

		  
		  
		  //PLAYER 1 Functionality
        // 1 means up
        else if(address_dmem == 17'd4101 && upSig2 == 1'b1 && downSig2 == 1'b0 && leftSig2 == 1'b0 && rightSig2 == 1'b0) begin
            proc_data_in <= 32'd1;
        end
        
        // 2 means right 
        else if (address_dmem == 17'd4101 && upSig2 == 1'b0 && downSig2 == 1'b0 && leftSig2 == 1'b0 && rightSig2 == 1'b1) begin
            proc_data_in <= 32'd2;
        end
        
        // 3 means down
        else if (address_dmem == 17'd4101 && upSig2 == 1'b0 && downSig2 == 1'b1 && leftSig2 == 1'b0 && rightSig2 == 1'b0) begin
            proc_data_in <= 32'd3;
        end
        
        // 4 means left
        else if (address_dmem == 17'd4101 && upSig2 == 1'b0 && downSig2 == 1'b0 && leftSig2 == 1'b1 && rightSig2 == 1'b0) begin
            proc_data_in <= 32'd4;
        end
        
        else if (address_dmem == 17'd4101 && upSig2 == 1'b0 && downSig2 == 1'b0 && leftSig2 == 1'b0 && rightSig2 == 1'b0) begin
            proc_data_in <= 32'd0;
        end

		  
        //PLAYER 0 x, y, & POWERUP Functionality
        else if(address_dmem == 17'd4200 && wren == 1'b0) begin
            proc_data_in <= player0_x;
        end
        
        else if(address_dmem == 17'd4201 && wren == 1'b0) begin
            proc_data_in <= player0_y;
        end
		  
		  else if(address_dmem == 17'd4202 && wren == 1'b0) begin
				proc_data_in <= powerup0Register;
		  end
		  
		  
		  //PLAYER 1 x, y, & POWERUP Functionality
        else if(address_dmem == 17'd4203 && wren == 1'b0) begin
            proc_data_in <= player1_x;
        end
        
        else if(address_dmem == 17'd4204 && wren == 1'b0) begin
            proc_data_in <= player1_y;
        end
		  
		  else if(address_dmem == 17'd4205 && wren == 1'b0) begin
				proc_data_in <= powerup1Register;
		  end
		  

		  
	  
		  //Player 0 collision with Power-Up 0 (super speed)
        if(((player0_x +  width >= powerup0_x && player0_x + width <= powerup0_x + width) || 
			   (player0_x >= powerup0_x && player0_x <= powerup0_x + width)) &&
			  ((player0_y +  height >= powerup0_y && player0_y + height <= powerup0_y + height) ||
			   (player0_y >= powerup0_y && player0_y <= powerup0_y + height))) begin
					powerup0_x <= 32'b11111111111111111111111111111111;
			      powerup0_y <= 32'b11111111111111111111111111111111;
					powerup0Register <= 32'd1;
					
					powerup0DurationStageReg <= 32'd1;
		  end
		  
		  
		  //Player 0 powerup duration
		  if(powerup0DurationStageReg > 32'd0)
				powerup0DurationReg <= powerup0DurationReg + 1;
				
		  if(powerup0DurationReg == 32'd100000000) begin
				powerup0DurationStageReg <= powerup0DurationStageReg + 1;
				powerup0DurationReg <= 32'd0;
		  end
				
		  if(powerup0DurationStageReg == 32'd8) begin
				powerup0DurationStageReg <= 32'd0;
				powerup0DurationReg <= 32'd0;
				powerup0Register <= 32'd0;
		   end
			
			
			//Player 1 collision with Power-Up 0 (super speed)
        if(((player1_x +  width >= powerup0_x && player1_x + width <= powerup0_x + width) || 
			   (player1_x >= powerup0_x && player1_x <= powerup0_x + width)) &&
			  ((player1_y +  height >= powerup0_y && player1_y + height <= powerup0_y + height) ||
			   (player1_y >= powerup0_y && player1_y <= powerup0_y + height))) begin
					powerup0_x <= 32'b11111111111111111111111111111111;
			      powerup0_y <= 32'b11111111111111111111111111111111;
					powerup1Register <= 32'd1;
					
					powerup1DurationStageReg <= 32'd1;
		  end
		  
		  
		  //Player 1 powerup duration
		  if(powerup1DurationStageReg > 32'd0)
				powerup1DurationReg <= powerup1DurationReg + 1;
				
		  if(powerup1DurationReg == 32'd100000000) begin
				powerup1DurationStageReg <= powerup1DurationStageReg + 1;
				powerup1DurationReg <= 32'd0;
		  end
				
		  if(powerup1DurationStageReg == 32'd8) begin
				powerup1DurationStageReg <= 32'd0;
				powerup1DurationReg <= 32'd0;
				powerup1Register <= 32'd0;
		   end		  
    end
	 
	 
	 
	 always @(negedge clock) begin
	 	  if (address_dmem == 17'd4200 && wren == 1'b1) begin
            player0_x <= data;
        end
		  
		  if (address_dmem == 17'd4203 && wren == 1'b1) begin
            player1_x <= data;
        end
	 end
     
	 always @(negedge clock) begin
        if (address_dmem == 17'd4201 && wren == 1'b1) begin
            player0_y <= data;
        end
		  
		  if (address_dmem == 17'd4204 && wren == 1'b1) begin
            player1_y <= data;
        end
	 end
	 
    
    //Player Instantiation
    initial begin
        player0_x <= 32'd240;
        player0_y <= 32'd250;
		  
		  player1_x <= 32'd100;
		  player1_y <= 32'd100;
		  
		  powerup0_x <= 32'd300;
		  powerup0_y <= 32'd300;
		  
		  powerup0Register <= 32'd0;
		  powerup0DurationReg <= 32'd0;
		  powerup0DurationStageReg <= 32'd0;
		  
		  powerup1Register <= 32'd0;
		  powerup1DurationReg <= 32'd0;
		  powerup1DurationStageReg <= 32'd0;
		  
	 end
    



endmodule
