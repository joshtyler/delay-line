//Testbench for edge detector

module test_edge_detect;

parameter CLK_PERIOD = 10;

reg clk, n_reset, in;
wire out;

clock #(.PERIOD(CLK_PERIOD)) clk0(.*);
power_on_reset por0(.*);
edge_detect dut(.*);


//Stimulus
integer i;
initial
begin
	in = 0;
	#100ns; //Wait for reset
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
