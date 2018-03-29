module VGA_clock_converter(CLOCK_50, VGA_clock, clockCounter);

    input CLOCK_50;
    
    output reg VGA_clock;
    
    output reg [31:0] clockCounter;
    
    
    initial begin
        clockCounter <= 32'd0;
        VGA_clock <= 1'b0;
    end
    
    always@(posedge CLOCK_50) begin
    
        
        if(clockCounter == 32'd1000000) begin
            VGA_clock <= ~VGA_clock;
            clockCounter <= 32'd0;
          
        end
        else
            clockCounter <= clockCounter + 32'd1;
    end
    
endmodule