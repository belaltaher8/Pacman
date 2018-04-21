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
							 player1_collisionUp, player1_collisionDown, player1_collisionRight, player1_collisionLeft);


input [7:0] ps2_key_data_in;
input procClock;

input [31:0] player0_x, player0_y, player1_x, player1_y;
input [31:0] powerup0_x, powerup0_y, powerup1_x, powerup1_y, powerup1_playerXRegister;

reg [8:0] scoreReg;


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
               
reg [12:0] ADDRinScorePlayer0;

wire inScorePlayer0;

assign inScorePlayer0 = (xADDRToCompare >= 1 && xADDRToCompare <= 36 && yADDRToCompare >= 30 && yADDRToCompare <= 55) ? 1'b1: 1'b0;

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
	  
	  ADDRinScorePlayer0 <= 13'd0;
	  
  end
  
  else if (cHS==1'b0 && cVS==1'b0) begin
     realADDR <= 19'd0;
	  ADDR <= 19'd0;
	  
	  firstRow <= 1'b0;
	  secondRow <= 1'b1;
	  
	  ADDRinScorePlayer0 <= 13'd0;
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
	  
	  if(inScorePlayer0 == 1'b1)
			ADDRinScorePlayer0 <= ADDRinScorePlayer0 + 1;
			
			
	end
	
  	
  
end










//Creates register for the block and initializes value
reg [9:0] xLoc0;
reg [8:0] yLoc0;

reg [9:0] xLoc1;
reg [8:0] yLoc1;

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

initial begin
    xLoc0 <= 10'b0000000000;
    yLoc0 <=  9'b000000000;
	 	 
    xLoc1 <= 10'b0000000000;
    yLoc1 <=  9'b000000000;
    
    width <=  10'd24;
    height <=  9'd24;
	 
	 
	 powerup0xLocToRender <= 10'b0000000000;
	 powerup0yLocToRender <=  9'b000000000;
	 
	 powerup1xLocToRender <= 10'd0;
	 powerup1yLocToRender <=  9'd0;
	 
	 scoreReg <= 8'd0;
    
    
end

addrConverter myAddrConverterPlayer0(ADDR, VGA_CLK_n, xADDR, yADDR);

 always@(posedge VGA_CLK_n) begin
 
    //Updates player 0 location
    xLoc0 <= player0_x[9:0];
    yLoc0 <= player0_y[8:0];
	 
	 //Updates player 1 location
	 xLoc1 <= player1_x[9:0];
	 yLoc1 <= player1_y[8:0];
		  
	 //Updates powerup 0 location	  
    powerup0xLocToRender <= powerup0_x[9:0];
	 powerup0yLocToRender <= powerup0_y[8:0];
	 
	 ///Updates powerup 1 location
	 powerup1xLocToRender <= powerup1_x[9:0];
	 powerup1yLocToRender <= powerup1_y[8:0];

 
 
    xADDRToCompare <= xADDR;
    yADDRToCompare <= yADDR;
    
	 
    if((xADDRToCompare > xLoc0) && (xADDRToCompare < xLoc0 + width) && (yADDRToCompare > yLoc0) && (yADDRToCompare < yLoc0 + height) )
        color <= 23'b111111110000000000000000;
		  
    else if((xADDRToCompare > powerup0xLocToRender) && (xADDRToCompare < powerup0xLocToRender + width) && (yADDRToCompare > powerup0yLocToRender) && (yADDRToCompare < powerup0yLocToRender + height) )
		  color <= 23'b000000001111111100000000;
		  
    else if((xADDRToCompare > xLoc1) && (xADDRToCompare < xLoc1 + width) && (yADDRToCompare > yLoc1) && (yADDRToCompare < yLoc1 + height) )	  
		  color <= 23'b000000000000000011111111;
		  
    else if((xADDRToCompare > powerup1xLocToRender) && (xADDRToCompare < powerup1xLocToRender + width) && (yADDRToCompare > powerup1yLocToRender) && (yADDRToCompare < powerup1yLocToRender + height) )
		  color <= 23'b111111110000000011111111;
		  
    else if(powerup1_playerXRegister == 32'd1 && inScorePlayer0 != 1'b1)
        color <= 23'b000000000000000000000000;  
	 else if(inScorePlayer0 == 1'b1)
		  color <= score_data_raw;
	 else 
		  color <= bgr_data_raw;
		  

		 
	 

end

output reg player0_collisionUp, player0_collisionDown, player0_collisionRight, player0_collisionLeft, player1_collisionUp, player1_collisionDown, player1_collisionRight, player1_collisionLeft;


reg upCollisionFlag0, downCollisionFlag0, rightCollisionFlag0, leftCollisionFlag0;
reg upCollisionFlag1, downCollisionFlag1, rightCollisionFlag1, leftCollisionFlag1;



//COLLISION FLAGS

always@(posedge procClock) begin


	 //Player 0 UP COLLISIONS
	 if(bgr_data_raw == 24'hFF5757 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 - 1)) begin
		  player0_collisionUp <= 1'b1;
		  upCollisionFlag0 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF5757 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 - 1) && upCollisionFlag0 == 1'b0)
		  player0_collisionUp <= 1'b0;
		  
	 else if(xADDRToCompare > xLoc0 + width + 1)
		  upCollisionFlag0 <= 1'b0;
		
		
	 //Player 0 DOWN COLLISIONS	
	 if(bgr_data_raw == 24'hFF5757 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 + height + 1)) begin
		  player0_collisionDown <= 1'b1;
		  downCollisionFlag0 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF5757 && (xADDRToCompare > xLoc0) && (xADDRToCompare < (xLoc0 + width)) && (yADDRToCompare == yLoc0 + height + 1) && downCollisionFlag0 == 1'b0) begin
		  player0_collisionDown <= 1'b0;
	 end
		  
	 else if(xADDRToCompare > xLoc0 + width + 1)
		  downCollisionFlag0 <= 1'b0;
		
		
	//Player 0 RIGHT COLLISIONS
	if(bgr_data_raw == 24'hFF5757 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 + width + 1))begin
			player0_collisionRight <= 1'b1;
			rightCollisionFlag0 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF5757 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 + width + 1) && rightCollisionFlag0 == 1'b0)
		   player0_collisionRight <= 1'b0;
			
	else if(yADDRToCompare > yLoc0 + height + 1)
			rightCollisionFlag0 <= 1'b0;
	
	
	//Player 0 LEFT COLLISIONS
	if(bgr_data_raw == 24'hFF5757 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 - 1))begin
			player0_collisionLeft <= 1'b1;
			leftCollisionFlag0 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF5757 && (yADDRToCompare > yLoc0) && (yADDRToCompare < (yLoc0 + height)) && (xADDRToCompare == xLoc0 - 1) && leftCollisionFlag0 == 1'b0)
		   player0_collisionLeft <= 1'b0;
			
	else if(yADDRToCompare > yLoc0 + height + 1)
			leftCollisionFlag0 <= 1'b0;
			
			
			
			
			
	 //Player 1 UP COLLISIONS
	 if(bgr_data_raw == 24'hFF5757 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 - 1)) begin
		  player1_collisionUp <= 1'b1;
		  upCollisionFlag1 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF5757 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 - 1) && upCollisionFlag1 == 1'b0)
		  player1_collisionUp <= 1'b0;
		  
	 else if(xADDRToCompare > xLoc1 + width + 1)
		  upCollisionFlag1 <= 1'b0;
		
		
		
	 //Player 0 DOWN COLLISIONS	
	 if(bgr_data_raw == 24'hFF5757 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 + height + 1)) begin
		  player1_collisionDown <= 1'b1;
		  downCollisionFlag1 <= 1'b1;
	 end
		  
	 else if(bgr_data_raw != 24'hFF5757 && (xADDRToCompare > xLoc1) && (xADDRToCompare < (xLoc1 + width)) && (yADDRToCompare == yLoc1 + height + 1) && downCollisionFlag1 == 1'b0) begin
		  player1_collisionDown <= 1'b0;
	 end
		  
	 else if(xADDRToCompare > xLoc1 + width + 1)
		  downCollisionFlag1 <= 1'b0;
		
		
		
	//Player 0 RIGHT COLLISIONS
	if(bgr_data_raw == 24'hFF5757 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 + width + 1))begin
			player1_collisionRight <= 1'b1;
			rightCollisionFlag1 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF5757 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 + width + 1) && rightCollisionFlag1 == 1'b0)
		   player1_collisionRight <= 1'b0;
			
	else if(yADDRToCompare > yLoc1 + height + 1)
			rightCollisionFlag1 <= 1'b0;
	
	
	//Player 0 LEFT COLLISIONS
	if(bgr_data_raw == 24'hFF5757 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 - 1))begin
			player1_collisionLeft <= 1'b1;
			leftCollisionFlag1 <= 1'b1;
	end
	
	else if(bgr_data_raw != 24'hFF5757 && (yADDRToCompare > yLoc1) && (yADDRToCompare < (yLoc1 + height)) && (xADDRToCompare == xLoc1 - 1) && leftCollisionFlag1 == 1'b0)
		   player1_collisionLeft <= 1'b0;
			
	else if(yADDRToCompare > yLoc1 + height + 1)
			leftCollisionFlag1 <= 1'b0;
		
		
	
		
		
end
	


	
	
	
	
	
	
assign VGA_CLK_n = ~iVGA_CLK;

bgr_pixel_data	img_data_inst (
	.aclr(1'b0),
	.address_a ( realADDR ),
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
	
wire [1:0] scoreWirePlayer0;
wire [23:0] score_data_raw;
	
digits_image_data scoreRenderer (
	.address(ADDRinScorePlayer0),
	.clock(VGA_CLK_n),
	.q(scoreWirePlayer0)
	);
	
digits_color_data scoreRenderer2 (
	.address(scoreWirePlayer0),
	.clock(iVGA_CLK),
	.q(score_data_raw)
	);
	
	

	

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











