//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:41:49 07/03/2017 
// Design Name: 
// Module Name:    pll 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pll(
    input clock_in,
    output clock_out,
    output locked
    );
	 
	 assign clock_out = clock_in;
	 assign locked = 1;

endmodule
