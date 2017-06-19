// Edge detector
// Detects the rising edge of the input waveform
// Asserts its output on the next clock cycle
// There is a timeout until the next edge can be detected

module edge_detect(clk, n_reset, in, out);

parameter TIMEOUT = 20;

input clk, n_reset, in;
output out;

localparam CTR_WIDTH = $clog2(TIMEOUT); //This is actually systemverilog, but widely supported
reg [CTR_WIDTH-1:0] ctr, next_ctr;

enum reg[1:0] {SM_WAIT, SM_ASSERT, SM_TIMEOUT} state; //This is actually systemverilog, but widely supported

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
		endcase;
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
