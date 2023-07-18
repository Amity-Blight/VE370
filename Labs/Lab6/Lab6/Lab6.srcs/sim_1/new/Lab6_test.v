`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/12 19:29:18
// Design Name: 
// Module Name: Lab6_test
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


module CacheTest;
    reg clock;

    parameter half_period = 5;
    integer t = 0;
    
    top test(clock);
    
    initial begin
        #0 clock = 0;
    end
    
    always #half_period begin
        clock = ~clock;
        t=t+1;
    end
    
    always @(posedge clock) begin
            $display("===============================================");
            $display("Clock cycle %d", t/2);
            $display("Read data = %H", test.read_data_cache);
            $display("hit_miss = %d", test.hit_miss);
            $display("===============================================");
    end
    initial
        #200 $stop;

endmodule
