//Test top level test harness module
`include "../src/uart_msg_consts.h"

module test_test_harness;

parameter integer DATA_WIDTH = 8;
parameter integer STOP_BITS = 1;
parameter integer BAUD = 9600;
parameter integer CLK_RATE = 12_000_000; //12MHz

localparam integer CLKS_PER_BAUD = (CLK_RATE / BAUD);
localparam realtime CLK_PERIOD = (1.0s / CLK_RATE);
localparam realtime BAUD_PERIOD = (1.0s / BAUD);

localparam integer WORDS_PER_PACKET = `UART_MSG_WIDTH / DATA_WIDTH;

//Clock
reg clk = 0;
always #(CLK_PERIOD/2) clk = !clk;

//DUT
reg uart_tb_tx_fpga_rx, uart_tb_rx_fpga_tx;
wire led0, led1;
test_harness dut(.clk(clk), .uart_rx_pin(uart_tb_tx_fpga_rx), .uart_tx_pin(uart_tb_rx_fpga_tx), .led0(led0), .led1(led1));

//UART Receiver
reg [DATA_WIDTH-1:0] received_num;
reg receive_done = 0;
integer rec_iter;
always @(negedge uart_tb_rx_fpga_tx)
begin
	#(0.5*BAUD_PERIOD);//Half way through start bit
	assert(0 == uart_tb_rx_fpga_tx);

	for(rec_iter=0; rec_iter < DATA_WIDTH; rec_iter++) //Get data bits
	begin
		#BAUD_PERIOD;
		received_num[rec_iter] = uart_tb_rx_fpga_tx;
	end

	for(rec_iter=0; rec_iter < STOP_BITS; rec_iter++)
	begin
		#BAUD_PERIOD;
		assert(1 == uart_tb_rx_fpga_tx);
	end
	//We are now done, and are half way through the last stop bit
	receive_done = 1;
	#1
	receive_done = 0;
end

always @(posedge receive_done)
begin
	$display("Received %X at time %t", received_num, $realtime);
end

task uart_transmit;
input reg[DATA_WIDTH-1:0] num;
integer i;
begin
	//Transmit
	//Start bit
	uart_tb_tx_fpga_rx = 0;
	#BAUD_PERIOD;
	//Data bits
	for(i=0;i<DATA_WIDTH; i++)
	begin
		uart_tb_tx_fpga_rx = num[i];
		#BAUD_PERIOD;
	end
	//Stop bits
	for(i=0; i<STOP_BITS; i++)
	begin
		uart_tb_tx_fpga_rx = 1;
		#BAUD_PERIOD;
	end 
end
endtask

task uart_transmit_packet;
input logic `UART_HEADER_SIZE header;
input logic `UART_PAYLOAD_SIZE payload;
logic `UART_MSG_SIZE msg;
integer i;
begin
	msg `UART_HEADER_BITS = header;
	msg `UART_PAYLOAD_BITS = payload;
	for(i=0; i < WORDS_PER_PACKET; i++)
	begin
		uart_transmit(msg[(DATA_WIDTH -1): 0]);
		msg = msg >> DATA_WIDTH;
	end
end
endtask

localparam realtime SPACE_DELAY = 100us;
localparam realtime END_DELAY = 100ms;

//Stimulus
integer i;
logic `UART_PAYLOAD_SIZE payload;
initial
begin
	uart_tb_tx_fpga_rx = 1;
	#SPACE_DELAY;
	payload = 0;
	payload `UART_MEM_PARAMS_NO_NUMS_PAYLOAD_BITS = 5; //5 Numbers
	payload `UART_MEM_PARAMS_TEST_MODE_PAYLOAD_BITS = 0; //Test mode off
	payload `UART_MEM_PARAMS_PULSE_WIDTH_PAYLOAD_BITS = 12; // 1us at 12MHz
	payload `UART_MEM_PARAMS_PULSE_GAP_PAYLOAD_BITS = 12; // 1us at 12MHz
	uart_transmit_packet(`UART_HEADER_MEM_PARAMS,payload); //Setup memory manager
	uart_transmit_packet(`UART_HEADER_SYS_STATUS,1); //Run
	uart_transmit_packet(`UART_HEADER_REPLACE_NUM,0); //Replace the number at address 0 with 0
	#END_DELAY;
	$finish;
end

endmodule
