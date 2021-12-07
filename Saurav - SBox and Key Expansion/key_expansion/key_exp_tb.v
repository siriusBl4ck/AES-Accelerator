 module key_exp_tb;
    reg [127:0] t [11:0];
    reg  clk = 0;
    reg [9:0] cnt = 0;
    reg start = 0;
    reg reset;
    
    initial begin
        t[0] = 12;
        t[1] = 10;
        short_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        reset = 1'b1;
        start = 1'b0;
    end
    // Set up clock
    always #5 clk <= ~clk;

    reg [127:0] short_key;
    wire [127:0] subkey;
    wire rdy;
    reg [127:0] res;
    
    AESKeyexpansion_128 s1(clk, reset, start, short_key, subkey, rdy);

    always @(posedge clk) begin
        if (cnt < 1) begin
            reset <= 1'b0;
            start <= 1'b1;
        end
        else if (cnt >= 1 && cnt < 11) begin
            res <= subkey;
        end
        else $finish;
        cnt <= cnt + 1;
        
    end
    
    always @(posedge clk) begin
        $display("subkey no. %d -> %h ", cnt, subkey);
    end
endmodule