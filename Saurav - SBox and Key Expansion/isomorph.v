module isomorph(
    input [7:0] a,
    output [7:0] gamma
);
    assign gamma[7] =a[5] ^ a[7];
    assign gamma[6] =a[1] ^ a[5] ^ a[4] ^ a[6];
    assign gamma[5] =a[3] ^ a[2] ^ a[5] ^ a[7];
    assign gamma[4] =a[3] ^ a[2] ^ a[4] ^ a[7] ^ a[6];
    assign gamma[3] =a[1] ^ a[2] ^ a[7] ^ a[6];
    assign gamma[2] =a[3] ^ a[2] ^ a[7] ^ a[6];
    assign gamma[1] =a[1] ^ a[4] ^ a[6];
    assign gamma[0] =a[1] ^ a[0] ^ a[3] ^ a[2] ^ a[7];
endmodule