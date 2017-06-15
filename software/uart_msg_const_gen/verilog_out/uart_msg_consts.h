// UART Message Constants 
// Automatically generated  by uart_msg_const_gen.py at 03:40PM on June 15, 2017

`ifndef UART_MSG_CONSTS_H
`define UART_MSG_CONSTS_H

// Generic constants
`define UART_MSG_WIDTH 64
`define UART_MSG_SIZE [63:0]
`define UART_MSG_BITS [63:0]
`define UART_HEADER_WIDTH 8
`define UART_HEADER_SIZE [7:0]
`define UART_HEADER_BITS [7:0]
`define UART_PAYLOAD_WIDTH 56
`define UART_PAYLOAD_SIZE [55:0]
`define UART_PAYLOAD_BITS [63:8]

// Received num
`define UART_HEADER_RECEIVED_NUM 0
`define UART_ADDR_WIDTH 9
`define UART_ADDR_SIZE [8:0]
`define UART_ADDR_BITS [16:8]
`define UART_DATA_WIDTH 36
`define UART_DATA_SIZE [35:0]
`define UART_DATA_BITS [52:17]

// Replace num
`define UART_HEADER_REPLACE_NUM 1
`define UART_ADDR_WIDTH 9
`define UART_ADDR_SIZE [8:0]
`define UART_ADDR_BITS [16:8]
`define UART_DATA_WIDTH 36
`define UART_DATA_SIZE [35:0]
`define UART_DATA_BITS [52:17]

// Mod params
`define UART_HEADER_MOD_PARAMS 2
`define UART_CYCLES_PER_PULSE_WIDTH 5
`define UART_CYCLES_PER_PULSE_SIZE [4:0]
`define UART_CYCLES_PER_PULSE_BITS [12:8]
`define UART_PULSE_GAP_WIDTH 8
`define UART_PULSE_GAP_SIZE [7:0]
`define UART_PULSE_GAP_BITS [20:13]

// Sys status
`define UART_HEADER_SYS_STATUS 3
`define UART_RUN_WIDTH 1
`define UART_RUN_SIZE [0:0]
`define UART_RUN_BITS [8:8]

// Mem params
`define UART_HEADER_MEM_PARAMS 4
`define UART_NO_NUMS_WIDTH 9
`define UART_NO_NUMS_SIZE [8:0]
`define UART_NO_NUMS_BITS [16:8]
`define UART_TEST_MODE_WIDTH 1
`define UART_TEST_MODE_SIZE [0:0]
`define UART_TEST_MODE_BITS [17:17]

// Err fifo full
`define UART_HEADER_ERR_FIFO_FULL 5
`define UART_PAYLOAD_WIDTH 56
`define UART_PAYLOAD_SIZE [55:0]
`define UART_PAYLOAD_BITS [63:8]

// Err update run
`define UART_HEADER_ERR_UPDATE_RUN 6
`define UART_PAYLOAD_WIDTH 56
`define UART_PAYLOAD_SIZE [55:0]
`define UART_PAYLOAD_BITS [63:8]

// Err invalid msg
`define UART_HEADER_ERR_INVALID_MSG 7
`define UART_PAYLOAD_WIDTH 56
`define UART_PAYLOAD_SIZE [55:0]
`define UART_PAYLOAD_BITS [63:8]

// Ack
`define UART_HEADER_ACK 8
`define UART_PAYLOAD_WIDTH 56
`define UART_PAYLOAD_SIZE [55:0]
`define UART_PAYLOAD_BITS [63:8]


`endif
