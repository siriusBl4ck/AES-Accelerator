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