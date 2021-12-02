module InvMixCols(
    input [31:0] colin1,
    input [31:0] colin2,
    input [31:0] colin3,
    input [31:0] colin4,
    output reg [31:0] colout1;
    output reg [31:0] colout2;
    output reg [31:0] colout3;
    output reg [31:0] colout4;
);

function automatic [7:0] mul2 (input [7:0] a);
    begin
        mul2 = (a[7]) ? (({a[6:0],1'b0})^(8'b00011011)) : ({a[6:0],1'b0});
    end
endfunction

function automatic [7:0] mul (input [7:0] a, input [3:0] multiplier);   
    begin
        case({multiplier[2],multiplier[1]})
        2'b00: mul = mul2(mul2(mul2(a)))^a;
        2'b01: mul = mul2(mul2(mul2(a))^a)^a;
        2'b10: mul = mul2(mul2(mul2(a)^a))^a;
        2'b11: mul = mul2(mul2(mul2(a)^a)^a);
        endcase
    end
endfunction

always @(*)
begin
    colout1[31:24] = mul(colin1[31:24],4'hE)^mul(colin1[23:16],4'hB)^mul(colin1[15:8],4'hD)^mul(colin1[7:0],4'h9);
    colout2[31:24] = mul(colin2[31:24],4'hE)^mul(colin2[23:16],4'hB)^mul(colin2[15:8],4'hD)^mul(colin2[7:0],4'h9);
    colout3[31:24] = mul(colin3[31:24],4'hE)^mul(colin3[23:16],4'hB)^mul(colin3[15:8],4'hD)^mul(colin3[7:0],4'h9);
    colout4[31:24] = mul(colin4[31:24],4'hE)^mul(colin4[23:16],4'hB)^mul(colin4[15:8],4'hD)^mul(colin4[7:0],4'h9);

    colout1[23:16] = mul(colin1[31:24],4'h9)^mul(colin1[23:16],4'hE)^mul(colin1[15:8],4'hB)^mul(colin1[7:0],4'hD);
    colout2[23:16] = mul(colin2[31:24],4'h9)^mul(colin2[23:16],4'hE)^mul(colin2[15:8],4'hB)^mul(colin2[7:0],4'hD);
    colout3[23:16] = mul(colin3[31:24],4'h9)^mul(colin3[23:16],4'hE)^mul(colin3[15:8],4'hB)^mul(colin3[7:0],4'hD);
    colout4[23:16] = mul(colin4[31:24],4'h9)^mul(colin4[23:16],4'hE)^mul(colin4[15:8],4'hB)^mul(colin4[7:0],4'hD);

    colout1[15:8] = mul(colin1[31:24],4'hD)^mul(colin1[23:16],4'h9)^mul(colin1[15:8],4'hE)^mul(colin1[7:0],4'hB);
    colout2[15:8] = mul(colin2[31:24],4'hD)^mul(colin2[23:16],4'h9)^mul(colin2[15:8],4'hE)^mul(colin2[7:0],4'hB);
    colout3[15:8] = mul(colin3[31:24],4'hD)^mul(colin3[23:16],4'h9)^mul(colin3[15:8],4'hE)^mul(colin3[7:0],4'hB);
    colout4[15:8] = mul(colin4[31:24],4'hD)^mul(colin4[23:16],4'h9)^mul(colin4[15:8],4'hE)^mul(colin4[7:0],4'hB);

    colout1[7:0] = mul(colin1[31:24],4'hB)^mul(colin1[23:16],4'hD)^mul(colin1[15:8],4'h9)^mul(colin1[7:0],4'hE);
    colout2[7:0] = mul(colin2[31:24],4'hB)^mul(colin2[23:16],4'hD)^mul(colin2[15:8],4'h9)^mul(colin2[7:0],4'hE);
    colout3[7:0] = mul(colin3[31:24],4'hB)^mul(colin3[23:16],4'hD)^mul(colin3[15:8],4'h9)^mul(colin3[7:0],4'hE);
    colout4[7:0] = mul(colin4[31:24],4'hB)^mul(colin4[23:16],4'hD)^mul(colin4[15:8],4'h9)^mul(colin4[7:0],4'hE);
end

endmodule