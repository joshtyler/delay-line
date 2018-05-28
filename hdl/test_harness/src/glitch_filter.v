//Glitch filter
//Only propagate input to output once it has been stable for long enough

module glitch_filter (clk, n_reset, signal_in, signal_out);

parameter integer DELAY=10;

input clk, n_reset, signal_in;
output reg signal_out;

parameter COUNT_WIDTH = $clog2(DELAY);

reg prev_signal;
reg [COUNT_WIDTH:0] cnt;

always @(posedge clk)
begin
	if(!n_reset)
	begin
		cnt <= 0;
		prev_signal <= 1;
		signal_out <= 1; //Reset to 1
	end else begin
		if(prev_signal != signal_in) //Signal change so reset counter
		begin
			cnt <= 0;
		end else if(cnt == DELAY) begin //We've reached the max count, so reset counter and let signal go to output
			cnt <= 0;
			signal_out <= signal_in;
		end else begin
			cnt <= cnt + 1'b1;
		end

		prev_signal <= signal_in; //Remember previous signal
	end
end

endmodule
