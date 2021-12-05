parameter Nb = 4; //number of 32 bit words in each round key
parameter Nk = 4; //number of 32 bit words in the main key
parameter Nr = 11; //number of rounds

module key_exp128(
    input clk,
    input [127:0] k,
    output rdy,
    output reg [127:0] rk [10:0]
);
    reg [31:0] w [(Nb*(Nr + 1) - 1):0]; 
    reg [31:0] cnt = 0;
    reg [31:0] rcon [10:0];

    initial begin
        rcon[0] = 32'b0;
        rcon[1] = 32'b1000000000000000000000000;
        rcon[2] = 32'b10000000000000000000000000;
        rcon[3] = 32'b100000000000000000000000000;
        rcon[4] = 32'b1000000000000000000000000000;
        rcon[5] = 32'b10000000000000000000000000000;
        rcon[6] = 32'b100000000000000000000000000000;
        rcon[7] = 32'b1000000000000000000000000000000;
        rcon[8] = 32'b10000000000000000000000000000000;
        rcon[9] = 32'b100000000000000000000000000000000;
        rcon[10] = 32'b1000000000000000000000000000000000;
    end
    
    always @(posedge clk) begin
        rdy <= 0;
        if (cnt < Nk) begin
            w[cnt] <= k[(2*(cnt)*16 + 31):(2*cnt*16)];
        end
        else if (cnt < Nb*(Nr + 1)) begin
            w[cnt] = temp(w[cnt - 1], w[cnt-Nk], cnt, rcon);
        end
        else rdy <= 1;
        cnt <= cnt + 4;
    end

function automatic [31:0] temp;
    input [31:0] prev_w;
    input [31:0] cnt_minus_Nk_w;
    input [31:0] cnt;
    input [31:0] rcon [10:0];
    
    begin
        if ((cnt % Nk) == 0) begin
            temp = ({sbox(prev_w[23:16]), sbox(prev_w[15:8]), sbox(prev_w[7:0]), sbox(prev_w[31:24])} ^ rcon[cnt/Nb]) ^ cnt_minus_Nk_w;
        end
        else if ((Nk > 6) && (i % Nk == 4)) begin
            temp = (sbox(prev_w)) ^ cnt_minus_Nk_w;
        end
        else temp = prev_w ^ cnt_minus_Nk_w;
    end
endfunction

function automatic [7:0] rcon128;
    input [31:0] cnt;

    begin
        case(cnt):
            
        endcase
    end
endfunction

function automatic [7:0] sbox;
    input [7:0] in_byte;
    reg [7:0] out_iso;
    reg [3:0] g0;
    reg [3:0] g1;
    reg [3:0] g1_g0_t;
    reg [3:0] g0_sq;
    reg [3:0] g1_sq_mult_v;
    reg [3:0] inverse;
    reg [3:0] d0;
    reg [3:0] d1;
    
    begin
    out_iso = isomorph(in_byte);

    g1 = out_iso[7:4];
    g0 = out_iso[3:0];

    g1_g0_t = gf4_mul(g1, g0);
    g0_sq = gf4_sq(g0);
    g1_sq_mult_v = gf4_sq_mul_v(g1);

    inverse = gf4_inv((g1_g0_t ^ g0_sq ^ g1_sq_mult_v));

    d1 = gf4_mul(g1, inverse);
    d0 = gf4_mul((g0 ^ g1), inverse);

    sbox = inv_isomorph_and_affine({d1, d0});
    end
endfunction

function automatic [7:0] isomorph;
    input [7:0] a;
    begin
        isomorph[7] =a[5] ^ a[7];
        isomorph[6] =a[1] ^ a[5] ^ a[4] ^ a[6];
        isomorph[5] =a[3] ^ a[2] ^ a[5] ^ a[7];
        isomorph[4] =a[3] ^ a[2] ^ a[4] ^ a[7] ^ a[6];
        isomorph[3] =a[1] ^ a[2] ^ a[7] ^ a[6];
        isomorph[2] =a[3] ^ a[2] ^ a[7] ^ a[6];
        isomorph[1] =a[1] ^ a[4] ^ a[6];
        isomorph[0] =a[1] ^ a[0] ^ a[3] ^ a[2] ^ a[7];
    end
endfunction

function automatic [3:0] gf4_sq;
    input [3:0] a;
    begin
    gf4_sq[3] = a[3];
    gf4_sq[2] = a[1] ^ a[3];
    gf4_sq[1] = a[2];
    gf4_sq[0] = a[0] ^ a[2];
    end
