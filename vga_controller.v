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

reg [9:0] scoreRegPlayer0, scoreRegPlayer1;
output reg [1:0] screenReg;

reg [31:0] pellet0_x, pellet0_y, pellet1_x, pellet1_y, pellet2_x, pellet2_y, pellet3_x, pellet3_y, pellet4_x, pellet4_y, pellet5_x, pellet5_y;


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
reg [12:0] ADDRinScorePlayer1Digit0, ADDRinScorePlayer1Digit1, ADDRinScorePlayer1Digit2, player1Digit0Offset, player1Digit1Offset, player1Digit2Offset;

wire inScorePlayer0Digit0, inScorePlayer0Digit1, inSCorePlayer0Digit2;

assign inScorePlayer0Digit2 = (xADDRToCompare >=  1 && xADDRToCompare <= 30 && yADDRToCompare >= 60 && yADDRToCompare <= 84) ? 1'b1: 1'b0;
assign inScorePlayer0Digit1 = (xADDRToCompare >= 31 && xADDRToCompare <= 60 && yADDRToCompare >= 60 && yADDRToCompare <= 84) ? 1'b1: 1'b0;
assign inScorePlayer0Digit0 = (xADDRToCompare >= 61 && xADDRToCompare <= 90 && yADDRToCompare >= 60 && yADDRToCompare <= 84) ? 1'b1: 1'b0;

assign inScorePlayer1Digit2 = (xADDRToCompare >= 541 && xADDRToCompare <= 570 && yADDRToCompare >= 60 && yADDRToCompare <= 84) ? 1'b1 : 1'b0;
assign inScorePlayer1Digit1 = (xADDRToCompare >= 571 && xADDRToCompare <= 600 && yADDRToCompare >= 60 && yADDRToCompare <= 84) ? 1'b1: 1'b0;
assign inScorePlayer1Digit0 = (xADDRToCompare >= 601 && xADDRToCompare <= 630 && yADDRToCompare >= 60 && yADDRToCompare <= 84) ? 1'b1: 1'b0;

