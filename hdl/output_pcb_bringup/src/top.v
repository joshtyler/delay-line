// Top level module

module top(LED0, LED1, clk_in);

input clk_in;
output LED0, LED1;

reg [23:0] ctr;

//Hold LEDs
assign LED0 = 0;
assign LED1 = ctr[23];

always @(posedge clk_in) ctr <= ctr + 1;

endmodule