endfunction

function automatic [3:0] gf4_sq_mul_v;
    input [3:0] a;

    reg [3:0] a_sq;

    reg [3:0] a_1;
    reg [3:0] a_2;
    reg [3:0] a_3;

    reg [3:0] p_0;
    reg [3:0] p_1;
    reg [3:0] p_2;

    begin
    a_sq[3] = a[3];
    a_sq[2] = a[1] ^ a[3];
    a_sq[1] = a[2];
    a_sq[0] = a[0] ^ a[2];

    p_0 = a_sq;
    a_1 = {a_sq[2:0], 1'b0} ^ ((a_sq[3])? 4'b0011 : 4'b0);

    p_1 = p_0;
    a_2 = {a_1[2:0], 1'b0} ^ ((a_1[3])? 4'b0011 : 4'b0);

    p_2 = p_1 ^ a_2;
    a_3 = {a_2[2:0], 1'b0} ^ ((a_2[3])? 4'b0011 : 4'b0);

    gf4_sq_mul_v = p_2 ^ a_3;
    end
endfunction

function automatic [3:0] gf4_mul;
    input [3:0] a;
    input [3:0] b;
    reg [3:0] a_1;
    reg [3:0] a_2;
    reg [3:0] a_3;

    reg [3:0] p_0;
    reg [3:0] p_1;
    reg [3:0] p_2;
    begin
    p_0 = (b[0])? a : 4'b0;
    a_1 = {a[2:0], 1'b0} ^ ((a[3])? 4'b0011 : 4'b0);

    p_1 = p_0 ^ ((b[1])? a_1 : 4'b0);
    a_2 = {a_1[2:0], 1'b0} ^ ((a_1[3])? 4'b0011 : 4'b0);

    p_2 = p_1 ^ ((b[2])? a_2 : 4'b0);
    a_3 = {a_2[2:0], 1'b0} ^ ((a_2[3])? 4'b0011 : 4'b0);

    gf4_mul = p_2 ^ ((b[3])? a_3 : 4'b0);
    end
endfunction

function automatic [3:0] gf4_inv;
    input [3:0] a;
    begin
    gf4_inv[3] = (a[3] & a[2] & a[1] & a[0]) | (~a[3] & ~a[2] & a[1]) | (~a[3] & a[2] & ~a[1]) | (a[3] & ~a[2] & ~a[0]) | (a[2] & ~a[1] & ~a[0]);
    gf4_inv[2] = (a[3] & a[2] & ~a[1] & a[0]) | (~a[3] & a[2] & ~a[0]) | (a[3] & ~a[2] & ~a[0]) | (~a[2] & a[1] & a[0]) | (~a[3] & a[1] & a[0]);
    gf4_inv[1] =  (a[3] & ~a[2] & ~a[1]) | (~a[3] & a[1] & a[0]) | (~a[3] & a[2] & a[0]) | (a[3] & a[2] & ~a[0]) | (~a[3] & a[2] & a[1]);
    gf4_inv[0] = (a[3] & ~a[2] & ~a[1] & ~a[0]) | (a[3] & ~a[2] & a[1] & a[0]) | (~a[3] & ~a[1] & a[0]) | (~a[3] & a[1] & ~a[0]) | (a[2] & a[1] & ~a[0]) | (~a[3] & a[2] & ~a[1]);
    end
endfunction

function automatic [7:0] inv_isomorph_and_affine;
    input [7:0] delta;
    begin
    inv_isomorph_and_affine[7] = delta[1] ^ delta[2] ^ delta[3] ^ delta[7];
    inv_isomorph_and_affine[6] = ~(delta[4] ^ delta[7]);
    inv_isomorph_and_affine[5] = ~(delta[1] ^ delta[2] ^ delta[7]);
    inv_isomorph_and_affine[4] = delta[0] ^ delta[1] ^ delta[2] ^ delta[4] ^ delta[6] ^ delta[7];
    inv_isomorph_and_affine[3] = delta[0];
    inv_isomorph_and_affine[2] = delta[0] ^ delta[1] ^ delta[3] ^ delta[4];
    inv_isomorph_and_affine[1] = ~(delta[0] ^ delta[2] ^ delta[7]);
    inv_isomorph_and_affine[0] = ~(delta[0] ^ delta[5] ^ delta[6] ^ delta[7]);
    end
endfunction
endmodule