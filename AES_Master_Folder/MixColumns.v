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