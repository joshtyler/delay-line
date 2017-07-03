// Top level module

module delay_line_wrapper(clk_in, in, out);

input clk_in, in;
output out; //LED0 is PLL lock, // LED1 is FIFO full

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
	.en(en),
	.n_reset(n_reset)
);

delay_line delay_line_0
(
	.*
);


endmodule