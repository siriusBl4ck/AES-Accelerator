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
    input [255:0] short_key
);

reg ct_rdy, pt_rdy, key_exp_status;
reg [127:0] ct_encr, pt_decr;

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
          raddr_encr,
          raddr_decr,
          waddr,
          wkey,
          rkey_encr,
          rkey_decr,
          valid_bits);

key_exp_outer a1(clk,
                 reset,
                 start,
                 short_key,
                 key_len,
                 valid,                                 
                 reset_valid_bits,
                 waddr,
                 subkey);

AES_encrypt a2(clk,
               reset,
               pt_encr,
               key,
               key_len,
               ct_encr,
               ready,
               subkey,
               subkey_addr);

AES_decrypt a3(clk,
               reset,
               start,
               key_len,
               ready,
               ct_decr,
               pt_decr,
               subkey,
               subkey_addr);

always @(posedge clk) begin
    
end
