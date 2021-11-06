module Addkey(
    input [127:0] a,
    input [127:0] b,
    output [127:0] out
)

assign out = a^b;
endmodule