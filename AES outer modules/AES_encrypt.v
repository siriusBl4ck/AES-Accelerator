
module aes_encrypt (clk,
	     reset,
	     plaintext,
		 start,
		 key_len,
		 ciphertext,
		 ready,
		 subkey,
		 subkey_addr,
		 subkey_valid
		 );
	input clk, reset, start;
	input [127:0] plaintext;
	input [2:0] key_len;
	input [127:0] subkey;
	input subkey_valid;
	output [3:0] subkey_addr;
	output [127:0] ciphertext;
	output reg ready;

	reg status;
	reg [127:0] result;
	reg [5:0] max_rounds; ////
	reg [3:0] skey_addr;

	wire [127:0] pre_addkey_out, subbytes_out, shiftrows_out, mixcols_out, addkey_in, addkey_out;
	wire addkey_switch;
	assign addkey_switch = (max_rounds==1);
	assign addkey_in = addkey_switch? mixcols_out : shiftrows_out;

	assign ciphertext = result;

	//assign subkey_addr =  (|key_len) && (start) && (status==0)


	AddRoundKey A1(pre_addkey_out, plaintext, subkey);

	SubBytes SB(subbytes_out, result);
	ShiftRows SR(shiftrows_out, subbytes_out);
	MixColumns M(mixcols_out, shiftrows_out);
	AddRoundKey A2(addkey_out, addkey_in, subkey);

	always@(posedge clk) begin
		if (reset) begin
			status <= 0;
			result <= 0;
			max_rounds <= 0; 
		end
		else if ((|key_len) && (start) && (status==0))	begin
			status <= 1;
			if (key_len[2]) 	max_rounds <= 14;
			else if (key_len[1]) max_rounds <= 12;
			else max_rounds <= 10;
			result <= pre_addkey_out;
			skey_addr <= 0;
		end
		else if (status == 1) begin
			if (subkey_valid) begin
				result <= pre_addkey_out;
				status <= 2;
				skey_addr <= skey_addr+1;
			end
		end
		else if (status == 2) begin
			max_rounds <= max_rounds-1;
			result <= addkey_out;
			skey_addr <= skey_addr+1;
			
			if (max_rounds==1) begin
				status <= 0;
				ready <= 1'b1;
			end
		end
	end

endmodule

