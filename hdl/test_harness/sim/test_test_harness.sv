//Test top level test harness module

`timescale 1ns/1ps

module test_test_harness;

parameter integer DATA_WIDTH = 8;
parameter integer STOP_BITS = 1;
parameter integer BAUD = 9600;
parameter integer CLK_RATE = 12_000_000; //12MHz

localparam integer CLKS_PER_BAUD = (CLK_RATE / BAUD);
localparam realtime CLK_PERIOD = (1.0s / CLK_RATE);
localparam realtime BAUD_PERIOD = (1.0s / BAUD);

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

	@(posedge receive_done)
	begin
		assert(num == received_num);
		$display("Transmit done. Sent %d, received %d", num, received_num);
	end 
end
endtask


localparam realtime SPACE_DELAY = 100us;

//Stimulus
integer i;
initial
begin
	uart_tb_tx_fpga_rx = 1;
	#SPACE_DELAY;
	uart_transmit(0);
	#SPACE_DELAY;
	uart_transmit('1);
	for(i=0; i<100; i++)
	begin
		#SPACE_DELAY;
		uart_transmit($urandom_range(255,0));
	end

	$finish;
end

endmodule
