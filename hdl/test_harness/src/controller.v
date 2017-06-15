//Controller

module controller;

//Clocking/reset inputs
input clk, n_reset;

//System status
output run; //True when the system is running

//UART message input
input uart_in_avail; //Messge is waiting in the FIFO
input `UART_MSG_SIZE uart_in_msg; //Message from input FIFO
input uart_in_full; //Input FIFO is full
output uart_in_req; //Request input message from FIFO

//UART message output
input uart_out_ready; //System is ready to process output message
output `UART_MSG_SIZE uart_out_msg; //Message to client
output uart_out_req; //Send message to client

//Memory manager IO
input `MEM_NUM_SIZE mem_received_num; //Received number message from memory manager
input mem_valid; //The current message is valid - reset when acked 
input mem_overrun; //High if a second number is received before the first is acked
output mem_ack; //The current message has been read
output `MEM_NUM_SIZE mem_replace_num; //Number to replace a number in memory
output mem_replace_valid; //True when memory replacement number is true
output `MEM_PARAM_SIZE mem_params; //Memory manager parameters

//Modulator IO
output `MOD_PARAM_SIZE mod_params

enum logic[1:0] {SM_POLL_MEM_MANAGER, SM_POLL_UART_IN, SM_POLL_UART_OUT, SM_HALT} state;

uartMessageType uart_msg_out next_uart_msg_out;

reg next_run;

//Next state logic
always @(posedge clk)
begin
	if(!n_reset)
	begin
		state <= SM_POLL_MEM_MANAGER;
		run <= 0;
		mod_params <= `DEFAULT_MOD_PARAMS;
		mem_params <= `DEFUALT_MEM_PARAMS;
	else begin
		uart_msg_out <= next_uart_msg_out
		run <= next_run;
		mod_params <= next_mod_params;
		mem_params <= next_mem_params;
		case(state)
			SM_POLL_MEM_MANAGER:
				if(mem_valid || mem_overrun)
					state <= SM_POLL_UART_OUT; //Send message (or error) via UART
				else
					state <= SM_POLL_UART_IN; //No new number, check UART

			SM_POLL_UART_IN:
				if(uart_in_avail)
					state <= SM_POLL_UART_OUT; //Send via UART
				else
					state <= SM_POLL_MEM_MANAGER; //Nothing at UART, check memory manager

			SM_POLL_UART_OUT:
				if(uart_out_ready)
				begin
					if(isErrorMessage(uart_out_msg))
						state <= SM_HALT; //Halt if error message
					else
						state <= SM_POLL_MEM_MANAGER; //If we can send the message, otherwise wait
				end
		endcase
	end

//State machine output logic
always @(*)
begin
	uart_in_req = 0;
	next_run = run;
	next_uart_msg_out = uart_out_msg;
	mem_ack = 0;
	uart_out_req = 0;
	mem_replace_valid = 0;
	next_mod_params = mod_params;
	next_mem_params = mem_params;

	case(state)
		SM_POLL_MEM_MANAGER:
		begin
			if(mem_overrun)
				next_uart_msg_out = `UART_ERROR_MEM_OVERRUN; //Throw error
			else begin
				if(mem_valid)
				begin
					mem_ack = 1;
					next_uart_msg_out = { `UART_HEADER_REC_NUM , mem_received_num };
				end
			end
		end

		SM_POLL_UART_IN:
			if(uart_in_full)
				next_uart_msg_out = `UART_ERROR_IN_FIFO_FULL; //Throw error
			else begin
				if(uart_in_avail)
				begin
					uart_in_req = 1;
					next_uart_msg_out = {`UART_HEADER_ACK, uart_in_msg};
					case(uart_in_msg[`UART_HEADER_BITS]) //Handle various input messages here
						`UART_HEADER_REPLACE_NO :
							mem_replace_valid = 1;
						`UART_HEADER_MOD_PARAMS :
							if(run)
								next_uart_msg_out = `UART_ERROR_UPDATE_PARAMS_WHILST_RUNNING;
							else
								next_mod_params = uart_in_msg[`UART_MOD_PARAMS_BITS];
						`UART_HEADER_MEM_PARAMS :
							if(run)
								next_uart_msg_out = `UART_ERROR_UPDATE_PARAMS_WHILST_RUNNING;
							else
								next_mem_params = uart_in_msg[`UART_MEM_PARAMS_BITS];

						`UART_HEADER_SYS_STATUS :
							next_run = uart_in_msg[`UART_MSG_RUN_BIT];

						default: next_uart_msg_out = `UART_ERROR_INVALID_MESSAGE;
					endcase
				end
			end

		SM_POLL_UART_OUT:
			if(uart_out_ready)
				uart_out_req = 1;

		SM_HALT:
			next_run = 0;
	endcase
end

endmodule