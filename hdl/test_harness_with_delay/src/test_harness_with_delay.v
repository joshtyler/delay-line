// Top level module

module test_harness_with_delay(clk_in, harness_in, delay_line_in, uart_rx_pin, harness_out, delay_line_out, uart_tx_pin);

input clk_in, harness_in, delay_line_in, uart_rx_pin;
output harness_out, delay_line_out, uart_tx_pin;

localparam integer CLK_FREQ = 81_000_000; //81Mhz (out of PLL)
localparam real BIT_TIME = 1.9e-6; //Time per bit
localparam real BITS = 576; //Number of bits in a delay line

//localparam DELAY = BIT_TIME * BITS; //Make delay slighty shorter so that we hit the middle of the clock pulse


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

//Test harness
test_harness #(
	.CLK_RATE(CLK_FREQ)
) test_harness0 (
	.clk(clk),
	.n_reset(n_reset),
	.uart_rx_pin(uart_rx_pin),
	.in(harness_in),
	.uart_tx_pin(uart_tx_pin),
	.out(harness_out)
);

//Delay line
delay_line #(
	.CLK_FREQ(CLK_FREQ)
//	.DELAY_TIME(DELAY)
)  delay_line_0 (
	.clk(clk),
	.n_reset(n_reset),
	.in(delay_line_in),
	.out(delay_line_out)
);

endmodule