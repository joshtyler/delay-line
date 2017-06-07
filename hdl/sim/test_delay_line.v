//Testbench for delay line (top level

module test_delay_line;

parameter CLK_PERIOD = 10;

wire clk_in;
reg in = 0;
wire led0, led1, out;

delay_line dut(clk_in, in, led0, led1, out);

reg clk =0;
assign clk_in = clk;

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
	for(i = 0; i < 50; i ++)
	begin
		in = 0;
		for(j = 0; j < 100; j ++) @(posedge clk);
		in = 1;
		for(j = 0; j < 10; j ++) @(posedge clk);
	end
	
	$finish;
end

endmodule
