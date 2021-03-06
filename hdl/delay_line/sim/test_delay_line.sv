//Testbench for delay line (top level)
//Run with 1fs time precision to avoid assert failures
`timescale 1fs/1fs
`define DEBUG

module test_delay_line;

parameter integer CLK_FREQ = 12_000_000; //12Mhz System clock frequency
parameter integer MOD_FREQ = 13_500_000; //13.5Mhz Moduluation frequency
parameter realtime PULSE_WIDTH = 0.9us;
parameter realtime PULSE_GAP = 1.0us;
parameter realtime DELAY = 1.14108642ms;
parameter integer EDSAC_NUM_WIDTH = 35; //Number with (excluding blanking pulse)

localparam realtime CLK_PERIOD = (1.0s / CLK_FREQ);
localparam realtime MOD_PERIOD = (1.0s / MOD_FREQ);
localparam integer PULSES = $floor(PULSE_WIDTH / MOD_PERIOD);

localparam realtime DELAY_TOLERANCE = CLK_PERIOD;
 

logic clk, clk_in, in, out;

clock #(.PERIOD(CLK_PERIOD)) clk0(.*);
delay_line_wrapper dut(.clk_in(clk), .in_sig(in), .out_sig(out), .enable(), .LED0(), .LED1(), .LED2(), .LED3(), .LED4(), .SD());
defparam dut.pll0.uut.CLK_FREQ = 81_000_000;

//assert property (@(posedge clk) dut.pll0.uut.CLK_FREQ == dut.CLK_FREQ); //We cannot set the PLL freq to a non-constant value, but we can check that it is the same as the DUT!

assign (pull1,pull0) out_sig = 1'b0; //Drive weak 0 due to tristate output (simulate pulldown)

assign clk_in = clk;


//Queue for verification of pulses
realtime pulse_queue[$] = {}; //Empty queue

//Task to simulate an individual input pulse
task simulate_pulse;
input logic value;
integer i;
begin
	#100ns;
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
	if(out != 1'bz)
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
	end;
end


//Stimulus
integer i;
initial
begin
	in = 0;
	#100ns;
	simulate_number('1);
	simulate_number(0);

	for(i=0; i<20; i++)
		simulate_number($urandom_range( (2 << EDSAC_NUM_WIDTH) -1 ,0));

	#(1.5*DELAY);
	$display("Simulation completed successfully");
	$finish;
end

endmodule