module SubBytes (res, inp);
	input [127:0] inp;
	output [127:0] res;

	function automatic [7:0] sbox;
    input [7:0] in_byte;
    reg [7:0] out_iso;
    reg [3:0] g0;
    reg [3:0] g1;
    reg [3:0] g1_g0_t;
    reg [3:0] g0_sq;
    reg [3:0] g1_sq_mult_v;
    reg [3:0] inverse;
    reg [3:0] d0;
    reg [3:0] d1;
    
    begin
    out_iso = isomorph(in_byte);

    g1 = out_iso[7:4];
    g0 = out_iso[3:0];

    g1_g0_t = gf4_mul(g1, g0);
    g0_sq = gf4_sq(g0);
    g1_sq_mult_v = gf4_sq_mul_v(g1);

    inverse = gf4_inv((g1_g0_t ^ g0_sq ^ g1_sq_mult_v));

    d1 = gf4_mul(g1, inverse);
    d0 = gf4_mul((g0 ^ g1), inverse);

    sbox = inv_isomorph_and_affine({d1, d0});
    end
    endfunction

	function automatic [7:0] isomorph;
		input [7:0] a;
		begin
			isomorph[7] =a[5] ^ a[7];
			isomorph[6] =a[1] ^ a[5] ^ a[4] ^ a[6];
			isomorph[5] =a[3] ^ a[2] ^ a[5] ^ a[7];
			isomorph[4] =a[3] ^ a[2] ^ a[4] ^ a[7] ^ a[6];
			isomorph[3] =a[1] ^ a[2] ^ a[7] ^ a[6];
			isomorph[2] =a[3] ^ a[2] ^ a[7] ^ a[6];
			isomorph[1] =a[1] ^ a[4] ^ a[6];
			isomorph[0] =a[1] ^ a[0] ^ a[3] ^ a[2] ^ a[7];
		end
	endfunction

	function automatic [3:0] gf4_sq;
		input [3:0] a;
		begin
		gf4_sq[3] = a[3];
		gf4_sq[2] = a[1] ^ a[3];
		gf4_sq[1] = a[2];
		gf4_sq[0] = a[0] ^ a[2];
		end
	endfunction

	function automatic [3:0] gf4_sq_mul_v;
		input [3:0] a;

		reg [3:0] a_sq;

		reg [3:0] a_1;
		reg [3:0] a_2;
		reg [3:0] a_3;

		reg [3:0] p_0;
		reg [3:0] p_1;
		reg [3:0] p_2;

		begin
		a_sq[3] = a[3];
		a_sq[2] = a[1] ^ a[3];
		a_sq[1] = a[2];
		a_sq[0] = a[0] ^ a[2];

		p_0 = a_sq;
		a_1 = {a_sq[2:0], 1'b0} ^ ((a_sq[3])? 4'b0011 : 4'b0);

		p_1 = p_0;
		a_2 = {a_1[2:0], 1'b0} ^ ((a_1[3])? 4'b0011 : 4'b0);

		p_2 = p_1 ^ a_2;
		a_3 = {a_2[2:0], 1'b0} ^ ((a_2[3])? 4'b0011 : 4'b0);

		gf4_sq_mul_v = p_2 ^ a_3;
		end
	endfunction

	function automatic [3:0] gf4_mul;
		input [3:0] a;
		input [3:0] b;
		reg [3:0] a_1;
		reg [3:0] a_2;
		reg [3:0] a_3;

		reg [3:0] p_0;
		reg [3:0] p_1;
		reg [3:0] p_2;
		begin
		p_0 = (b[0])? a : 4'b0;
		a_1 = {a[2:0], 1'b0} ^ ((a[3])? 4'b0011 : 4'b0);

		p_1 = p_0 ^ ((b[1])? a_1 : 4'b0);
		a_2 = {a_1[2:0], 1'b0} ^ ((a_1[3])? 4'b0011 : 4'b0);

		p_2 = p_1 ^ ((b[2])? a_2 : 4'b0);
		a_3 = {a_2[2:0], 1'b0} ^ ((a_2[3])? 4'b0011 : 4'b0);

		gf4_mul = p_2 ^ ((b[3])? a_3 : 4'b0);
		end
	endfunction

	function automatic [3:0] gf4_inv;
		input [3:0] a;
		begin
		gf4_inv[3] = (a[3] & a[2] & a[1] & a[0]) | (~a[3] & ~a[2] & a[1]) | (~a[3] & a[2] & ~a[1]) | (a[3] & ~a[2] & ~a[0]) | (a[2] & ~a[1] & ~a[0]);
		gf4_inv[2] = (a[3] & a[2] & ~a[1] & a[0]) | (~a[3] & a[2] & ~a[0]) | (a[3] & ~a[2] & ~a[0]) | (~a[2] & a[1] & a[0]) | (~a[3] & a[1] & a[0]);
		gf4_inv[1] =  (a[3] & ~a[2] & ~a[1]) | (~a[3] & a[1] & a[0]) | (~a[3] & a[2] & a[0]) | (a[3] & a[2] & ~a[0]) | (~a[3] & a[2] & a[1]);
		gf4_inv[0] = (a[3] & ~a[2] & ~a[1] & ~a[0]) | (a[3] & ~a[2] & a[1] & a[0]) | (~a[3] & ~a[1] & a[0]) | (~a[3] & a[1] & ~a[0]) | (a[2] & a[1] & ~a[0]) | (~a[3] & a[2] & ~a[1]);
		end
	endfunction

	function automatic [7:0] inv_isomorph_and_affine;
		input [7:0] delta;
		begin
		inv_isomorph_and_affine[7] = delta[1] ^ delta[2] ^ delta[3] ^ delta[7];
		inv_isomorph_and_affine[6] = ~(delta[4] ^ delta[7]);
		inv_isomorph_and_affine[5] = ~(delta[1] ^ delta[2] ^ delta[7]);
		inv_isomorph_and_affine[4] = delta[0] ^ delta[1] ^ delta[2] ^ delta[4] ^ delta[6] ^ delta[7];
		inv_isomorph_and_affine[3] = delta[0];
		inv_isomorph_and_affine[2] = delta[0] ^ delta[1] ^ delta[3] ^ delta[4];
		inv_isomorph_and_affine[1] = ~(delta[0] ^ delta[2] ^ delta[7]);
		inv_isomorph_and_affine[0] = ~(delta[0] ^ delta[5] ^ delta[6] ^ delta[7]);
		end
	endfunction

	genvar i;
	for(i=0; i<120; i=i+8)
		assign res[i+7:i] = sbox(inp[i+7:i]);
endmodule

module ShiftRows (res, inp);
	input [127:0] inp;
	output [127:0] res;

	assign res[7:0]     = inp[7:0];
	assign res[15:8]    = inp[15:8];
	assign res[23:16]   = inp[23:16];
	assign res[31:24]   = inp[31:24];
	assign res[39:32]   = inp[47:40];
	assign res[47:40]   = inp[55:48];
	assign res[55:48]   = inp[63:56];
	assign res[63:56]   = inp[39:32];
	assign res[71:64]   = inp[87:80];
	assign res[79:72]   = inp[95:88];
	assign res[87:80]   = inp[71:64];
	assign res[95:88]   = inp[79:72];
	assign res[103:96]  = inp[127:120];
	assign res[111:104] = inp[103:96];
	assign res[119:112] = inp[111:104];
	assign res[127:120] = inp[119:112];
endmodule

module MixColumns (res, inp);
	input [127:0] inp;
	output [127:0] res;

	genvar i;

	function automatic [7:0] mixer(input integer i, input [7:0] inp);
	begin:a1
		reg [7:0] temp;
		if(i==1)
			mixer = inp;
		else if(i==2)
		begin
			if(inp[7]) temp = 8'h1b;
			else temp = 0;
			mixer = (inp<<1)^temp;
		end
		else
		begin
			if(inp[7]) temp = 8'h1b;
			else temp = 0;
			mixer = inp^(inp<<1)^temp;
		end
	end
	endfunction

	for(i=0; i<4; i=i+1)
	begin
		assign res[8*i     +7:8*i]      = mixer(2, inp[8*i+7:8*i]) ^ mixer(3, inp[8*(4+i)+7:8*(4+i)]) ^ mixer(1, inp[8*(8+i) +7:8*(8+i)]) ^ mixer(1, inp[8*(12+i)+7:8*(12+i)]);
		assign res[8*(4+i) +7:8*(4+i)]  = mixer(1, inp[8*i+7:8*i]) ^ mixer(2, inp[8*(4+i)+7:8*(4+i)]) ^ mixer(3, inp[8*(8+i) +7:8*(8+i)]) ^ mixer(1, inp[8*(12+i)+7:8*(12+i)]);
		assign res[8*(8+i) +7:8*(8+i)]  = mixer(1, inp[8*i+7:8*i]) ^ mixer(1, inp[8*(4+i)+7:8*(4+i)]) ^ mixer(2, inp[8*(8+i) +7:8*(8+i)]) ^ mixer(3, inp[8*(12+i)+7:8*(12+i)]);
		assign res[8*(12+i)+7:8*(12+i)] = mixer(3, inp[8*i+7:8*i]) ^ mixer(1, inp[8*(4+i)+7:8*(4+i)]) ^ mixer(1, inp[8*(8+i) +7:8*(8+i)]) ^ mixer(2, inp[8*(12+i)+7:8*(12+i)]);
	end
endmodule

module AddRoundKey (res, inp, subkey);
	input [127:0] inp, subkey;
	output [127:0] res;

	assign res = inp ^ subkey;
endmodule

