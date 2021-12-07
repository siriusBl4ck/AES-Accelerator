 module key_outer_tb;
    reg  clk = 0;
    reg reset = 1;
    reg [1:0] aes_mode = 2'b11; //AES-256

    // Set up clock
    always #5 clk <= ~clk;

    reg [255:0] short_key = 256'h603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4;
    //128'h2b7e151628aed2a6abf7158809cf4f3c;
    //192'h8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b;
    wire [127:0] subkey;
    reg [127:0] res;
    reg [31:0] cnt = 0;
    reg [3:0] rkey_addr = 0;
    wire [127:0] rkey;
    wire rdy;
    
    key_exp_outer s1(clk, short_key, aes_mode, reset, rkey_addr, rkey, rdy);

    always @(posedge clk) begin
        if (cnt == 5) begin
            reset <= 1;
        end
        else if (cnt > 5 && rdy) begin
            reset <= 0;
        end
        if (cnt < 100) cnt <= cnt + 1;
    end

    always @(posedge clk) begin
        if (cnt == 100) begin
            $display("reading key_mem[%d] -> %h", rkey_addr, rkey);
            rkey_addr = rkey_addr + 1;
        end

        if (rkey_addr == 15) $finish;
    end

    /*
    
            $display("key_mem[0] -> %h", key_mem[0]);
            $display("key_mem[1] -> %h", key_mem[1]);
            $display("key_mem[2] -> %h", key_mem[2]);
            $display("key_mem[3] -> %h", key_mem[3]);
            $display("key_mem[4] -> %h", key_mem[4]);
            $display("key_mem[5] -> %h", key_mem[5]);
            $display("key_mem[6] -> %h", key_mem[6]);
            $display("key_mem[7] -> %h", key_mem[7]);
            $display("key_mem[8] -> %h", key_mem[8]);
            $display("key_mem[9] -> %h", key_mem[9]);
            $display("key_mem[10] -> %h", key_mem[10]);
            $display("key_mem[11] -> %h", key_mem[11]);
            $display("key_mem[12] -> %h", key_mem[12]);
            $display("key_mem[13] -> %h", key_mem[13]);
            $display("key_mem[14] -> %h", key_mem[14]);
            $finish;
    */
endmodule