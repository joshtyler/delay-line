//Dummy model of PLL. Always output 135MHz
`timescale 1fs/1fs

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
localparam integer CLK_FREQ = 135_000_000; //135Mhz System clock frequency
localparam realtime CLK_PERIOD = (1.0s / CLK_FREQ);
reg clk = 0;
always #(CLK_PERIOD/2) clk = !clk;
assign PLLOUTCORE = clk;

assign LOCK = 1;

endmodule