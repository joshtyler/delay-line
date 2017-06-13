//Testbench for sychronous FIFO

module test_fifo;

parameter WIDTH = 8;
parameter DEPTH = 10;
parameter CLK_PERIOD = 10;

reg clk = 0, wr_en, rd_en;
wire empty, full;
reg [WIDTH-1:0] data_in;
wire [WIDTH-1:0] data_out;

fifo #(WIDTH, DEPTH) dut(clk, data_in, wr_en, data_out, rd_en, empty, full);

//fifo dut #(.WIDTH(WIDTH), .DEPTH(DEPTH)) (*.);

//Dump to waveform
integer i;
initial
 begin
    $dumpfile("test.lxt");
    $dumpvars(0,dut);
	for(i=0; i< DEPTH; i++)
		$dumpvars(1, dut.mem[i]);
 end

//Clock
always #(CLK_PERIOD/2) clk = !clk;


//Stimulus
initial
begin
	wr_en = 0;
	rd_en = 0;
	data_in = 0;
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
