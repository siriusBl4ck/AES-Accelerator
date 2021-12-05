module AES_decrypt(
    input clk,
    input reset,
    input [255:0] key,
    input start,
    input [1:0] key_len,
    output ready,
    input [127:0] ciphertext,
    output [127:0] plaintext
);

    reg ready;
    reg started;
    reg [127:0] plaintext;
    reg [3:0] rounds;

    wire [127:0] subkey, output_1, invshiftrows_out;
    wire [127:0] invsubbytes_out, addkey_out, invmixcols_out;

    Addkey inst (ciphertext,subkey,output_1);

    wire [31:0] rowin1, rowin2, rowin3, rowin4;

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
            rounds <= 0;
            started <= 0;
        end
        else if((|key_len)&&(start)&&(~started)) begin
            ready <= 0;
            started <= 1;
            plaintext <= output_1;
            case(key_len)
            2'b00: ;
            2'b01: rounds <= 4'd10;
            2'b10: rounds <= 4'd12;
            2'b11: rounds <= 4'd14;
            endcase
        end
        else if(rounds>0) begin
            rounds <= rounds-1;
            plaintext <= invmixcols_out;
        end
        else if((started)&&(rounds==0)) begin
            ready <= 1;
            started <= 0;
            plaintext <= addkey_out;
        end
    end

endmodule