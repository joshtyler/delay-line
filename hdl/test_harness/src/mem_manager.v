//Memory manager
`include "uart_msg_consts.h"
`include "test_harness_consts.h"

module mem_manager(clk,
                  in,
                  run,
                  mem_received_num, mem_received_replaced, mem_received_valid, mem_received_overrun, mem_received_ack,
                  mem_replace_num, mem_replace_valid,
                  mem_params,
                  out
                  );

//Clocking/reset inputs
input clk, run; //Run is effectively a reset for this module, it resets when run is low, and is active when run is high

//Data input
input in;

output reg `UART_RECEIVED_WRONG_NUM_TOTAL_PAYLOAD_SIZE mem_received_num; //Received incrorrect number message from memory manager
output reg mem_received_replaced; //True if the received number was a replacement, false if it was an incorrect number
output mem_received_valid; //The current message is valid - reset when acked 
output reg mem_received_overrun; //High if a second number is received before the first is acked
input mem_received_ack; //The current message has been read
input `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE mem_replace_num; //Number to replace a number in memory
input mem_replace_valid; //True when memory replacement number is true
input `UART_MEM_PARAMS_TOTAL_PAYLOAD_SIZE mem_params; //Memory manager parameters

//Data output
output out;

//Decode params
wire `UART_MEM_PARAMS_NO_NUMS_SIZE no_nums; //Number of numbers that we are storing
assign no_nums = mem_params `UART_MEM_PARAMS_NO_NUMS_PAYLOAD_BITS;
parameter MAX_NUMS = 2**`UART_MEM_PARAMS_NO_NUMS_WIDTH;

