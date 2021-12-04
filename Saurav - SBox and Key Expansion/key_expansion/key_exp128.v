parameter Nb = 4
parameter Nr = 11
module key_exp128(
    input clk,
    input [127:0] k,
    output rdy,
    output reg [127:0] rk [10:0]
);
    reg [31:0] w [(Nb*(Nr + 1) - 1):0]; 
    reg [31:0] cnt = 0;
    
    always @(posedge clk) begin
        rdy <= 0;
        if (cnt < Nb) begin
            w[cnt] <= k[(2*(cnt)*16 + 31):(2*cnt*16)];
        end
        else if (cnt < Nb*(Nr + 1)) begin
            
        end
        else rdy <= 1;
        cnt <= cnt + 1;
    end

    
endmodule