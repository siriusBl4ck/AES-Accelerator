module axi4_mem_periph #(
	parameter AXI_TEST = 0,
	parameter VERBOSE = 0
) (
	/* verilator lint_off MULTIDRIVEN */

	input             clk,
	input             mem_axi_awvalid,
	output reg        mem_axi_awready,
	input      [31:0] mem_axi_awaddr,
	input      [ 2:0] mem_axi_awprot,

	input             mem_axi_wvalid,
	output reg        mem_axi_wready,
	input      [31:0] mem_axi_wdata,
	input      [ 3:0] mem_axi_wstrb,

	output reg        mem_axi_bvalid,
	input             mem_axi_bready,

	input             mem_axi_arvalid,
	output reg        mem_axi_arready,
	input      [31:0] mem_axi_araddr,
	input      [ 2:0] mem_axi_arprot,

	output reg        mem_axi_rvalid,
	input             mem_axi_rready,
	output reg [31:0] mem_axi_rdata,

	output reg        tests_passed
);
	reg [31:0]   memory [0:128*1024/4-1] /* verilator public */;
	reg verbose;
	initial verbose = $test$plusargs("verbose") || VERBOSE;

	initial begin
		mem_axi_awready = 0;
		mem_axi_wready = 0;
		mem_axi_bvalid = 0;
		mem_axi_arready = 0;
		mem_axi_rvalid = 0;
		tests_passed = 0;
	end

	reg latched_raddr_en = 0;
	reg latched_waddr_en = 0;
	reg latched_wdata_en = 0;

	reg fast_raddr = 0;
	reg fast_waddr = 0;
	reg fast_wdata = 0;

	reg [31:0] latched_raddr;
	reg [31:0] latched_waddr;
	reg [31:0] latched_wdata;
	reg [ 3:0] latched_wstrb;
	reg        latched_rinsn;

	/// My variables
	wire [63:0] p_M;
	wire rdy_M;
	reg reset_M;
	reg [31:0] a_M, b_M, lower_prod_M, upper_prod_M;

	seq_mult M ( .p(p_M), .rdy(rdy_M), .clk(clk), .reset(reset_M), .a(a_M), .b(b_M));
	///

	task handle_axi_arvalid; begin
		mem_axi_arready <= 1;
		latched_raddr = mem_axi_araddr;
		latched_rinsn = mem_axi_arprot[2];
		latched_raddr_en = 1;
		fast_raddr <= 1;
	end endtask

	task handle_axi_awvalid; begin
		mem_axi_awready <= 1;
		latched_waddr = mem_axi_awaddr;
		latched_waddr_en = 1;
		fast_waddr <= 1;
	end endtask

	task handle_axi_wvalid; begin
		mem_axi_wready <= 1;
		latched_wdata = mem_axi_wdata;
		latched_wstrb = mem_axi_wstrb;
		latched_wdata_en = 1;
		fast_wdata <= 1;
	end endtask

	task handle_axi_rvalid; begin
		if (verbose)
			$display("RD: ADDR=%08x DATA=%08x%s", latched_raddr, memory[latched_raddr >> 2], latched_rinsn ? " INSN" : "");
		if (!arb_en) begin
			if (latched_raddr < 128*1024) begin
				mem_axi_rdata <= memory[latched_raddr >> 2];
				mem_axi_rvalid <= 1;
				latched_raddr_en = 0;
			end
		end else
		if (arb_en) begin
			if ((latched_raddr >= aes_dest_addr_start) && (latched_raddr < aes_dest_addr_start+128)) begin //start with dest_end
				if (out_ready) begin
					mem_axi_rdata <= aes_out[latched_raddr-aes_dest_addr_start];
					mem_axi_rvalid <= 1;
					latched_raddr_en = 0;
				end else begin
					mem_axi_rvalid <= 0;
					latched_raddr_en = 1;
				end
			end else
			/*if ((latched_raddr >= aes_dest_addr_start + 128) && (latched_raddr < aes_dest_addr_end)) begin
				if (in_enable) begin //check
					latched_custom_inp = aes_addr_start+{(latchd_raddr-aes_dest_addr_start)[31:4],4'b0};
					input_switch <= 1;
				end 
				r_cache_addr <= aes_addr_start+{(latchd_raddr-aes_dest_addr_start)[31:4],4'b0};
				r_cache_valid <= 1;
				mem_axi_rvalid <= 0;
				latched_raddr_en = 1;	
			end else	//Can reduce the cycle by putting flag  in other one		
					*/

			if (latched_raddr < 128*1024) begin
				mem_axi_rdata <= memory[latched_raddr >> 2];
				mem_axi_rvalid <= 1;
				latched_raddr_en = 0;
			end
		end
		//// Sequential multiplier's output signals are read here
		if (latched_raddr == 32'h3000_0000) begin
			// Returning the ready status. Here bit 0 is high if ready
            mem_axi_rdata <= {31'd0, rdy_M};
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0; 
		end else
		if (latched_raddr == 32'h3000_0004) begin
            // Returning the upper word of final product
			mem_axi_rdata <= p_M[63:32];
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0;		
		end else
		if (latched_raddr == 32'h3000_000c) begin
			// Returning the lower word of final product
			mem_axi_rdata <= p_M[31:0];
			mem_axi_rvalid <= 1;
			latched_raddr_en = 0; // This is set to 0 to enable next value to be accepted by arvalid task
		end
		////
		else begin
			$display("OUT-OF-BOUNDS MEMORY READ FROM %08x", latched_raddr);
			$finish;
		end
	end endtask

	task r_arb; begin
		mem_axi_arready <=  1; //check
		latched_raddr = aes_addr_start + (rcounter<<2);
		latched_raddr_en = 1;
		latched_rinsn = mem_axi_arprot[2]; //maye
		rcounter <= rcounter + 1;
		if (rcounter == 3) latcheed_rarb_pass = 0;
		latched_rarb_send = 1;
	end endtask

	task handle_axi_bvalid; begin
		if (verbose)
			$display("WR: ADDR=%08x DATA=%08x STRB=%04b", latched_waddr, latched_wdata, latched_wstrb);
		if (!arb_en) begin
			if (latched_waddr < 128*1024) begin
				if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
				if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
				if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
				if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
			end else
			if (latched_waddr == BASE) begin
				$display("Writing %d to starting address",  latched_wdata);
				aes_addr_start <= latched_wdata;
			end else
			if (latched_waddr == BASE+1) begin
				aes_addr_end <= latched_wdata; //Check if addr more?? If order fixed then use status reg?
				// Also burst size limit to be added here
				//status reg can also check if aes_addrs < 128*1024
				//also to be checked if dest addr in between aes_addrs
				//instead of this number of 128bits can also be considered
			end else
		
			if (latched_waddr == BASE+2) begin
				aes_dest_addr <= latched_wdata;
			end else

			if (latched_waddr == BASE+3) begin
				//if  status ok
				aes_start <= latched_wdata[0];
				arb_en <= 1'b1;
			end
		end else
	
		if (arb_en) begin
			//if ((aes_done) && (aes_addr_start - aes_addr_end > 128))
			//	aes_addr_start <= aes_addr_start+128;
			//This should happen auto every cycle
			if (!latched_warb_send) begin
				if (latched_waddr < 128*1024) begin
					if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
					if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
					if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
					if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
				end

				if ((latched_waddr >=aes_dest_addr) && (latched_waddr < aes_dest_addr_end)) begin//check signs
				//w_cache needs to store only 10bits of addr if burst = 255 and one bit for validity
					w_cache_addr <= latched_waddr;
					w_cache_strb <=  latched_wstrb;
				end else
			
				if ((latched_waddr >=aes_addr_start+128) && (latched_waddr < aes_addr_end)) begin
					$display("WARNING:write happpening in yet to be read data");
					//can write here or be skipped (see wait maybe)
					
				end 
			end else
			if (latched_warb_send) begin
				if (latched_waddr < 128*1024) begin //may not be needed
					if (latched_wstrb[0]) memory[latched_waddr >> 2][ 7: 0] <= latched_wdata[ 7: 0];
					if (latched_wstrb[1]) memory[latched_waddr >> 2][15: 8] <= latched_wdata[15: 8];
					if (latched_wstrb[2]) memory[latched_waddr >> 2][23:16] <= latched_wdata[23:16];
					if (latched_wstrb[3]) memory[latched_waddr >> 2][31:24] <= latched_wdata[31:24];
				end
				latched_warb_send = 0;
			end
		end

		if (latched_waddr == 32'h1000_0000) begin
			if (verbose) begin
				if (32 <= latched_wdata && latched_wdata < 128)
					$display("OUT: '%c'", latched_wdata[7:0]);
				else
					$display("OUT: %3d", latched_wdata);
			end else begin
				$write("%c", latched_wdata[7:0]);
`ifndef VERILATOR
				$fflush();
`endif
				end
			end else
		// address below used by assembly in start.S - we are not using this
		if (latched_waddr == 32'h2000_0000) begin
			if (latched_wdata == 1)
				tests_passed = 1;
		end else 
		// Changed the target address for the 'all pass' so that it can be written from C
		if (latched_waddr == 32'h2100_0000) begin
			if (latched_wdata == 1)
				tests_passed = 1;
		end else 
		//// Sequential multiplier's inputs are given here
		if (latched_waddr 
			 32'h3000_0000) begin
			$display("Writing %3d to the reset signal", latched_wdata);
			reset_M <= latched_wdata[0];
		end else 
		if (latched_waddr == 32'h3000_0004) begin
			$display("Writing %3d to mult 'a' input", latched_wdata);
			a_M <= latched_wdata;
		end else 
		if (latched_waddr == 32'h3000_0008) begin 
			$display("Writing %3d to mult 'b' input", latched_wdata);
			b_M <= latched_wdata;
		end 
		////
		else begin
			$display("OUT-OF-BOUNDS MEMORY WRITE TO %08x", latched_waddr);
			$finish;
		end
		mem_axi_bvalid <= 1;
		latched_waddr_en = 0;
		latched_wdata_en = 0;
	end endtask

	task my_arb_en; begin
		aes_out <= ciphertext;
		if (!(latched_waddr_en || latched_wdata_en)) begin
			latched_warb_pass = 1;
			out_ready <= 1'b0;
		end
	end endtask

	task my_w_arb; begin
		mem_axi_wready <= 1; //check!!
		mem_axi_awready <= 1;
		latched_wdata = aes_out[counter];
		latched_wstrb = 4'b1111;
		latched_waddr = aes_dest_addr+(counter<<2); //check
		latched_waddr_en = 1;
		latched_wdata_en = 1;
		latched_warb_send = 1;
		if (counter == 3) latched_war_pass = 0;
		counter <= counter + 1;
	end endtask

	always @(negedge clk) begin
		if ((!latched_rar_pass) && mem_axi_arvalid && !(latched_raddr_en || fast_raddr)) handle_axi_arvalid;
		if ((!latched_warb_pass) && mem_axi_awvalid && !(latched_waddr_en || fast_waddr)) handle_axi_awvalid;
		if ((!latched_warb_pass) && mem_axi_wvalid  && !(latched_wdata_en || fast_wdata)) handle_axi_wvalid;
		if (!mem_axi_rvalid && latched_raddr_en) handle_axi_rvalid;
		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en) handle_axi_bvalid;
		if (arb_enn && (!latched_warb_pass) && (out_ready)) my_arb_en;
		if ((!latched_warb_send) && (latched_warb_pass)) my_w_arb;
		if ((latched_rar_pass) && (!latched_rarb_send)) my_r_arb;
	end

	always @(posedge clk) begin
		mem_axi_arready <= 0;
		mem_axi_awready <= 0;
		mem_axi_wready <= 0;

		fast_raddr <= 0;
		fast_waddr <= 0;
		fast_wdata <= 0;

		if (mem_axi_rvalid && mem_axi_rready) begin
			mem_axi_rvalid <= 0;
		end

		if (mem_axi_bvalid && mem_axi_bready) begin
			mem_axi_bvalid <= 0;
		end

		if (mem_axi_arvalid && mem_axi_arready && !fast_raddr) begin
			latched_raddr = mem_axi_araddr;
			latched_rinsn = mem_axi_arprot[2];
			latched_raddr_en = 1;
		end

		if (mem_axi_awvalid && mem_axi_awready && !fast_waddr) begin
			latched_waddr = mem_axi_awaddr;
			latched_waddr_en = 1;
		end

		if (mem_axi_wvalid && mem_axi_wready && !fast_wdata) begin
			latched_wdata = mem_axi_wdata;
			latched_wstrb = mem_axi_wstrb;
			latched_wdata_en = 1;
		end

		if (mem_axi_arvalid && !(latched_raddr_en || fast_raddr)) handle_axi_arvalid;
		if (mem_axi_awvalid && !(latched_waddr_en || fast_waddr)) handle_axi_awvalid;
		if (mem_axi_wvalid  && !(latched_wdata_en || fast_wdata)) handle_axi_wvalid;

		if (!mem_axi_rvalid && latched_raddr_en) handle_axi_rvalid;
		if (!mem_axi_bvalid && latched_waddr_en && latched_wdata_en) handle_axi_bvalid;
	end
endmodule
© 2021 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
