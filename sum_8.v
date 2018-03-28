module sum_8(a, b, cin, Pin, Gin, s, cout, Pout, Gout);

	input[7:0] a, b, Pin, Gin;
	input cin;
	output [7:0] s;
	output cout, Pout, Gout;
	
	wire w0, w1, w2, carry_op0, carry_op1;
	wire [3:0] s_op0, s_op1;
	wire G_0, G_1, G_2, G_3, G_4, G_5, G_6, G_7;
	
	sum_4la sum0(a[3:0], b[3:0], cin, Pin[3:0], Gin[3:0], s[3:0], w0);
	and lookahead(w1, a[3], b[3]);
	or carry_in(w2, w0, w1);
	
	sum_4la sum1_0(a[7:4], b[7:4], 1'b0, Pin[7:4], Gin[7:4], s_op0, carry_op0);
	sum_4la sum1_1(a[7:4], b[7:4], 1'b1, Pin[7:4], Gin[7:4], s_op1, carry_op1);
	
	mux2_1 mux0(w2, s_op0, s_op1, s[7:4]);
	mux2_1 mux1(w2, carry_op0, carry_op1, cout);
	
	and and_p(Pout, Pin[0], Pin[1], Pin[2], Pin[3], Pin[4], Pin[5], Pin[6], Pin[7]);
	assign G_7 = Gin[7];
	and and_0(G_6, Pin[7], Gin[6]);
	and and_1(G_5, Pin[7], Pin[6], Gin[5]);
	and and_2(G_4, Pin[7], Pin[6], Pin[5], Gin[4]);
	and and_3(G_3, Pin[7], Pin[6], Pin[5], Pin[4], Gin[3]);
	and and_4(G_2, Pin[7], Pin[6], Pin[5], Pin[4], Pin[3], Gin[2]);
	and and_5(G_1, Pin[7], Pin[6], Pin[5], Pin[4], Pin[3], Pin[2], Gin[1]);
	and and_6(G_0, Pin[7], Pin[6], Pin[5], Pin[4], Pin[3], Pin[2], Pin[1], Gin[0]);
	or or_g(Gout, G_0, G_1, G_2, G_3, G_4, G_5, G_6, G_7);


endmodule