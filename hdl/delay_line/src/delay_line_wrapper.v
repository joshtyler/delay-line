// Top level module

module delay_line_wrapper(clk_in, in_sig, out_sig, //Real inputs
LED0, LED1, LED2, LED3, LED4, SD); //Inputs to hold at either vcc or ground

input clk_in, in_sig;
output out_sig, LED0, LED1, LED2, LED3, LED4, SD;

//Hold LEDs at 0V
assign LED0 = 0;
assign LED1 = 0;
assign LED2 = 0;
assign LED3 = 0;
assign LED4 = 0;

//Hold IR shutdown at 3.3V (active high shutdown)
assign SD = 1;

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

endmodule