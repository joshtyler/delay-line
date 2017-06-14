//Loopback to test UART TX and RX at the same time

`timescale 1ns/1ps

module test_uart;

parameter integer DATA_WIDTH = 8;
parameter integer STOP_BITS = 1;
parameter integer BAUD = 9600;
parameter integer CLK_RATE = 12_000_000; //12MHz

localparam integer CLKS_PER_BAUD = (CLK_RATE / BAUD);
localparam realtime CLK_PERIOD = (1.0s / CLK_RATE);

//Clock
reg clk = 0;
always #(CLK_PERIOD/2) clk = !clk;

//DUTs
reg transmit=0, bus;
wire transmit_ready, output_valid;
reg [DATA_WIDTH-1:0] data_in, data_out;

uart_tx #(
		.DATA_BITS(DATA_WIDTH),
		.STOP_BITS(STOP_BITS),
		.CLKS_PER_BIT(CLKS_PER_BAUD)
	) uart_tx_0 ( //N.B. Ready isn't connected for this test.
		.clk(clk),
		.start(transmit),
		.data_in(data_in),
		.ready(transmit_ready),
		.out(bus)
	);

uart_rx #(
		.DATA_BITS(DATA_WIDTH),
		.STOP_BITS(STOP_BITS),
		.CLKS_PER_BIT(CLKS_PER_BAUD)
	) uart_rx_0 ( //N.B. Ready isn't connected for this test.
		.clk(clk),
		.data_in(bus),
		.valid(output_valid),
		.data_out(data_out)
	);

task singleTest;
input reg[DATA_WIDTH-1:0] num;
begin
	//Transmit
	assert(transmit_ready == 1);
	data_in = num;
	transmit = 1;
	@(posedge clk);
	#1;
	assert(transmit_ready == 0);
	transmit = 0;
	//Wait for receive
	@(posedge output_valid)
		assert(data_out == num);

	while(!transmit_ready) //Wait for transmit to be ready
		#1;

end
endtask

//Stimulus
integer i;
initial
begin
	@(posedge clk);
	#1;
	singleTest('1);
	singleTest('0);

	for(i=0; i<100; i++)
		singleTest($urandom_range(255,0));

	$display("Tests completed sucessfully");
	$finish;
end

endmodule
