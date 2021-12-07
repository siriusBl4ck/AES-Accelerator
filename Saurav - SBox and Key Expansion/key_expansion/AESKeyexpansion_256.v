module AESKeyexpansion_256(
    input clk,
    input reset,
    input start,
    input [255:0] short_key,
    output [127:0] subkey
    output rdy
);

reg [5:0] i;
reg [127:0] prev_period_key_1, prev_period_key_2;
reg status;

wires [31:0] key1, key2, key3, key4;

current_word_gen_256 word1(.i(i),.prev_word(prev_period_key_2[31:0]),.prev_period_word(prev_period_key_1[127:96]),.current_word(key1));
current_word_gen_256 word2(.i(i+1),.prev_word(key1),.prev_period_word(prev_period_key_1[95:64]),.current_word(key2));
current_word_gen_256 word3(.i(i+2),.prev_word(key2),.prev_period_word(prev_period_key_1[63:32]),.current_word(key3));
current_word_gen_256 word4(.i(i+3),.prev_word(key3),.prev_period_word(prev_period_key_1[31:0]),.current_word(key4));

assign subkey = {key1, key2, key3, key4};
assign rdy = status;

always @(posedge clk)
begin
    if(reset) begin
       i <= 8;
       prev_period_key_1 <= 0;
       prev_period_key_2 <= 0;
       status <= 0;
    end
    else begin
        if(start) begin
            i <= 8;
            prev_period_key_1 <= short_key[255:128];
            prev_period_key_2 <= short_key[127:0];
            status <= 1;
        end
        else if(status && i<56) begin
            prev_period_key_1 <= prev_period_key_2;
            prev_period_key_2 <= {key1,key2,key3,key4};
            i <= i+4;
        end
        else if(i==56) begin
            i <= 8;
            status <= 0;
            prev_period_key_1 <= 0;
            prev_period_key_2 <= 0;
        end
    end
end
endmodule

  