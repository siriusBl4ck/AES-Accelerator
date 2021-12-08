module MixColumns (res, inp);
	input [127:0] inp;
	output [127:0] res;

	genvar i;

	for(i=0; i<4; i=i+1)
	begin
		assign res[31+32*i:24+32*i]  = mixer(2, inp[31+32*i:24+32*i]) ^ mixer(3, inp[23+32*i:16+32*i]) ^ mixer(1, inp[15+32*i:8+32*i]) ^ mixer(1, inp[7+32*i:32*i]);
		assign res[23+32*i:16+32*i]   = mixer(1, inp[31+32*i:24+32*i]) ^ mixer(2, inp[23+32*i:16+32*i]) ^ mixer(3, inp[15+32*i:8+32*i]) ^ mixer(1, inp[7+32*i:32*i]);
		assign res[15+32*i:8+32*i]   = mixer(1, inp[31+32*i:24+32*i]) ^ mixer(1, inp[23+32*i:16+32*i]) ^ mixer(2, inp[15+32*i:8+32*i]) ^ mixer(3, inp[7+32*i:32*i]);
		assign res[7+32*i:32*i]       = mixer(3, inp[31+32*i:24+32*i]) ^ mixer(1, inp[23+32*i:16+32*i]) ^ mixer(1, inp[15+32*i:8+32*i]) ^ mixer(2, inp[7+32*i:32*i]);
	end

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
endmodule
