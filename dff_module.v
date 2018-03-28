module dff_module(d, clk, ena, sclr, q);

	input d, clk, ena, sclr;
	output q;
	
	reg q_int;
	
	assign q = q_int;
	
	initial begin
		q_int = 1'b0;
	end
	
	always @(posedge clk) begin
		casex({sclr, ena, d})
			3'b01x: q_int = d;
			3'b1xx: q_int = 1'b0;
			default : ;
			
		endcase
	end
	

endmodule