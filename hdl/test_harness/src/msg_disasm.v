// Message disassembler
// Receives a long message from controller, and transmits via UART
// Note that input message must be valid for entire time that message is being transmitted
// This saves duplicating a very wide register from controller
// Active low synchronous reset

module msg_disasm(clk, n_reset,
               data_in, data_in_valid, //Controller IO
               uart_ready, data_out, data_out_req, //UART IO
               ready //Signal that module is ready to accept data
               );

parameter integer WORD_SIZE = 8;
parameter integer WORDS_PER_PACKET = 4;

localparam integer CTR_WIDTH = $clog2(WORDS_PER_PACKET);
localparam integer INPUT_WIDTH = WORD_SIZE * WORDS_PER_PACKET;

input clk, n_reset;
input [INPUT_WIDTH-1:0] data_in;
input data_in_valid;

input uart_ready;
output reg [WORD_SIZE-1:0] data_out;
output data_out_req;

output ready;

enum reg[0:0] {SM_RX, SM_TX} state;

reg [CTR_WIDTH-1:0] ctr;

//Count how many words we have transmitted
always @(posedge clk)
	if(!n_reset)
		ctr <= 0;
	else begin
		case(state)
			SM_RX: ctr <= 0;
			SM_TX: if(data_out_req) ctr <= ctr + 1;
		endcase
	end

//Transmit word
reg [WORD_SIZE-1:0] mem [2**CTR_WIDTH-1:0];
always @(posedge clk)
		data_out <= mem[ctr];

//Combinationally assign input to the entire contents of memory
genvar i;
for(i=0; i< WORDS_PER_PACKET; i++)
	assign mem[i] = data_in[((i+1)*WORD_SIZE)-1:(i*WORD_SIZE)];

//State logic
always @(posedge clk)
	if(!n_reset)
		state <= SM_RX;
	else begin
		case(state)
			SM_RX : if(data_in_valid) state <= SM_TX;
			SM_TX : if(data_out_req && (ctr == (WORDS_PER_PACKET - 1))) state <= SM_RX;
		endcase
	end

assign ready = (state == SM_RX); //We are ready to accept a new request
assign data_out_req = (state == SM_TX) && uart_ready; //Request a transmit when we are transmitting and data is ready to go

endmodule