// Top level module

module test_harness_wrapper(clk_in, uart_rx_pin, in, uart_tx_pin, out, output_clk, in_demod, sample, next_word, clk_out);

input clk_in, uart_rx_pin, in;
output uart_tx_pin, out;

//Debug outputs
output output_clk,in_demod, sample, next_word, clk_out;


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
	.clk(clk),
	.n_reset(n_reset),
	.uart_rx_pin(uart_rx_pin),
	.in(in),
	.uart_tx_pin(uart_tx_pin),
	.out(out)
);


assign output_clk = 0; //test_harness_0.mem_manager_0.output_clk;
assign in_demod = 0; // test_harness_0.demod_out;
assign sample = 0; // test_harness_0.mem_manager_0.output_clk_middle_high;
assign next_word = 0; // test_harness_0.mem_manager_0.load_replacement_num;
assign clk_out = clk;


endmodule
