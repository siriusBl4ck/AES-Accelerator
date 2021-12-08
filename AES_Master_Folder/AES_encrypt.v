module AES_encrypt (clk,
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
	output reg [3:0] skey_addr;
	output [127:0] ciphertext;
	output reg ready;

	reg [1:0] status;
	reg [127:0] result;
	reg [5:0] max_rounds; ////

	wire [127:0] pre_addkey_out, subbytes_out, shiftrows_out, mixcols_out, addkey_in, addkey_out;
	wire addkey_switch;
	assign addkey_switch = (max_rounds==1);
	assign addkey_in = addkey_switch? mixcols_out : shiftrows_out;

	assign ciphertext = result;

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
			ready <= 0;
		end
		else if ((|key_len) && (start) && (status==0))	begin
			status <= 1;
			if (key_len[2]) max_rounds <= 15;
			else if (key_len[1]) max_rounds <= 13;
			else max_rounds <= 11;
			skey_addr <= 0;
			ready <= 0;
		end
		else if (status == 1) begin
			if (subkey_valid) begin
				result <= pre_addkey_out;
				status <= 2;
				skey_addr <= skey_addr+1;
			end
		end
		else if (status == 2) begin
			if (subkey_valid) begin
				max_rounds <= max_rounds-1;
				result <= addkey_out;
				skey_addr <= skey_addr+1;

				if (max_rounds==1) begin
					status <= 0;
					ready <= 1'b1;
				end
			end
		end
	end

endmodule
