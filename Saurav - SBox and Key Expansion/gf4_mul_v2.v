module gf4_mul_v2( input [3:0]x,input [3:0]y, output [3:0]out);

wire [6:0]c;
assign c[0]=(x[0]&y[0]);
assign c[1]=(x[0]&y[1] ^ x[1]&y[0]);
assign c[2]=(x[0]&y[2] ^ x[1]&y[1] ^ x[2]&y[0]);
assign c[3]=(x[0]&y[3] ^ x[1]&y[2] ^ x[2]&y[1]  ^ x[3]&y[0]);
assign c[4]=(x[3]&y[1] ^ x[2]&y[2] ^ x[1]&y[3]);
assign c[5]=(x[3]&y[2] ^ x[2]&y[3]);
assign c[6]=(x[3]&y[3]);
assign out[3]= (c[6]^c[3]) ;
assign out[2]= ( c[6] ^ c[5] ^  c[2] );
assign out[1]= (c[5] ^ c[4] ^c[1] );
assign out[0]= ( (c[4]) ^c[0]);
endmodule