//UART Receiver
//Variable stop bits, no parity
//Sample once in the middle of each bit
//Synchronous active low reset

module uart_rx(clk, n_reset, data_in, valid, data_out);

parameter integer DATA_BITS = 8;
parameter integer STOP_BITS = 1;
parameter integer CLKS_PER_BIT = 1000; //Number of clocks per bit

localparam SAMPLE_COUNT = CLKS_PER_BIT/2; //Count to sample data on.
parameter BIT_CTR_WIDTH = $clog2(DATA_BITS); //Counter to track which bit we are on
parameter SAMPLE_CTR_WIDTH = $clog2(CLKS_PER_BIT); //Counter to track when to sample and transition between bits

input clk, n_reset, data_in;
output reg valid;
output reg [DATA_BITS-1:0] data_out;

reg[1:0] state;
localparam START = 2'b00;
localparam DATA = 2'b01;
localparam STOP = 2'b10;


reg [BIT_CTR_WIDTH-1:0] bit_ctr, next_bit_ctr;

reg [SAMPLE_CTR_WIDTH-1:0] sample_ctr;

//Sample counter
reg prev_in;
wire falling_edge, sample_ctr_end;
assign falling_edge = ((prev_in == 1) && (data_in == 0)); //Falling edge of data input
assign sample_ctr_end = (sample_ctr == CLKS_PER_BIT -1); //Counter has reached end

always @(posedge clk)
begin
	if(!n_reset)
	begin
		prev_in <= 1;
		sample_ctr <= 0;
	end else begin
		prev_in <= data_in;
		if( falling_edge || sample_ctr_end ) //Reset counter on falling input, or overflow
			sample_ctr <= 0;
		else
			sample_ctr <= sample_ctr + 1'b1;
	end
end

wire sample;
assign sample = (sample_ctr == SAMPLE_COUNT); //True when we should sample each bit

//State machine
wire data_bits_done, stop_bits_done;
assign data_bits_done = ((DATA_BITS-1) == bit_ctr);
assign stop_bits_done = ((STOP_BITS-1) == bit_ctr);

always @(posedge clk)
begin
	if(!n_reset)
		state <= START;
	else begin

		valid <= 0; //Will we overwritten in STOP state if required
		if(sample) bit_ctr <= next_bit_ctr;
		case(state)
			START : if((0 == data_in) && sample) state <= DATA; //Valid start bit
			DATA : begin
				if(sample)
				begin
					if(data_bits_done)
						state <= STOP;
					data_out[bit_ctr] <= data_in;
				end
			end
			STOP : begin
				if(sample)
				begin
					if((0 == data_in) || stop_bits_done) //Invalid stop bit, or we are done
						state <= START;
	
					if((1 == data_in) && stop_bits_done) //Valid stop bit and we are done
						valid <= 1;
				end
			end
		endcase
	end
end

//Bit counter
always @(*)
begin
	next_bit_ctr = 0;
	case(state)
		START : next_bit_ctr = 0;
		DATA : if(data_bits_done) next_bit_ctr = 0; else next_bit_ctr = bit_ctr + 1'b1;
		STOP: next_bit_ctr = bit_ctr + 1'b1;
	endcase
end


endmodule
