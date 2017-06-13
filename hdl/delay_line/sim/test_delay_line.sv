//Testbench for delay line (top level)

`timescale 1fs/1fs

//`define DEBUG

module test_delay_line;

parameter integer CLK_FREQ = 135_000_000; //135Mhz System clock frequency
parameter integer MOD_FREQ = 13_500_000; //13.5Mhz Moduluation frequency
parameter realtime PULSE_WIDTH = 0.9us;
parameter realtime PULSE_GAP = 1.0us;
parameter realtime DELAY = 1.0ms;
parameter integer EDSAC_NUM_WIDTH = 35; //Number with (excluding blanking pulse)

localparam realtime CLK_PERIOD = (1.0s / CLK_FREQ);
localparam realtime MOD_PERIOD = (1.0s / MOD_FREQ);
localparam integer PULSES = $floor(PULSE_WIDTH / MOD_PERIOD);

localparam realtime DELAY_TOLERANCE = 0.5*CLK_PERIOD; //Allow +/- this
 

wire clk_in;
reg in = 0;
wire led0, led1, out;

delay_line dut(clk_in, in, led0, led1, out);

reg clk =0;
assign clk_in = clk;

//Dump to waveform
initial
begin
    $dumpfile("test.gtk");
    $dumpvars(0,dut);
end

//Clock
always #(CLK_PERIOD/2) clk = !clk;


//Queue for verification of pulses
realtime pulse_queue[$] = {}; //Empty queue

//Task to simulate an individual input pulse
task simulate_pulse;
input logic value;
integer i;
begin
	in = 0;
	for(i=0; i< PULSES; i++)
	begin
		in = value;
		if(value)
			pulse_queue.push_back($realtime + DELAY);
		`ifdef DEBUG
		$display("Time is %t, adding %t to queue", $realtime, $realtime + DELAY);
		`endif
		#(MOD_PERIOD/2);
		in = 0;
		#(MOD_PERIOD/2);
	end
	#PULSE_GAP;
end
endtask

task simulate_number;
input logic[EDSAC_NUM_WIDTH-1:0] num;
integer i;
begin
	//Transmit number
	for(i=$high(num); i >= 0; i--)
		simulate_pulse(num[i]);

	//Spacing pulse
	simulate_pulse(0);
end
endtask

//Check that delay is working correctly
realtime target, diff;
always @(posedge out)
begin
	target = pulse_queue.pop_front();
	`ifdef DEBUG
	$display("Target: %t, Realtime: %t", target, $realtime);
	`endif
	if(target > $realtime)
		diff = target - $realtime;
	else
		diff = $realtime - target;
	assert(diff < DELAY_TOLERANCE) else begin $display("diff: %t, tol: %t",diff, DELAY_TOLERANCE); $finish; end;	
end


//Stimulus
integer i;
initial
begin
	simulate_number('1);
	simulate_number(0);

	for(i=0; i<20; i++)
		simulate_number($urandom_range( (2 << EDSAC_NUM_WIDTH) -1 ,0));

	#(1.5*DELAY);
	$display("Simulation completed successfully");
	$finish;
end

endmodule