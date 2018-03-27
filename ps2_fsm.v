module ps2_fsm(key_pressed, clock, reset, in, out);

	input key_pressed, clock, reset;
	input [7:0] in;
	output [7:0] out;
	reg [7:0] out;
	reg [31:0] counter;
	reg afterF;
 
	always @ (posedge clock) begin
		 if (reset) begin
			 out = 8'b0;
			 counter = 32'b0;
			 afterF = 1'b0;
		 end
		 else if (counter == 1200000) begin
			 counter = 32'b0;
			 out = 8'b0;
		 end
		 else if (in == 8'b11110000) begin
			 afterF = 1'b1;
		 end
		 else if (afterF) begin
			 counter = 32'b0;
			 out = in;
			 afterF = 1'b0;
		 end
		 else begin
			 counter = counter + 1;
		 end
	end
 
endmodule