`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/02 13:28:01
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb();
reg clk, rst, start;
wire [15:0] dout;
top DUT(clk, rst, start, dout);
always #3 clk = ~clk;

initial begin
clk = 0; rst = 0; start = 0;
#99; 
#15 rst = 1;
#15 rst = 0;
#6 start = 1;
#6 start = 0;
#300;
end
endmodule
