module key_exp_tb;
    reg [127:0] t [11:0];
    reg  clk = 0;
    reg [9:0] cnt = 0;
    reg start = 0;
    reg reset;
    
    initial begin
        t[0] = 12;
        t[1] = 10;
        short_key = 192'h8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b;
        reset = 1'b1;
        start = 1'b0;
    end
    // Set up clock
    always #5 clk <= ~clk;

    reg [191:0] short_key;
    wire [127:0] subkey;
    wire rdy;
    reg [127:0] res;
    
    AESKeyexpansion_192 s1(clk, reset, start, short_key, subkey, rdy);

    always @(posedge clk) begin
        if (cnt < 1) begin
            reset <= 1'b0;
            start <= 1'b1;
        end
        else if (cnt == 1) begin
            res <= subkey;
        end
        else if(cnt>=2 && cnt < 13) begin
            res <= subkey;
        end
        else $finish;
        cnt <= cnt + 1;
 
    end
    
    always @(posedge clk) begin
        $display("subkey no. %d -> %h ", cnt, subkey);
    end
endmodule

