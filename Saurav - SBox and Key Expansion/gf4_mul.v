module gf4_mul(
    input [3:0] a,
    input [3:0] b,
    output [3:0] p
);
    wire [3:0] a_1;
    wire [3:0] a_2;
    wire [3:0] a_3;

    wire [3:0] p_0;
    wire [3:0] p_1;
    wire [3:0] p_2;

    assign p_0 = (b[0])? a : 4'b0;
    assign a_1 = {a[2:0], 1'b0} ^ ((a[3])? 4'b0011 : 4'b0);

    assign p_1 = p_0 ^ ((b[1])? a_1 : 4'b0);
    assign a_2 = {a_1[2:0], 1'b0} ^ ((a_1[3])? 4'b0011 : 4'b0);

    assign p_2 = p_1 ^ ((b[2])? a_2 : 4'b0);
    assign a_3 = {a_2[2:0], 1'b0} ^ ((a_2[3])? 4'b0011 : 4'b0);

    assign p = p_2 ^ ((b[3])? a_3 : 4'b0);
endmodule