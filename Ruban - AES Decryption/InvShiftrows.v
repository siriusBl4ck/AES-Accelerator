module InvShiftrows(
    input [31:0] rowin1,
    input [31:0] rowin2,
    input [31:0] rowin3,
    input [31:0] rowin4,
    output [31:0] rowout1,
    output [31:0] rowout2,
    output [31:0] rowout3,
    output [31:0] rowout4
)

assign rowout1 = rowin1;
assign rowout2 = {rowin2[7:0],rowin2[31:8]};
assign rowout3 = {rowin3[15:0],rowin3[31:16]};
assign rowout4 = {rowin4[23:0],rowin4[31:24]};
endmodule