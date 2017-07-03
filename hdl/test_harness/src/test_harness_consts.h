//Test harness consts

`ifndef TEST_HARNESS_CONSTS_H
`define TEST_HARNESS_CONSTS_H

`include "../src/uart_msg_consts.h"

`define DEFAULT_DEMOD_PARAMS 0 //Fill in with something useful!
`define DEFAULT_MOD_PARAMS 0 //Fill in with something useful!
`define DEFAULT_MEM_PARAMS 0 //Fill in with something useful!

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
	genAckErrMsg = {msg_in[($high(msg_in)-`UART_HEADER_WIDTH):0], header};
endfunction

`endif