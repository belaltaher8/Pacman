module sum_4la(a, b, cin, Pin, Gin, s, cout);

	input [3:0] a, b, Pin, Gin;
	input cin;
	output [3:0] s;
	output cout;
	
	wire c1, c2, c3, prop0, prop1, prop1_1, prop2, prop2_1, prop2_2, prop3, prop3_1, prop3_2, prop3_3;
	
	sum_1la sum0(a[0], b[0], cin, s[0]);
	sum_1la sum1(a[1], b[1], c1, s[1]);
	sum_1la sum2(a[2], b[2], c2, s[2]);
	sum_1la sum3(a[3], b[3], c3, s[3]);
	
	and and0(prop0, Pin[0], cin);
	or or0(c1, prop0, Gin[0]);
	
	and and1(prop1, Pin[1], Gin[0]);
	and and1_1(prop1_1, Pin[1], Pin[0], cin);
	or or1(c2, prop1, prop1_1, Gin[1]);
	
	and and2(prop2, Pin[2], Gin[1]);
	and and2_1(prop2_1, Pin[2], Pin[1], Gin[0]);
	and and2_2(prop2_2, Pin[2], Pin[1], Pin[0], cin);
	or or2(c3, prop2, prop2_1, prop2_2, Gin[2]);
	
	and and3(prop3, Pin[3], Gin[2]);
	and and3_1(prop3_1, Pin[3], Pin[2], Gin[1]);
	and and3_2(prop3_2, Pin[3], Pin[2], Pin[1], Gin[0]);
	and and3_3(prop3_3, Pin[3], Pin[2], Pin[1], Pin[0], cin);
	or or3(cout, prop3, prop3_1, prop3_2, prop3_3, Gin[3]);


endmodule