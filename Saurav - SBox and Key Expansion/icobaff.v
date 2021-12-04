module icobaff(input [7:0]in,output [7:0]out
);
assign out[0]=1^ in[0]^ in[5]^ in[6]^ in[7];
assign out[1]=1^ in[0]^ in[2]^ in[7];
assign out[2]=0^ in[0]^ in[1]^ in[3]^ in[4];
assign out[3]=0^ in[0];
assign out[4]=0^ in[0]^ in[1]^ in[2]^ in[4]^ in[6]^ in[7];
assign out[5]=1^ in[1]^ in[2]^ in[7];
assign out[6]=1^ in[4]^ in[7];
assign out[7]=0^ in[1]^ in[2]^ in[3]^ in[7];
endmodule