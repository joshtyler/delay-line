// Dual port RAM for iCE40
// Single clock because that is how we roll
// Would work for other FPGAs, as memory is inferred

module dual_port_ram(clk, wr_addr, wr_en, wr_data, rd_addr, rd_en, rd_data);

parameter WIDTH = 8;
parameter DEPTH = 8;
localparam ADDR_WIDTH = $clog2(DEPTH);

input clk, wr_en, rd_en;
input [ADDR_WIDTH-1:0] wr_addr, rd_addr;
input [WIDTH-1:0] wr_data;
output reg [WIDTH-1:0] rd_data;

reg [WIDTH-1:0] mem [DEPTH-1:0];

//Initialise memory to all zeros
integer i;
initial
	for(i=0; i < DEPTH; i=i+1)
		mem[i] <= 0;

always @(posedge clk)
begin
	if(wr_en)
		mem[wr_addr] <= wr_data;

	if(rd_en)
		rd_data <= mem[rd_addr];
end

endmodule
