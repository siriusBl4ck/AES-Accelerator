
module tb;
	reg [31:0] status;
	reg clk = 0;
	reg reset;
	
	always #5 clk <= ~clk;
	
	reg pt_valid, ct_valid;
	reg [127:0] pt_encr, ct_decr;
	wire [127:0] ct_encr, pt_decr;
	wire ct_rdy, pt_rdy;
	
	reg [1:0] key_len;
	reg [255:0] short_key;
	wire key_exp_status;
	wire error;
	
	AES M(clk,reset,pt_valid,ct_rdy,pt_encr,ct_encr,ct_valid,    	 pt_rdy,ct_decr,pt_decr,key_len,key_exp_status,short_key,error);
    	 
   initial begin
   reset = 1;
   pt_valid = 0;
   ct_valid = 0;
   key_len = 0;
   status = 0;
   end
   
   always @(posedge clk) begin
       if (status == 0) begin //128
       		key_len <= 2'b01;
       		short_key <= {128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h0};
       		pt_encr <= 128'h3243f6a8885a308d313198a2e0370734;
       		pt_valid <= 1;
       		status <= 1;
			reset <= 0;
       	end
       	else if (status == 1) begin
			key_len <= 2'b0;
			pt_valid <= 0;
       		if (ct_rdy)	 begin
       			$display($time,"-%d: ct-%h", status, ct_encr);
       			status <= 2;
				$finish;
       			//ct_decr <= 128'h
       			//ct_valid <= 1;
       		end
       	end
   end
  endmodule
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
