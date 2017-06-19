//Shift register

module shift_register(clk, n_reset, in, load, shift, load_data, current_data, out);

parameter integer WIDTH = 8;

input clk;
input n_reset;
input in; //Single bit to shift in
input load; //Trigger parallel load
input shift; //Shift enable signal
input [WIDTH-1:0] load_data; //Parallel load

output [WIDTH-1:0] current_data; //Current data contents
output out; //Single bit to shift out

reg [WIDTH-1:0] data;

always @(posedge clk)
begin
	if(!n_reset)
		data <= 0;
	else begin
		if(load)
			data <= load_data;
		else if(shift) begin
			data <= {in, data[WIDTH-1:1]};
		end		
	end
end

assign out = data[0];
assign current_data = data;

endmodule
