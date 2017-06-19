//Memory To store replacement number
//Note that this block is not reset, so numbers will continue to be replaced after shutdown
`include "uart_msg_consts.h"

module replace_num_mem(clk, n_reset,
                       wr_packet,
                       rd_addr,
                       rd_en, wr_en,
                       data_out,
                       valid_out
                       );

//Clocking/reset inputs
input clk, n_reset; //n_reset is synchronous

//Data input
input `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE wr_packet; //Address and data to write
input `UART_REPLACE_NUM_ADDR_SIZE rd_addr;
input rd_en, wr_en; //Read and write enables

output reg `UART_REPLACE_NUM_DATA_SIZE data_out;
output reg valid_out; //Valid if the replacement data is valid


//Decode wr_packet
wire `UART_REPLACE_NUM_ADDR_SIZE wr_addr;
assign wr_addr = wr_packet `UART_REPLACE_NUM_ADDR_PAYLOAD_BITS;

wire `UART_REPLACE_NUM_DATA_SIZE wr_data;
assign wr_data = wr_packet `UART_REPLACE_NUM_DATA_PAYLOAD_BITS;


//Data memory
//Wide enough for data field and valid flag
reg wr_en_mem;
reg `UART_REPLACE_NUM_ADDR_SIZE wr_addr_mem;
reg [`UART_REPLACE_NUM_DATA_WIDTH:0] wr_data_mem;
reg clear; //Request to clear location
reg `UART_REPLACE_NUM_ADDR_SIZE clear_addr;

//This block handles clearing of a write request after reading
//It asumes that there will be at least one clock cycle where we are not writing before the next number comes around
//This is a reasonable assumption!
always @(posedge clk)
begin
	wr_en_mem <= wr_en; //Default to write enable signals
	wr_addr_mem <= wr_addr;
	wr_data_mem <= {1'b1, wr_data}; //The '1' is the write flag

	//If we are waiting to clear, and we are not writing this cycle
	if(clear && !wr_en) 
	begin
		clear <= 0;
		wr_en_mem <= 1;
		wr_addr_mem <= clear_addr;
		wr_data_mem <= 0;
	end

	//Check if we have a new location to clear
	//If so, store for later
	if(rd_en)
	begin
		clear <= 1;
		clear_addr <= rd_addr;
	end
end

reg [`UART_REPLACE_NUM_DATA_WIDTH:0] data_mem `UART_REPLACE_NUM_ADDR_SIZE; //Data memory - block RAM
always @(posedge clk)
begin
	if(wr_en_mem)
		data_mem[wr_addr_mem] <= wr_data_mem;

	if(rd_en)
		{valid_out, data_out} <= data_mem[rd_addr];
		
end


endmodule
