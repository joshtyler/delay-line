// Top level module

module test_harness_wrapper(clk_in, uart_rx_pin, in_sig, uart_tx_pin, out_sig, output_clk, in_demod, sample, next_word, clk_out);

input clk_in, uart_rx_pin, in_sig;
output uart_tx_pin, out_sig;

//Debug outputs
output output_clk,in_demod, next_word, clk_out;
output reg sample;


//PLLa 
wire clk, clk_intermediate, pll_locked, plla_locked, pllb_locked;
plla plla0
(
	.clock_in(clk_in),
	.clock_out(clk_intermediate),
	.locked(plla_locked)
);

pllb pllb0
(
	.clock_in(clk_intermediate),
	.clock_out(clk),
	.locked(pllb_locked)
);

assign pll_locked = plla_locked && pllb_locked;


//Power on reset
wire n_reset;
power_on_reset por0
(
	.clk(clk),
	.en(pll_locked),
	.n_reset(n_reset)
);

wire out, out_en;
test_harness test_harness_0
(
	.clk(clk),
	.n_reset(n_reset),
	.uart_rx_pin(uart_rx_pin),
	.in(in_sig),
	.uart_tx_pin(uart_tx_pin),
	.out(out),
	.out_en(out_en)
);
assign out_sig = out_en? out : 1'bz; //Tristate output


assign output_clk = 0; //test_harness_0.mem_manager_0.output_clk;
assign in_demod = 0; // test_harness_0.demod_out;
assign next_word = 0; // test_harness_0.mem_manager_0.load_replacement_num;

always @(posedge clk)
	sample <= uart_rx_pin; // test_harness_0.mem_manager_0.output_clk_middle_high;

assign clk_out = clk;


endmodule
