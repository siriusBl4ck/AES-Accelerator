module gf4_sq_mul_v_v2(input[3:0]x , output [3:0] out);

wire [6:0]c;
assign c[0]=((x[2]^x[0])&1'b1);
assign c[1]=((x[2]^x[0])&1'b0^(x[2])&1'b1);
assign c[2]=((x[2]^x[0])&1'b1^(x[2])&1'b0^(x[3]^x[1])&1'b1);
assign c[3]=((x[2]^x[0])&1'b1^(x[2])&1'b1^(x[3]^x[1])&1'b0^(x[3])&1'b1);
assign c[4]=((x[3])&1'b0^(x[3]^x[1])&1'b1^(x[2])&1'b1);
assign c[5]=((x[3])&1'b1^(x[3]^x[1])&1'b1);
assign c[6]=((x[3])&1'b1);
assign out[3]= (c[6]^c[3]) ;
assign out[2]= ( c[6] ^ c[5] ^  c[2] );
assign out[1]= (c[5] ^ c[4] ^c[1] );
assign out[0]= ( (c[4]) ^c[0]);
endmodule