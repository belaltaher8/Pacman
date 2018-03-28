module sum_4(a, b, cin, s, cout);

	input [3:0] a, b;
	input cin;
	output [3:0] s;
	output cout;
	
	wire [1:0] s0, s1;
	wire w0, w1, w2, cout0, cout1;
	
	sum_2 sum0(a[1:0], b[1:0], cin, s[1:0], w0);
	and lookahead(w1, a[1], b[1]);
	or carry_in(w2, w0, w1);
	
	sum_2 sum1_0(a[3:2], b[3:2], 1'b0, s0, cout0);
	sum_2 sum1_1(a[3:2], b[3:2], 1'b1, s1, cout1);
	
	mux2_1 mux0(w2, s0, s1, s[3:2]);
	mux2_1 mux1(w2, cout0, cout1, cout);


endmodule