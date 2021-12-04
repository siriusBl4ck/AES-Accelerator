module gf4_inv_tb;
    reg [3:0] t [1:0];
    reg  clk = 0;
    reg [4:0] cnt = 0;
    
    initial begin
        t[0] = 12;
        t[1] = 10;
    end
    // Set up clock
    always #5 clk <= ~clk;

    reg [3:0] a;
    wire [3:0] expected_res;
    wire [3:0] res;
    

    gf4_inv inv(a, res);
    gf_inv_v2 inv2(a, expected_res);


    always @(posedge clk) begin
        if (cnt < 16) begin
            a <= cnt;
            //expected_res <= t[cnt + 1];
        end
        else $finish;
        cnt <= cnt + 1;
        
    end

    
    always @(negedge clk) begin
        if (res == expected_res) $display("PASS %d", res);
        else $display("%d %d", a, expected_res);
    end
    
endmodule