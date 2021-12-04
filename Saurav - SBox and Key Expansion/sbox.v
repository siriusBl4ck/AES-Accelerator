module sbox(
    input [7:0] in_byte,
    output [7:0] out_byte
);
    wire [3:0] g0;
    wire [3:0] g1;
    wire [3:0] g1_g0_t;
    wire [3:0] g0_sq;
    wire [3:0] g1_sq_mult_v;
    wire [3:0] inverse;
    wire [3:0] d0;
    wire [3:0] d1;
    
    isomorph iso(in_byte, {g1, g0});

    gf4_mul g1g0t(g1, g0, g1_g0_t);
    gf4_sq g0sq(g0, g0_sq);
    gf4_sq_mul_v g1sqmultv(g1, g1_sq_mult_v);

    gf4_inv inv((g1_g0_t ^ g0_sq ^ g1_sq_mult_v), inverse);

    gf4_mul mulg1(g1, inverse, d1);
    gf4_mul mulg0plustg1((g0 ^ g1), inverse, d0);

    inv_isomorph_and_affine inviso({d1, d0}, out_byte);

endmodule