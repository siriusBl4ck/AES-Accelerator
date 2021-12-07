 // 3 modes
 // aes_mode 00 -> 128, 01 -> 192, 10 -> 256, 11 -> 256
 module key_exp_outer(
    input clk,
    input [255:0] short_key,
    input [1:0] aes_mode,
    input reset,
    input [3:0] rkey_addr,
    output reg [127:0] rkey,
    output rdy
 );
    reg [127:0] key_mem [14:0];
    wire [127:0] subkey128;
    wire [127:0] subkey192;
    wire [127:0] subkey256;
    reg [4:0] cnt_limit;
    wire rdy, rdy128, rdy256, rdy192;
    reg rst128 = 1;
    reg rst192 = 1;
    reg rst256 = 1;
    reg start128 = 0;
    reg start192 = 0;
    reg start256 = 0;
    reg [4:0] cnt = 0;

    assign rdy = ~(rdy128 | rdy192 | rdy256);

    always @(*) begin
        case(aes_mode)
            2'b00: cnt_limit = 5'd12;
            2'b01: cnt_limit = 5'd14;
            default: cnt_limit = 5'd16;
        endcase
    end

    AESKeyexpansion_128 s1(clk, rst128, start128, short_key[127:0], subkey128, rdy128);
    //AESKeyexpansion_192 s2(clk, rst192, start192, short_key[191:0], subkey192, rdy192);
    AESKeyexpansion_256 s3(clk, rst256, start256, short_key, subkey256, rdy256);


    always @(posedge clk) begin
        if (~reset) begin
            if (cnt < 1) begin
                if (aes_mode == 2'b00) begin
                    rst128 <= 0;
                    start128 <= 1;
                end
                else if (aes_mode == 2'b01) begin
                    rst192 <= 0;
                    start192 <= 1;
                end
                else begin
                    rst256 <= 0;
                    start256 <= 1;
                end
                cnt <= cnt + 1;
            end
            else if (cnt >= 1 && cnt < cnt_limit) begin
                start128 <= 0;
                start192 <= 0;
                start256 <= 0;

                if (aes_mode == 2'b00) begin
                    key_mem[cnt-1] <= subkey128;
                    $display("writing key_mem[%d] -> %h", cnt-5'd1, subkey128);
                end
                else if (aes_mode == 2'b01) begin
                    key_mem[cnt-1] <= subkey192;
                    $display("key_mem[%d] -> %h", cnt-5'd1, subkey192);
                end
                else begin
                    key_mem[cnt-1] <= subkey256;
                    $display("key_mem[%d] -> %h", cnt-5'd1, subkey256);
                end

                cnt <= cnt + 1;
            end
            else begin
                rst128 <= 1;
                rst192 <= 1;
                rst256 <= 1;
            end
        end
        else begin
            rst128 = 1;
            rst192 = 1;
            rst256 = 1;
            start128 = 0;
            start192 = 0;
            start256 = 0;
            cnt <= 0;
        end
    end

    always @(*) begin
        rkey = key_mem[rkey_addr];
    end
endmodule