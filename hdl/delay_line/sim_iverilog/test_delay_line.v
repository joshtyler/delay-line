//Testbench for delay line (top level)

`define assert(cond) \
        if (!cond) begin \
            $display("ASSERTION FAILED in %m"); \
            $finish; \
        end

`timescale 1fs/1fs

module test_delay_line;

parameter integer CLK_FREQ = 135_000_000; //135Mhz System clock frequency
parameter integer MOD_FREQ = 13_500_000; //13.5Mhz Moduluation frequency
parameter realtime PULSE_WIDTH = 0.9us;
parameter realtime PULSE_GAP = 1.0us;
parameter realtime DELAY = 1.0ms; 

localparam realtime CLK_PERIOD = (1.0s / CLK_FREQ);
localparam realtime MOD_PERIOD = (1.0s / MOD_FREQ);

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
    $dumpfile("test.lxt");
    $dumpvars(0,dut);
end

//Clock
always #(CLK_PERIOD/2) clk = !clk;

//Task to simulate an individual input pulse
task simulate_pulse;
realtime t;
begin
	in = 0;
	t = $realtime;
	while($realtime < (t + PULSE_WIDTH))
	begin
		in = 1;
		#(MOD_PERIOD/2);
		in = 0;
		#(MOD_PERIOD/2);
	end
	#PULSE_GAP;
end
endtask

task simulate_pulse_train;
input integer len; //Number to simulate
integer i;
realtime t, diff;
begin
	t = $realtime;
	$display("Start, t= %d", t);
	//Produce pulses
	for(i=0; i < len; i++)
		simulate_pulse;

	$display("End, t= %d", $realtime);
	@(posedge out); //Wait for pulses to come out
	$display("Delayed, t= %d", $realtime);
	if(($realtime - t) > DELAY)
		diff = ($realtime - t) - DELAY;
	else
		diff = DELAY - ($realtime - t);

	$display("Diff: %d \n", diff);


	`assert((diff < DELAY_TOLERANCE));
	`assert((diff > (-DELAY_TOLERANCE)));

end
endtask


//Stimulus
integer i,j;
initial
begin
	$display("Clock period: %d \n", CLK_PERIOD);
	$display("DELAY: %d \n", DELAY);
	$display("DELAY_TOLERANCE: %d \n", DELAY_TOLERANCE);
	$display("dut.DELAY_CYCLES: %d \n", dut.DELAY_CYCLES);
	$display("dut.DELAY: %d \n", dut.DELAY);
	simulate_pulse_train(5);
	
	$finish;
end

endmodule
