module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
                      ps2_key_data_in,
                      player0_x, player0_y, powerup0_x, powerup0_y);


input [7:0] ps2_key_data_in;

input [31:0] player0_x, player0_y; 
input [31:0] powerup0_x, powerup0_y;


input iRST_n;
input iVGA_CLK;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;
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
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
end

//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////






//Creates register for the block and initializes value
reg [9:0] xLoc;
reg [8:0] yLoc;
reg [9:0] width;
reg [8:0] height;
wire [9:0] xADDR;
wire [8:0] yADDR; 
reg [9:0] xADDRToCompare;
reg [8:0] yADDRToCompare;

reg [9:0] powerup1xLocToRender;
reg [8:0] powerup1yLocToRender; 

reg [31:0] clockCounter;

initial begin
    xLoc <= 10'b0000000000;
    yLoc <=  9'b000000000;
    
    width <=  10'b0000100000;
    height <=  9'b000100000;
	 
	 
	 powerup1xLocToRender <= 10'b0000000000;
	 powerup1yLocToRender <=  9'b000000000;
    
    
end

addrConverter myAddrConverterPlayer0(ADDR, VGA_CLK_n, xADDR, yADDR);

 always@(posedge VGA_CLK_n) begin
 
    //Updates player 0 location
    xLoc <= player0_x[9:0];
    yLoc <= player0_y[8:0];
		  
	 //Checks to see if the powerup has been collected yet	  
    powerup1xLocToRender <= powerup0_x[9:0];
	 powerup1yLocToRender <= powerup0_y[8:0];

 
 
    xADDRToCompare <= xADDR;
    yADDRToCompare <= yADDR;
    
    if(      (xADDRToCompare > xLoc) && (xADDRToCompare < xLoc + width) && (yADDRToCompare > yLoc) && (yADDRToCompare < yLoc + height) )
        color <= 23'b111111110000000000000000;
		  
    else if( (xADDRToCompare > powerup1xLocToRender) && (xADDRToCompare < powerup1xLocToRender + width) && (yADDRToCompare > powerup1yLocToRender) && (yADDRToCompare < powerup1yLocToRender + height) )
		  color <= 23'b000000001111111100000000;
		  
    else
        color <= bgr_data_raw;  
		 
	 

end





//////Add switch-input logic here
	
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











