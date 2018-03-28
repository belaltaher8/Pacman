module sum_16(a, b, cin, Pin, Gin, s, cout);

	input[15:0] a, b, Pin, Gin;
	input cin;
	output [15:0] s;
	output cout;
	
	wire [7:0] P0, P1, P1_, G0, G1, G1_;
	wire c0, w1, prop0, c8, c8_calc, carry_op1_0, carry_op1_1, prop1, prop1_1, c16_calc;
	wire [15:0] s_op1_0, s_op1_1;
	
	sum_8 sum0(a[7:0], b[7:0], cin, Pin[7:0], Gin[7:0], s[7:0], c8_calc, P0, G0);
	and and0(prop0, P0, cin);
	or or0(c8, prop0, G0);
	
	sum_8 sum1_0(a[15:8], b[15:8], 1'b0, Pin[15:8], Gin[15:8], s_op1_0, carry_op1_0, P1, G1);
	sum_8 sum1_1(a[15:8], b[15:8], 1'b1, Pin[15:8], Gin[15:8], s_op1_1, carry_op1_1, P1_, G1_);
	mux2_1 mux1_0(c8, s_op1_0, s_op1_1, s[15:8]);
	mux2_1 mux1_1(c8, carry_op1_0, carry_op1_1, c16_calc);
	and and1(prop1, P1, G0);
	and and1_1(prop1_1, P1, P0, cin);
	or or1(cout, prop1, prop1_1, G1);

endmodule