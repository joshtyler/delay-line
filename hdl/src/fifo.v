// Synchronous FIFO for ice40
// No reset - we are committed to the data in the FIFO

module fifo(clk, data_in, wr_en, data_out, rd_en, empty, full);

parameter WIDTH = 8;
parameter DEPTH = 10;
localparam ADDR_WIDTH = $clog2(DEPTH); //ceiling applied to log2. Technically SystemVerilog...
localparam CTR_WIDTH = $clog2(DEPTH+1); //The counter must be able to count from 0 to depth, not depth-1

input clk, rst, wr_en, rd_en;
input [WIDTH-1:0] data_in;

output reg [WIDTH-1:0] data_out;
output empty, full;

reg [ADDR_WIDTH-1:0] rd_addr = 0, wr_addr = 0;
reg [CTR_WIDTH-1:0] counter = 0; //Counter holds num. of elements in fifo

reg [WIDTH-1:0] mem [DEPTH-1:0];

//Signals for when reading and writing is requested and allowed
wire rd_en_checked, wr_en_checked;
assign rd_en_checked = (rd_en && !empty); //Ignore read request if empty
assign wr_en_checked = (wr_en && !full); //Ignore write request if empty

//Should infer Block RAM
always @(posedge clk)
begin
	if(rd_en_checked)
		data_out <= mem[rd_addr];

	if(wr_en_checked) //Ignore write request if full
		mem[wr_addr] <= data_in;
end

//Take care of counter
//Decrement on read
//Increment on write
//Dont change if both at once
always @(posedge clk)
begin
	if(rd_en_checked ^ wr_en_checked) // Don't change if we are both reading and writing
	begin
		if(rd_en_checked) //If reading decrement
			counter <= counter -1;
		else if(wr_en_checked) //If writing increment
			counter <= counter +1;
	end
end

//Fifo address handling
//Logic to handle address incrementing
//Increment address on enable
//Wrap around if at the end

//Read address
always @(posedge clk)
begin
	if(rd_en_checked)
	begin
		if(rd_addr == DEPTH -1) // If we are at the highest address
			rd_addr <= 0;
		else
			rd_addr <= rd_addr + 1;
	end
end

//Write address
always @(posedge clk)
begin
	if(wr_en_checked)
	begin
		if(wr_addr == DEPTH -1) // If we are at the highest address
			wr_addr <= 0;
		else
			wr_addr <= wr_addr + 1;
	end
end

//Empty/full signals
assign empty = (counter == 0);
assign full = (counter == DEPTH);

endmodule
