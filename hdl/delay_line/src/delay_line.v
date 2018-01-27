// Top level module

module delay_line(clk, n_reset, in, out, out_en);

parameter integer FIFO_DEPTH = 1024; //Depth of main FIFO (How many pulses can be stored)
parameter integer MODULATION_FREQ = 13_500_000; //13.5MHz
parameter integer CLK_FREQ = 81_000_000; //Must be an even multiple of modulation freq
parameter real EDGE_DETECT_TIMEOUT = 1.5e-6; //Timeout for edge detector
parameter integer DELAY_CYCLES = 92502; // =delay time / clk period = 1.152e-3 / 12.3456ns
parameter real PULSE_TIME = 1.2e-6; //Time of pulse (will be rounded to full cycles of modulation frequency)

localparam real CLK_PERIOD = 1.0 / CLK_FREQ;
localparam real MODULATION_PERIOD = 1.0 / MODULATION_FREQ;
localparam integer EDGE_DETECT_TIMEOUT_CYCLES = EDGE_DETECT_TIMEOUT/ CLK_PERIOD; //Timeout for edge detector, in clock periods
//localparam integer DELAY_CYCLES = DELAY_TIME / CLK_PERIOD; // Delay of delay line in clock periods.
localparam integer PULSE_GEN_CLKS_PER_HALF_PERIOD = (MODULATION_PERIOD/CLK_PERIOD)/2; //Number of pulses per half period of pulse generator
localparam integer PULSE_GEN_PULSES = PULSE_TIME / MODULATION_PERIOD; //Number of pulses for pulse generator to produce
parameter integer CTR_WIDTH = $clog2(DELAY_CYCLES); //Counter must not overflow twice between delays, or we will miss the event

localparam integer DELAY = DELAY_CYCLES - 2 - 1 - 1; // We lose two clock cycles due to synchronisation flip flops, one in edge detector, and one in output stage

input clk, n_reset, in;
output out, out_en;

//Synchronisation flip flops
reg in_sync_intermediate, in_sync;
always @(posedge clk)
begin
	in_sync_intermediate <= in;
	in_sync <= in_sync_intermediate;
end

//Counter
reg [CTR_WIDTH-1:0] ctr;
wire [CTR_WIDTH-1:0] fifo_data_in;
always @(posedge clk)
	if(!n_reset)
		ctr <= 0;
	else
		ctr <= ctr + 1;
assign fifo_data_in = ctr + DELAY; //Data in to FIFO

//Edge detector
wire fifo_wren; //FIFO write enable
edge_detect #(
		.TIMEOUT(EDGE_DETECT_TIMEOUT_CYCLES)
	) edge0( 
		.clk(clk),
		.n_reset(n_reset),
		.in(in_sync),
		.out(fifo_wren)
	);

//FIFO
wire fifo_empty, fifo_full, fifo_rden;
wire [CTR_WIDTH-1:0] fifo_data_out;
fifo #(
		.WIDTH(CTR_WIDTH),
		.DEPTH(FIFO_DEPTH)
	)fifo0(
		.clk(clk),
		.n_reset(n_reset),
		.data_in(fifo_data_in),
		.wr_en(fifo_wren),
		.data_out(fifo_data_out),
		.rd_en(fifo_rden),
		.empty(fifo_empty),
		.full(fifo_full)
	);

//Comparator
wire pulse_gen_trigger;
comparator #(
		.WIDTH(CTR_WIDTH)
	) comp0 (
		.clk(clk),
		.n_reset(n_reset),
		.empty(fifo_empty),
		.data_in(fifo_data_out),
		.count(ctr),
		.req_data(fifo_rden),
		.trigger(pulse_gen_trigger)
	);

//Pulse generator
pulse_gen #(
		.CLKS_PER_HALF_PERIOD(PULSE_GEN_CLKS_PER_HALF_PERIOD),
		.PULSES(PULSE_GEN_PULSES)
	) pulse_gen0 (
		.clk(clk),
		.n_reset(n_reset),
		.en(pulse_gen_trigger),
		.active(out_en),
		.out(out)
	);

endmodule
