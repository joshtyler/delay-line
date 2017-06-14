//UART Transmitter
//Variable stop bits, no parity
//No need for data_in to be stable during data write

module uart_tx(clk, start, data_in, ready, out);

parameter integer DATA_BITS = 8;
parameter integer STOP_BITS = 1;
parameter integer CLKS_PER_BIT = 1000; //Number of clocks per bit

localparam BIT_CTR_WIDTH = $clog2(DATA_BITS); //Assume that DATA_BITS is bigger than STOP_BITS
localparam SAMPLE_CTR_WIDTH = $clog2(CLKS_PER_BIT); //Counter to track when to sample and transition between bits

input clk, start;
input [DATA_BITS-1:0] data_in;
reg [DATA_BITS-1:0] data_reg;

output ready;
output reg out;

enum {READY, START, DATA, STOP} state = READY;

reg [BIT_CTR_WIDTH-1:0] bit_ctr, next_bit_ctr;

reg [SAMPLE_CTR_WIDTH-1:0] sample_ctr =0;

always @(posedge clk)
	if(sample_ctr == CLKS_PER_BIT-1)
		sample_ctr <= 0;
	else
		sample_ctr <= sample_ctr + 1;

wire next_bit;
assign next_bit = (0 == sample_ctr);

always @(posedge clk)
begin
	case(state)
		READY : if(start) begin //Wait for data
			state <= START;
			data_reg <= data_in;
			end
		START : if(next_bit) state <= DATA; //Output start bit
		DATA : if((0 == bit_ctr) && next_bit) state <= STOP; //Output data bits
		STOP : if((0 == bit_ctr) && next_bit) state <= READY; //Output stop bit(s)
	endcase

	if(next_bit) bit_ctr <= next_bit_ctr;
end

assign ready = (state == READY);

always @(*)
begin
	//Counter
	next_bit_ctr = 0;
	case(state)
		START : next_bit_ctr = (DATA_BITS-1);
		DATA : if(0 == bit_ctr) next_bit_ctr = (STOP_BITS-1); else next_bit_ctr = bit_ctr-1;
		STOP: next_bit_ctr = bit_ctr - 1;
	endcase

end

always @(*)
begin
	//Output
	out = 0;
	case(state)
		READY: out = 1;
		START: out = 0;
		DATA: out = data_reg[bit_ctr];
		STOP: out = 1;
	endcase
end


endmodule
