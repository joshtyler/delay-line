//Testbench for edge detector

module test_edge_detect;

parameter CLK_PERIOD = 10;

reg clk = 0, in;
wire out;

edge_detect dut(clk, in, out);

//Dump to waveform
initial
begin
    $dumpfile("test.lxt");
    $dumpvars(0,dut);
end

//Clock
always #(CLK_PERIOD/2) clk = !clk;

//Stimulus
integer i;
initial
begin
	in = 0;
	@(posedge clk);
	for(i = 0; i < 50; i ++)
	begin
		in = !in;
		@(posedge clk);
		@(posedge clk);
	end
	
	$finish;
end

endmodule
