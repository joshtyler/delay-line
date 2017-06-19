//Testbench for message disassembler

module test_msg_disasm;

parameter realtime CLK_PERIOD = 5ns;
parameter integer WORD_SIZE = 8;
parameter integer WORDS_PER_PACKET =4;

//Clock
logic clk;
clock #(.PERIOD(CLK_PERIOD)) clk0(.*);


//Reset
logic n_reset;
power_on_reset por0 (.*);

//Controller IO
logic [WORD_SIZE*WORDS_PER_PACKET-1:0] data_in;
logic data_in_valid;

//UART IO
logic uart_ready;
logic[WORD_SIZE-1:0] data_out;
logic data_out_req;

//System status
logic ready;

msg_disasm #(.WORD_SIZE(WORD_SIZE), .WORDS_PER_PACKET(WORDS_PER_PACKET))
	dut(.*);


task sendWord;
input [WORD_SIZE*WORDS_PER_PACKET-1:0] word;
begin
	assert(ready);
	data_in = word;
	@(posedge clk)
		data_in_valid = 1;
	@(posedge clk)
		data_in_valid = 0;
	@(posedge clk);
	$display("Sent %x at %t", word, $realtime);
	while(!ready) //Wait for transmit
		#1;
end
endtask


//Receive data
always @(posedge clk)
begin
	automatic integer i;
	if(data_out_req)
	begin
		$display("Received %x at %t", data_out, $realtime);
		uart_ready = 0;
		for(i=0; i< 10; i++) @(posedge clk); //Simuate UART TX delay
		uart_ready = 1;
	end else
		uart_ready = 1;
end
		

initial
begin
	data_in_valid = 0;
	#100ns; //Wait for reset
	sendWord('0);
	sendWord('1);
	sendWord('hFACEBEEF);
	#100ns;
	$display("Simulation completed");
	$finish;
end



endmodule