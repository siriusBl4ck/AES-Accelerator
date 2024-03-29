module InvMixCols(
    input [31:0] colin1,
    input [31:0] colin2,
    input [31:0] colin3,
    input [31:0] colin4,
    output [127:0] out
);

reg [31:0] colout1, colout2, colout3, colout4;

function automatic [7:0] mul2 (input [7:0] a);
    begin
        mul2 = (a[7]) ? (({a[6:0],1'b0})^(8'b00011011)) : ({a[6:0],1'b0});
    end
endfunction

function automatic [7:0] mul (input [7:0] a, input [1:0] sel);   
    begin
        case(sel)
        2'b00: mul = mul2(mul2(mul2(a)))^a;          //x09
        2'b01: mul = mul2(mul2(mul2(a))^a)^a;        //x0B
        2'b10: mul = mul2(mul2(mul2(a)^a))^a;        //x0D
        2'b11: mul = mul2(mul2(mul2(a)^a)^a);        //x0E
        endcase
    end
endfunction

always @(*)
begin
    colout1[31:24] = mul(colin1[31:24],2'b11)^mul(colin1[23:16],2'b01)^mul(colin1[15:8],2'b10)^mul(colin1[7:0],2'b00);
    colout2[31:24] = mul(colin2[31:24],2'b11)^mul(colin2[23:16],2'b01)^mul(colin2[15:8],2'b10)^mul(colin2[7:0],2'b00);
    colout3[31:24] = mul(colin3[31:24],2'b11)^mul(colin3[23:16],2'b01)^mul(colin3[15:8],2'b10)^mul(colin3[7:0],2'b00);
    colout4[31:24] = mul(colin4[31:24],2'b11)^mul(colin4[23:16],2'b01)^mul(colin4[15:8],2'b10)^mul(colin4[7:0],2'b00);

    colout1[23:16] = mul(colin1[31:24],2'b00)^mul(colin1[23:16],2'b11)^mul(colin1[15:8],2'b01)^mul(colin1[7:0],2'b10);
    colout2[23:16] = mul(colin2[31:24],2'b00)^mul(colin2[23:16],2'b11)^mul(colin2[15:8],2'b01)^mul(colin2[7:0],2'b10);
    colout3[23:16] = mul(colin3[31:24],2'b00)^mul(colin3[23:16],2'b11)^mul(colin3[15:8],2'b01)^mul(colin3[7:0],2'b10);
    colout4[23:16] = mul(colin4[31:24],2'b00)^mul(colin4[23:16],2'b11)^mul(colin4[15:8],2'b01)^mul(colin4[7:0],2'b10);

    colout1[15:8] = mul(colin1[31:24],2'b10)^mul(colin1[23:16],2'b00)^mul(colin1[15:8],2'b11)^mul(colin1[7:0],2'b01);
    colout2[15:8] = mul(colin2[31:24],2'b10)^mul(colin2[23:16],2'b00)^mul(colin2[15:8],2'b11)^mul(colin2[7:0],2'b01);
    colout3[15:8] = mul(colin3[31:24],2'b10)^mul(colin3[23:16],2'b00)^mul(colin3[15:8],2'b11)^mul(colin3[7:0],2'b01);
    colout4[15:8] = mul(colin4[31:24],2'b10)^mul(colin4[23:16],2'b00)^mul(colin4[15:8],2'b11)^mul(colin4[7:0],2'b01);

    colout1[7:0] = mul(colin1[31:24],2'b01)^mul(colin1[23:16],2'b10)^mul(colin1[15:8],2'b00)^mul(colin1[7:0],2'b11);
    colout2[7:0] = mul(colin2[31:24],2'b01)^mul(colin2[23:16],2'b10)^mul(colin2[15:8],2'b00)^mul(colin2[7:0],2'b11);
    colout3[7:0] = mul(colin3[31:24],2'b01)^mul(colin3[23:16],2'b10)^mul(colin3[15:8],2'b00)^mul(colin3[7:0],2'b11);
    colout4[7:0] = mul(colin4[31:24],2'b01)^mul(colin4[23:16],2'b10)^mul(colin4[15:8],2'b00)^mul(colin4[7:0],2'b11);
end

assign out = {colout1, colout2, colout3, colout4};

endmodule