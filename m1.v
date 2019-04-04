`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:28:36 03/10/2019 
// Design Name: 
// Module Name:    m1 
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
module m1(rst,date,sclk,ack,scl,sda);
	input sclk,rst;
	input [3:0] date;
	output ack,scl,sda;
	reg scl,sdabuf,ack,link_sda;
	reg[3:0] datebuf;
	reg[7:0] state;
	
	assign sda = link_sda?sdabuf:1'b0;  //先明确总线的输出
	
	parameter
		ready = 8'b0000_0000,  //ready状态开始占用总线
		start = 8'b0000_0001,  //start状态开始数据的总线传输
		 bit1 = 8'b0000_0010,  
		 bit2 = 8'b0000_0100,
		 bit3 = 8'b0000_1000,
		 bit4 = 8'b0001_0000,
		 bit5 = 8'b0010_0000,
		 stop = 8'b0100_0000,
		 idle = 8'b1000_0000;
		 
	always @ (posedge sclk or negedge rst)
		begin
			if(!rst)
				scl <= 1;
			else
				scl <= ~scl;  //由上一级时钟创造本级时钟
		end
		
	always @ (posedge ack)
		datebuf <= date;
		
	always @ (negedge sclk or negedge rst)
		if(!rst)
			begin
				state <= ready;
				link_sda <= 0;  //解除总线占用
				ack <= 0;
				sdabuf <= 1;  //sdabuf为1，以提供下一过程的sda下降沿，响应题设的要求：在scl=1时，sda下降沿的出现，为数据流启动的标志。
			end
		else
			begin
				case (state)
					ready:
						if(ack)
							begin
								link_sda <= 1;  //开始占用总线
								state <= start;
							end
						else
							begin
								link_sda <= 0;  //让出总线
								state <= ready;
								ack <= 1;
							end
							
					start:
						if(scl && ack)  //个人感觉没必要加ack，因为上一状态中ack已经是1.
							begin
								sdabuf <= 0;  //要点：在scl=1时给出sda下降沿的状态，以便在m2模块中，成为开始记录数据的结合点。m2中：always@（negedge sda）   if(scl),开始记录数据。
								
								state <= bit1;
							end
						else
								state <= start;
								
					bit1:
						if(!scl)
							begin
								sdabuf <= datebuf[3];
								state <= bit2;
								ack <= 0;         //不再请求新数据
							end
						else
							state <= bit1;
						
					bit2:
						if(!scl)
							begin
								sdabuf <= datebuf[2];
								state <= bit3;
							end
						else
							state <= bit2;
							
					bit3:
						if(!scl)
							begin
								sdabuf <= datebuf[1];
								state <= bit4;
							end
						else
							state <= bit3;
							
					bit4:
						if(!scl)
							begin
								sdabuf <= datebuf[0];
								state <= bit5;
							end
						else
							state <= bit4;
						
					bit5:
						if(!scl)
							begin
								sdabuf <= 0;
								state <= stop;
							end
						else
							state <= bit5;
							
					stop:
						if(scl)
							begin
								sdabuf <= 1;
								state <= idle;
							end
						else
							state <= stop;
							
					idle:
						begin
							link_sda <= 0;
							state <= ready;
						end
					default: 
						begin
							state <= ready;
							sdabuf <= 1;
							link_sda <= 0;
						end
				endcase
			end
endmodule
				