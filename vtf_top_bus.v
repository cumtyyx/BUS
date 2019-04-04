`timescale 1ns / 1ps
`define halfperiod 50
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:59:17 03/11/2019
// Design Name:   top
// Module Name:   C:/myfpga/project/bus/testbench/vtf_top_bus.v
// Project Name:  bus
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vtf_top_bus;

	// Inputs
	reg [3:0] date;
	reg sclk;
	reg rst;

	// Outputs
	wire ack;
	wire [15:0] outhigh;

	// Instantiate the Unit Under Test (UUT)
	
	m1 uut1(.rst(rst),.sclk(sclk),.ack(ack),.sda(sda),.date(date),.scl(scl));
	m2 uut2(.scl(scl),.sda(sda),.outhigh(outhigh));
	initial
		begin
			rst = 1;
			#10 rst = 0;
			#(`halfperiod*2+3) rst = 1;
		end
		
	initial
		begin
			sclk = 0;
			date = 0;
			#(`halfperiod*1000) $stop;
		end
	
	always #(`halfperiod) sclk = ~sclk;
	
	always @ (posedge ack)
		begin
			#(`halfperiod/2+3) date = date + 1;
		end
      
endmodule

