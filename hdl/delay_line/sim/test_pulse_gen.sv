//Testbench for pulse generator

module test_pulse_gen;

parameter CLK_PERIOD = 10;

logic clk, n_reset, en;
logic out;

clock #(.PERIOD(CLK_PERIOD)) clk0(.*);
power_on_reset por0(.*);
pulse_gen dut(.*);

//Stimulus
integer i,j;
initial
begin
	en = 0;
	#100ns;
	@(posedge clk);
	for(i = 0; i < 2; i ++)
	begin
		#1 en = 1;
		@(posedge clk);
		#1 en = 0;
		for(j = 0; j < 50; j++)
			@(posedge clk);
	end
	
	$finish;
end

endmodule
