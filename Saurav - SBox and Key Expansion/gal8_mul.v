/*
gal8_mul.v

 * Multiplies two numbers in the GF(2^8) finite field defined 
 * by the polynomial x^8 + x^4 + x^3 + x + 1 = 0
 * using the Russian Peasant Multiplication algorithm

EXPLANATION
Run the following loop 8 times (once per bit). It is OK to stop when a or b is zero before an iteration:
    1. If the rightmost bit of b is set, exclusive OR the product p by the value of a. This is polynomial addition.
    2. Shift b one bit to the right, discarding the rightmost bit, and making the leftmost bit have a value of zero. This divides the polynomial by x, discarding the x0 term.
    3. Keep track of whether the leftmost bit of a is set to one and call this value carry.
    4. Shift a one bit to the left, discarding the leftmost bit, and making the new rightmost bit zero. This multiplies the polynomial by x, but we still need to take account of carry which represented the coefficient of x7.
    5. If carry had a value of one, exclusive or a with the hexadecimal number 0x1b (00011011 in binary). 0x1b corresponds to the irreducible polynomial with the high term eliminated. Conceptually, the high term of the irreducible polynomial and carry add modulo 2 to 0.
p now has the product
Source: Wikipedia
7 6 5 4 3 2 1 0
My notes:
The conditional bit shifting and "looping" mentioned above has been parallelised resulting in a purely combinational module
*/

module gal8_mul(
    input [7:0] a,
    input [7:0] b,
    output [7:0] p
);
    wire [7:0] a_1;
    wire [7:0] a_2;
    wire [7:0] a_3;
    wire [7:0] a_4;
    wire [7:0] a_5;
    wire [7:0] a_6;
    wire [7:0] a_7;

    wire [7:0] p_0;
    wire [7:0] p_1;
    wire [7:0] p_2;
    wire [7:0] p_3;
    wire [7:0] p_4;
    wire [7:0] p_5;
    wire [7:0] p_6;

    assign p_0 = (b[0])? a : 8'b0;
    assign a_1 = {a[6:0], 1'b0} ^ ((a[7])? 8'b00011011 : 8'b0);

    assign p_1 = p_0 ^ ((b[1])? a_1 : 8'b0);
    assign a_2 = {a_1[6:0], 1'b0} ^ ((a_1[7])? 8'b00011011 : 8'b0);

    assign p_2 = p_1 ^ ((b[2])? a_2 : 8'b0);
    assign a_3 = {a_2[6:0], 1'b0} ^ ((a_2[7])? 8'b00011011 : 8'b0);

    assign p_3 = p_2 ^ ((b[3])? a_3 : 8'b0);
    assign a_4 = {a_3[6:0], 1'b0} ^ ((a_3[7])? 8'b00011011 : 8'b0);

    assign p_4 = p_3 ^ ((b[4])? a_4 : 8'b0);
    assign a_5 = {a_4[6:0], 1'b0} ^ ((a_4[7])? 8'b00011011 : 8'b0);

    assign p_5 = p_4 ^ ((b[5])? a_5 : 8'b0);
    assign a_6 = {a_5[6:0], 1'b0} ^ ((a_5[7])? 8'b00011011 : 8'b0);

    assign p_6 = p_5 ^ ((b[6])? a_6 : 8'b0);
    assign a_7 = {a_6[6:0], 1'b0} ^ ((a_6[7])? 8'b00011011 : 8'b0);

    assign p = p_6 ^ ((b[7])? a_7 : 8'b0);
endmodule