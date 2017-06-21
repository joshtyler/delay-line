//Top level module for test harness
//Variable stop bits, no parity
//Sample once in the middle of each bit

`include "uart_msg_consts.h"

module test_harness(clk, uart_rx_pin, uart_tx_pin, led0, led1);

input clk, uart_rx_pin;
output uart_tx_pin, led0, led1;

parameter integer UART_DATA_WIDTH = 8;
parameter integer UART_STOP_BITS = 1;
parameter integer UART_BAUD = 9600;
parameter integer CLK_RATE = 12_000_000; //12MHz
parameter integer MSG_ASM_FIFO_DEPTH = 8; //8 Packets
parameter integer MSG_DISASM_FIFO_DEPTH = 8; //8 Packets

localparam integer UART_CLKS_PER_BAUD = (CLK_RATE / UART_BAUD);


//Reset
reg n_reset;
power_on_reset por_gen (.*);

//Output LEDs are unused for now
assign led0 = 0;
assign led1 = 0;

//We currently don't have an input and output, so hold input at zero
wire in, out;
assign in = 0;

//UART
wire uart_tx_en;
wire uart_tx_ready;
wire uart_rx_valid; //N.B. Ready isn't used for this test.
wire [UART_DATA_WIDTH-1:0] uart_tx_data, uart_rx_data;

uart_tx #(
		.DATA_BITS(UART_DATA_WIDTH),
		.STOP_BITS(UART_STOP_BITS),
		.CLKS_PER_BIT(UART_CLKS_PER_BAUD)
	) uart_tx_0 (
		.clk(clk),
		.n_reset(n_reset),
		.ready(uart_tx_ready),
		.start(uart_tx_en),
		.data_in(uart_tx_data),
		.out(uart_tx_pin)
	);

uart_rx #(
		.DATA_BITS(UART_DATA_WIDTH),
		.STOP_BITS(UART_STOP_BITS),
		.CLKS_PER_BIT(UART_CLKS_PER_BAUD)
	) uart_rx_0 (
		.clk(clk),
		.n_reset(n_reset),
		.data_in(uart_rx_pin),
		.valid(uart_rx_valid),
		.data_out(uart_rx_data)
	);

//Message Assembler (and FIFO) (takes input from UART RX and outputs to controller)
localparam integer ASM_DISASM_WORDS_PER_PACKET = `UART_MSG_WIDTH / UART_DATA_WIDTH;

reg `UART_MSG_SIZE asm_data_out, uart_in_data;
reg asm_data_valid;
reg uart_in_req;
reg uart_in_full;
reg uart_in_fifo_empty;

msg_asm #(
		.WORD_SIZE(UART_DATA_WIDTH),
		.WORDS_PER_PACKET(ASM_DISASM_WORDS_PER_PACKET)
	) msg_asm_0 (
		.clk(clk),
		.n_reset(n_reset),
		.data_in(uart_rx_data),
		.data_in_valid(uart_rx_valid),
		.data_out(asm_data_out),
		.data_out_valid(asm_data_valid)
	);

fifo #(
		.WIDTH(`UART_MSG_WIDTH),
		.DEPTH(MSG_ASM_FIFO_DEPTH)
	) msg_asm_fifo (
		.clk(clk),
		.n_reset(n_reset),
		.data_in(asm_data_out),
		.wr_en(asm_data_valid),
		.data_out(uart_in_data),
		.rd_en(uart_in_req),
		.empty(uart_in_fifo_empty),
		.full(uart_in_full)
	);

//Message disassembler (and FIFO)(takes input from controller and outputs to UART TX)
reg `UART_MSG_SIZE uart_out_data, disasm_data_in;
reg disasm_req;
reg uart_out_full, disasm_fifo_empty, uart_out_req;
msg_disasm #(
		.WORD_SIZE(UART_DATA_WIDTH),
		.WORDS_PER_PACKET(ASM_DISASM_WORDS_PER_PACKET)
	) msg_disasm_0 (
		.clk(clk),
		.n_reset(n_reset),
		.data_in(disasm_data_in),
		.data_in_ready(!disasm_fifo_empty),
		.data_in_req(disasm_req),
		.uart_ready(uart_tx_ready),
		.data_out(uart_tx_data),
		.data_out_req(uart_tx_en)
	);

fifo #(
		.WIDTH(`UART_MSG_WIDTH),
		.DEPTH(MSG_DISASM_FIFO_DEPTH)
	) msg_disasm_fifo (
		.clk(clk),
		.n_reset(n_reset),
		.data_in(uart_out_data),
		.wr_en(uart_out_req),
		.data_out(disasm_data_in),
		.rd_en(disasm_req),
		.empty(disasm_fifo_empty),
		.full(uart_out_full)
	);

//Controller
reg run;

reg `UART_RECEIVED_WRONG_NUM_TOTAL_PAYLOAD_SIZE mem_received_num;
reg mem_received_valid, mem_received_overrun, mem_received_ack, mem_replace_valid, mem_received_replaced;
reg `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE mem_replace_num; 
reg `UART_MEM_PARAMS_TOTAL_PAYLOAD_SIZE mem_params; 

reg `UART_MOD_PARAMS_TOTAL_PAYLOAD_SIZE mod_params;

controller controller_0
(
	.clk(clk),
	.n_reset(n_reset),
	.run(run),

	.uart_in_avail(!uart_in_fifo_empty),
	.uart_in_msg(uart_in_data),
	.uart_in_full(uart_in_full),
	.uart_in_req(uart_in_req),

	.uart_out_full(uart_out_full),
	.uart_out_msg(uart_out_data),
	.uart_out_req(uart_out_req),

	.mem_received_num(mem_received_num),
	.mem_received_replaced(mem_received_replaced),
	.mem_received_valid(mem_received_valid),
	.mem_received_overrun(mem_received_overrun),
	.mem_received_ack(mem_received_ack),
	.mem_replace_num(mem_replace_num),
	.mem_replace_valid(mem_replace_valid),
	.mem_params(mem_params),

	.mod_params(mod_params)
);

//Memory manager

mem_manager mem_manager_0
(
	.clk(clk),
	.in(in),
	.run(run),

	.mem_received_num(mem_received_num),
	.mem_received_replaced(mem_received_replaced),
	.mem_received_valid(mem_received_valid),
	.mem_received_overrun(mem_received_overrun),
	.mem_received_ack(mem_received_ack),

	.mem_replace_num(mem_replace_num),
	.mem_replace_valid(mem_replace_valid),

	.mem_params(mem_params),

	.out(out)
);

endmodule
