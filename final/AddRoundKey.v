/*module xd;
	wire [127:0] res;
	reg [127:0] inp = 128'h046681e5e0cb199a48f8d37a2806264c;
	reg [127:0] sk = 128'ha0fafe1788542cb123a339392a6c7605;
	AddRoundKey A (res, inp, sk);
	reg clk = 0;

	always #5 clk <= ~clk;
	always@(posedge clk) begin
		$display("%h",res);
		$finish;
	end
endmodule*/

module AddRoundKey (res, inp, subkey);
	input [127:0] inp, subkey;
	output [127:0] res;

	assign res = inp ^ subkey;
endmodule