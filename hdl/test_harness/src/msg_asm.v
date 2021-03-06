// Message assembler
// Receives N messages from the UART, then writes to the FIFO
// Active low reset

module msg_asm(clk, n_reset,
               data_in, data_in_valid, //UART IO
               data_out, data_out_valid //FIFO IO
               );

parameter integer WORD_SIZE = 8;
parameter integer WORDS_PER_PACKET = 4;

parameter integer CTR_WIDTH = $clog2(WORDS_PER_PACKET);
localparam integer OUTPUT_WIDTH = WORD_SIZE * WORDS_PER_PACKET;

input clk, n_reset;
input [WORD_SIZE-1:0] data_in;
input data_in_valid;

output [OUTPUT_WIDTH-1:0] data_out;
output data_out_valid;

reg[0:0] state;
localparam SM_RX = 1'b0;
localparam SM_TX = 1'b1;

reg [CTR_WIDTH-1:0] ctr;

//Count how many words we have received
always @(posedge clk)
	if(!n_reset)
		ctr <= 0;
	else begin
		case(state)
			SM_RX: if(data_in_valid) ctr <= ctr + 1'b1;
			SM_TX: ctr <= 0;
		endcase
	end

//Assemble word
reg [WORD_SIZE-1:0] mem [2**CTR_WIDTH-1:0];
always @(posedge clk)
	if(data_in_valid)
		mem[ctr] <= data_in;

//Combinationally assign output to the entire contents of memory
genvar i;
generate
	for(i=0; i< WORDS_PER_PACKET; i=i+1)
	begin : generate_block
		assign data_out[((i+1)*WORD_SIZE)-1:(i*WORD_SIZE)] = mem[i];
	end
endgenerate

//State logic
always @(posedge clk)
	if(!n_reset)
		state <= SM_RX;
	else begin
		case(state)
			SM_RX : if((ctr == (WORDS_PER_PACKET -1)) && data_in_valid) state <= SM_TX;
			SM_TX : state <= SM_RX;
		endcase
	end

assign data_out_valid = (state == SM_TX);

endmodule