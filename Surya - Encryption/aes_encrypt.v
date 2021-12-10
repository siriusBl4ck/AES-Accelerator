
module tb;
	reg clk=0, reset=1;
	reg [31:0] st=0;

	reg [127:0] plaintext;
	reg [255:0] key;
	reg [2:0] key_len;

	always #5 clk <= ~clk;

	wire [127:0] ciphertext;
	wire ready;

	integer i;
	aes_encrypt A(clk, reset, plaintext, key, key_len, ciphertext, ready);

	always@(posedge clk) begin
		if (st==0) begin
			reset <=1;
			st <= 1;
		end

		if (st==1) begin
			reset <= 0;

		plaintext <= 128'hab123;
		key <= 256'h10ae3;
		key_len <= 3'b101;
		st <= 2;
		end
		if (st==2) begin
			if(ready) begin
				$display($time," CT-%h", ciphertext);
				$finish;
			end
			else
				$display($time, "- waiting..");
		end
	end
endmodule

module SubBytes (res, inp);
	input [127:0] inp;
	output [127:0] res;

	function automatic [7:0] sbox; ////////
		input byte_in;
		begin
			sbox = 8'd0;
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

module aes_encrypt (clk,
	     reset,
	     plaintext,
	     key,
		 key_len,
		 ciphertext,
		 ready
		 );
	input clk, reset;
	//input [7:0] plaintext [15:0]; //fixed size
	//input [7:0] key [31:0]; //max size
	input [127:0] plaintext;
	input [255:0] key;
	input [2:0] key_len; //if all 0 then invalid inputs
	//output [7:0] ciphertext [15:0];
	output [127:0] ciphertext;
	output reg ready;

	//Key expansion module here - key is used instead for now

	wire [127:0] tempkey;
	assign tempkey = key[127:0];

	reg status;
	reg [127:0] result;
	reg [5:0] max_rounds; ////

	wire [127:0] pre_addkey_out, subbytes_out, shiftrows_out, mixcols_out, addkey_in, addkey_out;
	wire addkey_switch;
	assign addkey_switch = (max_rounds==1);
	assign addkey_in = addkey_switch? mixcols_out : shiftrows_out;

	assign ciphertext = result;

	AddRoundKey A1(pre_addkey_out, plaintext, tempkey);

	SubBytes SB(subbytes_out, result);
	ShiftRows SR(shiftrows_out, subbytes_out);
	MixColumns M(mixcols_out, shiftrows_out);
	AddRoundKey A2(addkey_out, addkey_in, tempkey);

	always@(posedge clk) begin
		if (reset) begin
			status <= 0;
			result <= 0;
			max_rounds <= 0; 
			$display($time," hi reset");
		end

		else if ((|key_len) && (status==0))	begin
			$display($time," init");
			status <= 1;
			if (key_len[2]) 	max_rounds <= 14;
			else if (key_len[1]) max_rounds <= 12;
			else max_rounds <= 10;
			result <= pre_addkey_out;
		end

		else if (status==1) begin
			$display($time," free %d, %h", max_rounds, result);
			max_rounds <= max_rounds-1;
			result <= addkey_out;

			if (max_rounds==1) begin
				status <= 0;
				ready <= 1'b1;
			end
		end
	end

endmodule






