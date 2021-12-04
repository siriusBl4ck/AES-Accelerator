module gf4_inv_tb;
    reg [3:0] t [1:0];
    reg  clk = 0;
    reg [15:0] cnt = 0;
    
    initial begin
        t[0] = 12;
    end
    // Set up clock
    always #5 clk <= ~clk;

    reg [7:0] a;
    reg [3:0] b;
    wire [7:0] expected_res;
    wire [7:0] res;
    

    isomorph inv(a, res);
    cob inv2(a, expected_res);


    always @(posedge clk) begin
        if (cnt < 256) begin
            a <= cnt;
            //b <= 10 - cnt;
            //expected_res <= t[cnt + 1];
        end
        else $finish;
        cnt <= cnt + 1;
        
    end

    
    always @(negedge clk) begin
        if (res != expected_res) $display("FAIL %d %d", res, expected_res);
        else $display("PASS");
    end
    
endmodule