// Top level module

module delay_line(clk_in, in, led0, led1, out);

parameter CTR_WIDTH = 16; //Width of main counter
parameter EDGE_DETECT_TIMEOUT = 20; //Timeout for edge detector, in clock periods
parameter DELAY_RAW = 200; // Delay of delay line in clock periods.
parameter FIFO_DEPTH = 1000; //Depth of main FIFO
parameter PULSE_GEN_CLKS_PER_HALF_PERIOD = 2; //Number of pulses per half period of pulse generator
parameter PULSE_GEN_PULSES = 3; //Number of pulses for pulse generator to produce

localparam DELAY = DELAY_RAW - 1 - 1 - 1; // We lose two clock cycles due to synchronisation flip flops, one in edge detector, and one in output stage

input clk_in, in;
output led0, led1, out; //LED0 is heartbeat, // LED1 is FIFO full


//Temporary, names are different to allow for addition of PLL
wire clk;
assign clk = clk_in;

//Synchronisation flip flops
reg in_sync_intermediate, in_sync;
always @(posedge clk)
begin
	in_sync_intermediate <= in;
	in_sync <= in_sync_intermediate;
end

//Counter
reg [CTR_WIDTH-1:0] ctr = 0, fifo_data_in;
always @(posedge clk)
	ctr <= ctr + 1;
assign fifo_data_in = ctr + DELAY; //Data in to FIFO

//Edge detector
wire fifo_wren; //FIFO write enable
edge_detect #(EDGE_DETECT_TIMEOUT) edge0(clk, in, fifo_wren);

//FIFO
wire fifo_empty, fifo_full, fifo_rden;
reg [CTR_WIDTH-1:0] fifo_data_out;
fifo #(CTR_WIDTH, FIFO_DEPTH)  fifo0(clk, fifo_data_in, fifo_wren, fifo_data_out, fifo_rden, fifo_empty, fifo_full);
assign led1 = fifo_full;

//Comparator
wire pulse_gen_trigger;
comparator #(CTR_WIDTH) comp0(clk, fifo_empty, fifo_data_out, ctr, fifo_rden, pulse_gen_trigger);

//Pulse generator
pulse_gen #(PULSE_GEN_CLKS_PER_HALF_PERIOD, PULSE_GEN_PULSES) pulse_gen0(clk, pulse_gen_trigger, out);

endmodule
