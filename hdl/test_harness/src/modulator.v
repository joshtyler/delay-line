//Modulator
//Synchronous reset
`include "uart_msg_consts.h"

module modulator (clk,
                  n_reset,
                  in,
                  mod_params,
                  out
                  );

input clk, n_reset, in;
input `UART_MOD_PARAMS_TOTAL_PAYLOAD_SIZE mod_params;
output out;

wire `UART_MOD_PARAMS_CYCLES_PER_HALF_PERIOD_SIZE cycles_per_half_period;
assign cycles_per_half_period = mod_params `UART_MOD_PARAMS_CYCLES_PER_HALF_PERIOD_PAYLOAD_BITS;


reg `UART_MOD_PARAMS_CYCLES_PER_HALF_PERIOD_SIZE ctr;

always @(posedge clk)
	if(!n_reset)
		ctr <= 0;
	else
		if(ctr > (cycles_per_half_period -1))
			ctr <= 0;
		else
			ctr <= ctr + 1'b1;

reg mod; //Signal to AND with data and modulate
always @(posedge clk)
	if(!n_reset)
		mod <= 0;
	else if(ctr == 0)
		mod <= !mod;

//Modulate output with input signal
assign out = in && mod;

endmodule
