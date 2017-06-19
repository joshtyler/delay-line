// Message assembler
// Receives N messages from the UART, then writes to the FIFO
// Active low reset

module msg_asm(clk, n_reset,
               data_in, data_in_valid, //UART IO
               data_out, data_out_valid //FIFO IO
               );

parameter integer WORD_SIZE;
parameter integer WORDS_PER_PACKET;

localparam integer CTR_WIDTH = $clog2(WORDS_PER_PACKET);
localparam integer OUTPUT_WIDTH = WORD_SIZE * WORDS_PER_PACKET;

input clk, n_reset;
input [WORD_SIZE-1:0] data_in;
input data_in_valid;

output reg [OUTPUT_WIDTH-1:0] data_out;
output data_out_valid;

enum reg[0:0] {SM_RX, SM_TX} state;

reg [CTR_WIDTH-1:0] ctr;

//Count how many words we have received
always @(posedge clk)
	if(!n_reset)
		ctr <= 0;
	else begin
		case(state)
			SM_RX: if(data_in_valid) ctr <= ctr + 1;
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
for(i=0; i< WORDS_PER_PACKET; i++)
	assign data_out[((i+1)*WORD_SIZE)-1:(i*WORD_SIZE)] = mem[i];

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