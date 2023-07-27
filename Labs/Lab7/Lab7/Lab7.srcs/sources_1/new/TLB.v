`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 16:17:31
// Design Name: 
// Module Name: TLB
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


module TLB(
    input       [13:0]  virtual_address,
    input       [1:0]   PPN_in,
    input               Page_Table_hit,
    output reg  [5:0]   VPN_out,
    output reg  [9:0]   physical_address,
    output reg          TLB_hit,
    output reg          Page_Fault
);

    reg valid_bits[3:0];
    reg [1:0] ref_bits[3:0];
    reg [5:0] tags[3:0];
    reg [1:0] ppn[3:0];
    reg [1:0] PPN_out;
    reg [1:0] ref;
    wire [5:0] VPN_in;
    integer i,j;

    assign VPN_in = virtual_address[13:8];

    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            valid_bits[i] <= 0;
            ref_bits[i] <= 0;
            tags[i] <= 0;
            ppn[i] <= 0;
        end
        TLB_hit <= 0;
        Page_Fault <= 0;
        ref <= 2'b11;
    end

    always @(VPN_in) begin
        TLB_hit = 0;
        /* Search in TLB */
        j = 4;
        for (i = 0; i < 4; i = i + 1) begin
            if (valid_bits[i] == 1 && tags[i] == VPN_in) j = i;
        end
        if (j != 4) begin // TLB hit
            PPN_out = ppn[j];
            physical_address = {PPN_out, virtual_address[7:0]};
            Page_Fault = 0;
            TLB_hit = 1;
        end
        else begin //TLB miss
            TLB_hit = 0;
            VPN_out = VPN_in;
            #1
            if (Page_Table_hit) begin // Page Table hit
                Page_Fault = 0;
                /* Search for LRU entry */
                if (valid_bits[0] == 0) j = 0;
                else if (valid_bits[1] == 0) j = 1;
                else if (valid_bits[2] == 0) j = 2;
                else if (valid_bits[3] == 0) j = 3;
                else begin
                    if (ref_bits[0] == 2'b0) j = 0;
                    else if (ref_bits[1] == 2'b0) j = 1;
                    else if (ref_bits[2] == 2'b0) j = 2;
                    else if (ref_bits[3] == 2'b0) j = 3;
                    else begin
                        for (i = 0; i < 4; i = i + 1) begin
                            if (ref_bits[i] < ref) begin // find LRU entry
                                ref = ref_bits[i];
                                j = i;
                            end
                        end
                    end
                end
                /* Update the j entry */
                valid_bits[j] = 1;
                tags[j] = VPN_in;
                ppn[j] = PPN_in;
                ref = 2'b11;
                /* Update ref bits */
                for (i = 0; i < 4; i = i + 1) begin
                    if (i == j) ref_bits[i] = 2'b11;
                    else begin
                        if (ref_bits[i] != 2'b00) ref_bits[i] = ref_bits[i] - 1;
                    end
                end
                /* Output */
                PPN_out = ppn[j];
                physical_address = {PPN_out, virtual_address[7:0]};
                TLB_hit = 1;
            end
            else begin // Page Fault
                Page_Fault = 1;
            end
        end
    end

endmodule