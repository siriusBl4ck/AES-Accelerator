module AES(
    input clk,
    input reset,
    input pt_valid,
    output ct_rdy,
    input [127:0] pt_encr,
    output [127:0] ct_encr,
    input ct_valid,
    output pt_rdy,
    input [127:0] ct_decr,
    output [127:0] pt_decr
    input [1:0] key_len,
    output key_exp_status,
    input [255:0] short_key,
    output error
);

reg ct_rdy, pt_rdy;
reg [127:0] ct_encr, pt_decr;
reg status;

wire w_en;
wire reset_valid_bits;
wire [3:0] raddr_encr;
wire [3:0] raddr_decr;
wire [3:0] waddr;
wire [127:0] wkey;
wire [127:0] rkey_encr;
wire [127:0] rkey_decr;
wire [14:0] valid_bits; 

keymem a0(clk,
          reset,
          w_en,
          reset_valid_bits,
          raddr_encr,
          raddr_decr,
          waddr,
          wkey,
          rkey_encr,
          rkey_decr,
          valid_bits);

assign w_en = (|key_len)|(valid);           //Write first key or valid key
assign waddr = (|key_len) ? 4'd0 : waddr_exp;
assign wkey = (|key_len) ? short_key[255:128] : subkey_exp; 
assign raddr_encr = subkey_addr_encr;
assign raddr_decr = subkey_Addr_decr;


key_exp_outer a1(clk,
                 reset,
                 start_exp,
                 short_key,
                 key_len,
                 valid,                                 
                 reset_valid_bits,
                 waddr_exp,
                 subkey_exp);

assign key_exp_status = (&valid_bits);
assign start_exp = (|key_len)&(~status);

AES_encrypt a2(clk,
               reset,
               pt_encr,
               start_encr,
               key_len,
               ct_encr,
               ready_encr,
               subkey_encr,
               subkey_addr_encr,
               subkey_valid_encr);

assign start_encr = pt_valid;
assign subkey_encr = rkey_encr;
assign subkey_valid_encr = valid_bits[raddr_encr];
assign ct_rdy = ready_encr;

AES_decrypt a3(clk,
               reset,
               start_decr,
               key_len,
               ready_decr,
               ct_decr,
               pt_decr,
               subkey_decr,
               subkey_valid_decr,
               subkey_addr_decr);

assign start_decr = ct_valid;
assign subkey_decr = rkey_decr;
assign subkey_valid_decr = valid_bits[raddr_decr];
assign pt_rdy = ready_decr;

assign error = (~(|valid_bits))&status;

always @(posedge clk) begin
    if(reset) begin
        status <= 1'b0;
    end
    else if(pt_valid | ct_valid) begin
        status <= 1'b1;
    end
end

endmodule
