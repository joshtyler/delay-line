// Edge detector
// Detects the rising edge of the input waveform
// Asserts its output on the next clock cycle
// There is a timeout until the next edge can be detected

module edge_detect(clk, n_reset, in, out);

parameter TIMEOUT = 20;

input clk, n_reset, in;
output out;

parameter CTR_WIDTH = $clog2(TIMEOUT);
reg [CTR_WIDTH-1:0] ctr, next_ctr;

reg[1:0] state;
localparam SM_WAIT = 2'b00;
localparam SM_ASSERT = 2'b01;
localparam SM_TIMEOUT = 2'b10;


//Next state logic
always @(posedge clk)
begin
	if(!n_reset)
	begin
		ctr <= 0;
		state <= SM_WAIT;
	end else begin
		case(state)
			SM_WAIT:
				if(in) state <= SM_ASSERT; //Move on rising edge (assume signal is low on entry)
			SM_ASSERT:
				state <= SM_TIMEOUT;
			SM_TIMEOUT:
				if(ctr == (TIMEOUT-1))
					state <= SM_WAIT;
		endcase
		ctr <= next_ctr;
	end
end

//Combinational logic
always @(*)
begin
	if(state == SM_TIMEOUT)
		next_ctr = ctr + 1;
	else
		next_ctr = 0;
end

assign out = (state == SM_ASSERT);

endmodule
