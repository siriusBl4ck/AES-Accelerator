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