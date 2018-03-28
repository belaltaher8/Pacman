module one_bit_add_sub(a, b, cin, s, cout);

	input a, b, cin;
	output s, cout;
	
	wire w1, w2, w3;

	xor xor0(w1, a, b);
	xor xor1(s, w1, cin);
	nand nand0(w2, w1, cin);
	nand nand1(w3, a, b);
	or or0(cout, ~w2, ~w3);


endmodule