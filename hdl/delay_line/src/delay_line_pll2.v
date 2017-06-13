module delay_line_pll2(REFERENCECLK,
                       PLLOUTCORE,
                       PLLOUTGLOBAL,
                       RESET,
                       LOCK);

input REFERENCECLK;
input RESET;    /* To initialize the simulation properly, the RESET signal (Active Low) must be asserted at the beginning of the simulation */ 
output PLLOUTCORE;
output PLLOUTGLOBAL;
output LOCK;

SB_PLL40_CORE delay_line_pll2_inst(.REFERENCECLK(REFERENCECLK),
                                   .PLLOUTCORE(PLLOUTCORE),
                                   .PLLOUTGLOBAL(PLLOUTGLOBAL),
                                   .EXTFEEDBACK(),
                                   .DYNAMICDELAY(),
                                   .RESETB(RESET),
                                   .BYPASS(1'b0),
                                   .LATCHINPUTVALUE(),
                                   .LOCK(LOCK),
                                   .SDI(),
                                   .SDO(),
                                   .SCLK());

//\\ Fin=12, Fout=135;
defparam delay_line_pll2_inst.DIVR = 4'b0000;
defparam delay_line_pll2_inst.DIVF = 7'b0101100;
defparam delay_line_pll2_inst.DIVQ = 3'b001;
defparam delay_line_pll2_inst.FILTER_RANGE = 3'b001;
defparam delay_line_pll2_inst.FEEDBACK_PATH = "SIMPLE";
defparam delay_line_pll2_inst.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
defparam delay_line_pll2_inst.FDA_FEEDBACK = 4'b0000;
defparam delay_line_pll2_inst.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
defparam delay_line_pll2_inst.FDA_RELATIVE = 4'b0000;
defparam delay_line_pll2_inst.SHIFTREG_DIV_MODE = 2'b00;
defparam delay_line_pll2_inst.PLLOUT_SELECT = "GENCLK";
defparam delay_line_pll2_inst.ENABLE_ICEGATE = 1'b0;

endmodule
