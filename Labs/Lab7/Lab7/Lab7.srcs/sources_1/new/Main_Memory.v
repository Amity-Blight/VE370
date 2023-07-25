`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 16:17:31
// Design Name: 
// Module Name: Main_Memory
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


module Main_Memory(
    input               read_write_mem,
    input       [9:0]   address_mem,
    input       [127:0] write_data_mem,
    output reg  [127:0] read_data_mem,
    output reg          Done
);
endmodule