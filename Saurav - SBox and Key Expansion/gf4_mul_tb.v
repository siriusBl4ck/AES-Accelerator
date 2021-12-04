module gf4_inv_tb;
    reg [3:0] t [1:0];
    reg  clk = 0;
    reg [4:0] cnt = 0;
    
    initial begin
        t[0] = 12;
    end
    // Set up clock
    always #5 clk <= ~clk;

    reg [3:0] a;
    reg [3:0] b;
    wire [3:0] expected_res;
    wire [3:0] res;
    

    gf4_mul inv(a, a, res);
    gf4_mul_v2 inv2(a, a, expected_res);


    always @(posedge clk) begin
        if (cnt < 16) begin
            a <= cnt;
            b <= 12 - cnt;
            //expected_res <= t[cnt + 1];
        end
        else $finish;
        cnt <= cnt + 1;
        
    end

    
    always @(negedge clk) begin
        if (res == expected_res) $display("PASS %d", res);
        else $display("FAIL %d %d", a, expected_res);
    end
    
endmodule