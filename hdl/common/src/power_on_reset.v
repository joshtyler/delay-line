//Power on reset generator for Lattice iCE40
//Generates a synchronous reset for one period after reset
//en is an enable signal, e.g. from a PLL lock indicator

module power_on_reset(clk, en, n_reset);

input clk, en;
output n_reset;

//Lattice guarantees that all registers will contain 0 on power up
reg [1:0] ctr = 0;

always @(posedge clk)
	if(en)
	begin
		if(ctr != 2'b10) //Halt on 10
			ctr <= ctr + 1;
	end

assign n_reset = !(ctr == 2'b01);
endmodule