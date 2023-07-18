`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/12 19:25:50
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
    input           read_write_mem,
    input   [9:0]   address_mem,
    input   [31:0]  write_data_mem,
    output  [31:0]  read_data_mem,
    output          Done
);

    reg [7:0] main_mem[1023:0];

    initial begin
        read_data_mem = 32'b0;
        Done = 0;
    end

    always @(*) begin
        Done = 0;
        
    end

endmodule
