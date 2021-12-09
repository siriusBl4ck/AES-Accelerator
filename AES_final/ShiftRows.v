module ShiftRows (res, inp);
	input [127:0] inp;
	output [127:0] res;

	assign res = {inp[127:120],inp[87:80],inp[47:40],inp[7:0],
              inp[95:88],inp[55:48],inp[15:8],inp[103:96],
              inp[63:56],inp[23:16],inp[111:104],inp[71:64],
              inp[31:24],inp[119:112],inp[79:72],inp[39:32]};
endmodule