 module key_exp_outer(
    input clk,
    input reset,
    input start,
    input [255:0] short_key,
    input [1:0] key_len,
    output valid,                                 //Subkey valid or not
    output reset_valid_bits,
    output [3:0] waddr,
    output [127:0] subkey
 );
    wire [127:0] subkey128;
    wire [127:0] subkey192;
    wire [127:0] subkey256;
    wire valid_skey128, valid_skey192, valid_skey256;
    wire[3:0] cnt128, cnt192, cnt256;

    reg start128, start192, start256; 
    reg [255:0] prev_key;
    reg [1:0] key_len_reg;
    reg [127:0] subkey;
    reg reset_valid_bits;
    reg [3:0] waddr;

    assign valid = (valid_skey128 | valid_skey192 | valid_skey256);

    always @(*) begin
        case(key_len_reg)
            2'b01: begin
                subkey = subkey128;
                waddr = cnt128;
            end
            2'b10: begin
                subkey = subkey192;
                waddr = cnt192;
            end
            2'b11: begin 
                subkey = subkey256;
                waddr = cnt256;
            end
            2'b00: subkey = 0; 
        endcase
    end
    
    AESKeyexpansion_128 s1(clk, reset, start128, short_key[255:128], subkey128, cnt128, valid_skey128);
    AESKeyexpansion_192 s2(clk, reset, start192, short_key[255:64], subkey192, cnt192, valid_skey192);
    AESKeyexpansion_256 s3(clk, reset, start256, short_key, subkey256, cnt256, valid_skey256);

    always @(posedge clk) begin
        if(reset) begin
            prev_key <= 0;
            key_len_reg <= 0;
            start128 <= 0;
            start192 <= 0;
            start256 <= 0;
            reset_valid_bits <= 0;
            $display("key_exp reset");
        end
        else begin
            if(start) begin
                if(prev_key == short_key) begin
                    key_len_reg <= 0;
                    start128 <= 0;
                    start192 <= 0;
                    start256 <= 0;
                    reset_valid_bits <= 0;
                end
                else begin
                    $display($time, "key sampled");
                    key_len_reg <= key_len;
                    prev_key <= short_key;
                    reset_valid_bits <= 1;
                    case(key_len)
                    2'b01: start128 <= 1;
                    2'b10: start192 <= 1;
                    2'b11: start256 <= 1;
                    2'b00: begin
                        start128 <= 0;
                        start192 <= 0;
                        start256 <= 0;
                    end
                    endcase
                end
            end
            else begin
                start128 <= 0;
                start192 <= 0;
                start256 <= 0;
                reset_valid_bits <= 0;
              //  if (valid) $display("key-exp skey %h", subkey );
            end
        end
    end
endmodule