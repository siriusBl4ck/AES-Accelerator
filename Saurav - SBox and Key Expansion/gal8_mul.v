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

    //Keep track of whether the leftmost bit of a is set to one and call this value carry.
    //Shift a one bit to the left, discarding the leftmost bit, and making the new rightmost bit zero. 
    //This multiplies the polynomial by x, but we still need to take account of carry which represented the coefficient of x7.
    //If carry had a value of one, exclusive or a with the hexadecimal number 0x1b (00011011 in binary).
    assign a_1 = {a[6:0], 1'b0} ^ (8'b00011011 & {8{a[7]}});
    assign a_2 = {a[5:0], 2'b0} ^ (8'b00011011 & {8{a[6]}});
    assign a_3 = {a[4:0], 3'b0} ^ (8'b00011011 & {8{a[5]}});
    assign a_4 = {a[3:0], 4'b0} ^ (8'b00011011 & {8{a[4]}});
    assign a_5 = {a[2:0], 5'b0} ^ (8'b00011011 & {8{a[3]}});
    assign a_6 = {a[1:0], 6'b0} ^ (8'b00011011 & {8{a[2]}});
    assign a_7 = {a[0], 7'b0} ^ (8'b00011011 & {8{a[1]}});

    //If the rightmost bit of b is set, exclusive OR the product p by the value of a. This is polynomial addition.
    //Shift b one bit to the right, discarding the rightmost bit, and making the leftmost bit have a value of zero.
    //This bit shifting of b is unnecessary, since we only use the rightmost bit every time, it corresponds to b[0], b[1], b[2] etc
    //So we use it directly instead of saying (b >> n)[0]
    assign p = (a & {8{b[0]}}) ^ (a_1 & {8{b[1]}}) ^ (a_2 & {8{b[2]}}) ^ (a_3 & {8{b[3]}}) ^ (a_4 & {8{b[4]}}) ^ (a_5 & {8{b[5]}}) ^ (a_6 & {8{b[6]}}) ^ (a_7 & {8{b[7]}});
endmodule