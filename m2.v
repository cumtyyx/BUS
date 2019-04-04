`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:33 03/11/2019 
// Design Name: 
// Module Name:    m2 
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
module m2(scl,sda,outhigh);
	input scl,sda;
	output [15:0] outhigh;
	reg [4:0] mstate;
	reg [3:0] pdate,pdatebuf;
	reg [15:0] outhigh;
	reg startflag,endflag;
	
	always @ (negedge sda)
		begin
			if(scl)
				startflag <= 1;
			else if(endflag)
					startflag <= 0;
		end
		
	always @ (posedge sda)
		begin
			if(sda)
				begin
					endflag <= 1;
					pdatebuf <= pdate;
				end
			else
				endflag <= 0;
		end
		
	parameter
		sbit1 = 5'b00001,
		sbit2 = 5'b00010,
		sbit3 = 5'b00100,
		sbit4 = 5'b01000,
		sbit5 = 5'b10000;
		
	always @ (pdatebuf)
		begin
			case (pdatebuf)
				0001: outhigh <= 16'b0000_0000_0000_0001;		//可以写作：
				0010: outhigh <= 16'b0000_0000_0000_0010;		//initial 
				0011: outhigh <= 16'b0000_0000_0000_0100;		//	outhigh <= 16'b0000_0000_0000_0000;
				0100: outhigh <= 16'b0000_0000_0000_1000;		//	always @ (padebuf)
				0101: outhigh <= 16'b0000_0000_0001_0000;		//		outhigh[padebuf] <= 1;
				0110: outhigh <= 16'b0000_0000_0010_0000;
				0111: outhigh <= 16'b0000_0000_0100_0000;
				1000: outhigh <= 16'b0000_0000_1000_0000;
				1001: outhigh <= 16'b0000_0001_0000_0000;
				1010: outhigh <= 16'b0000_0010_0000_0000;
				1011: outhigh <= 16'b0000_0100_0000_0000;
				1100: outhigh <= 16'b0000_1000_0000_0000;
				1101: outhigh <= 16'b0001_0000_0000_0000;
				1110: outhigh <= 16'b0010_0000_0000_0000;
				1111: outhigh <= 16'b0100_0000_0000_0000;
				0000: outhigh <= 16'b1000_0000_0000_0000;
			endcase
		end
		
	always @ (posedge scl)
		if(startflag)
			case (mstate)
				sbit1:
					begin
						pdate[3] <= sda;
						mstate <= sbit2;
						$display ("I am in sdabit1");
					end
				sbit2:
					begin
						pdate[2] <= sda;
						mstate <= sbit3;
						$display ("I am in sdabit2");
					end
				sbit3:
					begin
						pdate[1] <= sda;
						mstate <= sbit4;
						$display ("I am in sdabit3");
					end
				sbit4:
					begin
						pdate[0] <= sda;
						mstate <= sbit5;
						$display ("I am in sdabit4");
					end
				sbit5:							//sbit5属于空状态，为了不使得在下一个时钟上升沿到来时，sbit4直接返回stib1而使得在下一个状态pdate[3]重新赋值，
					begin						//而此时endflag也正好重新赋值以结束对pdate的数据传输，这样会发生两个矛盾事件同时到达的现象。故而，添加一
						mstate <= sbit1;		//个空状态，使得pdate数据传输结束后，再回到sbit1的状态。
					end
				default: mstate <= sbit1;
			endcase
		else
			mstate <= sbit1;

endmodule
