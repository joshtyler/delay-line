//Top level module for test harness
//Variable stop bits, no parity
//Sample once in the middle of each bit

module test_harness(clk, uart_tx_pin, uart_rx_pin);

parameter integer DATA_WIDTH = 8;
parameter integer STOP_BITS = 1;
parameter integer BAUD = 9600;
parameter integer CLK_RATE = 12_000_000; //12MHz

localparam integer CLKS_PER_BAUD = (CLK_RATE / BAUD);

//Loopback test
wire en;
reg [DATA_WIDTH-1:0] data;

uart_tx #(
		.DATA_BITS(DATA_WIDTH),
		.STOP_BITS(STOP_BITS),
		.CLKS_PER_BIT(CLKS_PER_BIT)
	) uart0 ( //N.B. Ready isn't connected for this test.
		.clk(clk),
		.start(en),
		.data_in(data),
		.out(uart_tx_pin)
	);

uart_rx #(
		.DATA_BITS(DATA_WIDTH),
		.STOP_BITS(STOP_BITS),
		.CLKS_PER_BIT(CLKS_PER_BIT)
	) uart0 ( //N.B. Ready isn't connected for this test.
		.clk(clk),
		.data_in(uart_rx_pin),
		.valid(en),
		.data_out(data)
	);

endmodule
