//Controller
`include "uart_msg_consts.h"
`include "test_harness_consts.h"

module controller(clk, n_reset, run,
                  uart_in_avail, uart_in_msg, uart_in_full, uart_in_req,
                  uart_out_full, uart_out_msg, uart_out_req,
                  mem_received_num, mem_received_replaced, mem_received_valid, mem_received_overrun, mem_received_ack,
                  mem_replace_num, mem_replace_valid, mem_params,
                  mod_params,
                  demod_params);

//Clocking/reset inputs
input clk, n_reset;

//System status
output reg run; //True when the system is running

//UART message input
input uart_in_avail; //Messge is waiting in the FIFO
input `UART_MSG_SIZE uart_in_msg; //Message from input FIFO
input uart_in_full; //Input FIFO is full
output reg uart_in_req; //Request input message from FIFO

//UART message output
input uart_out_full; //Output FIFO is full
output reg `UART_MSG_SIZE uart_out_msg; //Message to client
output reg uart_out_req; //Send message to client

//Memory manager IO
input `UART_RECEIVED_WRONG_NUM_TOTAL_PAYLOAD_SIZE mem_received_num; //Received number message from memory manager
input mem_received_replaced; //True if the number is a replacement rather than an errror
input mem_received_valid; //The current message is valid - reset when acked 
input mem_received_overrun; //High if a second number is received before the first is acked
output reg mem_received_ack; //The current message has been read
output `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE mem_replace_num; //Number to replace a number in memory
output reg mem_replace_valid; //True when memory replacement number is true
output reg `UART_MEM_PARAMS_TOTAL_PAYLOAD_SIZE mem_params; //Memory manager parameters

//Modulator IO
output reg `UART_MOD_PARAMS_TOTAL_PAYLOAD_SIZE mod_params;

//Demodulator IO
output reg `UART_DEMOD_PARAMS_TOTAL_PAYLOAD_SIZE demod_params;

reg[2:0] state;
localparam SM_POLL_MEM_MANAGER = 3'b000;
localparam SM_POLL_UART_IN = 3'b001;
localparam SM_UART_IN_MSG = 3'b010;
localparam SM_POLL_UART_OUT = 3'b011;
localparam SM_HALT = 3'b100;


reg `UART_MSG_SIZE next_uart_out_msg;
reg `UART_MEM_PARAMS_TOTAL_PAYLOAD_SIZE next_mem_params;
reg `UART_MOD_PARAMS_TOTAL_PAYLOAD_SIZE next_mod_params;
reg `UART_DEMOD_PARAMS_TOTAL_PAYLOAD_SIZE next_demod_params;
reg next_run;
reg next_mem_received_ack; //This needs to be registered to avoid a logic loop

//Used to determine if the system should HALT or not
function isFatalErrorMessage;
input `UART_HEADER_SIZE head;
	isFatalErrorMessage = (//head == `UART_HEADER_ERR_INVALID_MSG ||
	                  //head == `UART_HEADER_ERR_UPDATE_WHILST_RUN ||
	                  head == `UART_HEADER_RECEIVED_WRONG_NUM ||
	                  head == `UART_HEADER_ERR_MEM_OVERRUN || 
	                  head == `UART_HEADER_ERR_FIFO_FULL);
endfunction

//Create an acknowledge/invalid message message
function `UART_MSG_SIZE genAckErrMsg;
input `UART_MSG_SIZE msg_in;
input `UART_HEADER_SIZE header;
	genAckErrMsg = {msg_in[(`UART_MSG_WIDTH-`UART_HEADER_WIDTH-1):0], header};
endfunction

//Next state logic
always @(posedge clk)
begin
	if(!n_reset)
	begin
		state <= SM_POLL_MEM_MANAGER;
		run <= 0;
		mod_params <= `DEFAULT_MOD_PARAMS;
		mem_params <= `DEFAULT_MEM_PARAMS;
		demod_params <= `DEFAULT_DEMOD_PARAMS;
		mem_received_ack <= 0;
		
	end else begin
		uart_out_msg <= next_uart_out_msg;
		run <= next_run;
		mod_params <= next_mod_params;
		mem_params <= next_mem_params;
		demod_params <= next_demod_params;
		mem_received_ack <= next_mem_received_ack;
		case(state)
			SM_POLL_MEM_MANAGER:
				if(mem_received_valid || mem_received_overrun)
					state <= SM_POLL_UART_OUT; //Send message (or error) via UART
				else
					state <= SM_POLL_UART_IN; //No new number, check UART

			SM_POLL_UART_IN:
				if(uart_in_avail)
					state <= SM_UART_IN_MSG; //Create response message
				else if (uart_in_full)
					state <= SM_POLL_UART_OUT; //Send error message
				else
					state <= SM_POLL_MEM_MANAGER; //Nothing at UART, check memory manager

			SM_UART_IN_MSG:
				state <= SM_POLL_UART_OUT; //Send via UART

			SM_POLL_UART_OUT:
				if(!uart_out_full)
				begin
					if(isFatalErrorMessage(uart_out_msg `UART_HEADER_BITS))
						state <= SM_HALT; //Halt if error message
					else
						state <= SM_POLL_MEM_MANAGER; //If we can send the message, otherwise wait
				end
			SM_HALT:
				state <= SM_POLL_MEM_MANAGER; //Run has been reset to 0, so we can start again
		endcase
	end
