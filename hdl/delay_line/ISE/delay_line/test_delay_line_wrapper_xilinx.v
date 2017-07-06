`timescale 1ns / 1fs

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:38:11 07/04/2017
// Design Name:   delay_line_wrapper
// Module Name:   /home/josh/Dropbox/My Documents/Uni work/MSc/Embedded Systems/Project/repository/hdl/delay_line/ISE/delay_line/test_delay_line_wrapper_xilinx.v
// Project Name:  delay_line
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: delay_line_wrapper
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_delay_line_wrapper_xilinx;

	// Inputs
	reg clk_in;
	wire in_sig;

	// Outputs
	wire out_sig;
	wire led;

	// Instantiate the Unit Under Test (UUT)
	delay_line_wrapper uut (
		.clk_in(clk_in), 
		.in_sig(in_sig), 
		.out_sig(out_sig), 
		.led(led)
	);
	
	initial clk_in = 0;
	
	always #5 clk_in = !clk_in;
	
	reg en;
	reg clk135;
	
	initial clk135 = 0;
	always #74 clk135 = !clk135;
	
	assign in_sig = en && clk135;

	initial begin
		// Initialize Inputs
		en = 0;

		// Wait 100 ns for global reset to finish
		#103;
        
		// Add stimulus here
		
		en = 1;
		#900;
		en = 0;
		#1000
		en = 1;
		#900;
		en = 0;
		
		#1030000;
		en = 1;
		#900;
		en = 0;
		#1000
		en = 1;
		#900;
		en = 0;

	end
      
endmodule

