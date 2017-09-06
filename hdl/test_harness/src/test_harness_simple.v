//A "dumbed down" test harness, that just outputs a burst once every now and then

`include "uart_msg_consts.h"

module test_harness(clk, n_reset, uart_rx_pin, in, uart_tx_pin, out, out_en);

input clk, n_reset, uart_rx_pin, in;
output uart_tx_pin, out, out_en;
parameter integer CLK_RATE = 54_000_000;

//Enable counter
//We want a 900ns burst once every 1.5ms

//18.8ns clock period.
//Output clock is 900ns active. 2us total
//Therefore 49 period active, 216 total
localparam integer ACTIVE_PERIOD = 49;
localparam integer TOTAL_PERIOD = 108;
localparam integer CTR_WIDTH = $clog2(TOTAL_PERIOD);

reg [(CTR_WIDTH-1):0] ctr;

reg new_period;

always @(posedge clk)
	if(ctr < (TOTAL_PERIOD-1))
	begin
		ctr <= ctr + 1;
		new_period <= 0;
	end else begin
		ctr <= 0;
		new_period <= 1;
	end

//Bit counter is longer than EDSAC pulse width to allow for space between words

localparam integer BIT_CTR_SIZE = 750;
localparam integer BIT_CTR_WIDTH = $clog2(BIT_CTR_SIZE);

reg [BIT_CTR_WIDTH:0] bit_ctr;
always @(posedge clk)
	if(new_period)
	begin
		if(bit_ctr < (BIT_CTR_SIZE -1))
			bit_ctr <= bit_ctr + 1;
		else
			bit_ctr <= 0;
		
	end
		
wire [BIT_CTR_SIZE-1:0] test_vector;
//assign test_vector = 'hDEADBEEF;
assign test_vector = 1;



wire output_clk;
assign output_clk = (ctr < (ACTIVE_PERIOD-1));


wire modulation;
assign modulation = output_clk && test_vector[bit_ctr];




reg `UART_MOD_PARAMS_TOTAL_PAYLOAD_SIZE mod_params;

assign mod_params = 1;

//Modulator
modulator modulator_0
(
	.clk(clk),
	.n_reset(n_reset),
	.in(modulation),
	.mod_params(mod_params),
	.out(out)
);

assign out_en = modulation; // This is when the modulation is active

assign uart_tx_pin = 1;

endmodule
