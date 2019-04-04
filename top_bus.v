`timescale 1ns / 1ps
`include "m1.v"
`include "m2.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:13 03/11/2019 
// Design Name: 
// Module Name:    top 
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
module top(date,sclk,rst,ack,outhigh);
	input date,sclk,rst;
	output ack,outhigh;
	wire [15:0] outhigh;
	wire ack,sda,scl;
	
	m1 m1(.rst(rst),.sclk(sclk),.ack(ack),.sda(sda),.date(date),.scl(scl));
	m2 m2(.scl(scl),.sda(sda),.outhigh(outhigh));

endmodule
