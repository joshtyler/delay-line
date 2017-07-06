// Comparator
// Manages reading data from the FIFO, and comparing it to the current count.
// Asserts output when count matches

module comparator(clk, n_reset, empty, data_in, count, req_data, trigger);

parameter WIDTH = 8;

input clk, n_reset, empty;
input [WIDTH-1:0] data_in, count;
output req_data, trigger;

reg[1:0] state; //State machine
localparam SM_WAIT_FOR_DATA = 2'b00;
localparam SM_REQUEST = 2'b01;
localparam SM_WAIT = 2'b10;
localparam SM_ASSERT = 2'b11;


//Next state logic
always @(posedge clk)
begin
	if(!n_reset)
		state <= SM_WAIT_FOR_DATA;
	else begin
		case(state)
			SM_WAIT_FOR_DATA: // Wait for FIFO to not be empty, then request data
				if(!empty) state <= SM_REQUEST;
			SM_REQUEST: // Request read of data
				state <= SM_WAIT;
			SM_WAIT: //Wait for timer to match desired value
				if(count == data_in)
					state <= SM_ASSERT;
			SM_ASSERT:
					state <= SM_WAIT_FOR_DATA;
		endcase
	end
end

assign req_data = (state == SM_REQUEST);
assign trigger = (state == SM_ASSERT);

endmodule
