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
							 player0_collisionUp, player0_collisionDown, player0_collisionRight, player0_collisionLeft, colorUp);


input [7:0] ps2_key_data_in;
input procClock;

input [31:0] player0_x, player0_y, player1_x, player1_y;
input [31:0] powerup0_x, powerup0_y, powerup1_x, powerup1_y, powerup1_playerXRegister;


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
  end
  
  else if (cHS==1'b0 && cVS==1'b0) begin
     realADDR <= 19'd0;
	  ADDR <= 19'd0;
	  firstRow <= 1'b0;
	  secondRow <= 1'b1;
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
	end
			
	
	
  	
  
end



//////////////////////////
//////INDEX addr.

	
/////////////////////////






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
    
    width <=  10'd25;
    height <=  9'd25;
	 
	 
	 powerup0xLocToRender <= 10'b0000000000;
	 powerup0yLocToRender <=  9'b000000000;
	 
	 powerup1xLocToRender <= 10'd0;
	 powerup1yLocToRender <=  9'd0;
	 
    
    
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
		  
    else if(powerup1_playerXRegister == 32'd1)
        color <= 23'b000000000000000000000000;  
	 else 
		  color <= bgr_data_raw;
		 
	 

end

output reg player0_collisionUp, player0_collisionDown, player0_collisionRight, player0_collisionLeft;

always@(posedge procClock) begin

	if(colorUp == 6'hFF5757) begin
		player0_collisionUp <= 1'b1;
   end
	else if(colorUp != 6'hFF5757) begin
		player0_collisionUp <= 1'b0;
	end
		
	/*if(colorDown == 6'hFF5757)
		player0_collisionDown <= 1'b1;
	else
		player0_collisionDown <= 0;
		
	if(colorLeft == 6'hFF5757)
		player0_collisionLeft <= 1;
	else
		player0_collisionLeft <= 0;
		
	if(colorRight == 6'hFF5757)
		player0_collisionRight <= 1;
	else
		player0_collisionRight <= 0;*/
		
		
end
	

wire [7:0] upIndex;
output wire [23:0] colorUp;

wire [9:0] xLocToUse;
wire [8:0] yLocToUse;

assign xLocToUse = xLoc0;
assign yLocToUse = yLoc0;

img_data upCollisionDetector(
	.address((yLocToUse-1) * 640 + xLocToUse),
	.clock(procClock),
	.q(upIndex)
	);
	
img_index upCollisionDetector2(
	.address(upIndex),
	.clock(~procClock),
	.q(colorUp)
	);
	
/*wire [7:0] downIndex;
wire [23:0] colorDown;

img_data downCollisionDetector(
	.address((yLoc+1) * 640 + xLoc),
	.clock(procClock),
	.q(downIndex)
	);
	
img_index downCollisionDetector2(
	.address(downIndex),
	.clock(~procClock),
	.q(colorDown)
	);
	
wire [7:0] rightIndex;
wire [23:0] colorRight;

img_data rightCollisionDetector(
	.address((yLoc) * 640 + xLoc + 1),
	.clock(procClock),
	.q(rightIndex)
	);
	
img_index rightCollisionDetector2(
	.address(rightIndex),
	.clock(~procClock),
	.q(colorRight)
	);
	
wire [7:0] leftIndex;
wire [23:0] colorLeft;

img_data leftCollisionDetector(
	.address((yLoc) * 640 + xLoc - 1),
	.clock(procClock),
	.q(leftIndex)
	);
	
img_index leftCollisionDetector2(
	.address(leftIndex),
	.clock(~procClock),
	.q(colorLeft)
	);*/
	
	
	
	
	
	
	
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( realADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);	
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////
//////latch valid data at falling edge;

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