/*
module aes_encrypt (clk,
	     reset,
	     plaintext,
	     key,
		 key_len,
		 ciphertext,
		 ready
		 );
	input clk, reset;
	input [7:0] plaintext [15:0]; //fixed size
	input [7:0] key [31:0]; //max size
	input [2:0] key_len, //if all 0 then invalid inputs
	output reg [7:0] ciphertext [15:0];
	output ready;

	assign ready = (max_rounds==0);

	//Key expansion module here - key is used instead for now

	wire [7:0][15:0] tempkey;
	assign tempkey = key[15:0];

	reg status;
	reg [7:0] result [15:0];
	reg [5:0] max_rounds; ////

	function automatic [7:0] sbox; ////////
		input byte_in;
		begin
			sbox = 8'd0;
		end
	endfunction

	function automatic [7:0][15:0] SubBytes(input [7:0] inp [15:0]);
		begin
		integer i=0;

		for(i=0; i<16: i=i+1)
			SubBytes[i] = sbox(inp[i]);
		end
	endfunction

	function automatic [7:0][15:0] ShiftRows(input [7:0] inp[15:0]);
		begin
			ShiftRows[0] = inp[0];
			ShiftRows[1] = inp[1];
			ShiftRows[2] = inp[2];
			ShiftRows[3] = inp[3];
			ShiftRows[4] = inp[5];
			ShiftRows[5] = inp[6];
			ShiftRows[6] = inp[7];
			ShiftRows[7] = inp[4];
			ShiftRows[8] = inp[10];
			ShiftRows[9] = inp[11];
			ShiftRows[10] = inp[8];
			ShiftRows[11] = inp[9];
			ShiftRows[12] = inp[15];
			ShiftRows[13] = inp[12];
			ShiftRows[14] = inp[13];
			ShiftRows[15] = inp[14];
		end
	endfunction

	function automatic [7:0] mixer(integer i, input [7:0] inp);
	begin
		reg [7:0] temp=0, temp=0;
		if(i==1)
			mixer = inp;
		else if(i==2)
		begin
			if(inp[7]) temp = 8'h1b;
			mixer = (inp<<1)^temp;
		end
		else
		begin
			if(inp[7]) temp = 8'h1b;
			mixer = inp^(inp<<1)^temp;
		end
	end
	endfunction

	/*
	| 2 3 1 1 |
	| 1 2 3 1 |
	| 1 1 2 3 |
	| 3 1 1 2 |
	*/
/*
	function automatic [7:0][15:0] MixColumns(input [7:0] inp [15:0]);
	begin
		integer i;

		for(i=0; i<4; i=i+1)
		begin
			MixColumns[i] = mixer(2, inp[i]) ^ mixer(3, inp[4+i]) ^ mixer(1, inp[8+i]) ^ mixer(1, inp[12+i]);
			MixColumns[4+i] = mixer(1, inp[i]) ^ mixer(2, inp[4+i]) ^ mixer(3, inp[8+i]) ^ mixer(1, inp[12+i]);
			MixColumns[8+i] = mixer(1, inp[i]) ^ mixer(1, inp[4+i]) ^ mixer(2, inp[8+i]) ^ mixer(3, inp[12+i]);
			MixColumns[12+i] = mixer(3, inp[i]) ^ mixer(1, inp[4+i]) ^ mixer(1, inp[8+i]) ^ mixer(2, inp[12+i]);
		end
	end
	endfunction

	function automatic [7:0][15:0] AddRoundKey(input [7:0] inp_text [15:0],	input [7:0] subkey [15:0]);
		begin
			integer i;

			for(i=0; i<16; i=i+1)
				AddRoundKey[i] = inp_text[i]^subkey[i];
		end
	endfunction

	always@(posedge clk)	begin
		if (reset) begin
			status <= 0;
			result <= 0;
			max_rounds <= 0; 
			ready <= 1;
		end

		else if ((|key_len) && (status==0))	begin
			status <= 1;
			if (key_len[2]) 	max_rounds <= 14;
			else if (key_len[1]) max_rounds <= 12;
			else max_rounds <= 10;
			result <= AddRoundKey(plaintext, tempkey);
			////pass key and keylen
		end

		else if (status==1) begin
			max_rounds <= max_rounds-1;

			if (max_rounds > 1) //optimisations possible
				result <= AddRoundKey(MixColumns(ShiftRows(SubBytes(result))), tempkey);
			else begin
				ciphertext <= AddRoundKey(ShiftRows(SubBytes(result)), tempkey);
				result <= 0;
				status <= 0;
			end
		end
	end
endmodule
*/

