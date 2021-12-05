module InvSubBytes(
    input [127:0] in,
    output [127:0] out
);

for(i=0; i<=120; i=i+8)
begin
    assign out[i+7:i] = InvSbox(in[i+7:i]);
end
endmodule