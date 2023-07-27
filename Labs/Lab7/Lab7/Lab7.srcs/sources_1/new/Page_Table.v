`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 16:17:31
// Design Name: 
// Module Name: Page_Table
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


module Page_Table(
<<<<<<< HEAD

    );
=======
    input       [5:0]   VPN_in,
    output reg  [1:0]   PPN_out,
    output reg          Page_Table_hit
);

    reg [31:0] pt[10:0];
    reg page_fault;

    initial begin
        pt[0] = {1'b1, 29'b0, 2'b01};
        pt[1] = {1'b1, 29'b0, 2'b11};
        pt[2] = {1'b0, 29'b0, 2'b10};
        pt[3] = {1'b1, 29'b0, 2'b11};
        pt[4] = {1'b1, 29'b0, 2'b10};
        pt[5] = 32'b0;
        pt[6] = 32'b0;
        pt[7] = {1'b1, 29'b0, 2'b01}; 
        pt[8] = {1'b1, 29'b0, 2'b01};
        pt[9] = 32'b0;
        pt[10] = {1'b1, 29'b0, 2'b01}; 
        PPN_out = 2'b0;
        Page_Table_hit = 0;
        page_fault = 0;
    end

    always @(VPN_in) begin
        if (pt[VPN_in][31] == 1) begin
            PPN_out = pt[VPN_in][1:0];
            Page_Table_hit = 1;
        end
        else begin
            Page_Table_hit = 0;
            page_fault = 1;
        end
        #2
        Page_Table_hit = 0;
        page_fault = 0;
    end

>>>>>>> lab7
endmodule
