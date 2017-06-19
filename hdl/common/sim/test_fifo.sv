//Testbench for sychronous FIFO

module test_fifo;

parameter WIDTH = 8;
parameter DEPTH = 10;
parameter CLK_PERIOD = 10;

logic clk, n_reset, wr_en, rd_en;
logic empty, full;
logic [WIDTH-1:0] data_in;
logic [WIDTH-1:0] data_out;

clock #(.PERIOD(CLK_PERIOD)) clk0(.*);

fifo  #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut(.*);

power_on_reset reset0 (.*);

//Stimulus
initial
begin
	wr_en = 0;
	rd_en = 0;
	data_in = 0;
	#100ns; //Reset
	@(posedge clk);

	while(!full)
	begin
		data_in = $urandom_range((2 << WIDTH)-1,0);
		wr_en= 1;
		$display("Writing ", data_in);
		@(posedge clk);
		#1 wr_en = 0;
	end

	while(!empty)
	begin
		rd_en= 1;
		@(posedge clk);
		rd_en = 0;
		#1 $display("Read ", data_out);
	end

	$finish;
end

endmodule
