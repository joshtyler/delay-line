//Testbench for controller

// The test strategy for this testbench is to provide stimulus in the form of UART messages, and received messages
// A queue will then be created for each of the outputs, and the expected message will be put onto that
// When the output changes, it will be compared to the item on the top of the queue

// Inputs: uart_in, mem_valid
// Outputs: uart_out, mem_params, mod_params, mem_replace, run

`timescale 1ns/1ps

`include "../src/test_harness_consts.h"
`include "../src/uart_msg_consts.h"

module test_controller;

parameter realtime CLK_PERIOD = 5ns;

//Clock
logic clk = 0;
always #(CLK_PERIOD/2) clk = !clk;

//Reset
logic n_reset_power, n_reset_sys = 1, n_reset;
assign n_reset = n_reset_power && n_reset_sys; //Reset when either is low
power_on_reset reset0(.clk(clk), .n_reset(n_reset_power));

logic run;

logic uart_in_avail = 0, uart_in_full = 0, uart_in_req;
logic `UART_MSG_SIZE uart_in_msg;

logic uart_out_ready = 0, uart_out_req;
logic `UART_MSG_SIZE uart_out_msg;

logic mem_valid=0, mem_overrun = 0, mem_ack, mem_replace_valid;
logic `UART_RECEIVED_NUM_TOTAL_PAYLOAD_SIZE mem_received_num;
logic `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE mem_replace_num;
logic `UART_MEM_PARAMS_TOTAL_PAYLOAD_SIZE mem_params;

