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