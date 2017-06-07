// Edge detector
// Detects the rising edge of the input waveform
// Asserts its output on the next clock cycle
// There is a timeout until the next edge can be detected

module edge_detect(clk, in, out);

parameter TIMEOUT = 20;

input clk, in;
output out;

localparam CTR_WIDTH = $clog2(TIMEOUT); //This is actually systemverilog, but widely supported
reg [CTR_WIDTH-1:0] ctr, next_ctr = 0;

enum {SM_WAIT, SM_ASSERT, SM_TIMEOUT} state = SM_WAIT; //This is actually systemverilog, but widely supported

//Next state logic
always @(posedge clk)
begin
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
