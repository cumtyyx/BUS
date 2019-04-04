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
	
	assign sda = link_sda?sdabuf:1'b0;  //����ȷ���ߵ����
	
	parameter
		ready = 8'b0000_0000,  //ready״̬��ʼռ������
		start = 8'b0000_0001,  //start״̬��ʼ���ݵ����ߴ���
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
				scl <= ~scl;  //����һ��ʱ�Ӵ��챾��ʱ��
		end
		
	always @ (posedge ack)
		datebuf <= date;
		
	always @ (negedge sclk or negedge rst)
		if(!rst)
			begin
				state <= ready;
				link_sda <= 0;  //�������ռ��
				ack <= 0;
				sdabuf <= 1;  //sdabufΪ1�����ṩ��һ���̵�sda�½��أ���Ӧ�����Ҫ����scl=1ʱ��sda�½��صĳ��֣�Ϊ�����������ı�־��
			end
		else
			begin
				case (state)
					ready:
						if(ack)
							begin
								link_sda <= 1;  //��ʼռ������
								state <= start;
							end
						else
							begin
								link_sda <= 0;  //�ó�����
								state <= ready;
								ack <= 1;
							end
							
					start:
						if(scl && ack)  //���˸о�û��Ҫ��ack����Ϊ��һ״̬��ack�Ѿ���1.
							begin
								sdabuf <= 0;  //Ҫ�㣺��scl=1ʱ����sda�½��ص�״̬���Ա���m2ģ���У���Ϊ��ʼ��¼���ݵĽ�ϵ㡣m2�У�always@��negedge sda��   if(scl),��ʼ��¼���ݡ�
								
								state <= bit1;
							end
						else
								state <= start;
								
					bit1:
						if(!scl)
							begin
								sdabuf <= datebuf[3];
								state <= bit2;
								ack <= 0;         //��������������
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
				