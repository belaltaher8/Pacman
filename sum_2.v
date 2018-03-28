module sum_2(a, b, cin, s, cout);

	input [1:0] a, b;
	input cin;
	output [1:0] s;
	output cout;
	
	wire w0, w1, w2;
	
	sum_1 sum0(a[0], b[0], cin, s[0], w0);
	and lookahead(w1, a[0], b[0]);
	or carry_in(w2, w0, w1);
	
	sum_1 sum1_0(a[1], b[1], w2, s[1], cout);

endmodule