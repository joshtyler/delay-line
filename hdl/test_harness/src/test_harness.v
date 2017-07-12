//Top level module for test harness

`include "uart_msg_consts.h"

module test_harness(clk, n_reset, uart_rx_pin, in, uart_tx_pin, out);

input clk, n_reset, uart_rx_pin, in;
output uart_tx_pin, out;

parameter integer UART_DATA_WIDTH = 8;
parameter integer UART_STOP_BITS = 1;
parameter integer UART_BAUD = 9600;
parameter integer CLK_RATE = 108_000_000;
parameter integer MSG_ASM_FIFO_DEPTH = 8; //8 Packets
parameter integer MSG_DISASM_FIFO_DEPTH = 8; //8 Packets
parameter integer GLITCH_WIDTH = 30; //Filter all glitches shorter this many clock cycles 


localparam integer UART_CLKS_PER_BAUD = (CLK_RATE / UART_BAUD);

//UART
wire uart_tx_en;
wire uart_tx_ready;
wire uart_rx_valid;
wire [UART_DATA_WIDTH-1:0] uart_tx_data, uart_rx_data;

uart_tx #(
		.DATA_BITS(UART_DATA_WIDTH),
		.STOP_BITS(8), //Send 8 stop bits to space out packets
		.CLKS_PER_BIT(UART_CLKS_PER_BAUD)
	) uart_tx_0 (
		.clk(clk),
		.n_reset(n_reset),
		.ready(uart_tx_ready),
		.start(uart_tx_en),
		.data_in(uart_tx_data),
		.out(uart_tx_pin)
	);

wire uart_rx_filtered;
glitch_filter #(
		.DELAY(GLITCH_WIDTH)
	) uart_rx_filter (
		.clk(clk),
		.n_reset(n_reset),
		.signal_in(uart_rx_pin),
		.signal_out(uart_rx_filtered)
	);

uart_rx #(
		.DATA_BITS(UART_DATA_WIDTH),
		.STOP_BITS(UART_STOP_BITS),
		.CLKS_PER_BIT(UART_CLKS_PER_BAUD)
	) uart_rx_0 (
		.clk(clk),
		.n_reset(n_reset),
		.data_in(uart_rx_filtered),
		.valid(uart_rx_valid),
		.data_out(uart_rx_data)
	);

//Message Assembler (and FIFO) (takes input from UART RX and outputs to controller)
localparam integer ASM_DISASM_WORDS_PER_PACKET = `UART_MSG_WIDTH / UART_DATA_WIDTH;

wire `UART_MSG_SIZE asm_data_out, uart_in_data;
wire asm_data_valid;
wire uart_in_req;
wire uart_in_full;
wire uart_in_fifo_empty;

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
wire `UART_MSG_SIZE uart_out_data, disasm_data_in;
wire disasm_req;
wire uart_out_full, disasm_fifo_empty, uart_out_req;
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
wire run;

wire `UART_RECEIVED_WRONG_NUM_TOTAL_PAYLOAD_SIZE mem_received_num;
wire mem_received_valid, mem_received_overrun, mem_received_ack, mem_replace_valid, mem_received_replaced;
wire `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE mem_replace_num; 
wire `UART_MEM_PARAMS_TOTAL_PAYLOAD_SIZE mem_params; 
wire `UART_DEMOD_PARAMS_TOTAL_PAYLOAD_SIZE demod_params; 
wire `UART_MOD_PARAMS_TOTAL_PAYLOAD_SIZE mod_params;

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

	.mod_params(mod_params),
	.demod_params(demod_params)
);


//Demodulator
wire demod_out;
demodulator demodulator_0
(
	.clk(clk),
	.n_reset(n_reset),
	.in(in),
	.demod_params(demod_params),
	.out(demod_out)
);

//Memory manager
wire mem_manager_out;
mem_manager mem_manager_0
(
	.clk(clk),
	.in(demod_out),
	.run(run),

	.mem_received_num(mem_received_num),
	.mem_received_replaced(mem_received_replaced),
	.mem_received_valid(mem_received_valid),
	.mem_received_overrun(mem_received_overrun),
	.mem_received_ack(mem_received_ack),

	.mem_replace_num(mem_replace_num),
	.mem_replace_valid(mem_replace_valid),

	.mem_params(mem_params),

	.out(mem_manager_out)
);

//Modulator
modulator modulator_0
(
	.clk(clk),
	.n_reset(n_reset),
	.in(mem_manager_out),
	.mod_params(mod_params),
	.out(out)
);

endmodule