wire test_mode; //Is test mode enabled
assign test_mode = mem_params `UART_MEM_PARAMS_TEST_MODE_PAYLOAD_BITS;

wire `UART_MEM_PARAMS_PULSE_WIDTH_SIZE pulse_width;
assign pulse_width = mem_params `UART_MEM_PARAMS_PULSE_WIDTH_PAYLOAD_BITS;

wire `UART_MEM_PARAMS_PULSE_GAP_SIZE pulse_gap;
assign pulse_gap = mem_params `UART_MEM_PARAMS_PULSE_GAP_PAYLOAD_BITS;


//Output clock generator
localparam integer OUTPUT_CLK_WIDTH = $clog2(2**`UART_MEM_PARAMS_PULSE_WIDTH_WIDTH + 2**`UART_MEM_PARAMS_PULSE_GAP_WIDTH);
reg [OUTPUT_CLK_WIDTH-1:0] output_clk_ctr;
wire [OUTPUT_CLK_WIDTH-1:0] output_clk_max_count, output_clk_high_count;
assign output_clk_high_count = pulse_gap; //Count at which to set the output high
assign output_clk_max_count = pulse_width + pulse_gap -1; //Count at which to reset the counter

wire output_clk, output_clk_middle_high, output_clk_rising_edge, output_clk_falling_edge;
assign output_clk = (output_clk_ctr >= output_clk_high_count) && (output_clk_ctr != 0); //The != 0 stops the output clock idling high when the max count is 0
assign output_clk_middle_high = (output_clk_ctr == ((output_clk_high_count-1) + (pulse_width/2))); //High for one pulse in middle of high period (for sampling)
assign output_clk_rising_edge = (output_clk_ctr == (output_clk_high_count -1)); //High for clock edge when output clock rises
assign output_clk_falling_edge = (output_clk_ctr >= output_clk_max_count); //High for clock edge when input clock falls

always @(posedge clk)
	if(!run)
		output_clk_ctr <= 0;
	else begin
		if(output_clk_falling_edge)
			output_clk_ctr <= 0;
		else
			output_clk_ctr <= output_clk_ctr + 1;
	end


//Bit counter
localparam integer BIT_CTR_WIDTH = $clog2(`UART_REPLACE_NUM_DATA_WIDTH); //Must be able to count up to the word width
reg [BIT_CTR_WIDTH-1:0] bit_ctr;
wire bit_ctr_reset;
assign bit_ctr_reset = (bit_ctr == `UART_REPLACE_NUM_DATA_WIDTH -1);
always @(posedge clk)
	if(!run)
		bit_ctr <=0;
	else begin
		if(output_clk_rising_edge) //Output clock transition
		begin
			if(bit_ctr_reset)
				bit_ctr <= 0;
			else
				bit_ctr <= bit_ctr + 1;
		end
		
	end

//Word counter
wire word_transition; //High on the rising edge which transitions between words
assign word_transition = output_clk_rising_edge && bit_ctr_reset;
reg `UART_REPLACE_NUM_ADDR_SIZE word_ctr, next_word_ctr; //next_word_ctr holds the value of the next word;
always @(posedge clk)
	if(!run)
	begin
		word_ctr <= 0;
		next_word_ctr <= 1;
	end else begin
		if(word_transition)
		begin
			if(word_ctr >= (no_nums-1))
				word_ctr <= 0;
			else
				word_ctr <= word_ctr +1;

			if(next_word_ctr >= (no_nums-1))
				next_word_ctr <= 0;
			else
				next_word_ctr <= next_word_ctr + 1;
		end
	end

//Replacement number memory
wire `UART_REPLACE_NUM_DATA_SIZE  replace_num_data;
wire replace_num_valid;
wire read_replacement_num; //Load during last bit of output word
assign read_replacement_num = (output_clk_falling_edge && bit_ctr_reset); //Load during last bit of output word
replace_num_mem mem0 (.clk(clk),
                      .n_reset(run),
                      .wr_packet(mem_replace_num),
                      .rd_addr(next_word_ctr),
                      .rd_en(read_replacement_num), .wr_en(mem_replace_valid),
                      .data_out(replace_num_data),
                      .valid_out(replace_num_valid)
                      );

//Shift registers
wire replace_shift_out;
wire `UART_REPLACE_NUM_DATA_SIZE normal_shift_data_out;
wire load_replacement_num;
assign load_replacement_num = (output_clk_rising_edge && bit_ctr_reset); //Load on transition to next number
shift_register #(.WIDTH(`UART_REPLACE_NUM_DATA_WIDTH)) replace_shift
(
	.clk(clk),
	.n_reset(run),
	.in(1'b0), //We dont use this. Hold at zero for easier debug
	.load(load_replacement_num),
	.shift(output_clk_rising_edge),
	.load_data(replace_num_data),
	.current_data(),
	.out(replace_shift_out)
);

shift_register #(.WIDTH(`UART_REPLACE_NUM_DATA_WIDTH)) normal_shift
(
	.clk(clk),
	.n_reset(run),
	.in(in),
	.load(1'b0),
	.shift(output_clk_middle_high), //Sample in middle of period
	.load_data( `UART_REPLACE_NUM_DATA_WIDTH 'b0),
	.current_data(normal_shift_data_out),
	.out()
);

//Output multiplexer
reg mux_en;
always @(posedge clk)
	if(!run)
		mux_en <= 0;
	else if(output_clk_rising_edge && bit_ctr_reset) //Word transition
		if(replace_num_valid)
			mux_en <= 1;
		else
			mux_en <= 0;

assign out = (mux_en? replace_shift_out : in) && output_clk; //AND with output clock to enforce gap

//Received number handler
reg data_out_ready;
assign mem_received_valid = data_out_ready && !mem_received_ack; //make sure we remove valid flag once the client has acked
always @(posedge clk)
begin
	if(!run)
	begin
		data_out_ready <= 0;
		mem_received_overrun <= 0;
	end else begin

		if(mem_received_ack)
			data_out_ready <= 0;

		// On last falling edge before transition to next number, and either number is wrong, or we replaced it
		if(read_replacement_num && ( (normal_shift_data_out != replace_num_data)||replace_num_valid)) 
		begin
			mem_received_num `UART_RECEIVED_WRONG_NUM_ADDR_PAYLOAD_BITS <= word_ctr;
			mem_received_num `UART_RECEIVED_WRONG_NUM_DATA_PAYLOAD_BITS <= normal_shift_data_out;
			mem_received_replaced <= replace_num_valid; //True if this was a number we just replaced
			data_out_ready <= 1;

			if(data_out_ready)
				mem_received_overrun <= 1;
		end
	end
end


endmodule
