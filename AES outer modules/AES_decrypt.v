module AES_decrypt(
    input clk,
    input reset,
    input start,
    input [1:0] key_len,
    output ready,
    input [127:0] ciphertext,
    output [127:0] plaintext,
    input [127:0] subkey,
    input subkey_valid,
    output [3:0] subkey_addr
);

    reg ready;
    reg [1:0] status;
    reg [127:0] plaintext;
    reg [3:0] skey_addr;

    wire [127:0] output_1, invshiftrows_out;
    wire [127:0] invsubbytes_out, addkey_out, invmixcols_out;

    Addkey inst (ciphertext,subkey,output_1);

    wire [31:0] rowin1, rowin2, rowin3, rowin4;
    assign subkey_addr = skey_addr;
    assign rowin1 = {plaintext[127:120], plaintext[95:88], plaintext[63:56], plaintext[31:24]};
    assign rowin2 = {plaintext[119:112], plaintext[87:80], plaintext[55:48], plaintext[23:16]};
    assign rowin3 = {plaintext[111:104], plaintext[79:72], plaintext[47:40], plaintext[15:8]};
    assign rowin4 = {plaintext[103:96], plaintext[71:64], plaintext[39:32], plaintext[7:0]};

    InvShiftrows inst_1 (rowin1, rowin2, rowin3, rowin4, invshiftrows_out);
    InvSubBytes inst_1 (invshiftrows_out, invsubbytes_out);
    Addkey inst_1 (invsubbytes_out, subkey, addkey_out);

    wire [31:0] colin1, colin2, colin3, colin4;

    assign colin1 = {addkey_out[127:120],addkey_out[119:112], addkey_out[111:104], addkey_out[103:96]};
    assign colin2 = {addkey_out[95:88], addkey_out[87:80], addkey_out[79:72], addkey_out[71:64]};
    assign colin3 = {addkey_out[63:56], addkey_out[55:48], addkey_out[47:40], addkey_out[39:32]};
    assign colin4 = {addkey_out[31:24], addkey_out[23:16], addkey_out[15:8], addkey_out[7:0]};

    InvMixCols inst_1 (colin1, colin2, colin3, colin4, invmixcols_out);

    always @(posedge clk) begin
        if(reset) begin
            ready <= 0;
            plaintext <= 0;
            skey_addr <= 0;
            status <= 0;
        end
        else if((|key_len) && (start) && (~status)) begin
            ready <= 0;
            status <= 1;
            case(key_len)
            2'b00: ;
            2'b01: begin
                skey_addr <= 10;
            end
            2'b10: begin
                skey_addr <= 12;
            end
            2'b11: begin
                skey_addr <= 14;
            end
            endcase
        end
        else if (status==1) begin
            if (subkey_valid) begin
                plaintext <= output_1;
                skey_addr <= skey_addr-1;
                status <= 2;
            end
        end
        else if (status == 2) begin
            if (subkey_valid) begin
                skey_addr <= skey_addr-1;
                
                if (skey_addr==0) begin
                    status <= 0;
                    ready <= 1;
                    plaintext <= addkey_out;
                end
                else plaintext <= invmixcols_out;
            end
        end
    end
endmodule



