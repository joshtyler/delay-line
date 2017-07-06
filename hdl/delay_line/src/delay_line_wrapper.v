// Top level module

module delay_line_wrapper(clk_in, in_sig, out_sig, led);

input clk_in, in_sig;
output out_sig, led;

//PLL
wire clk, pll_locked;
pll pll0
(
	.clock_in(clk_in),
	.clock_out(clk),
	.locked(pll_locked)
);

//Power on reset
wire n_reset;
power_on_reset por0
(
	.clk(clk),
	.en(pll_locked),
	.n_reset(n_reset)
);

delay_line delay_line_0
(
	.clk(clk),
	.n_reset(n_reset),
	.in(in_sig),
	.out(out_sig)
);

//Heartbeat LED
reg [27:0] ctr;
always @(posedge clk)
	if(!n_reset)
		ctr <= 0;
	else
		ctr <= ctr +1;
assign led = ctr[27];


endmodule