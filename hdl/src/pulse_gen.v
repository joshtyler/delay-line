// Pulse generator

module pulse_gen(clk, en, out);

parameter CLKS_PER_HALF_PERIOD = 2;
parameter PULSES = 3;

input clk, en;
output out;

localparam PERIOD_CTR_WIDTH = $clog2(CLKS_PER_HALF_PERIOD);
localparam PULSE_CTR_WIDTH = $clog2(PULSES);
reg [PERIOD_CTR_WIDTH-1:0] period_ctr, next_period_ctr = 0;
reg [PULSE_CTR_WIDTH-1:0] pulse_ctr, next_pulse_ctr = 0;

enum {WAIT, HIGH, LOW} state = WAIT; //This is actually systemverilog, but widely supported

`define PERIOD_DONE (period_ctr == (CLKS_PER_HALF_PERIOD - 1))
`define PULSE_DONE (pulse_ctr == (PULSES-1))

//Next state logic
always @(posedge clk)
begin
	case(state)
		WAIT:
			if(en) state <= HIGH;
		HIGH:
			if(`PERIOD_DONE) state <= LOW;
		LOW:
			if(`PERIOD_DONE)
			begin
				if(`PULSE_DONE)
					state <= WAIT;
				else
					state <= HIGH;
			end
	endcase;

	period_ctr <= next_period_ctr;
	pulse_ctr <= next_pulse_ctr;
end

//Combinational logic
always @(*)
begin
	next_period_ctr = period_ctr;
	next_pulse_ctr = pulse_ctr;

	case(state)
		WAIT:
		begin
			next_pulse_ctr = 0;
			next_period_ctr = 0;
		end

		HIGH:
		begin
			if(`PERIOD_DONE)
				next_period_ctr = 0;
			else
				next_period_ctr = period_ctr + 1;
		end

		LOW:
		begin
			if(`PERIOD_DONE)
			begin
				next_period_ctr = 0;
				next_pulse_ctr = pulse_ctr + 1;
			end else
				next_period_ctr = period_ctr + 1;
		end

	endcase;
end

assign out = (state == HIGH);

endmodule