assign inGameOver = (xADDRToCompare >= 127 && xADDRToCompare <=  506 && yADDRToCompare >= 172 && yADDRToCompare <= 312) ? 1'b1 : 1'b0;

				
reg [15:0] ADDRinGameOver;
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
	  
	  ADDRinScorePlayer1Digit0 <= 13'd0;
	  ADDRinScorePlayer1Digit1 <= 13'd0;
	  ADDRinScorePlayer1Digit2 <= 13'd0;
	  
	  ADDRinGameOver <= 16'd0;
	  
  end
  
  else if (cHS==1'b0 && cVS==1'b0) begin
     realADDR <= 19'd0;
	  ADDR <= 19'd0;
	  
	  firstRow <= 1'b0;
	  secondRow <= 1'b1;
	  
	  ADDRinScorePlayer0Digit0 <= 13'd0;
	  ADDRinScorePlayer0Digit1 <= 13'd0;
	  ADDRinScorePlayer0Digit2 <= 13'd0;
	  
	  ADDRinScorePlayer1Digit0 <= 13'd0;
	  ADDRinScorePlayer1Digit1 <= 13'd0;
	  ADDRinScorePlayer1Digit2 <= 13'd0;
	  
	  ADDRinGameOver <= 16'd0;
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
			
			
			
	  if(inScorePlayer1Digit0 == 1'b1)
			ADDRinScorePlayer1Digit0 <= ADDRinScorePlayer1Digit0 + 1;
		
	  if(inScorePlayer1Digit1 == 1'b1)
			ADDRinScorePlayer1Digit1 <= ADDRinScorePlayer1Digit1 + 1;
			
	  if(inScorePlayer1Digit2 == 1'b1)
			ADDRinScorePlayer1Digit2 <= ADDRinScorePlayer1Digit2 + 1;
			
	  if(inGameOver == 1'b1)
			ADDRinGameOver <= ADDRinGameOver + 1;
	  
			
			
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

reg [19:0] pacman_counter;
reg [25:0] player0_deathCount;
reg [25:0] player1_deathCount;


reg pinkSig1, pinkSig2, pinkSig3, pinkSig4, redSig1, redSig2, redSig3, redSig4, orangeSig1, orangeSig2, orangeSig3, orangeSig4, blueSig1, blueSig2, blueSig3, blueSig4;
reg [18:0] pinkCounter, redCounter, orangeCounter, blueCounter;

initial begin
    xLoc0 <= 10'b0000000000;
    yLoc0 <=  9'b000000000;
	 	 
    xLoc1 <= 10'b0000000000;
    yLoc1 <=  9'b000000000;
	 
	 xLocG0 <= 10'd108;
    yLocG0 <=  9'd18;
	 
	 xLocG1 <= 10'd108;
    yLocG1 <=  9'd409;
	 
	 xLocG2 <= 10'd186;
    yLocG2 <=  9'd72;
	 
	 xLocG3 <= 10'd508;
    yLocG3 <=  9'd409;
    
    width <=  10'd24;
    height <=  9'd24;
	 
	 pinkSig1 <= 1;
	 pinkSig2 <= 0;
	 pinkSig3 <= 0;
	 pinkSig4 <= 0;
	 pinkCounter <= 0;
	 
	 gameOverOccurred <= 1;
	 
	 redSig1 <= 1;
	 redSig2 <= 0;
	 redSig3 <= 0;
	 redSig4 <= 0;
	 redCounter <= 0;
	 
	 orangeSig1 <= 1;
	 orangeSig2 <= 0;
	 orangeSig3 <= 0;
	 orangeSig4 <= 0;
	 orangeCounter <= 0;
	 
	 blueSig1 <= 1;
	 blueSig2 <= 0;
	 blueSig3 <= 0;
	 blueSig4 <= 0;
	 blueCounter <= 0;
	 
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
	 
	 pellet0_x <= 235;
	 pellet0_y <= 163;
	 
	 pellet1_x <= 235;
	 pellet1_y <= 187;
	 
	 pellet2_x <= 235;
	 pellet2_y <= 211;
	 
	 pellet3_x <= 235;
	 pellet3_y <= 235;
	 
	 pellet4_x <= 235;
	 pellet4_y <= 259;
	 
	 pellet5_x <= 235;
	 pellet5_y <= 283;
	 

    
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
			  
		 else if(powerup1_playerXRegister == 32'd1 && inScorePlayer0Digit0 != 1'b1 && inScorePlayer0Digit1 != 1'b1 && inScorePlayer0Digit2 != 1'b1 && inScorePlayer1Digit0 != 1'b1 && inScorePlayer1Digit1 != 1'b1 && inScorePlayer1Digit2 != 1'b1)
			  color <= 23'b000000000000000000000000;  
			  
		 else if(inScorePlayer0Digit0 == 1'b1)
			  color <= score_data_rawDigit0;
			  
		 else if(inScorePlayer0Digit1 == 1'b1)
			  color <= score_data_rawDigit1;
			  
		 else if(inScorePlayer0Digit2 == 1'b1)
			  color <= score_data_rawDigit2;
			  
		 else if(inScorePlayer1Digit0 == 1'b1)
			  color <= score_data_rawPlayer1Digit0;
			  
		 else if(inScorePlayer1Digit1 == 1'b1)
			  color <= score_data_rawPlayer1Digit1;
			  
		 else if(inScorePlayer1Digit2 == 1'b1)
			  color <= score_data_rawPlayer1Digit2;
		 
		 else if(xADDRToCompare > pellet0_x && xADDRToCompare < pellet0_x + width && yADDRToCompare > pellet0_y && yADDRToCompare < pellet0_y + height)
				color <= 23'b000000001111111111111111;
				
		 else if(xADDRToCompare > pellet1_x && xADDRToCompare < pellet1_x + width && yADDRToCompare > pellet1_y && yADDRToCompare < pellet1_y + height)
				color <= 23'b000000001111111111111111;
				
		 else if(xADDRToCompare > pellet2_x && xADDRToCompare < pellet2_x + width && yADDRToCompare > pellet2_y && yADDRToCompare < pellet2_y + height)
				color <= 23'b000000001111111111111111;
				
		 else if(xADDRToCompare > pellet3_x && xADDRToCompare < pellet3_x + width && yADDRToCompare > pellet3_y && yADDRToCompare < pellet3_y + height)
				color <= 23'b000000001111111111111111;
				
		 else if(xADDRToCompare > pellet4_x && xADDRToCompare < pellet4_x + width && yADDRToCompare > pellet4_y && yADDRToCompare < pellet4_y + height)
				color <= 23'b000000001111111111111111;
				
		 else if(xADDRToCompare > pellet5_x && xADDRToCompare < pellet5_x + width && yADDRToCompare > pellet5_y && yADDRToCompare < pellet5_y + height)
				color <= 23'b000000001111111111111111;
		
		else if(inGameOver == 1'b1 && gameOverOccurred == 1'b1 && gameOverDataRaw != 24'h00FF00)
				color <= gameOverDataRaw;
			  
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

reg gameOverOccurred;

//COLLISION FLAGS

always@(posedge procClock) begin


	 //Player 0 UP COLLISIONS
	 if(bgr_data_raw == 24'hFF3333 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 - 1)) begin
		  player0_collisionUp <= 1'b1;
		  upCollisionFlag0 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF3333 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 - 1) && upCollisionFlag0 == 1'b0)
		  player0_collisionUp <= 1'b0;
		  
	 else if(xADDRToCompare > xLoc0 + width + 1)
		  upCollisionFlag0 <= 1'b0;
		
		
	 //Player 0 DOWN COLLISIONS	
	 if(bgr_data_raw == 24'hFF3333 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 + height + 1)) begin
		  player0_collisionDown <= 1'b1;
		  downCollisionFlag0 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF3333 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 + height + 1) && downCollisionFlag0 == 1'b0) begin
		  player0_collisionDown <= 1'b0;
	 end
		  
	 else if(xADDRToCompare > xLoc0 + width + 1)
		  downCollisionFlag0 <= 1'b0;
		
		
	//Player 0 RIGHT COLLISIONS
	if(bgr_data_raw == 24'hFF3333 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 + width + 1))begin
			player0_collisionRight <= 1'b1;
			rightCollisionFlag0 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF3333 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 + width + 1) && rightCollisionFlag0 == 1'b0)
		   player0_collisionRight <= 1'b0;
			
	else if(yADDRToCompare > yLoc0 + height + 1)
			rightCollisionFlag0 <= 1'b0;
	
	
	//Player 0 LEFT COLLISIONS
	if(bgr_data_raw == 24'hFF3333 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 - 1))begin
			player0_collisionLeft <= 1'b1;
			leftCollisionFlag0 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF3333 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 - 1) && leftCollisionFlag0 == 1'b0)
		   player0_collisionLeft <= 1'b0;
			
	else if(yADDRToCompare > yLoc0 + height + 1)
			leftCollisionFlag0 <= 1'b0;
			
			
			
			
			
	 //Player 1 UP COLLISIONS
	 if(bgr_data_raw == 24'hFF3333 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 - 1)) begin
		  player1_collisionUp <= 1'b1;
		  upCollisionFlag1 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF3333 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 - 1) && upCollisionFlag1 == 1'b0)
		  player1_collisionUp <= 1'b0;
		  
	 else if(xADDRToCompare > xLoc1 + width + 1)
		  upCollisionFlag1 <= 1'b0;
		
		
		
	 //Player 1 DOWN COLLISIONS	
	 if(bgr_data_raw == 24'hFF3333 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 + height + 1)) begin
		  player1_collisionDown <= 1'b1;
		  downCollisionFlag1 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF3333 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 + height + 1) && downCollisionFlag1 == 1'b0) begin
		  player1_collisionDown <= 1'b0;
	 end
		  
	 else if(xADDRToCompare > xLoc1 + width + 1)
		  downCollisionFlag1 <= 1'b0;
		
		
		
	//Player 1 RIGHT COLLISIONS
	if(bgr_data_raw == 24'hFF3333 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 + width + 1))begin
			player1_collisionRight <= 1'b1;
			rightCollisionFlag1 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF3333 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 + width + 1) && rightCollisionFlag1 == 1'b0)
		   player1_collisionRight <= 1'b0;
			
	else if(yADDRToCompare > yLoc1 + height + 1)
			rightCollisionFlag1 <= 1'b0;
	
	
	//Player 1 LEFT COLLISIONS
	if(bgr_data_raw == 24'hFF3333 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 - 1))begin
			player1_collisionLeft <= 1'b1;
			leftCollisionFlag1 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF3333 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 - 1) && leftCollisionFlag1 == 1'b0)
		   player1_collisionLeft <= 1'b0;
			
	else if(yADDRToCompare > yLoc1 + height + 1)
			leftCollisionFlag1 <= 1'b0;
			
			
		
	player0Digit0Offset <= scoreRegPlayer0 % 10;
	player0Digit1Offset <= (scoreRegPlayer0 % 100) / 10;
	player0Digit2Offset <= scoreRegPlayer0 / 100;
	
	player1Digit0Offset <= scoreRegPlayer1 % 10;
	player1Digit1Offset <= (scoreRegPlayer1 % 100) / 10;
	player1Digit2Offset <= scoreRegPlayer1 / 100;
	

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
	end
	
	redCounter <= redCounter + 1;
	
	if(redCounter == 0 && redSig1 == 1)
		xLocG1 = xLocG1 + 1;
	else if(redCounter == 0 && redSig2 == 1)
		yLocG1 = yLocG1 - 1;
	else if(redCounter == 0 && redSig3 == 1)
		xLocG1 = xLocG1 - 1;
	else if(redCounter == 0 && redSig4 == 1)
		yLocG1 = yLocG1 + 1;
		
	if(xLocG1 == 283 && yLocG1 == 409) begin
		redSig1 <= 0;
		redSig2 <= 1;
	end
	
	else if(xLocG1 == 283 && yLocG1 == 369) begin
		redSig2 <= 0;
		redSig3 <= 1;
	end
	
	else if(xLocG1 == 234 && yLocG1 == 369) begin
		redSig3 <= 0;
		redSig2 <= 1;
	end
	
	else if(xLocG1 == 234 && yLocG1 == 326) begin
		redSig2 <= 0;
		redSig3 <= 1;
	end
	
	else if(xLocG1 == 187 && yLocG1 == 326) begin
		redSig3 <= 0;
		redSig4 <= 1;
	end
	
	else if(xLocG1 == 187 & yLocG1 == 369) begin
		redSig4 <= 0;
		redSig3 <= 1;
	end
	
	else if (xLocG1 == 108 && yLocG1 == 369) begin
		redSig3 <= 0;
		redSig4 <= 1;
	end
	
	else if (xLocG1 == 108 && yLocG1 == 409) begin
		redSig4 <= 0;
		redSig1 <= 1;
	end
	
	orangeCounter <= orangeCounter + 1;
	
	if(orangeCounter == 0 && orangeSig1 == 1)
		xLocG3 <= xLocG3 - 1;
	else if(orangeCounter == 0 && orangeSig2 == 1)
		yLocG3 <= yLocG3 - 1;
	else if(orangeCounter == 0 && orangeSig3 == 1)
		xLocG3 <= xLocG3 + 1;
	else if(orangeCounter == 0 && orangeSig4 == 1)
		yLocG3 <= yLocG3 + 1;
		
	if(xLocG3 == 332 && yLocG3 == 409) begin
		orangeSig1 <= 0;
		orangeSig2 <= 1;
	end 
	else if(xLocG3 == 332 && yLocG3 == 368) begin
		orangeSig3 <= 1;
		orangeSig2 <= 0;
	end
	else if(xLocG3 == 379 && yLocG3 == 368) begin
		orangeSig2 <= 1;
		orangeSig3 <= 0;
	end
	else if(xLocG3 == 379 && yLocG3 == 326) begin
		orangeSig3 <= 1;
		orangeSig2 <= 0;
	end
	else if(xLocG3 == 427 && yLocG3 == 326) begin
		orangeSig4 <= 1;
		orangeSig3 <= 0;
	end
	else if(xLocG3 == 427 && yLocG3 == 367) begin
		orangeSig4 <= 0; 
		orangeSig3 <= 1;
	end
	else if(xLocG3 == 508 && yLocG3 == 367) begin
		orangeSig3 <= 0;
		orangeSig4 <= 1;
	end
	else if(xLocG3 == 508 && yLocG3 == 409) begin
		orangeSig1 <= 1;
		orangeSig4 <= 0;
	end
	
	blueCounter <= blueCounter + 1;
	
	
	if(blueCounter == 0 && blueSig1 == 1)
		xLocG0 <= xLocG0 + 1;
	else if(blueCounter == 0 && blueSig2 == 1)
		yLocG0 <= yLocG0 + 1;
	else if(orangeCounter == 0 && blueSig3 == 1)
		yLocG0 <= yLocG0 - 1;
	else if(orangeCounter == 0 && blueSig4 == 1)
		xLocG0 <= xLocG0 - 1;
	
	if(xLocG0 == 108 && yLocG0 == 18) begin
		blueSig1 <= 1;
		blueSig3 <= 0;
	end
	else if(xLocG0 == 283 && yLocG0 == 18) begin
		blueSig1 <= 0;
		blueSig2 <= 1;
	end
	else if(xLocG0 == 283 && yLocG0 == 74) begin
		blueSig2 <= 0;
		blueSig1 <= 1;
	end
	else if(xLocG0 == 332 && yLocG0 == 74) begin
		blueSig3 <= 1;
		blueSig1 <= 0;
	end
	else if(xLocG0 == 332 && yLocG0 == 21) begin
		blueSig1 <= 1;
		blueSig3 <= 0;
	end
	else if(xLocG0 == 507 && yLocG0 == 21) begin
		blueSig2 <= 1;
		blueSig1 <= 0;
	end
	else if(xLocG0 == 507 && yLocG0 == 75) begin
		blueSig4 <= 1;
		blueSig2 <= 0;
	end
	else if(xLocG0 == 108 && yLocG0 == 75) begin	
		blueSig3 <= 1;
		blueSig4 <= 0;
	end
	
		 //Player 0 collision with pellet 0 
        if(((xLoc0 +  width >= pellet0_x && xLoc0 + width <= pellet0_x + width) || 
			   (xLoc0 >= pellet0_x && xLoc0 <= pellet0_x + width)) &&
			  ((yLoc0 +  height >= pellet0_y && yLoc0 + height <= pellet0_y + height) ||
			   (yLoc0 >= pellet0_y && yLoc0 <= pellet0_y + height))) begin
					pellet0_x <= 32'b11111111111111111111111111111111;
					pellet0_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer0 <= scoreRegPlayer0 + 5;
		  end	
		  
		 //Player 0 collision with pellet 1 
        if(((xLoc0 +  width >= pellet1_x && xLoc0 + width <= pellet1_x + width) || 
			   (xLoc0 >= pellet1_x && xLoc0 <= pellet1_x + width)) &&
			  ((yLoc0 +  height >= pellet1_y && yLoc0 + height <= pellet1_y + height) ||
			   (yLoc0 >= pellet1_y && yLoc0 <= pellet1_y + height))) begin
					pellet1_x <= 32'b11111111111111111111111111111111;
					pellet1_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer0 <= scoreRegPlayer0 + 5;
		  end	
		  
		 //Player 0 collision with pellet 2
        if(((xLoc0 +  width >= pellet2_x && xLoc0 + width <= pellet2_x + width) || 
			   (xLoc0 >= pellet2_x && xLoc0 <= pellet2_x + width)) &&
			  ((yLoc0 +  height >= pellet2_y && yLoc0 + height <= pellet2_y + height) ||
			   (yLoc0 >= pellet2_y && yLoc0 <= pellet2_y + height))) begin
					pellet2_x <= 32'b11111111111111111111111111111111;
					pellet2_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer0 <= scoreRegPlayer0 + 5;
		  end	
		  
		 //Player 0 collision with pellet 3
        if(((xLoc0 +  width >= pellet3_x && xLoc0 + width <= pellet3_x + width) || 
			   (xLoc0 >= pellet3_x && xLoc0 <= pellet3_x + width)) &&
			  ((yLoc0 +  height >= pellet3_y && yLoc0 + height <= pellet3_y + height) ||
			   (yLoc0 >= pellet3_y && yLoc0 <= pellet3_y + height))) begin
					pellet3_x <= 32'b11111111111111111111111111111111;
					pellet3_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer0 <= scoreRegPlayer0 + 5;
		  end	
		  
		 //Player 0 collision with pellet 0 
        if(((xLoc0 +  width >= pellet4_x && xLoc0 + width <= pellet4_x + width) || 
			   (xLoc0 >= pellet4_x && xLoc0 <= pellet4_x + width)) &&
			  ((yLoc0 +  height >= pellet4_y && yLoc0 + height <= pellet4_y + height) ||
			   (yLoc0 >= pellet4_y && yLoc0 <= pellet4_y + height))) begin
					pellet4_x <= 32'b11111111111111111111111111111111;
					pellet4_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer0 <= scoreRegPlayer0 + 5;
		  end	
		  
		 //Player 0 collision with pellet 5
        if(((xLoc0 +  width >= pellet5_x && xLoc0 + width <= pellet5_x + width) || 
			   (xLoc0 >= pellet5_x && xLoc0 <= pellet5_x + width)) &&
			  ((yLoc0 +  height >= pellet5_y && yLoc0 + height <= pellet5_y + height) ||
			   (yLoc0 >= pellet5_y && yLoc0 <= pellet5_y + height))) begin
					pellet5_x <= 32'b11111111111111111111111111111111;
					pellet5_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer0 <= scoreRegPlayer0 + 5;
		  end	
		  
		  
		  
		  
		  
		  
		
		 //Player 1 collision with pellet 0 
        if(((xLoc1 +  width >= pellet0_x && xLoc1 + width <= pellet0_x + width) || 
			   (xLoc1 >= pellet0_x && xLoc1 <= pellet0_x + width)) &&
			  ((yLoc1 +  height >= pellet0_y && yLoc1 + height <= pellet0_y + height) ||
			   (yLoc1 >= pellet0_y && yLoc1 <= pellet0_y + height))) begin
					pellet0_x <= 32'b11111111111111111111111111111111;
					pellet0_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer1 <= scoreRegPlayer1 + 5;
		  end	
		  
		 //Player 0 collision with pellet 1 
        if(((xLoc1 +  width >= pellet1_x && xLoc1 + width <= pellet1_x + width) || 
			   (xLoc1 >= pellet1_x && xLoc1 <= pellet1_x + width)) &&
			  ((yLoc1 +  height >= pellet1_y && yLoc1 + height <= pellet1_y + height) ||
			   (yLoc1 >= pellet1_y && yLoc1 <= pellet1_y + height))) begin
					pellet1_x <= 32'b11111111111111111111111111111111;
					pellet1_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer1 <= scoreRegPlayer1 + 5;
		  end	
		  
		 //Player 0 collision with pellet 2
        if(((xLoc1 +  width >= pellet2_x && xLoc1 + width <= pellet2_x + width) || 
			   (xLoc1 >= pellet2_x && xLoc1 <= pellet2_x + width)) &&
			  ((yLoc1 +  height >= pellet2_y && yLoc1 + height <= pellet2_y + height) ||
			   (yLoc1 >= pellet2_y && yLoc1 <= pellet2_y + height))) begin
					pellet2_x <= 32'b11111111111111111111111111111111;
					pellet2_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer1 <= scoreRegPlayer1 + 5;
		  end	
		  
		 //Player 0 collision with pellet 3
        if(((xLoc1 +  width >= pellet3_x && xLoc1 + width <= pellet3_x + width) || 
			   (xLoc1 >= pellet3_x && xLoc1 <= pellet3_x + width)) &&
			  ((yLoc1 +  height >= pellet3_y && yLoc1 + height <= pellet3_y + height) ||
			   (yLoc1 >= pellet3_y && yLoc1 <= pellet3_y + height))) begin
					pellet3_x <= 32'b11111111111111111111111111111111;
					pellet3_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer0 <= scoreRegPlayer0 + 5;
		  end	
		  
		 //Player 0 collision with pellet 0 
        if(((xLoc1 +  width >= pellet4_x && xLoc1 + width <= pellet4_x + width) || 
			   (xLoc1 >= pellet4_x && xLoc1 <= pellet4_x + width)) &&
			  ((yLoc1 +  height >= pellet4_y && yLoc1 + height <= pellet4_y + height) ||
			   (yLoc1 >= pellet4_y && yLoc1 <= pellet4_y + height))) begin
					pellet4_x <= 32'b11111111111111111111111111111111;
					pellet4_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer1 <= scoreRegPlayer1 + 5;
		  end	
		  
		 //Player 0 collision with pellet 5
        if(((xLoc1 +  width >= pellet5_x && xLoc1 + width <= pellet5_x + width) || 
			   (xLoc1 >= pellet5_x && xLoc1 <= pellet5_x + width)) &&
			  ((yLoc1 +  height >= pellet5_y && yLoc1 + height <= pellet5_y + height) ||
			   (yLoc1 >= pellet5_y && yLoc1 <= pellet5_y + height))) begin
					pellet5_x <= 32'b11111111111111111111111111111111;
					pellet5_y <= 32'b11111111111111111111111111111111;
					scoreRegPlayer1 <= scoreRegPlayer1 + 5;
		  end	
	
		
		
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
	.address(ADDRinScorePlayer0Digit0 + player0Digit0Offset * 720),
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
	.address(ADDRinScorePlayer0Digit1 + player0Digit1Offset * 720),
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
	.address(ADDRinScorePlayer0Digit2 + player0Digit2Offset * 720),
	.clock(VGA_CLK_n),
	.q(scoreWirePlayer0Digit2)
	);
	
digits_color_data scoreRenderer6 (
	.address(scoreWirePlayer0Digit2),
	.clock(iVGA_CLK),
	.q(score_data_rawDigit2)
	);

	
	
	
wire [1:0] scoreWirePlayer1Digit0;
wire [23:0] score_data_rawPlayer1Digit0;
	
digits_image_data scoreRenderer7 (
	.address(ADDRinScorePlayer1Digit0 + player1Digit0Offset * 720),
	.clock(VGA_CLK_n),
	.q(scoreWirePlayer1Digit0)
	);
	
digits_color_data scoreRenderer8 (
	.address(scoreWirePlayer1Digit0),
	.clock(iVGA_CLK),
	.q(score_data_rawPlayer1Digit0)
	);
	
wire [1:0] scoreWirePlayer1Digit1;
wire [23:0] score_data_rawPlayer1Digit1;
	
digits_image_data scoreRenderer9 (
	.address(ADDRinScorePlayer1Digit1 + player1Digit1Offset * 720),
	.clock(VGA_CLK_n),
	.q(scoreWirePlayer1Digit1)
	);
	
digits_color_data scoreRenderer10 (
	.address(scoreWirePlayer1Digit1),
	.clock(iVGA_CLK),
	.q(score_data_rawPlayer1Digit1)
	);
	
wire [1:0] scoreWirePlayer1Digit2;
wire [23:0] score_data_rawPlayer1Digit2;
	
digits_image_data scoreRenderer11 (
	.address(ADDRinScorePlayer1Digit2 + player1Digit2Offset * 720),
	.clock(VGA_CLK_n),
	.q(scoreWirePlayer1Digit2)
	);
	
digits_color_data scoreRenderer12 (
	.address(scoreWirePlayer1Digit2),
	.clock(iVGA_CLK),
	.q(score_data_rawPlayer1Digit2)
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

wire gameOverWire;
wire [23:0] gameOverDataRaw;

game_over_index gameOverScreen (
	.address(ADDRinGameOver),
	.clock(VGA_CLK_n),
	.q(gameOverWire),
	);
	
game_over_color gameOverScreen2(
	.address(gameOverWire),
	.clock(iVGA_CLK),
	.q( gameOverDataRaw),
	);

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
	
	if (player0_deathCount < 26'd4000000 && player0_dead == 1) begin 
		player0_deathCount <= player0_deathCount + 26'd1;
		pacman_ind <= pacman_d0;
	end
	else if (player0_deathCount < 26'd8000000 && player0_dead == 1) begin 
		player0_deathCount <= player0_deathCount + 26'd1;
		pacman_ind <= pacman_d1;
	end
	else if (player0_deathCount < 26'd12000000 && player0_dead == 1) begin 
		player0_deathCount <= player0_deathCount + 26'd1;
		pacman_ind <= pacman_d2;
	end
	else if (player0_deathCount < 26'd16000000 && player0_dead == 1) begin
		player0_deathCount <= player0_deathCount + 26'd1;
		pacman_ind <= pacman_d3;
	end
	else if (player0_deathCount < 26'd20000000 && player0_dead == 1) begin
		player0_deathCount <= player0_deathCount + 26'd1;
		pacman_ind <= pacman_d4;
	end
	else if (player0_deathCount < 26'd24000000 && player0_dead == 1) begin
		player0_deathCount <= player0_deathCount + 26'd1;
		pacman_ind <= pacman_d5;
	end
	else if (player0_deathCount < 26'd28000000 && player0_dead == 1) begin
		player0_deathCount <= player0_deathCount + 26'd1;
		pacman_ind <= pacman_d6;
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
		
	pacman_counter <= pacman_counter + 1;
	
	if (pacman_counter == 0 && pacman_mouth == 1) begin
		pacman_mouth <= 0;
	end
	else if(pacman_counter == 0 && pacman_mouth == 0) begin
		pacman_mouth <= 1;
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











