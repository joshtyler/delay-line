//Testbench for pulse generator

module test_pulse_gen;

parameter CLK_PERIOD = 10;

reg clk = 0, en;
wire out;

pulse_gen dut(clk, en, out);

//Dump to waveform
initial
begin
    $dumpfile("test.lxt");
    $dumpvars(0,dut);
end

//Clock
always #(CLK_PERIOD/2) clk = !clk;

//Stimulus
integer i,j;
initial
begin
	en = 0;
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
