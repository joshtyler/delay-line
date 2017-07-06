//Dummy model of PLL. Always output 135MHz
`timescale 1ps/1ps
module SB_PLL40_CORE(
	input RESETB,
	input BYPASS,
	input REFERENCECLK,
	output PLLOUTCORE,
	output LOCK,
	output PLLOUTGLOBAL,
	input EXTFEEDBACK,
	input [7:0] DYNAMICDELAY,
	input LATCHINPUTVALUE,
	input SDI,
	output SDO,
	input SCLK
	);

parameter DIVR = 4'b0000;
parameter DIVF = 7'b1000111;
parameter DIVQ = 3'b100; //MODIFIED MANUALLY TO BE 4
parameter FILTER_RANGE = 3'b001;
parameter FEEDBACK_PATH = "SIMPLE";
parameter DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
parameter FDA_FEEDBACK = 4'b0000;
parameter DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
parameter FDA_RELATIVE = 4'b0000;
parameter SHIFTREG_DIV_MODE = 2'b00;
parameter PLLOUT_SELECT = "GENCLK";
parameter ENABLE_ICEGATE = 1'b0;
parameter TEST_MODE = 1'b0;

//Clock
parameter integer CLK_FREQ = 1; //1Hz system clock (override with real value in instantiation)
localparam realtime CLK_PERIOD = (1.0s / CLK_FREQ);
reg clk = 0;
always #(CLK_PERIOD/2) clk = !clk;
assign PLLOUTCORE = clk;

assign LOCK = 1;

endmodule