end

//State machine output logic
assign mem_replace_num = uart_in_msg `UART_REPLACE_NUM_TOTAL_PAYLOAD_BITS;
always @(*)
begin
	uart_in_req = 0;
	next_run = run;
	next_uart_out_msg = uart_out_msg;
	next_mem_received_ack = 0;
	uart_out_req = 0;
	mem_replace_valid = 0;
	next_mod_params = mod_params;
	next_mem_params = mem_params;
	next_demod_params = demod_params;

	case(state)
		SM_POLL_MEM_MANAGER:
		begin
			if(mem_received_overrun)
				next_uart_out_msg = `UART_HEADER_ERR_MEM_OVERRUN; //Throw error
			else begin
				if(mem_received_valid)
				begin
					next_mem_received_ack = 1;
					if(mem_received_replaced)
						next_uart_out_msg = { mem_received_num, `UART_HEADER_REPLACE_NUM_DONE };
					else
						next_uart_out_msg = { mem_received_num, `UART_HEADER_RECEIVED_WRONG_NUM };
				end
			end
		end

		SM_POLL_UART_IN:
		begin
			if(uart_in_full)
				next_uart_out_msg = `UART_HEADER_ERR_FIFO_FULL; //Throw error
			else begin
				if(uart_in_avail)
					uart_in_req = 1;
			end
		end

		SM_UART_IN_MSG:
		begin
			next_uart_out_msg = genAckErrMsg(uart_in_msg, `UART_HEADER_ACK);
			case(uart_in_msg`UART_HEADER_BITS) //Handle various input messages here
				`UART_HEADER_REPLACE_NUM :
					mem_replace_valid = 1;
				`UART_HEADER_MOD_PARAMS :
					if(run)
						next_uart_out_msg = genAckErrMsg(uart_in_msg, `UART_HEADER_ERR_UPDATE_WHILST_RUN);
					else
						next_mod_params = uart_in_msg`UART_MOD_PARAMS_TOTAL_PAYLOAD_BITS;
				`UART_HEADER_DEMOD_PARAMS :
					if(run)
						next_uart_out_msg = genAckErrMsg(uart_in_msg, `UART_HEADER_ERR_UPDATE_WHILST_RUN);
					else
						next_demod_params = uart_in_msg`UART_DEMOD_PARAMS_TOTAL_PAYLOAD_BITS;
				`UART_HEADER_MEM_PARAMS :
					if(run)
						next_uart_out_msg = genAckErrMsg(uart_in_msg, `UART_HEADER_ERR_UPDATE_WHILST_RUN);
					else
						next_mem_params = uart_in_msg`UART_MEM_PARAMS_TOTAL_PAYLOAD_BITS;
					`UART_HEADER_SYS_STATUS :
					next_run = uart_in_msg`UART_SYS_STATUS_RUN_BITS;
					default: next_uart_out_msg = genAckErrMsg(uart_in_msg, `UART_HEADER_ERR_INVALID_MSG);
			endcase
		end

		SM_POLL_UART_OUT:
		if(!uart_out_full)
				uart_out_req = 1;

		SM_HALT:
			next_run = 0;
	endcase
end

endmodule