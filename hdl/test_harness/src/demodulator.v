//Demodulator
//Synchronous reset
`include "uart_msg_consts.h"

module demodulator (clk,
                  n_reset,
                  in,
                  demod_params,
                  out
                  );

input clk, n_reset, in;
input `UART_DEMOD_PARAMS_TOTAL_PAYLOAD_SIZE demod_params;
output out;

wire `UART_DEMOD_PARAMS_PULSE_WIDTH_SIZE pulse_width;
assign pulse_width = demod_params `UART_DEMOD_PARAMS_PULSE_WIDTH_PAYLOAD_BITS;


reg `UART_DEMOD_PARAMS_PULSE_WIDTH_SIZE ctr, next_ctr;

enum logic[1:0] {SM_WAIT, SM_COUNT} state;

//Next state logic
always @(posedge clk)
	if(!n_reset) begin
		state <= SM_WAIT;
		ctr <= 0;
	end else begin
		case(state)
			SM_WAIT: if(in) state <= SM_COUNT;
			SM_COUNT: if(ctr >= pulse_width-1) state <= SM_WAIT;
		endcase;
		ctr <= next_ctr;
	end

//Counter logic
always @(*)
	case(state)
		SM_WAIT: next_ctr = 0;
		SM_COUNT: next_ctr = ctr +1;
	endcase

//Output logic
assign out = (state == SM_COUNT);

endmodule
