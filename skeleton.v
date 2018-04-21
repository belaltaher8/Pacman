module skeleton(resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	debug_data_in, debug_addr, leds, 						// extra debugging ports
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
   sw0, sw1, sw2, sw3, sw4, sw5, sw6, sw7,              //switches
	ButtonNE, ButtonNW, ButtonSE, ButtonSW,				//buttons
	JoyN, JoyS, JoyE, JoyW,										//joystick
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50);  													// 50 MHz clock
		
	////////////////////////	VGA	////////////////////////////
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	input				CLOCK_50;

	////////////////////////	PS2	////////////////////////////
	input 			resetn;
	inout 			ps2_data, ps2_clock;
	
	////////////////////////	LCD and Seven Segment	////////////////////////////
	output 			   lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_data_in;
	output   [11:0]   debug_addr;
	
	
	wire			 clock;
	wire			 lcd_write_en;
	wire 	[31:0] lcd_write_data;
	wire	[7:0]	 ps2_key_data;
	wire			 ps2_key_pressed;
	wire	[7:0]	 ps2_out;	
    
    ////////////////////////    Switches     //////////////////////////
    input sw0, sw1, sw2, sw3, sw4, sw5, sw6, sw7;
   
	///////////////////////// Game Controller //////////////////////////////
	input ButtonNE, ButtonNW, ButtonSE, ButtonSW, JoyN, JoyS, JoyE, JoyW;
	reg [1:0] player0_direction;
	
	// clock divider (by 5, i.e., 10 MHz)
	//pll div(CLOCK_50,inclock);
	assign clock = CLOCK_50;
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	//assign clock = inclock;
	
	// your processor
    wire [31:0] player0_x, player0_y, player1_x, player1_y, reg1, powerup0_x, powerup0_y, powerup1_x, powerup1_y, powerup1_playerXRegister, reg13;
	 wire [16:0] address_dmem;
	 wire [31:0] q_dmem;
	 wire player0_collisionUp, player0_collisionRight, player0_collisionLeft, player0_collisionDown;
	 wire player1_collisionUp, player1_collisionRight, player1_collisionLeft, player1_collisionDown;


	 
	proc_skeleton myProcSkeleton(
                                 .clock(clock), 
                                 .reset(~resetn), 
                                 .ps2_key_pressed(ps2_key_pressed), 
                                 .ps2_out(ps2_out), 
                                 .player0_x(player0_x), 
                                 .player0_y(player0_y), 
											.player1_x(player1_x),
											.player1_y(player1_y),
                                 .upSig(JoyN),
											.address_dmem(address_dmem),
										 	.q_dmem(q_dmem),
                                 .rightSig(JoyE),
                                 .downSig(JoyS),
                                 .leftSig(JoyW),
											.upSig2(sw4),
											.rightSig2(sw5),
											.downSig2(sw6),
											.leftSig2(sw7),
                                 .reg1(reg1),
											.reg13(reg13),
											.powerup0_x(powerup0_x), .powerup0_y(powerup0_y),
											.powerup1_x(powerup1_x), .powerup1_y(powerup1_y),
											.powerup1_playerXRegister(powerup1_playerXRegister),
											.player0_collisionUp(player0_collisionUp),
											.player0_collisionDown(player0_collisionDown),
											.player0_collisionRight(player0_collisionRight),
											.player0_collisionLeft(player0_collisionLeft),
											.pauseButton(ButtonSE),
											.player1_collisionUp(player1_collisionUp),
											.player1_collisionDown(player1_collisionDown),
											.player1_collisionRight(player1_collisionRight),
											.player1_collisionLeft(player1_collisionLeft),
											.screenReg(screenReg)
                                 );
	
	initial begin
	player0_direction <= 2'b00;
	end
	
	always @(JoyN, JoyE, JoyW, JoyS) begin
		if (JoyE == 1) player0_direction <= 2'b00;
		else if (JoyS == 1) player0_direction <= 2'b01;
		else if (JoyW == 1) player0_direction <= 2'b10;
		else if (JoyN == 1) player0_direction <= 2'b11;
	end
	
	// keyboard controller
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
    
	
	// keyboard debouncer
	//wire [7:0] debounced_ps2;
	//ps2_fsm my_ps2_fsm(ps2_key_pressed, clock, ~resetn, ps2_key_data, debounced_ps2);
	
	// lcd controller
	lcd mylcd(clock, ~resetn, 1'b1, player0_x[7:0], lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	

	
	// example for sending ps2 data to the first two seven segment displays
	Hexadecimal_To_Seven_Segment hex1({1'b0, 1'b0, 1'b0, player0_collisionUp}, seg1);
	Hexadecimal_To_Seven_Segment hex2(4'b0, seg2);
	
	// the other seven segment displays are currently set to 0
	Hexadecimal_To_Seven_Segment hex3(4'b0, seg3);
	Hexadecimal_To_Seven_Segment hex4(4'b0, seg4);
	Hexadecimal_To_Seven_Segment hex5(4'b0, seg5);
	Hexadecimal_To_Seven_Segment hex6(4'b0, seg6);
	Hexadecimal_To_Seven_Segment hex7(4'b0, seg7);
	Hexadecimal_To_Seven_Segment hex8(4'b0, seg8);
	
	// FPGA LED outputs
	assign leds = {ButtonNE, ButtonNW, ButtonSE, ButtonSW, JoyN, JoyS, JoyE, player0_collisionUp};
		
	// VGA
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
    
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
    
    wire [11:0] VGA_address;
    wire [31:0] VGA_data;
	 wire [2:0] screenReg;
    
	vga_controller vga_ins(.iRST_n(DLY_RST), .procClock(clock),
								 .iVGA_CLK(VGA_CLK),
								 .oBLANK_n(VGA_BLANK),
								 .oHS(VGA_HS),
								 .oVS(VGA_VS),
								 .b_data(VGA_B),
								 .g_data(VGA_G),
								 .r_data(VGA_R),
                                 .ps2_key_data_in(ps2_key_data),
                                 .player0_x(player0_x), 
                                 .player0_y(player0_y), .powerup0_x(powerup0_x), .powerup0_y(powerup0_y), 
											.powerup1_x(powerup1_x), .powerup1_y(powerup1_y),
											.player1_x(player1_x),
											.player1_y(player1_y),
											.powerup1_playerXRegister(powerup1_playerXRegister),
											.player0_collisionUp(player0_collisionUp),
											.player0_collisionDown(player0_collisionDown),
											.player0_collisionRight(player0_collisionRight),
											.player0_collisionLeft(player0_collisionLeft),
											.player1_collisionUp(player1_collisionUp),
											.player1_collisionDown(player1_collisionDown),
											.player1_collisionRight(player1_collisionRight),
											.player1_collisionLeft(player1_collisionLeft),
											.screenReg(screenReg),
											.player0_direction(player0_direction)
                                 );
	
	
endmodule