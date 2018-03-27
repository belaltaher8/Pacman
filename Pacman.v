module Pacman(resetn, ps2_clock, ps2_data, CLOCK_50);


	// clock 
	input CLOCK_50;
	wire clock;
	assign clock = CLOCK_50;
	
	
	// PS2 I/O
	input 		 resetn;
	inout 		 ps2_data, ps2_clock; 
	wire	[7:0]	 ps2_key_data;
	wire			 ps2_key_pressed;
	wire	[7:0]	 ps2_out;	
	
	
	// Keyboard controller
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	
	
	
	
	
endmodule