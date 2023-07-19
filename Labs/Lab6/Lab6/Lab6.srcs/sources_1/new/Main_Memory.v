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
    input               read_write_mem,
    input       [9:0]   address_mem,
    input       [127:0] write_data_mem,
    output reg  [127:0] read_data_mem,
    output reg          Done
);

    reg [7:0] main_mem[63:0][15:0]; // 64 blocks in total; 16 bytes in a block
    wire [5:0] Index;

    initial begin
        read_data_mem = 128'b0;
        Done = 0;
    end

    always @(*) begin
        if (read_write_mem == 0) begin // Reading operation
            read_data_mem = {main_mem[Index][15], main_mem[Index][14], main_mem[Index][13], main_mem[Index][12],
                            main_mem[Index][11], main_mem[Index][10], main_mem[Index][9], main_mem[Index][8],
                            main_mem[Index][7], main_mem[Index][6], main_mem[Index][5], main_mem[Index][4],
                            main_mem[Index][3], main_mem[Index][2], main_mem[Index][1], main_mem[Index][0]};
        end
        else begin // Writing operation
            main_mem[Index][15] = write_data_mem[127:120];
            main_mem[Index][14] = write_data_mem[119:112];
            main_mem[Index][13] = write_data_mem[111:104];
            main_mem[Index][12] = write_data_mem[103:96];
            main_mem[Index][11] = write_data_mem[95:88];
            main_mem[Index][10] = write_data_mem[87:80];
            main_mem[Index][9] = write_data_mem[79:72];
            main_mem[Index][8] = write_data_mem[71:64];
            main_mem[Index][7] = write_data_mem[63:56];
            main_mem[Index][6] = write_data_mem[55:48];
            main_mem[Index][5] = write_data_mem[47:40];
            main_mem[Index][4] = write_data_mem[39:32];
            main_mem[Index][3] = write_data_mem[31:24];
            main_mem[Index][2] = write_data_mem[23:16];
            main_mem[Index][1] = write_data_mem[15:8];
            main_mem[Index][0] = write_data_mem[7:0];
        end
        Done = 1;
        #2 Done = 0;
    end

    assign Index = address_mem[9:4];

endmodule