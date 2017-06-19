//Testbench for message assembler

module test_msg_asm;

parameter realtime CLK_PERIOD = 5ns;
parameter integer WORD_SIZE = 8;
parameter integer WORDS_PER_PACKET =4;

//Clock
logic clk;
clock #(.PERIOD(CLK_PERIOD)) clk0(.*);


//Reset
logic n_reset;
power_on_reset por0 (.*);

logic [WORD_SIZE-1:0] data_in;
logic data_in_valid;

logic[WORD_SIZE*WORDS_PER_PACKET-1:0] data_out;
logic data_out_valid;

msg_asm #(.WORD_SIZE(WORD_SIZE), .WORDS_PER_PACKET(WORDS_PER_PACKET))
	dut(.*);

task sendWord;
input [WORD_SIZE-1:0] word;
begin
	assert(data_in_valid == 0);
	data_in = word;
	@(posedge clk)
		data_in_valid = 1;
	@(posedge clk)
		data_in_valid = 0;

	$display("Sent %x", word);
end
endtask


//Receive data
always @(posedge clk)
	if(data_out_valid)
		$display("Received %x", data_out);

initial
begin
	#100ns; //Wait for reset
	sendWord(0);
	sendWord(1);
	sendWord(2);
	sendWord(3);

	sendWord(255);
	sendWord(254);
	sendWord(253);
	sendWord(252);
	#100ns;
	
	$finish;
end



endmodule