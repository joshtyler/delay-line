//Memory manager testbench
`include "../src/uart_msg_consts.h"
`include "../src/test_harness_consts.h"

`timescale 1ns/1ps

module test_mem_manager;

localparam realtime CLK_PERIOD = 5ns;

//Clocking
logic clk =0;
always #(CLK_PERIOD/2) clk = !clk;

logic run;

logic `UART_RECEIVED_WRONG_NUM_TOTAL_PAYLOAD_SIZE mem_received_num; //Received number message from memory manager
logic mem_received_valid; //The current message is valid - reset when acked
logic mem_received_replaced; //True if the received number is a replacement, rather than an error
logic mem_received_overrun; //High if a second number is received before the first is acked
logic mem_received_ack; //The current message has been read
logic `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE mem_replace_num; //Number to replace a number in memory
logic mem_replace_valid; //True when memory replacement number is true
logic `UART_MEM_PARAMS_TOTAL_PAYLOAD_SIZE mem_params; //Memory manager parameters

logic in =0, out;

//Decode params
logic `UART_MEM_PARAMS_NO_NUMS_SIZE no_nums; //Number of numbers that we are storing
assign mem_params `UART_MEM_PARAMS_NO_NUMS_PAYLOAD_BITS = no_nums;
parameter MAX_NUMS = 2**`UART_MEM_PARAMS_NO_NUMS_WIDTH;

logic test_mode; //Is test mode enabled
assign mem_params `UART_MEM_PARAMS_TEST_MODE_PAYLOAD_BITS = test_mode;

logic `UART_MEM_PARAMS_PULSE_WIDTH_SIZE pulse_width;
assign mem_params `UART_MEM_PARAMS_PULSE_WIDTH_PAYLOAD_BITS = pulse_width;

logic `UART_MEM_PARAMS_PULSE_GAP_SIZE pulse_gap;
assign mem_params `UART_MEM_PARAMS_PULSE_GAP_PAYLOAD_BITS = pulse_gap;

//DUT
mem_manager dut (.*);


//Verify output clock high time
always @(posedge clk)
begin
	integer i;
	if(!run)
		i = 0;
	else begin
		if(dut.output_clk)
			i <= i + 1;
		else begin
			if(i != 0)
			begin
				assert(i == pulse_width) else $error(i);
				i = 0;
			end
		end
	end
end

//Verify output clock low time
always @(posedge clk)
begin
	integer i;
	if(!run)
		i = 0;
	else begin
		if(!dut.output_clk)
			i <= i + 1;
		else begin
			if(i != 0)
			begin
				assert(i == pulse_gap) else $error(i);
				i = 0;
			end
		end
	end
end

task decodeMessage;
input logic `UART_RECEIVED_WRONG_NUM_TOTAL_PAYLOAD_SIZE msg;
input logic replaced;
begin
	$display("Received %d at address %d. Replacement: %d. Time %t", msg `UART_RECEIVED_WRONG_NUM_DATA_PAYLOAD_BITS, msg `UART_RECEIVED_WRONG_NUM_ADDR_PAYLOAD_BITS, replaced, $realtime);
end
endtask

//Receive received number messages
logic ack_messages = 1; //Decides whether to ack messages or not
always @(posedge clk)
begin
	if(mem_received_valid)
	begin
		mem_received_ack <= ack_messages;
		decodeMessage(mem_received_num, mem_received_replaced);
	end else begin
		mem_received_ack <= 0;
	end
end

//Check for overrun
always @(posedge clk)
begin
	if(mem_received_overrun)
		$display("Warning memory overrun");
end


//Emulate delay line
//Delay is number of numbers * bits per number * bit period
always @(out)
begin
	automatic realtime delay = (no_nums * `UART_RECEIVED_WRONG_NUM_DATA_WIDTH *(pulse_width + pulse_gap) * CLK_PERIOD);
	in <= #delay out;
end

function `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE createReplaceMsgPacket;
input `UART_REPLACE_NUM_ADDR_SIZE addr;
input `UART_REPLACE_NUM_DATA_SIZE data;
logic `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE tmp;
begin
	tmp `UART_REPLACE_NUM_ADDR_PAYLOAD_BITS = addr;
	tmp `UART_REPLACE_NUM_DATA_PAYLOAD_BITS = data;
	createReplaceMsgPacket = tmp;
	
end
endfunction

task sendUpdateRequest;
input `UART_REPLACE_NUM_ADDR_SIZE addr;
input `UART_REPLACE_NUM_DATA_SIZE data;
begin
	assert(mem_replace_valid == 0);
	mem_replace_num = createReplaceMsgPacket(addr, data);
	@(posedge clk)
		mem_replace_valid = 1;
	@(posedge clk)
		mem_replace_valid = 0;
	$display("Sent update request for data %d, at address %d at time %t", data, addr, $realtime);
end
endtask 


//Stimulus
initial
begin
	run =0;
	mem_received_ack = 0;
	mem_replace_valid = 0;
	no_nums = 5;
	test_mode = 0;
	pulse_width = 10;
	pulse_gap = 10;
	#100us; //Wait for memory to reset
	run = 1;
	#100us;
	sendUpdateRequest(4,1);
	#100us;
	sendUpdateRequest(3,2);
	#100us;
	sendUpdateRequest(2,3);
	sendUpdateRequest(1,4);
	#100us;
	sendUpdateRequest(1,500);
	#100us;
	sendUpdateRequest(2,6000);
	#100us;
	sendUpdateRequest(3,01134);
	sendUpdateRequest(4,`UART_REPLACE_NUM_DATA_WIDTH'd07432142771);
	#100us;
	$finish;
end


endmodule
