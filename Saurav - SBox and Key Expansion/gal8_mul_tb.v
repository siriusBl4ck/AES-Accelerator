module gal8_mul_tb;
    reg [7:0] t [14:0];
    reg  clk = 0;
    reg [3:0] cnt = 0;
    
    initial begin
        $display("Loading data from file tb_final");
        $readmemh("tb_final", t);
        cnt = 0;
    end
    // Set up clock
    always #5 clk <= ~clk;

    reg [7:0] a;
    reg [7:0] b;
    reg [7:0] expected_res;
    wire [7:0] res;
    

    gal8_mul mult(a, b, res);


    always @(posedge clk) begin
        if (cnt < 15) begin
            a <= t[cnt];
            b <= t[cnt + 1];
            expected_res <= t[cnt + 2];
        end
        else $finish;
        cnt <= cnt + 3;
        
    end

    
    always @(negedge clk) begin
        if (res == expected_res) $display("PASS");
        else $display("FAIL %d %d %d %d", a, b, expected_res, res);
    end
    
endmodule