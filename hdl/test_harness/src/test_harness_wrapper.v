// Top level module

module test_harness_wrapper(clk_in, uart_rx_pin, in, uart_tx_pin, out);

input clk_in, uart_rx_pin, in;
output uart_tx_pin, out;

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

test_harness test_harness_0
(
	.*
);


endmodule