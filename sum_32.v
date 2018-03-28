module sum_32(a, b, cin, Pin, Gin, s, cout);

	input[31:0] a, b, Pin, Gin;
	input cin;
	output [31:0] s;
	output cout;
	
	wire [7:0] P0, P1, P2, P3, P1_, P2_, P3_, G0, G1, G2, G3, G1_, G2_, G3_;
	wire c0, w1, prop0, c8, c8_calc, carry_op1_0, carry_op1_1, prop1, prop1_1, c16, 
									c16_calc, carry_op2_0, carry_op2_1, prop2, prop2_1, prop2_2, c24,
									c24_calc, carry_op3_0, carry_op3_1, prop3, prop3_1, prop3_2, prop3_3,
									c32_calc;
	wire [15:0] s_op1_0, s_op1_1, s_op2_0, s_op2_1, s_op3_0, s_op3_1;
	
	sum_8 sum0(a[7:0], b[7:0], cin, Pin[7:0], Gin[7:0], s[7:0], c8_calc, P0, G0);
	and and0(prop0, P0, cin);
	or or0(c8, prop0, G0);
	
	sum_8 sum1_0(a[15:8], b[15:8], 1'b0, Pin[15:8], Gin[15:8], s_op1_0, carry_op1_0, P1, G1);
	sum_8 sum1_1(a[15:8], b[15:8], 1'b1, Pin[15:8], Gin[15:8], s_op1_1, carry_op1_1, P1_, G1_);
	mux2_1 mux1_0(c8, s_op1_0, s_op1_1, s[15:8]);
	mux2_1 mux1_1(c8, carry_op1_0, carry_op1_1, c16_calc);
	and and1(prop1, P1, G0);
	and and1_1(prop1_1, P1, P0, cin);
	or or1(c16, prop1, prop1_1, G1);
	
	sum_8 sum2_0(a[23:16], b[23:16], 1'b0, Pin[23:16], Gin[23:16], s_op2_0, carry_op2_0, P2, G2);
	sum_8 sum2_1(a[23:16], b[23:16], 1'b1, Pin[23:16], Gin[23:16], s_op2_1, carry_op2_1, P2_, G2_);
	mux2_1 mux2_0(c16, s_op2_0, s_op2_1, s[23:16]);
	mux2_1 mux2_1(c16, carry_op2_0, carry_op2_1, c24_calc);
	and and2(prop2, P2, G1);
	and and2_1(prop2_1, P2, P1, G0);
	and and2_2(prop2_2, P2, P1, P0, cin);
	or or2(c24, prop2, prop2_1, prop2_2, G2);
	
	sum_8 sum3_0(a[31:24], b[31:24], 1'b0, Pin[31:24], Gin[31:24], s_op3_0, carry_op3_0, P3, G3);
	sum_8 sum3_1(a[31:24], b[31:24], 1'b1, Pin[31:24], Gin[31:24], s_op3_1, carry_op3_1, P3_, G3_);
	mux2_1 mux3_0(c24, s_op3_0, s_op3_1, s[31:24]);
	mux2_1 mux3_1(c24, carry_op3_0, carry_op3_1, c32_calc);
	and and3(prop3, P3, G2);
	and and3_1(prop3_1, P3, P2, G1);
	and and3_2(prop3_2, P3, P2, P1, G0);
	and and3_3(prop3_3, P3, P2, P1, P0, cin);
	or or3(cout, prop3, prop3_1, prop3_2, prop3_3, G3);


endmodule