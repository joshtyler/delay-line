// Top level module

module delay_line(clk_in, in, led0, led1, out);

parameter integer FIFO_DEPTH = 600; //Depth of main FIFO (How many pulses can be stored)
parameter integer MODULATION_FREQ = 13_500_000; //13.5MHz
parameter integer CLK_FREQ = 135_000_000; //135Mhz - must be an even multiple of modulation freq
parameter real EDGE_DETECT_TIMEOUT = 1.5e-6; //Timeout for edge detector
parameter real DELAY_TIME = 1e-3; // Delay of delay line
parameter real PULSE_TIME = 0.9e-6; //Time of pulse (will be rounded to full cycles of modulation frequency)

localparam real CLK_PERIOD = 1.0 / CLK_FREQ;
localparam real MODULATION_PERIOD = 1.0 / MODULATION_FREQ;
localparam integer EDGE_DETECT_TIMEOUT_CYCLES = EDGE_DETECT_TIMEOUT/ CLK_PERIOD; //Timeout for edge detector, in clock periods
localparam integer DELAY_CYCLES = DELAY_TIME / CLK_PERIOD; // Delay of delay line in clock periods.
localparam integer PULSE_GEN_CLKS_PER_HALF_PERIOD = (MODULATION_PERIOD/CLK_PERIOD)/2; //Number of pulses per half period of pulse generator
localparam integer PULSE_GEN_PULSES = PULSE_TIME / MODULATION_PERIOD; //Number of pulses for pulse generator to produce
localparam integer CTR_WIDTH = $clog2(DELAY_CYCLES); //Counter must not overflow twice between delays, or we will miss the event

localparam integer DELAY = DELAY_CYCLES - 2 - 1 - 1; // We lose two clock cycles due to synchronisation flip flops, one in edge detector, and one in output stage

input clk_in, in;
output led0, led1, out; //LED0 is PLL lock, // LED1 is FIFO full

//PLL
wire clk;
pll pll0(clk_in, clk, led0);

//Power on reset
reg n_reset;
power_on_reset por0 (.*);

//Synchronisation flip flops
reg in_sync_intermediate, in_sync;
always @(posedge clk)
begin
	in_sync_intermediate <= in;
	in_sync <= in_sync_intermediate;
end

//Counter
reg [CTR_WIDTH-1:0] ctr, fifo_data_in;
always @(posedge clk)
	if(!n_reset)
		ctr <= 0;
	else
		ctr <= ctr + 1;
assign fifo_data_in = ctr + DELAY; //Data in to FIFO

//Edge detector
wire fifo_wren; //FIFO write enable
edge_detect #(EDGE_DETECT_TIMEOUT_CYCLES) edge0(clk, n_reset, in_sync, fifo_wren);

//FIFO
wire fifo_empty, fifo_full, fifo_rden;
reg [CTR_WIDTH-1:0] fifo_data_out;
fifo #(CTR_WIDTH, FIFO_DEPTH)  fifo0(clk, n_reset, fifo_data_in, fifo_wren, fifo_data_out, fifo_rden, fifo_empty, fifo_full);
assign led1 = fifo_full;

//Comparator
wire pulse_gen_trigger;
comparator #(CTR_WIDTH) comp0(clk, n_reset, fifo_empty, fifo_data_out, ctr, fifo_rden, pulse_gen_trigger);

//Pulse generator
pulse_gen #(PULSE_GEN_CLKS_PER_HALF_PERIOD, PULSE_GEN_PULSES) pulse_gen0(clk, n_reset, pulse_gen_trigger, out);

endmodule
