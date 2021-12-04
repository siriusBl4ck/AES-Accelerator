module inv_isomorph_and_affine(
    input [7:0] delta,
    output [7:0] sbox_out
);
    assign sbox_out[7] = delta[1] ^ delta[2] ^ delta[3] ^ delta[7];
    assign sbox_out[6] = ~(delta[4] ^ delta[7]);
    assign sbox_out[5] = ~(delta[1] ^ delta[2] ^ delta[7]);
    assign sbox_out[4] = delta[0] ^ delta[1] ^ delta[2] ^ delta[4] ^ delta[6] ^ delta[7];
    assign sbox_out[3] = delta[0];
    assign sbox_out[2] = delta[0] ^ delta[1] ^ delta[3] ^ delta[4];
    assign sbox_out[1] = ~(delta[0] ^ delta[2] ^ delta[7]);
    assign sbox_out[0] = ~(delta[0] ^ delta[5] ^ delta[6] ^ delta[7]);
endmodule