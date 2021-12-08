module AESKeyexpansion_128(
    input clk,
    input reset,
    input start,
    input [127:0] short_key,
    output [127:0] subkey,
    output reg rdy
);

reg [5:0] i;
reg [127:0] prev_period_key_1;

wire [31:0] key1, key2, key3, key4;
//w[i] <- w[i-1]
current_word_gen_128 word1(.i(i),.prev_word(prev_period_key_1[31:0]),.prev_period_word(prev_period_key_1[127:96]),.current_word(key1));
current_word_gen_128 word2(.i(i+6'd1),.prev_word(key1),.prev_period_word(prev_period_key_1[95:64]),.current_word(key2));
current_word_gen_128 word3(.i(i+6'd2),.prev_word(key2),.prev_period_word(prev_period_key_1[63:32]),.current_word(key3));
current_word_gen_128 word4(.i(i+6'd3),.prev_word(key3),.prev_period_word(prev_period_key_1[31:0]),.current_word(key4));

assign subkey = (start && i==0)? short_key : {key1, key2, key3, key4};

always @(posedge clk)
begin
    if(reset) begin
       i <= 0;
       prev_period_key_1 <= 0;
       rdy <= 0;
    end
    else if (start | rdy) begin
        if(i < 4) begin
            i <= i + 4;
            prev_period_key_1 <= short_key;
            rdy <= 1;
        end
        else if(i >= 4 && i<40) begin
            prev_period_key_1 <= {key1,key2,key3,key4};
            i <= i+4;
            rdy <= 1;
        end
        else if(i==40) begin
            i <= 0;
            rdy <= 0;
            prev_period_key_1 <= 0;
        end
    end
end
endmodule