/*
Copyright (c) 2019, Indian Institute of Technology Madras (IIT Madras)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

Neither the name of IIT Madras nor the names of its contributors may be 
used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
THE POSSIBILITY OF SUCH DAMAGE.


--------------------------------------------------------------------------------------------------------------*/
module GF2_4sqr(input [3:0]x , output [3:0]out);

assign out[3]=x[3];
assign out[2]=x[3]^x[1];
assign out[1]=x[2];
assign out[0]=x[2]^x[0];
endmodule
//------------------------------------------------------------------------------------------------------------

module GF2_4sqr_v(input[3:0]x , output [3:0] out);

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
//-----------------------------------------------------------------------------------------------

module GF2_4mult_t(input[3:0]x , input[3:0]y,output [3:0] out);

wire [6:0]c;
wire [6:0]d;
wire [6:0]out1;
assign c[0]=(x[0]&y[0]);
assign c[1]=(x[0]&y[1] ^ x[1]&y[0]);
assign c[2]=(x[0]&y[2] ^ x[1]&y[1] ^ x[2]&y[0]);
assign c[3]=(x[0]&y[3] ^ x[1]&y[2] ^ x[2]&y[1]  ^ x[3]&y[0]);
assign c[4]=(x[3]&y[1] ^ x[2]&y[2] ^ x[1]&y[3]);
assign c[5]=(x[3]&y[2] ^ x[2]&y[3]);
assign c[6]=(x[3]&y[3]);
assign out1[3]= (c[6]^c[3]) ;
assign out1[2]= (c[6] ^ c[5] ^  c[2] );
assign out1[1]= (c[5] ^ c[4] ^c[1] );
assign out1[0]= ((c[4]) ^c[0]);
assign d[0]=(out1[0]&1'b1);
assign d[1]=(out1[0]&1'b0^out1[1]&1'b1);
assign d[2]=(out1[0]&1'b0^out1[1]&1'b0^ out1[2]&1'b1);
assign d[3]=(out1[0]&1'b0^out1[1]&1'b0^ out1[2]&1'b0^out1[3]&1'b1);
assign d[4]=(out1[3]&1'b0^out1[2]&1'b0^ out1[1]&1'b0);
assign d[5]=(out1[3]&1'b0^out1[2]&1'b0);
assign d[6]=(out1[3]&1'b0);
assign out[3]= (d[6]^d[3]) ;
assign out[2]= (d[6] ^ d[5] ^ d[2] );
assign out[1]= (d[5] ^ d[4] ^d[1] );
assign out[0]= ((d[4]) ^d[0]);
endmodule
//------------------------------------------------------------------------------------------------------------

module GF2_4mult( input [3:0]x,input [3:0]y, output [3:0]out);

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
//-----------------------------------------------------------------------------------------------

module invGF2_4(input [3:0]in ,output [3:0]out);

assign out[0]=((~in[0])&(~in[1])&(~in[2])&in[3])|((~in[0])&(~in[3])&in[1])|((~in[0])&in[1]&in[2])|((~in[1])&(~in[3])&in[0])|((~in[1])&(~in[3])&in[2])|((~in[2])&in[0]&in[1]&in[3]);
assign out[1]=((~in[0])&(~in[1])&in[3])|((~in[0])&in[1]&in[2])|((~in[1])&(~in[2])&in[3])|((~in[3])&in[0]&in[1])|((~in[3])&in[0]&in[2])|((~in[3])&in[1]&in[2]);
assign out[2]=((~in[0])&(~in[2])&in[3])|((~in[0])&(~in[3])&in[2])|((~in[1])&in[0]&in[2]&in[3])|((~in[2])&in[0]&in[1])|((~in[3])&in[0]&in[1]);
assign out[3]=((~in[0])&(~in[1])&in[2])|((~in[0])&(~in[2])&in[3])|((~in[1])&(~in[3])&in[2])|((~in[2])&(~in[3])&in[1])|(in[0]&in[1]&in[2]&in[3]);
endmodule

//-----------------------------------------------------------------------------------------------

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

//-----------------------------------------------------------------------------------------------------------------
module cob(input [7:0]in,output [7:0]out
);
assign out[0] =in[1]^ in[0]^ in[3]^ in[2]^ in[7];
assign out[1] =in[1]^ in[4]^ in[6];
assign out[2] =in[3]^ in[2]^ in[7]^ in[6];
assign out[3] =in[1]^ in[2]^ in[7]^ in[6];
assign out[4] =in[3]^ in[2]^ in[4]^ in[7]^ in[6];
assign out[5] =in[3]^ in[2]^ in[5]^ in[7];
assign out[6] =in[1]^ in[5]^ in[4]^ in[6];
assign out[7] =in[5]^ in[7];
endmodule

//-----------------------------------------------------------------------------------------------------------------
module invGF2_4_2( input [7:0]a,output [7:0]c);

wire [3:0]ah;
wire [3:0]al;//ah and al are top and bottom slices of a
wire [3:0]t;
assign t =4'b1;
wire [3:0]b; // b is output inv in GF(2^4)
wire [3:0]d0;
wire [3:0]d1;
wire [3:0]out1;
wire [3:0]out3;
wire [3:0]out4;
wire [3:0]out6;
assign al[0]=a[0];
assign al[1]=a[1];
assign al[2]=a[2];
assign al[3]=a[3];
assign ah[0]=a[4];
assign ah[1]=a[5];
assign ah[2]=a[6];
assign ah[3]=a[7];
 GF2_4sqr_v sqr1(
 .x(ah),
 .out(out1)
);
GF2_4mult_t mult2(
 .x(ah),
 .y(al),
 .out(out3)
);
GF2_4sqr sqr2(
 .x(al),
 .out(out4)
);
invGF2_4 inv240(
 .in((out1^out3^out4)  ),
 .out(b)
 );
GF2_4mult mult4(
 .x(ah),
 .y(b),
 .out(d1)
);
GF2_4mult mult5(
 .x(ah),
 .y(t),
 .out(out6)
);
GF2_4mult mult6(
 .x(out6^al),
 .y(b),
 .out(d0)
);
assign c[0]=d0[0];
assign c[1]=d0[1];
assign c[2]=d0[2];
assign c[3]=d0[3];
assign c[4]=d1[0];
assign c[5]=d1[1];
assign c[6]=d1[2];
assign c[7]=d1[3];
endmodule
//-----------------------------------------------------------------------------------------------------------------
module sbox_v2(input [7:0]in, output [7:0]out
);
wire [7:0]temp1;
wire [7:0]temp2;
cob cob1(
.in(in),
.out(temp1)
);
invGF2_4_2 invGF2420(
.a(temp1),
.c(temp2)
);
icobaff icobaff1(
.in(temp2),
.out(out)
);
endmodule
//--------------------------------------------------------------------------------------------------------------------
//*------------------------------------------------------  TESTBENCH  -------------------------------------
/*
module testsbox();
reg [7:0]in;
wire [7:0]out;
reg clock;
integer i;
initial begin
clock = 0;
forever begin
#2 clock= ~clock;
end
end
SBOX SBOXtb(
.in(in),
.out(out)
);
initial
begin
for (i = 0; i < 256; i = i + 1) begin
#2
in=i;
$strobe(in,,out);
end
end
endmodule
*/
