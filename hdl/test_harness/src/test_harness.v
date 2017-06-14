//Top level module for test harness
//Variable stop bits, no parity
//Sample once in the middle of each bit

`define TX_ONLY_TEST

module test_harness(clk, uart_rx_pin, uart_tx_pin, led0, led1);

input clk, uart_rx_pin;
output uart_tx_pin, led0, led1;

parameter integer DATA_WIDTH = 8;
parameter integer STOP_BITS = 1;
parameter integer BAUD = 9600;
parameter integer CLK_RATE = 12_000_000; //12MHz

localparam integer CLKS_PER_BAUD = (CLK_RATE / BAUD);

//Reset
reg n_reset;
power_on_reset por_gen (.*);

//Loopback test
`ifdef TX_ONLY_TEST
reg en;
`else
wire en;
`endif
wire [DATA_WIDTH-1:0] data;

//Status LEDs. Assign inverse because line is normally high
assign led0 = !uart_tx_pin;
assign led1 = !uart_rx_pin;

wire ready; //N.B. Ready isn't used for this test.

uart_tx #(
		.DATA_BITS(DATA_WIDTH),
		.STOP_BITS(STOP_BITS),
		.CLKS_PER_BIT(CLKS_PER_BAUD)
	) uart_tx_0 (
		.clk(clk),
		.n_reset(n_reset),
		.ready(ready),
		.start(en),
		.data_in(data),
		.out(uart_tx_pin)
	);

`ifdef TX_ONLY_TEST
assign data = 84; //'T'
always @(posedge clk)
begin
	en <= 0;
	if(ready)
	begin
		en<= 1;
	end
end
`else
uart_rx #(
		.DATA_BITS(DATA_WIDTH),
		.STOP_BITS(STOP_BITS),
		.CLKS_PER_BIT(CLKS_PER_BAUD)
	) uart_rx_0 (
		.clk(clk),
		.n_reset(n_reset),
		.data_in(uart_rx_pin),
		.valid(en),
		.data_out(data)
	);
`endif


endmodule
