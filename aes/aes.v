module aes(
    input [127:0] plaintext_encrypt,
    output [127:0] ciphertext_encrypt,
    input en_encrypt,
    output rdy_encrypt,
    input [127:0] ciphertext_decrypt,
    output [127:0] plaintext_decrypt,
    input en_decrypt,
    output rdy_decrypt,
    input [255:0] short_key
);
endmodule