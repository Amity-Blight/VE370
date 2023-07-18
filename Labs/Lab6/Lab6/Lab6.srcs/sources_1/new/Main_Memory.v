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
    input   [31:0]  write_data_mem[3:0],
    output  [31:0]  read_data_mem[3:0],
    output  reg     Done
);

    reg [7:0] main_mem[63:0][15:0]; // 64 blocks in total; 16 bytes in a block
    reg [5:0] Index;
    integer i, j;

    initial begin
        read_data_mem = 32'b0;
        Done = 0;
    end

    always @(*) begin
        Done = 0;
        if (read_write_mem == 0) begin // Read operation
            read_data_mem[0] = main_mem[Index][3:0];
            read_data_mem[1] = main_mem[Index][7:4];
            read_data_mem[2] = main_mem[Index][11:8];
            read_data_mem[3] = main_mem[Index][15:12];
        end
        else begin // Write operation
            for (i = 0; i < 4; i = i+1) begin
                main_mem[Index]
            end
            main_mem[Index]
        end
    end

    assign Index = address_mem[9:4];

endmodule