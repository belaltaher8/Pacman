module vga_controller(iRST_n, procClock,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
                      ps2_key_data_in,
                      player0_x, player0_y, player1_x, player1_y, powerup0_x, powerup0_y, powerup1_x, powerup1_y, powerup1_playerXRegister,
							 player0_collisionUp, player0_collisionDown, player0_collisionRight, player0_collisionLeft,
							 player1_collisionUp, player1_collisionDown, player1_collisionRight, player1_collisionLeft, screenReg,
							 player0_direction, player1_direction,
							 player0_dead, player1_dead, gameplay, pacman_mouth);


input [7:0] ps2_key_data_in;
input procClock;

input [31:0] player0_x, player0_y, player1_x, player1_y;
input [31:0] powerup0_x, powerup0_y, powerup1_x, powerup1_y, powerup1_playerXRegister;
input [1:0] player0_direction, player1_direction;
input player0_dead, player1_dead;

input gameplay;

reg [9:0] scoreRegPlayer0;
output reg [1:0] screenReg;


input iRST_n;
input iVGA_CLK;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////      
reg firstRow;
reg secondRow;
               
reg [12:0] ADDRinScorePlayer0Digit0, ADDRinScorePlayer0Digit1, ADDRinScorePlayer0Digit2, player0Digit0Offset, player0Digit1Offset, player0Digit2Offset;

wire inScorePlayer0Digit0, inScorePlayer0Digit1, inSCorePlayer0Digit2;

assign inScorePlayer0Digit2 = (xADDRToCompare >= 1 && xADDRToCompare <= 30 && yADDRToCompare >= 60 && yADDRToCompare <= 82) ? 1'b1: 1'b0;
assign inScorePlayer0Digit1 = (xADDRToCompare >= 31 && xADDRToCompare <= 60 && yADDRToCompare >= 60 && yADDRToCompare <= 82) ? 1'b1: 1'b0;
assign inScorePlayer0Digit0 = (xADDRToCompare >= 61 && xADDRToCompare <= 90 && yADDRToCompare >= 60 && yADDRToCompare <= 82) ? 1'b1: 1'b0;


reg [12:0] ADDRinScorePlayer1; 

reg inScorePlayer1;
				
reg [18:0] ADDR;
reg [18:0] realADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
reg  [23:0] color;
wire cBLANK_n,cHS,cVS,rst;

wire [7:0] startscreen_ind;
wire [23:0] ss_data_raw;

wire [23:0] pacman_data_raw;
wire [7:0] pacman_or, pacman_ol, pacman_ou, pacman_od, pacman_cr, pacman_cl, pacman_cu, pacman_cd, pacman_d0, pacman_d1, pacman_d2, pacman_d3, pacman_d4, pacman_d5, pacman_d6;
reg [7:0] pacman_ind;
reg [9:0] pacman_addr;
output reg pacman_mouth;

wire [23:0] pacman_data_raw1;
wire [7:0] pacman_or1, pacman_ol1, pacman_ou1, pacman_od1, pacman_cr1, pacman_cl1, pacman_cu1, pacman_cd1;
reg [7:0] pacman_ind1;
reg [9:0] pacman_addr1;

wire [23:0] blue_data_raw;
wire [7:0] blue_NE, blue_NW, blue_SE, blue_SW;
reg [7:0] blue_ind;
reg [9:0] blue_addr;

wire [23:0] red_data_raw;
wire [7:0] red_NE, red_NW, red_SE, red_SW;
reg [7:0] red_ind;
reg [9:0] red_addr;

wire [23:0] orange_data_raw;
wire [7:0] orange_NE, orange_NW, orange_SE, orange_SW;
reg [7:0] orange_ind;
reg [9:0] orange_addr;

wire [23:0] pink_data_raw;
wire [7:0] pink_NE, pink_NW, pink_SE, pink_SW;
reg [7:0] pink_ind;
reg [9:0] pink_addr;

