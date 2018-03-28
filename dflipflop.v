module dflipflop(d, clk, clr, ena, q);
    input d, clk, ena, clr;

    output q;
    reg q_int;

	 assign q = q_int;

    initial
    begin
        q_int = 1'b0;
    end
	 
	 //bad for debugging purposes but if d is x, then it writes 0
    always @(posedge clk) begin
        if (q_int == 1'bx) begin
            q_int <= 1'b0;
        end else if (clr) begin
            q_int <= 1'b0;
        end else if (ena) begin
            q_int <= d;
        end
    end
endmodule
