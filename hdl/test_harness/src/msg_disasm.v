// Message disassembler
// Receives a long message from FIFO, and transmits via UART
// Note that input message must be valid for entire time that message is being transmitted
// This saves duplicating a very wide register from controller
// Active low synchronous reset

module msg_disasm(clk, n_reset,
                  data_in, data_in_ready, data_in_req, //FIFO IO
                  uart_ready, data_out, data_out_req //UART IO
                  );

parameter integer WORD_SIZE = 8;
parameter integer WORDS_PER_PACKET = 4;

parameter integer CTR_WIDTH = $clog2(WORDS_PER_PACKET +1);
localparam integer INPUT_WIDTH = WORD_SIZE * WORDS_PER_PACKET;

input clk, n_reset;
input [INPUT_WIDTH-1:0] data_in;
input data_in_ready;
output data_in_req;

input uart_ready;
output reg [WORD_SIZE-1:0] data_out;
output data_out_req;

reg[1:0] state;
localparam SM_RX = 2'b00;
localparam SM_RX_REQ = 2'b01;
localparam SM_TX_REQ = 2'b10;
localparam SM_TX = 2'b11;

reg [CTR_WIDTH-1:0] ctr;

//Count how many words we have transmitted
always @(posedge clk)
	if(!n_reset)
		ctr <= 0;
	else begin
		case(state)
			SM_RX_REQ: ctr <= 0; //Reset counter
			SM_TX_REQ: ctr <= ctr + 1'b1; //Increment counter
		endcase
	end

//Transmit word
wire [WORD_SIZE-1:0] mem [WORDS_PER_PACKET-1:0];
always @(posedge clk)
		data_out <= mem[ctr];

//Combinationally assign input to the entire contents of memory
genvar i;
generate
	for(i=0; i< WORDS_PER_PACKET; i=i+1)
	begin : generate_block
		assign mem[i] = data_in[((i+1)*WORD_SIZE)-1:(i*WORD_SIZE)];
	end
endgenerate

//State logic
always @(posedge clk)
	if(!n_reset)
		state <= SM_RX;
	else begin
		case(state)
			SM_RX : //Wait for FIFO to be ready
				if(data_in_ready)
					state <= SM_RX_REQ;
			SM_RX_REQ : //Request data from FIFO
				state <= SM_TX; 
			SM_TX : //Wait for UART to be ready, check if entire packet has been sent
				if(ctr == (WORDS_PER_PACKET))
					state <= SM_RX;
				else if(uart_ready)
					state <= SM_TX_REQ;
			SM_TX_REQ : //Request data transfer to UART
				if(uart_ready)
					state <= SM_TX; 
		endcase
	end

assign data_in_req = (state == SM_RX_REQ); // Request word from RAM
assign data_out_req = (state == SM_TX_REQ); //Request a transmit when we are transmitting and data is ready to go

endmodule
