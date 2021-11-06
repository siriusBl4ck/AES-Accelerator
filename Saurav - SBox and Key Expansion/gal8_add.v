/*
Source: Wikipedia
In a finite field with characteristic 2, addition modulo 2, subtraction modulo 2, and XOR are identical.
*/
module gal8_add(
    input [7:0] a,
    input [7:0] b,
    output [7:0] s
);
    assign s = a ^ b;
endmodule