////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin

  if (!iRST_n) begin
	  realADDR <= 19'd0;
     ADDR <= 19'd0;
	  
	  firstRow <= 1'b1;
	  secondRow <= 1'b0;
	  
	  ADDRinScorePlayer0Digit0 <= 13'd0;
	  ADDRinScorePlayer0Digit1 <= 13'd0;
	  ADDRinScorePlayer0Digit2 <= 13'd0;
	  
  end
  
  else if (cHS==1'b0 && cVS==1'b0) begin
     realADDR <= 19'd0;
	  ADDR <= 19'd0;
	  
	  firstRow <= 1'b0;
	  secondRow <= 1'b1;
	  
	  ADDRinScorePlayer0Digit0 <= 13'd0;
	  ADDRinScorePlayer0Digit1 <= 13'd0;
	  ADDRinScorePlayer0Digit2 <= 13'd0;
  end
  
  else if (cBLANK_n==1'b1) begin
     ADDR <= ADDR+1;
	  
	  if(ADDR % 640 == 0 && firstRow == 0 && secondRow == 1) begin
			secondRow <= 0;
			firstRow <= 1;
	  end
	  
	  else if(ADDR % 640 == 0 && firstRow == 1 && secondRow == 0) begin
			secondRow <= 1;
			firstRow <= 0;
	  end
	  
	  if(ADDR % 2 == 1 && firstRow == 1 && secondRow == 0) begin
			realADDR <= ADDR - 1;
	  end
	  
	  else if(ADDR % 2 == 1 && firstRow == 0 && secondRow == 1) begin
	      realADDR <= ADDR - 641;
	  end
	  
	  else if(ADDR % 2 == 0 && firstRow == 0 && secondRow == 1) begin
			realADDR <= ADDR - 640;
	  end
	  
	  else if(ADDR % 2 == 0 && firstRow == 1 && secondRow == 0) begin
			realADDR <= ADDR;
	  end
	  
	  if(inScorePlayer0Digit0 == 1'b1)
			ADDRinScorePlayer0Digit0 <= ADDRinScorePlayer0Digit0 + 1;
		
	  if(inScorePlayer0Digit1 == 1'b1)
			ADDRinScorePlayer0Digit1 <= ADDRinScorePlayer0Digit1 + 1;
			
	  if(inScorePlayer0Digit2 == 1'b1)
			ADDRinScorePlayer0Digit2 <= ADDRinScorePlayer0Digit2 + 1;
			
			
	end
	
  	
  
end










//Creates register for the block and initializes value
reg [9:0] xLoc0;
reg [8:0] yLoc0;

reg [9:0] xLoc1;
reg [8:0] yLoc1;

reg [9:0] xLocG0;
reg [8:0] yLocG0;

reg [9:0] xLocG1;
reg [8:0] yLocG1;

reg [9:0] xLocG2;
reg [8:0] yLocG2;

reg [9:0] xLocG3;
reg [8:0] yLocG3;

reg [9:0] width;
reg [8:0] height;
wire [9:0] xADDR;
wire [8:0] yADDR; 
reg [9:0] xADDRToCompare;
reg [8:0] yADDRToCompare;

reg [9:0] powerup0xLocToRender;
reg [8:0] powerup0yLocToRender; 

reg [9:0] powerup1xLocToRender;
reg [8:0] powerup1yLocToRender;

reg [31:0] clockCounter;

reg [32:0] pacman_counter;
reg [25:0] player0_deathCount;
reg [25:0] player1_deathCount;


reg pinkSig1, pinkSig2, pinkSig3, pinkSig4;
reg [19:0] pinkCounter;

initial begin
    xLoc0 <= 10'b0000000000;
    yLoc0 <=  9'b000000000;
	 	 
    xLoc1 <= 10'b0000000000;
    yLoc1 <=  9'b000000000;
	 
	 xLocG0 <= 10'd108;
    yLocG0 <=  9'd20;
	 
	 xLocG1 <= 10'd108;
    yLocG1 <=  9'd408;
	 
	 xLocG2 <= 10'd186;
    yLocG2 <=  9'd72;
	 
	 xLocG3 <= 10'd508;
    yLocG3 <=  9'd412;
    
    width <=  10'd24;
    height <=  9'd24;
	 
	 pinkSig1 <= 1;
	 pinkSig2 <= 0;
	 pinkSig3 <= 0;
	 pinkSig4 <= 0;
	 pinkCounter <= 0;
	 
	 
	 powerup0xLocToRender <= 10'b0000000000;
	 powerup0yLocToRender <=  9'b000000000;
	 
	 powerup1xLocToRender <= 10'd0;
	 powerup1yLocToRender <=  9'd0;
	 
	 scoreRegPlayer0 <= 8'd0;
    screenReg <= 2'd0;
	 
	 pacman_mouth <= 1'b0;
	 pacman_counter <= 0;
	 
	 player0_deathCount <= 26'd0;
	 player1_deathCount <= 26'd0;
    
end

addrConverter myAddrConverterPlayer0(ADDR, VGA_CLK_n, xADDR, yADDR);

 always@(posedge VGA_CLK_n) begin
 
    //Updates player 0 location
    xLoc0 <= player0_x[9:0];
    yLoc0 <= player0_y[8:0];
	 
	 //Updates player 1 location
	 xLoc1 <= player1_x[9:0];
	 yLoc1 <= player1_y[8:0];
	 
	 //Updates Ghost 0 location
//    xLocG0 <= ;
//    yLocG0 <= ;

	 //Updates Ghost 1 location
//    xLocG1 <= ;
//    yLocG1 <= ;

	 //Updates Ghost 2 location
//    xLocG2 <= ;
//    yLocG2 <= ;

	 //Updates Ghost 3 location
//    xLocG3 <= ;
//    yLocG3 <= ;
		  
	 //Updates powerup 0 location	  
    powerup0xLocToRender <= powerup0_x[9:0];
	 powerup0yLocToRender <= powerup0_y[8:0];
	 
	 ///Updates powerup 1 location
	 powerup1xLocToRender <= powerup1_x[9:0];
	 powerup1yLocToRender <= powerup1_y[8:0];

 
 
    xADDRToCompare <= xADDR;
    yADDRToCompare <= yADDR;
    
	 if (gameplay == 1'b1) begin
	 
		 if((xADDRToCompare > xLoc0) && (xADDRToCompare < xLoc0 + width) && (yADDRToCompare > yLoc0) && (yADDRToCompare < yLoc0 + height) )
			  color <= pacman_data_raw;
			  
		 else if((xADDRToCompare > powerup0xLocToRender) && (xADDRToCompare < powerup0xLocToRender + width) && (yADDRToCompare > powerup0yLocToRender) && (yADDRToCompare < powerup0yLocToRender + height) )
			  color <= 23'b000000001111111100000000;
			  
		 else if((xADDRToCompare > xLoc1) && (xADDRToCompare < xLoc1 + width) && (yADDRToCompare > yLoc1) && (yADDRToCompare < yLoc1 + height) )	  
			  color <= pacman_data_raw1;
			  
		 else if((xADDRToCompare > powerup1xLocToRender) && (xADDRToCompare < powerup1xLocToRender + width) && (yADDRToCompare > powerup1yLocToRender) && (yADDRToCompare < powerup1yLocToRender + height) )
			  color <= 23'b111111110000000011111111;
		
		 else if((xADDRToCompare > xLocG0) && (xADDRToCompare < xLocG0 + width) && (yADDRToCompare > yLocG0) && (yADDRToCompare < yLocG0 + height) )	  
			  color <= blue_data_raw;
			  
		 else if((xADDRToCompare > xLocG1) && (xADDRToCompare < xLocG1 + width) && (yADDRToCompare > yLocG1) && (yADDRToCompare < yLocG1 + height) )	  
			  color <= red_data_raw;
		 
		 else if((xADDRToCompare > xLocG2) && (xADDRToCompare < xLocG2 + width) && (yADDRToCompare > yLocG2) && (yADDRToCompare < yLocG2 + height) )	  
			  color <= orange_data_raw;
			 
		 else if((xADDRToCompare > xLocG3) && (xADDRToCompare < xLocG3 + width) && (yADDRToCompare > yLocG3) && (yADDRToCompare < yLocG3 + height) )	  
			  color <= pink_data_raw;
			  
		 else if(powerup1_playerXRegister == 32'd1 && inScorePlayer0Digit0 != 1'b1 && inScorePlayer0Digit1 != 1'b1 && inScorePlayer0Digit2 != 1'b1)
			  color <= 23'b000000000000000000000000;  
		 else if(inScorePlayer0Digit0 == 1'b1)
			  color <= score_data_rawDigit0;
			  
		 else if(inScorePlayer0Digit1 == 1'b1)
			  color <= score_data_rawDigit1;
			  
		 else if(inScorePlayer0Digit2 == 1'b1)
			  color <= score_data_rawDigit2;
			  
		 else 
			  color <= bgr_data_raw;
	 
	 end
	 else begin
	 
		color <= ss_data_raw;
		  
	end
		 
	 

end

output reg player0_collisionUp, player0_collisionDown, player0_collisionRight, player0_collisionLeft, player1_collisionUp, player1_collisionDown, player1_collisionRight, player1_collisionLeft;


reg upCollisionFlag0, downCollisionFlag0, rightCollisionFlag0, leftCollisionFlag0;
reg upCollisionFlag1, downCollisionFlag1, rightCollisionFlag1, leftCollisionFlag1;



//COLLISION FLAGS

always@(posedge procClock) begin


	 //Player 0 UP COLLISIONS
	 if(bgr_data_raw == 24'hFF3844 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 - 1)) begin
		  player0_collisionUp <= 1'b1;
		  upCollisionFlag0 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF3844 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 - 1) && upCollisionFlag0 == 1'b0)
		  player0_collisionUp <= 1'b0;
		  
	 else if(xADDRToCompare > xLoc0 + width + 1)
		  upCollisionFlag0 <= 1'b0;
		
		
	 //Player 0 DOWN COLLISIONS	
	 if(bgr_data_raw == 24'hFF3844 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 + height + 1)) begin
		  player0_collisionDown <= 1'b1;
		  downCollisionFlag0 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF3844 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 + height + 1) && downCollisionFlag0 == 1'b0) begin
		  player0_collisionDown <= 1'b0;
	 end
		  
	 else if(xADDRToCompare > xLoc0 + width + 1)
		  downCollisionFlag0 <= 1'b0;
		
		
	//Player 0 RIGHT COLLISIONS
	if(bgr_data_raw == 24'hFF3844 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 + width + 1))begin
			player0_collisionRight <= 1'b1;
			rightCollisionFlag0 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF3844 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 + width + 1) && rightCollisionFlag0 == 1'b0)
		   player0_collisionRight <= 1'b0;
			
	else if(yADDRToCompare > yLoc0 + height + 1)
			rightCollisionFlag0 <= 1'b0;
	
	
	//Player 0 LEFT COLLISIONS
	if(bgr_data_raw == 24'hFF3844 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 - 1))begin
			player0_collisionLeft <= 1'b1;
			leftCollisionFlag0 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF3844 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 - 1) && leftCollisionFlag0 == 1'b0)
		   player0_collisionLeft <= 1'b0;
			
	else if(yADDRToCompare > yLoc0 + height + 1)
			leftCollisionFlag0 <= 1'b0;
			
			
			
			
			
	 //Player 1 UP COLLISIONS
	 if(bgr_data_raw == 24'hFF3844 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 - 1)) begin
		  player1_collisionUp <= 1'b1;
		  upCollisionFlag1 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF3844 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 - 1) && upCollisionFlag1 == 1'b0)
		  player1_collisionUp <= 1'b0;
		  
	 else if(xADDRToCompare > xLoc1 + width + 1)
		  upCollisionFlag1 <= 1'b0;
		
		
		
	 //Player 1 DOWN COLLISIONS	
	 if(bgr_data_raw == 24'hFF3844 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 + height + 1)) begin
		  player1_collisionDown <= 1'b1;
		  downCollisionFlag1 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF3844 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 + height + 1) && downCollisionFlag1 == 1'b0) begin
		  player1_collisionDown <= 1'b0;
	 end
		  
	 else if(xADDRToCompare > xLoc1 + width + 1)
		  downCollisionFlag1 <= 1'b0;
		
		
		
	//Player 1 RIGHT COLLISIONS
	if(bgr_data_raw == 24'hFF3844 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 + width + 1))begin
			player1_collisionRight <= 1'b1;
			rightCollisionFlag1 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF3844 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 + width + 1) && rightCollisionFlag1 == 1'b0)
		   player1_collisionRight <= 1'b0;
			
	else if(yADDRToCompare > yLoc1 + height + 1)
			rightCollisionFlag1 <= 1'b0;
	
	
	//Player 1 LEFT COLLISIONS
	if(bgr_data_raw == 24'hFF3844 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 - 1))begin
			player1_collisionLeft <= 1'b1;
			leftCollisionFlag1 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF3844 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 - 1) && leftCollisionFlag1 == 1'b0)
		   player1_collisionLeft <= 1'b0;
			
	else if(yADDRToCompare > yLoc1 + height + 1)
			leftCollisionFlag1 <= 1'b0;
			
			
	//Player 0 Pellet Collisions
	/*if(bgr_data_raw == 24'h9BFFFF && (yADDRToCompare > yLoc0 && yADDRToCompare < yLoc0 + height) && (xADDRToCompare > xLoc0 && xADDRToCompare < xLoc0 + width))
		scoreRegPlayer0 <= scoreRegPlayer0 + 1;*/
		
	player0Digit0Offset <= scoreRegPlayer0 % 10;
	player0Digit1Offset <= (scoreRegPlayer0 % 100) / 10;
	player0Digit2Offset <= scoreRegPlayer0 / 100;
	
/*	
	pinkCounter <= pinkCounter + 1;

	if(pinkCounter == 0 && pinkSig1 == 1)
		xLocG2 = xLocG2+1;
	else if(pinkCounter == 0 && pinkSig2 == 1)
		yLocG2 = yLocG2 + 1;
	else if(pinkCounter == 0 && pinkSig3 == 1)
		xLocG2 = xLocG2-1;
	else if(pinkCounter == 0 && pinkSig4 == 1)
		yLocG2 = yLocG2 - 1;
		
	if(xLocG2 == 429 && yLocG2 == 72) begin
		pinkSig1 <= 0;
		pinkSig2 <= 1;
	end
	
	else if(xLocG2 == 429 && yLocG2 == 326) begin
		pinkSig2 <= 0;
		pinkSig3 <= 1;
	end
	
	else if(xLocG2 == 186 && yLocG2 == 326) begin
		pinkSig3 <= 0;
		pinkSig4 <= 1;
	end
	
	else if(xLocG2 == 186 && yLocG2 == 72) begin
		pinkSig1 <= 1;
		pinkSig4 <= 0;
	end*/
		
		
end
	


	
	
	
	
	
assign VGA_CLK_n = ~iVGA_CLK;

bgr_pixel_data	img_data_inst (
	.aclr(1'b0),
	.address_a ( ADDR ),
	.address_b (4'd0),
	.clock ( VGA_CLK_n ),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.q_a ( index ),
	.q_b ()
	);	

bgr_color_data img_index_inst (
	.aclr(1'b0),
	.address_a ( index ),
	.address_b (4'd0),
	.clock ( iVGA_CLK ),
	.rden_a (1'b1),
	.rden_b (1'b1),
	.q_a ( bgr_data_raw),
	.q_b ()
	);	

start_screen	ss (
	.aclr(1'b0),
	.address_a ( ADDR ),
	.address_b (4'd0),
	.clock ( VGA_CLK_n ),
	.rden_a(1'b1),
	.rden_b(1'b1),
	.q_a ( startscreen_ind ),
	.q_b ()
	);	

startscreen_index ssi (
	.aclr(1'b0),
	.address_a ( startscreen_ind ),
	.address_b (4'd0),
	.clock ( iVGA_CLK ),
	.rden_a (1'b1),
	.rden_b (1'b1),
	.q_a ( ss_data_raw),
	.q_b ()
	);	
	
wire [1:0] scoreWirePlayer0Digit0;
wire [23:0] score_data_rawDigit0;
	
digits_image_data scoreRenderer (
	.address(ADDRinScorePlayer0Digit0 + player0Digit0Offset * 638),
	.clock(VGA_CLK_n),
	.q(scoreWirePlayer0Digit0)
	);
	
digits_color_data scoreRenderer2 (
	.address(scoreWirePlayer0Digit0),
	.clock(iVGA_CLK),
	.q(score_data_rawDigit0)
	);
	
wire [1:0] scoreWirePlayer0Digit1;
wire [23:0] score_data_rawDigit1;
	
digits_image_data scoreRenderer3 (
	.address(ADDRinScorePlayer0Digit1 + player0Digit1Offset * 638),
	.clock(VGA_CLK_n),
	.q(scoreWirePlayer0Digit1)
	);
	
digits_color_data scoreRenderer4 (
	.address(scoreWirePlayer0Digit1),
	.clock(iVGA_CLK),
	.q(score_data_rawDigit1)
	);
	
wire [1:0] scoreWirePlayer0Digit2;
wire [23:0] score_data_rawDigit2;
	
digits_image_data scoreRenderer5 (
	.address(ADDRinScorePlayer0Digit2 + player0Digit2Offset * 638),
	.clock(VGA_CLK_n),
	.q(scoreWirePlayer0Digit2)
	);
	
digits_color_data scoreRenderer6 (
	.address(scoreWirePlayer0Digit2),
	.clock(iVGA_CLK),
	.q(score_data_rawDigit2)
	);


//////Pacman Player 0 VGA Shite
pacman_open_eye_right	poer (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_or )
	);
pacman_open_eye_up	poeu (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_ou )
	);
pacman_open_eye_left	poel (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_ol )
	);
pacman_open_eye_down	poed (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_od )
	);
pacman_closed_eye_right	pcer (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_cr )
	);
pacman_closed_eye_up	pceu (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_cu )
	);
pacman_closed_eye_left	pcel (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_cl )
	);
pacman_closed_eye_down	pced (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_cd )
	);
pacman_die0	pd0 (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_d0 )
	);
pacman_die1	pd1 (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_d1 )
	);
pacman_die2	pd2 (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_d2 )
	);
pacman_die3	pd3 (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_d3 )
	);
pacman_die4	pd4 (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_d4 )
	);
pacman_die5	pd5 (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_d5 )
	);
pacman_die6	pd6 (
	.address ( pacman_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_d6 )
	);
//////Color table output
pacman_index	pi (
	.address ( pacman_ind ),
	.clock ( iVGA_CLK ),
	.q ( pacman_data_raw)
	);	
//////

//////Pacman Player 1 VGA Shite
mspacman_open_eye_right	poer1 (
	.address ( pacman_addr1 ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_or1 )
	);
mspacman_open_eye_up	poeu1 (
	.address ( pacman_addr1 ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_ou1 )
	);
mspacman_open_eye_left	poel1 (
	.address ( pacman_addr1 ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_ol1 )
	);
mspacman_open_eye_down	poed1 (
	.address ( pacman_addr1 ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_od1 )
	);
mspacman_closed_eye_right	pcer1 (
	.address ( pacman_addr1 ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_cr1 )
	);
mspacman_closed_eye_up	pceu1 (
	.address ( pacman_addr1 ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_cu1 )
	);
mspacman_closed_eye_left	pcel1 (
	.address ( pacman_addr1 ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_cl1 )
	);
mspacman_closed_eye_down	pced1 (
	.address ( pacman_addr1 ),
	.clock ( VGA_CLK_n ),
	.q ( pacman_cd1 )
	);
//////Color table output
mspacman_index	pi1 (
	.address ( pacman_ind1 ),
	.clock ( iVGA_CLK ),
	.q ( pacman_data_raw1)
	);	
//////

//////Blue Ghost VGA Shite (0)
ghost_NE	bne (
	.address ( blue_addr ),
	.clock ( VGA_CLK_n ),
	.q ( blue_NE )
	);
ghost_NW	bnw (
	.address ( blue_addr ),
	.clock ( VGA_CLK_n ),
	.q ( blue_NW )
	);
ghost_SE	bse (
	.address ( blue_addr ),
	.clock ( VGA_CLK_n ),
	.q ( blue_SE )
	);
ghost_SW	bsw (
	.address ( blue_addr ),
	.clock ( VGA_CLK_n ),
	.q ( blue_SW )
	);
//////Color table output
blue_index	bi (
	.address ( blue_ind ),
	.clock ( iVGA_CLK ),
	.q ( blue_data_raw )
	);	
//////

//////Red Ghost VGA Shite (1)
ghost_NE	rne (
	.address ( red_addr ),
	.clock ( VGA_CLK_n ),
	.q ( red_NE )
	);
ghost_NW	rnw (
	.address ( red_addr ),
	.clock ( VGA_CLK_n ),
	.q ( red_NW )
	);
ghost_SE	rse (
	.address ( red_addr ),
	.clock ( VGA_CLK_n ),
	.q ( red_SE )
	);
ghost_SW	rsw (
	.address ( red_addr ),
	.clock ( VGA_CLK_n ),
	.q ( red_SW )
	);
//////Color table output
red_index	ri (
	.address ( red_ind ),
	.clock ( iVGA_CLK ),
	.q ( red_data_raw )
	);	
//////

//////Orange Ghost VGA Shite (2)
ghost_NE	one (
	.address ( orange_addr ),
	.clock ( VGA_CLK_n ),
	.q ( orange_NE )
	);
ghost_NW	onw (
	.address ( orange_addr ),
	.clock ( VGA_CLK_n ),
	.q ( orange_NW )
	);
ghost_SE	ose (
	.address ( orange_addr ),
	.clock ( VGA_CLK_n ),
	.q ( orange_SE )
	);
ghost_SW	osw (
	.address ( orange_addr ),
	.clock ( VGA_CLK_n ),
	.q ( orange_SW )
	);
//////Color table output
orange_index	oi (
	.address ( orange_ind ),
	.clock ( iVGA_CLK ),
	.q ( orange_data_raw )
	);	
//////

//////Pink Ghost VGA Shite (3)
ghost_NE	pne (
	.address ( pink_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pink_NE )
	);
ghost_NW	pnw (
	.address ( pink_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pink_NW )
	);
ghost_SE	pse (
	.address ( pink_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pink_SE )
	);
ghost_SW	psw (
	.address ( pink_addr ),
	.clock ( VGA_CLK_n ),
	.q ( pink_SW )
	);
//////Color table output
pink_index	pinki (
	.address ( pink_ind ),
	.clock ( iVGA_CLK ),
	.q ( pink_data_raw )
	);	
//////

always @(VGA_CLK_n) begin
	// Updates Pacman Address for VGA
	if((xADDR > player0_x) && (xADDR < player0_x + width) && (yADDR > player0_y) && (yADDR < player0_y + height))
		pacman_addr <= (yADDR-player0_y) * width + xADDR-player0_x;
	if((xADDR > player1_x) && (xADDR < player1_x + width) && (yADDR > player1_y) && (yADDR < player1_y + height))
		pacman_addr1 <= (yADDR-player1_y) * width + xADDR-player1_x;
	if((xADDR > xLocG0) && (xADDR < xLocG0 + width) && (yADDR > yLocG0) && (yADDR < yLocG0 + height))
		blue_addr <= (yADDR-yLocG0) * width + xADDR-xLocG0;
	if((xADDR > xLocG1) && (xADDR < xLocG1 + width) && (yADDR > yLocG1) && (yADDR < yLocG1 + height))
		red_addr <= (yADDR-yLocG1) * width + xADDR-xLocG1;
	if((xADDR > xLocG2) && (xADDR < xLocG2 + width) && (yADDR > yLocG2) && (yADDR < yLocG2 + height))
		orange_addr <= (yADDR-yLocG2) * width + xADDR-xLocG2;
	if((xADDR > xLocG3) && (xADDR < xLocG3 + width) && (yADDR > yLocG3) && (yADDR < yLocG3 + height))
		pink_addr <= (yADDR-yLocG3) * width + xADDR-xLocG3;
	
	if (player0_dead == 1'b1) begin
		if (player0_deathCount < 26'd4000000) begin 
			player0_deathCount <= player0_deathCount + 26'd1;
			pacman_ind <= pacman_d0;
		end
		else if (player0_deathCount < 26'd8000000) begin 
			player0_deathCount <= player0_deathCount + 26'd1;
			pacman_ind <= pacman_d1;
		end
		else if (player0_deathCount < 26'd12000000) begin 
			player0_deathCount <= player0_deathCount + 26'd1;
			pacman_ind <= pacman_d2;
		end
		else if (player0_deathCount < 26'd16000000) begin
			player0_deathCount <= player0_deathCount + 26'd1;
			pacman_ind <= pacman_d3;
		end
		else if (player0_deathCount < 26'd20000000) begin
			player0_deathCount <= player0_deathCount + 26'd1;
			pacman_ind <= pacman_d4;
		end
		else if (player0_deathCount < 26'd24000000) begin
			player0_deathCount <= player0_deathCount + 26'd1;
			pacman_ind <= pacman_d5;
		end
		else if (player0_deathCount < 26'd28000000) begin
			player0_deathCount <= player0_deathCount + 26'd1;
			pacman_ind <= pacman_d6;
		end
	end	
	else if ((player0_direction == 2'b00) && (pacman_mouth == 1'b1)) pacman_ind <= pacman_or;
	else if ((player0_direction == 2'b01) && (pacman_mouth == 1'b1)) pacman_ind <= pacman_od;
	else if ((player0_direction == 2'b10) && (pacman_mouth == 1'b1)) pacman_ind <= pacman_ol;
	else if ((player0_direction == 2'b11) && (pacman_mouth == 1'b1)) pacman_ind <= pacman_ou;
	else if ((player0_direction == 2'b00) && (pacman_mouth == 1'b0)) pacman_ind <= pacman_cr;
	else if ((player0_direction == 2'b01) && (pacman_mouth == 1'b0)) pacman_ind <= pacman_cd;
	else if ((player0_direction == 2'b10) && (pacman_mouth == 1'b0)) pacman_ind <= pacman_cl;
	else if ((player0_direction == 2'b11) && (pacman_mouth == 1'b0)) pacman_ind <= pacman_cu;
	
	if ((player1_direction == 2'b00) && (pacman_mouth == 1'b0)) pacman_ind1 <= pacman_cr1;
	else if ((player1_direction == 2'b01) && (pacman_mouth == 1'b0)) pacman_ind1 <= pacman_cd1;
	else if ((player1_direction == 2'b10) && (pacman_mouth == 1'b0)) pacman_ind1 <= pacman_cl1;
	else if ((player1_direction == 2'b11) && (pacman_mouth == 1'b0)) pacman_ind1 <= pacman_cu1;
	else if ((player1_direction == 2'b00) && (pacman_mouth == 1'b1)) pacman_ind1 <= pacman_or1;
	else if ((player1_direction == 2'b01) && (pacman_mouth == 1'b1)) pacman_ind1 <= pacman_od1;
	else if ((player1_direction == 2'b10) && (pacman_mouth == 1'b1)) pacman_ind1 <= pacman_ol1;
	else if ((player1_direction == 2'b11) && (pacman_mouth == 1'b1)) pacman_ind1 <= pacman_ou1;
	
	if ((player0_x <= xLocG0) && (player0_y <= yLocG0)) blue_ind <= blue_NW;
	else if ((player0_x > xLocG0) && (player0_y <= yLocG0)) blue_ind <= blue_NE;
	else if ((player0_x <= xLocG0) && (player0_y > yLocG0)) blue_ind <= blue_SW;
	else if ((player0_x > xLocG0) && (player0_y > yLocG0)) blue_ind <= blue_SE;
	
	if ((player1_x <= xLocG1) && (player1_y <= yLocG1)) red_ind <= red_NW;
	else if ((player1_x > xLocG1) && (player1_y <= yLocG1)) red_ind <= red_NE;
	
	else if ((player1_x <= xLocG1) && (player1_y > yLocG1)) red_ind <= red_SW;
	else if ((player1_x > xLocG1) && (player1_y > yLocG1)) red_ind <= red_SE;
	
	if ((player0_x <= xLocG2) && (player0_y <= yLocG2)) orange_ind <= orange_NW;
	else if ((player0_x > xLocG2) && (player0_y <= yLocG2)) orange_ind <= orange_NE;
	else if ((player0_x <= xLocG2) && (player0_y > yLocG2)) orange_ind <= orange_SW;
	else if ((player0_x > xLocG2) && (player0_y > yLocG2)) orange_ind <= orange_SE;
	
	if ((player1_x <= xLocG3) && (player1_y <= yLocG3)) pink_ind <= pink_NW;
	else if ((player1_x > xLocG3) && (player1_y <= yLocG3)) pink_ind <= pink_NE;
	else if ((player1_x <= xLocG3) && (player1_y > yLocG3)) pink_ind <= pink_SW;
	else if ((player1_x > xLocG3) && (player1_y > yLocG3)) pink_ind <= pink_SE;
		
	
	if (pacman_counter == 0 && pacman_mouth == 1) begin
		pacman_mouth <= 0;
		pacman_counter <= 1;
	end
	else if(pacman_counter == 0 && pacman_mouth == 0) begin
		pacman_mouth <= 1;
		pacman_counter <= 1;
	end
	else begin
		pacman_counter <= pacman_counter + 1;
	end
	
end
	

	

always@(posedge iVGA_CLK) bgr_data <= color;
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule
 	

module addrConverter(ADDR, VGA_CLK_n, xADDR, yADDR);

    input [18:0] ADDR;
    input VGA_CLK_n;
   
    output reg [9:0] xADDR;
    output reg [8:0] yADDR;
    
    always@(posedge VGA_CLK_n) begin
        yADDR <= ADDR / 18'd640;
        xADDR <= ADDR % 18'd640;
    end
    
endmodule











