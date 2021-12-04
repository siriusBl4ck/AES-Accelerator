// v = 13
module gf4_sq_mul_v(
    input [3:0] a,
    output [3:0] p
);
    wire [3:0] a_sq;
    assign a_sq[3] = a[3];
    assign a_sq[2] = a[1] ^ a[3];
    assign a_sq[1] = a[2];
    assign a_sq[0] = a[0] ^ a[2];
    
    wire [3:0] a_1;
    wire [3:0] a_2;
    wire [3:0] a_3;

    wire [3:0] p_0;
    wire [3:0] p_1;
    wire [3:0] p_2;

    assign p_0 = a_sq;
    assign a_1 = {a_sq[2:0], 1'b0} ^ ((a_sq[3])? 4'b0011 : 4'b0);

    assign p_1 = p_0;
    assign a_2 = {a_1[2:0], 1'b0} ^ ((a_1[3])? 4'b0011 : 4'b0);

    assign p_2 = p_1 ^ a_2;
    assign a_3 = {a_2[2:0], 1'b0} ^ ((a_2[3])? 4'b0011 : 4'b0);

    assign p = p_2 ^ a_3;
endmodule

//  v = 1 1 0 1
//index:3 2 1 0