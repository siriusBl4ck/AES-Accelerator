module gf4_sq(
    input [3:0] a,
    output [3:0] a_sq
);
    assign a_sq[3] = a[3];
    assign a_sq[2] = a[1] ^ a[3];
    assign a_sq[1] = a[2];
    assign a_sq[0] = a[0] ^ a[2];
endmodule