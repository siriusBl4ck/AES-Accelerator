module gf4_inv_tb;
    reg [3:0] t [1:0];
    reg  clk = 0;
    reg [9:0] cnt = 0;
    
    initial begin
        t[0] = 12;
        t[1] = 10;
    end
    // Set up clock
    always #5 clk <= ~clk;

    reg [7:0] a;
    wire [7:0] expected_res;
    wire [7:0] res;
    

    sbox s0(a, res);
    sbox_v2 s1(a, expected_res);


    always @(posedge clk) begin
        if (cnt < 256) begin
            a <= cnt;
            //expected_res <= t[cnt + 1];
        end
        else $finish;
        cnt <= cnt + 1;
        
    end

    
    always @(negedge clk) begin
        if (res == expected_res) $display("PASS %d", res);
        else $display("FAIL %d %d %d", a, res, expected_res);
    end
    
endmodule