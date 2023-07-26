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

    reg [7:0] main_mem[63:0][15:0]; // 64 blocks in total; 16 bytes in a block
    wire [5:0] Index;
    integer i, j;

    initial begin
        read_data_mem = 128'b0;
        Done = 0;
        for (i = 0; i < 64; i = i+1) begin
            for (j = 0; j < 16; j = j+1) begin
                main_mem[i][j] = 8'b0;
            end
        end
        main_mem[0][0] = 8'h55;
        main_mem[0][1] = 8'h55;
        main_mem[0][2] = 8'h55;
        main_mem[0][3] = 8'h55;
        main_mem[0][4] = 8'hF;
        main_mem[0][8] = 8'hE;
        main_mem[0][12] = 8'hA;

        main_mem[4][0] = 8'hCC;
        main_mem[4][1] = 8'hCC;
        main_mem[4][2] = 8'hCC;
        main_mem[4][3] = 8'hCC;
        main_mem[4][4] = 8'hEE;
        main_mem[4][5] = 8'hEE;
        main_mem[4][6] = 8'hEE;
        main_mem[4][7] = 8'hEE;
        main_mem[4][8] = 8'hAA;
        main_mem[4][9] = 8'hAA;
        main_mem[4][10] = 8'hAA;
        main_mem[4][11] = 8'hAA;
        main_mem[4][12] = 8'hBB;
        main_mem[4][13] = 8'hBB;
        main_mem[4][14] = 8'hBB;
        main_mem[4][15] = 8'hBB;

        main_mem[16][0] = 8'h44;
        main_mem[16][1] = 8'h44;
        main_mem[16][2] = 8'h44;
        main_mem[16][3] = 8'h44;
        main_mem[16][4] = 8'h33;
        main_mem[16][5] = 8'h33;
        main_mem[16][6] = 8'h33;
        main_mem[16][7] = 8'h33;
        main_mem[16][8] = 8'h22;
        main_mem[16][9] = 8'h22;
        main_mem[16][10] = 8'h22;
        main_mem[16][11] = 8'h22;
        main_mem[16][12] = 8'h11;
        main_mem[16][13] = 8'h11;
        main_mem[16][14] = 8'h11;
        main_mem[16][15] = 8'h11;

        main_mem[20][0] = 8'h8d;
        main_mem[20][1] = 8'h2;
        main_mem[20][8] = 8'h85;
        main_mem[20][9] = 8'h2;
        main_mem[20][12] = 8'h81;
        main_mem[20][13] = 8'h2;

        main_mem[21][0] = 8'h8d;
        main_mem[21][1] = 8'h2;
        main_mem[21][8] = 8'h85;
        main_mem[21][9] = 8'h2;
        main_mem[21][12] = 8'h81;
        main_mem[21][13] = 8'h2;

        main_mem[25][0] = 8'h91;
        main_mem[25][1] = 8'h1;
        main_mem[25][4] = 8'h99;
        main_mem[25][5] = 8'h1;
        main_mem[25][8] = 8'h95;
        main_mem[25][9] = 8'h1;
        main_mem[25][12] = 8'h91;
        main_mem[25][13] = 8'h1;
        
        main_mem[29][0] = 8'hdd;
        main_mem[29][1] = 8'h1;
        main_mem[29][4] = 8'hd9;
        main_mem[29][5] = 8'h1;
        main_mem[29][8] = 8'hd5;
        main_mem[29][9] = 8'h1;
        main_mem[29][12] = 8'hd1;
        main_mem[29][13] = 8'h1;
        
        main_mem[33][0] = 8'h88;
        main_mem[33][1] = 8'h88;
        main_mem[33][2] = 8'h88;
        main_mem[33][3] = 8'h88;
        main_mem[33][4] = 8'h77;
        main_mem[33][5] = 8'h77;
        main_mem[33][6] = 8'h77;
        main_mem[33][7] = 8'h77;
        main_mem[33][8] = 8'h66;
        main_mem[33][9] = 8'h66;
        main_mem[33][10] = 8'h66;
        main_mem[33][11] = 8'h66;
        main_mem[33][12] = 8'h55;
        main_mem[33][13] = 8'h55;
        main_mem[33][14] = 8'h55;
        main_mem[33][15] = 8'h55;

        main_mem[40][0] = 8'h8d;
        main_mem[40][1] = 8'h2;
        main_mem[40][4] = 8'h85;
        main_mem[40][5] = 8'h2;
        main_mem[40][12] = 8'h81;
        main_mem[40][13] = 8'h2;

        main_mem[48][0] = 8'h88;
        main_mem[48][1] = 8'h88;
        main_mem[48][2] = 8'h88;
        main_mem[48][3] = 8'h88;
        main_mem[48][4] = 8'h77;
        main_mem[48][5] = 8'h77;
        main_mem[48][6] = 8'h77;
        main_mem[48][7] = 8'h77;
        main_mem[48][8] = 8'h66;
        main_mem[48][9] = 8'h66;
        main_mem[48][10] = 8'h66;
        main_mem[48][11] = 8'h66;
        main_mem[48][12] = 8'h55;
        main_mem[48][13] = 8'h55;
        main_mem[48][14] = 8'h55;
        main_mem[48][15] = 8'h55;
        
        main_mem[49][0] = 8'h88;
        main_mem[49][1] = 8'h88;
        main_mem[49][2] = 8'h88;
        main_mem[49][3] = 8'h88;
        main_mem[49][4] = 8'h77;
        main_mem[49][5] = 8'h77;
        main_mem[49][6] = 8'h77;
        main_mem[49][7] = 8'h77;
        main_mem[49][8] = 8'h66;
        main_mem[49][9] = 8'h66;
        main_mem[49][10] = 8'h66;
        main_mem[49][11] = 8'h66;
        main_mem[49][12] = 8'h55;
        main_mem[49][13] = 8'h55;
        main_mem[49][14] = 8'h55;
        main_mem[49][15] = 8'h55;

        main_mem[57][0] = 8'h9d;
        main_mem[57][1] = 8'h3;
        main_mem[57][4] = 8'h95;
        main_mem[57][5] = 8'h3;
        main_mem[57][12] = 8'h91;
        main_mem[57][13] = 8'h3;

        main_mem[61][0] = 8'hdd;
        main_mem[61][1] = 8'h3;
        main_mem[61][4] = 8'hd9;
        main_mem[61][5] = 8'h3;
        main_mem[61][8] = 8'hd5;
        main_mem[61][9] = 8'h3;
        main_mem[61][12] = 8'hd1;
        main_mem[61][13] = 8'h3;
    end

    always @(*) begin
        if (read_write_mem == 0) begin // Reading operation
            i = 10086;
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