logic `UART_MOD_PARAMS_TOTAL_PAYLOAD_SIZE mod_params;


controller dut (.*);

//Task to add an ack to the uart queue (since we do it so much
task ackMsg;
input `UART_MSG_SIZE msg_in;
	uart_out_queue.push_back( genAckErrMsg(msg_in, `UART_HEADER_ACK) );
endtask

//Send a message to the controller from the UART
task send_uart_msg;
input `UART_HEADER_SIZE header;
input `UART_PAYLOAD_SIZE payload;
logic `UART_MSG_SIZE msg;
begin
	assert(uart_in_avail == 0);
	assert(uart_in_req == 0);
	uart_in_avail = 1;
	msg = {payload, header};
	case(header)
		`UART_HEADER_REPLACE_NUM:
		begin
			ackMsg(msg);
			mem_replace_queue.push_back(payload);
		end
		`UART_HEADER_SYS_STATUS:
		begin
			ackMsg(msg);
			assert(run_queue.size() ==0); //The following logic is invalid if we are outrunning the size of the queue
			if(payload != run)
			begin
//				$display("Logging run = %d at %tps", payload, $realtime);
				run_queue.push_back(payload);
			end
		end
		`UART_HEADER_MOD_PARAMS:
		begin
			if(run)
				uart_out_queue.push_back( genAckErrMsg(msg, `UART_HEADER_ERR_UPDATE_WHILST_RUN) );
			else begin
				assert(mod_params_queue.size() ==0); //The following logic is invalid if we are outrunning the size of the queue
				if(payload != mod_params)
					mod_params_queue.push_back(payload);
				ackMsg(msg);
			end
		end
		`UART_HEADER_MEM_PARAMS:
		begin
			if(run)
				uart_out_queue.push_back( genAckErrMsg(msg, `UART_HEADER_ERR_UPDATE_WHILST_RUN) );
			else begin
				assert(mem_params_queue.size()==0); //The following logic is invalid if we are outrunning the size of the queue
				if(payload != mem_params)
					mem_params_queue.push_back(payload);
				ackMsg(msg);
			end
		end
		default:
			uart_out_queue.push_back( genAckErrMsg(msg, `UART_HEADER_ERR_INVALID_MSG) );
	endcase
	while(uart_in_req == 0) //Wait for the controler to request the message
		@(posedge clk);
	uart_in_avail = 0; //Withdraw message availibility
	uart_in_msg = msg; //Put message on bus
	@(posedge clk);
	assert(uart_in_req == 0); //Ensure that the controller is no longer requesting a message
end
endtask;

//Send a 'number received' message
task send_num_received;
input `UART_RECEIVED_NUM_TOTAL_PAYLOAD_SIZE num;
begin
	assert(mem_valid == 0);
	assert(mem_overrun == 0);
	assert(mem_ack == 0);
	mem_received_num = num;
	mem_valid = 1;

	while(mem_ack ==0) //Wait for ack
		@(posedge clk);

	mem_valid = 0;
	
	uart_out_queue.push_back( genAckErrMsg(num, `UART_HEADER_RECEIVED_NUM));
	
	@(posedge clk)
		assert(mem_ack == 0); //Make sure controller withdraws ack
end
endtask;

//Verify FIFO full
always @(posedge uart_in_full)
begin
	uart_out_queue.push_back( genAckErrMsg('0, `UART_HEADER_ERR_FIFO_FULL) );
	assert(run_queue.size() ==0); //The following logic is invalid if we are outrunning the size of the queue
	if(run == 1)
		run_queue.push_back(0); //System will be stopped
	
end


//Verify message overrun
always @(posedge mem_overrun)
begin
	uart_out_queue.push_back( genAckErrMsg('0, `UART_HEADER_ERR_MEM_OVERRUN) );
	assert(run_queue.size() ==0); //The following logic is invalid if we are outrunning the size of the queue
	if(run == 1)
		run_queue.push_back(0); //System will be stopped
	
end

//Verify mod_params
logic `UART_MOD_PARAMS_TOTAL_PAYLOAD_SIZE mod_params_queue[$] = {};
always @(mod_params)
begin
	assert(mod_params_queue.size() != 0); //Make sure we are expecting a change
	assert(mod_params_queue.pop_front() == mod_params); //Make sure that the data is what we expect it to be
end

//Verify mem_params
logic `UART_MEM_PARAMS_TOTAL_PAYLOAD_SIZE mem_params_queue[$] = {};
always @(mem_params)
begin
	assert(mem_params_queue.size() != 0); //Make sure we are expecting a change
	assert(mem_params_queue.pop_front() == mem_params); //Make sure that the data is what we expect it to be
end
 
//Verify uart_out
logic `UART_MSG_SIZE uart_out_queue[$] = {};
always @(posedge clk)
begin
	if(uart_out_req)
	begin
		assert(uart_out_queue.size() != 0); //Make sure we are expecting a change
//		$display("UART received message: %d (queue length)", uart_out_queue[0], uart_out_queue.size());
		assert(uart_out_queue[0] == uart_out_msg) //Make sure that the data is what we expect it to be
			else begin $display("uart_out data error. Expected %X, Got %X", uart_out_queue[0], uart_out_msg); $error; end
		void'(uart_out_queue.pop_front());
	end
end
 
//Verify mem_replace
logic `UART_REPLACE_NUM_TOTAL_PAYLOAD_SIZE mem_replace_queue[$] = {};
always @(posedge clk)
begin
	if(mem_replace_valid)
	begin
		assert(mem_replace_queue.size() != 0); //Make sure we are expecting a change
		assert(mem_replace_queue.pop_front() == mem_replace_num); //Make sure that the data is what we expect it to be
	end
end

 
//Verify run
logic  run_queue[$] = {};
always @(run)
begin
	assert(run_queue.size() != 0); //Make sure we are expecting a change
	$display("Checking run = %d at %tps", run_queue[0], $realtime);
	assert(run_queue[0] == run) //Make sure that the data is what we expect it to be
		else begin $display("run error. Expected %d, Got %d", run_queue[0], run); $error; end
	void'(run_queue.pop_front());
end

function emptyQueues;
	emptyQueues = (mod_params_queue.size() == 0)
	            &&(mem_params_queue.size() == 0)
	            &&(uart_out_queue.size() == 0)
	            &&(mem_replace_queue.size() == 0)
	            &&(run_queue.size() == 0);
endfunction

task queueResetTransitions;
begin
	if( mod_params != `DEFAULT_MOD_PARAMS) mod_params_queue.push_back(`DEFAULT_MOD_PARAMS);
	if( mem_params != `DEFAULT_MOD_PARAMS) mem_params_queue.push_back(`DEFAULT_MEM_PARAMS);
	if( run != 0)
	begin
		run_queue.push_back(0);
		$display("(Reset) Logging run = 0 at %tps", $realtime);
	end
end
endtask

localparam realtime delay = 1us;

task resetController;
begin
	//Reset system
	@(posedge clk)
		n_reset_sys = 0;
	queueResetTransitions();
	@(posedge clk)
		n_reset_sys = 1;
	#delay;
end
endtask

integer i;
initial
begin
	//Log expected changes at reset (because we're resetting)
	mod_params_queue.push_back(`DEFAULT_MOD_PARAMS);
	mem_params_queue.push_back(`DEFAULT_MEM_PARAMS);
	run_queue.push_back(0);

	uart_out_ready = 1; //Always be ready (good advice for life)
	#delay;
	
	for(i=0; i<2; i++)
	begin
		$display("Test 1 at time %tps", $realtime);
		send_uart_msg(`UART_HEADER_REPLACE_NUM, {$urandom, $urandom});
		$display("Test 2 at time %tps", $realtime);
		send_uart_msg(`UART_HEADER_REPLACE_NUM, {$urandom, $urandom});
		$display("Test 3 at time %tps", $realtime);
		send_uart_msg(`UART_HEADER_MOD_PARAMS, {$urandom, $urandom});
		$display("Test 4 at time %tps", $realtime);
		send_uart_msg(`UART_HEADER_MEM_PARAMS, {$urandom, $urandom});
		$display("Test 5 at time %tps", $realtime);
		send_uart_msg(255, {$urandom, $urandom}); //Invalid message
		$display("Test 6 at time %tps", $realtime);
		send_uart_msg(`UART_HEADER_SYS_STATUS, i); //Stop / start system
	end

	$display("Test new number received at time %tps", $realtime);
	send_num_received( {$urandom, $urandom} ); //New number request;

	$display("Test mem overrun at time %tps", $realtime);
	//Test mem overrun
	@(posedge clk)
		mem_overrun = 1;
	#delay;
	@(posedge clk)
		mem_overrun = 0;


	$display("Reset system at time %tps", $realtime);
	resetController();

	$display("Test UART full at time %tps", $realtime);
	//Test UART FIFO full
	@(posedge clk)
		uart_in_full = 1;
	#delay;
	@(posedge clk)
		uart_in_full = 0;

	$display("Reset system at time %tps", $realtime);
	resetController();

	#delay;
	$display("Check queues empty at time %tps", $realtime);
	$display("uart_out_queue length: %d", uart_out_queue.size());
	$display("mod_params_queue length: %d", mod_params_queue.size());
	$display("mem_params_queue length: %d", mem_params_queue.size());
	$display("run_queue length: %d", run_queue.size());
	$display("mem_replace_queue length: %d", mem_replace_queue.size());
	assert(emptyQueues());
	$display("Simulation completed successfully");
	$finish;
end



endmodule