//Dummy model of PLL. Always output 135MHz

module SB_PLL40_CORE(
	input RESETB,
	input BYPASS,
	input REFERENCECLK,
	output PLLOUTCORE,
	output LOCK
	);

parameter FEEDBACK_PATH;
parameter DIVR;
parameter DIVF;
parameter DIVQ;
parameter FILTER_RANGE;

//Clock
parameter integer CLK_FREQ = 1; //1Hz system clock (override with real value in instantiation)
localparam realtime CLK_PERIOD = (1.0s / CLK_FREQ);
reg clk = 0;
always #(CLK_PERIOD/2) clk = !clk;
assign PLLOUTCORE = clk;

assign LOCK = 1;

endmodule