`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/02 11:38:56
// Design Name: 
// Module Name: top
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


module top(clk, rst, start, dout);
input clk, rst, start;
output [15:0] dout;
wire [1:0] dout_w;
wire [10:0] dout_in;
reg [9:0] addr_in;
reg [4:0] addr_w;
reg [9:0] addr_ram;
reg [15:0] din_ram;
reg [3:0] state;
reg [15:0] cnt_ram, cnt_col, cnt_col_stride, cnt_row_stride, cnt_row_ctrl;
reg [31:0] sum_mul;
wire [10:0] dout_mul;

reg wea;
in_rom u0(.clka(clk), .addra(addr_in), .douta(dout_in));
weights_rom u1(.clka(clk), .addra(addr_w), .douta(dout_w));
mult u2(.CLK(clk), .A(dout_in), .B(dout_w), .P(dout_mul));
result_ram u3(.clka(clk) ,.wea(wea), .addra(addr_ram), .dina(din_ram),.douta(dout));

localparam IDLE = 4'd0, DELAY_1 = 4'd1, DELAY_2 = 4'd2, DELAY_3 = 4'd3, DELAY_4 = 4'd4, DELAY_5 = 4'd5,  CONV1 = 4'd6, CONV2 = 4'd7, CONV3 = 4'd8, CONV4 = 4'd9, CONV5 = 4'd10,  DONE = 4'd11;


//state
always@(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        case(state)
             IDLE : if(start) state <= CONV1; else state <= IDLE;
             CONV1 : if(cnt_col == 4) state <= CONV2; else state <= CONV1;
             CONV2 : if(cnt_col == 4) state <= CONV3; else state <= CONV2;
             CONV3 : if(cnt_col == 4) state <= CONV4; else state <= CONV3;
             CONV4 : if(cnt_col == 4) state <= CONV5; else state <= CONV4;
             CONV5 : if(addr_ram == 10'd783 && cnt_col == 16'd4) state <= DONE; else if (addr_ram != 10'd783 && cnt_col == 16'd4) state <= CONV1;else state <= CONV5;
             DONE : state <= IDLE;
             default : state <= IDLE;
             endcase
end



always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_col <= 16'd0;
    else
        case(state)
            CONV1 : if(cnt_col == 4) cnt_col <= 16'd0; else cnt_col <= cnt_col + 1'd1;
            CONV2 : if(cnt_col == 4) cnt_col <= 16'd0; else cnt_col <= cnt_col + 1'd1;
            CONV3 : if(cnt_col == 4) cnt_col <= 16'd0; else cnt_col <= cnt_col + 1'd1;
            CONV4 : if(cnt_col == 4) cnt_col <= 16'd0; else cnt_col <= cnt_col + 1'd1;
            CONV5 : if(cnt_col == 4) cnt_col <= 16'd0; else cnt_col <= cnt_col + 1'd1;
            default : cnt_col <= 16'd0;
            endcase
end
always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_col_stride <= 16'd0;
    else
        case(state)
            CONV5 : if(cnt_col == 4 && cnt_row_ctrl != 139) cnt_col_stride <= cnt_col_stride + 16'd1; else if(cnt_col == 4 && cnt_row_ctrl == 139) cnt_col_stride <= 0; else cnt_col_stride <= cnt_col_stride;
            default : cnt_col_stride <= cnt_col_stride;
            endcase
end 

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_row_ctrl <= 16'd0;
    else
        case(state)
            CONV5 : if(cnt_row_ctrl == 139) cnt_row_ctrl <= 0; else cnt_row_ctrl  <= cnt_row_ctrl  + 16'd1; 
            default : cnt_row_ctrl <= cnt_row_ctrl;
            endcase
end 

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_row_ctrl <= 16'd0;
    else
        case(state)
            CONV5 : if(cnt_row_ctrl == 3919) cnt_row_ctrl <= 0; else cnt_row_ctrl  <= cnt_row_ctrl  + 16'd1; 
            default : cnt_row_ctrl <= cnt_row_ctrl;
            endcase
end 

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_row_stride <= 16'd0;
    else
        case(state)
            CONV5 : if(cnt_row_ctrl == 139) cnt_row_stride <= cnt_row_stride + 16'd32; else cnt_row_stride <= cnt_row_stride;
            default : cnt_row_stride <= cnt_row_stride;
            endcase
end 
      
always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_in <= 7'd0;
    else
        case(state)
            IDLE : addr_in <= 7'd0;
            CONV1 : addr_in <= 10'd0 + cnt_col + cnt_col_stride + cnt_row_stride;
            CONV2 : addr_in <= 10'd32 + cnt_col + cnt_col_stride + cnt_row_stride;
            CONV3 : addr_in <= 10'd64 + cnt_col + cnt_col_stride + cnt_row_stride;
            CONV4 : addr_in <= 10'd96 + cnt_col + cnt_col_stride + cnt_row_stride;
            CONV5 : addr_in <= 10'd128 + cnt_col + cnt_col_stride + cnt_row_stride;
           default : addr_in <= addr_in + 1'd1;
           endcase
end
// weights
always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_w <= 5'd0;
    else
        case(state)
            IDLE : addr_w <= 5'd0;
            CONV1 : addr_w <= cnt_col;
            CONV5 : if(addr_w == 5'd24) addr_w <= 0; else addr_w <= addr_w + 1'd1;
            default : addr_w <= addr_w + 1'd1;
            endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_ram <= 16'd0;
    else
        case(state)
            CONV1 : cnt_ram <= cnt_ram + 1'd1;
            CONV2 : if(cnt_ram == 26) cnt_ram <= 0; else cnt_ram <= cnt_ram + 1'd1;
            CONV3 : cnt_ram <= cnt_ram + 1'd1;
            CONV4 : cnt_ram <= cnt_ram + 1'd1;
            CONV5 : cnt_ram <= cnt_ram + 1'd1;
            default : cnt_ram <= 16'd0;
            endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        sum_mul <= 32'd0;
    else
        case(state)
            CONV1 :  sum_mul <= sum_mul + dout_mul;
            CONV2 :if(cnt_ram == 5'd26) sum_mul <= 32'd0; else sum_mul <= sum_mul + dout_mul;
            CONV3 : sum_mul <= sum_mul + dout_mul;
            CONV4 : sum_mul <= sum_mul + dout_mul;
            CONV5 :sum_mul <= sum_mul + dout_mul;
            default : sum_mul <= 32'd0;
            endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        din_ram <= 16'd0;
    else
        case(state)
            CONV2 :if(cnt_ram == 5'd26) din_ram <= sum_mul; else din_ram <= din_ram;
            default : din_ram <= din_ram;
            endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
    addr_ram <= 0;
    else
    case(state)
    CONV2 : if(addr_ram == 10'd783 && cnt_ram == 5'd26) addr_ram <= 0; else if(addr_ram == 5'd26 && addr_ram != 10'd783) addr_ram <= addr_ram + 1'd1; else addr_ram <= addr_ram;
    default addr_ram <= addr_ram;
    endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        wea <= 1'd0;
    else
        case(state)
            CONV2 : if(addr_ram == 10'd783 && cnt_ram == 5'd26) wea <= 1'd0; else wea <= 1'd1;
            default : wea <= 1'd0;
            endcase
end

endmodule
