// Pulse generator

module pulse_gen(clk, n_reset, en, active, out);

parameter CLKS_PER_HALF_PERIOD = 2;
parameter PULSES = 3;

input clk, n_reset, en;
output active, out;

parameter PERIOD_CTR_WIDTH = $clog2(CLKS_PER_HALF_PERIOD);
parameter PULSE_CTR_WIDTH = $clog2(PULSES);
reg [PERIOD_CTR_WIDTH-1:0] period_ctr, next_period_ctr;
reg [PULSE_CTR_WIDTH-1:0] pulse_ctr, next_pulse_ctr;

reg[1:0] state;
localparam WAIT = 2'b00;
localparam HIGH = 2'b01;
localparam LOW = 2'b10;


wire period_done, pulse_done;
assign period_done = (period_ctr == (CLKS_PER_HALF_PERIOD - 1));
assign pulse_done = (pulse_ctr == (PULSES-1));

//Next state logic
always @(posedge clk)
begin
	if(!n_reset)
	begin
		period_ctr <= 0;
		pulse_ctr <= 0;
		state <= WAIT;
	end else begin
		case(state)
			WAIT:
				if(en) state <= HIGH;
			HIGH:
				if(period_done) state <= LOW;
			LOW:
				if(period_done)
				begin
					if(pulse_done)
						state <= WAIT;
					else
						state <= HIGH;
				end
		endcase
	
		period_ctr <= next_period_ctr;
		pulse_ctr <= next_pulse_ctr;
	end
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
			if(period_done)
				next_period_ctr = 0;
			else
				next_period_ctr = period_ctr + 1;
		end

		LOW:
		begin
			if(period_done)
			begin
				next_period_ctr = 0;
				next_pulse_ctr = pulse_ctr + 1;
			end else
				next_period_ctr = period_ctr + 1;
		end

	endcase
end

assign out = (state == HIGH);
assign active = (state == HIGH || state == LOW);

endmodule
