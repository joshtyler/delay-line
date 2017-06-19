//Clock module
//Creates a 50/50 duty cycle clock
`timescale 1fs/1fs

module clock #(parameter realtime PERIOD) (output logic clk);

initial
begin
	clk = 0;
	forever
		#(PERIOD/2) clk = !clk;
end

endmodule