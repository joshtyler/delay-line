//Testbench for delay line (top level)

`timescale 1ns/1ps

module test_delay_line;

parameter integer CLK_FREQ = 165_000_000; //165Mhz
localparam time CLK_PERIOD = (1.0s / CLK_FREQ);
parameter time PULSE_WIDTH = 1us;
parameter time PULSE_GAP = 10us; // Not the same as the real system

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
	$display("Clock period: ", CLK_PERIOD);
	for(i = 0; i < 200; i ++)
	begin
		in = 0;
		#PULSE_GAP;
		in = 1;
		#PULSE_WIDTH;
	end
	in = 0;
	for(i = 0; i < 200; i ++) #PULSE_GAP;
	
	$finish;
end

endmodule
