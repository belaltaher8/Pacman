module skeleton(resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	debug_data_in, debug_addr, leds, 						// extra debugging ports
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
    sw0, sw1, sw2, sw3, sw4, sw5, sw6, sw7,              //switches
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50,
    isKeyboardLoad, q_imem, address_dmem, data);  													// 50 MHz clock
		
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
   
	
	// clock divider (by 5, i.e., 10 MHz)
	//pll div(CLOCK_50,inclock);
	assign clock = CLOCK_50;
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	//assign clock = inclock;
	
	// your processor
    output wire isKeyboardLoad;
    output [16:0] address_dmem;
    output [31:0] data, q_imem;
    wire [31:0] player0_x, player0_y, proc_data_in, reg1, reg2;
    
	proc_skeleton myProcSkeleton(
                                 .clock(clock), 
                                 .reset(~resetn), 
                                 .ps2_key_pressed(ps2_key_pressed), 
                                 .ps2_out(ps2_out), 
                                 .player0_x(player0_x), 
                                 .player0_y(player0_y), 
                                 .isKeyboardLoad(isKeyboardLoad), 
                                 .q_imem(q_imem), 
                                 .address_dmem(address_dmem), 
                                 .proc_data_in(proc_data_in),
                                 .upSig(sw1),
                                 .rightSig(sw2),
                                 .downSig(sw3),
                                 .leftSig(sw4),
                                 .reg1(reg1),
                                 .reg2(reg2)
                                 /*lcd_write_en, lcd_write_data, debug_data_in, debug_addr*/
                                 );
	
	// keyboard controller
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
    
	
	// keyboard debouncer
	//wire [7:0] debounced_ps2;
	//ps2_fsm my_ps2_fsm(ps2_key_pressed, clock, ~resetn, ps2_key_data, debounced_ps2);
	
	// lcd controller
	lcd mylcd(clock, ~resetn, 1'b1, player0_x[7:0], lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// example for sending ps2 data to the first two seven segment displays
	Hexadecimal_To_Seven_Segment hex1(reg1[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(reg1[7:4], seg2);
	
	// the other seven segment displays are currently set to 0
	Hexadecimal_To_Seven_Segment hex3(4'b0, seg3);
	Hexadecimal_To_Seven_Segment hex4(4'b0, seg4);
	Hexadecimal_To_Seven_Segment hex5(player0_y[3:0], seg5);
	Hexadecimal_To_Seven_Segment hex6(player0_y[7:4], seg6);
	Hexadecimal_To_Seven_Segment hex7(player0_x[3:0], seg7);
	Hexadecimal_To_Seven_Segment hex8(player0_x[7:4], seg8);
	
	// FPGA LED outputs
	assign leds = {sw7, sw6, sw5, sw4, sw3, sw2, sw1, isKeyboardLoad};
		
	// VGA
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
    
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
    
    wire [11:0] VGA_address;
    wire [31:0] VGA_data;
    
	vga_controller vga_ins(.iRST_n(DLY_RST),
								 .iVGA_CLK(VGA_CLK),
								 .oBLANK_n(VGA_BLANK),
								 .oHS(VGA_HS),
								 .oVS(VGA_VS),
								 .b_data(VGA_B),
								 .g_data(VGA_G),
								 .r_data(VGA_R),
                                 .ps2_key_data_in(ps2_key_data),
                                 .player0_x(player0_x), 
                                 .player0_y(player0_y)
                                 );
	
	
endmodule