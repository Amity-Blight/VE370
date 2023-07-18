`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/12 19:25:50
// Design Name: 
// Module Name: Cache
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


module Cache(
    input           read_write_cache,
    input   [9:0]   address_cache,
    /*
    Tag         = address_cache[9:6]
    Index       = address_cache[5:4]
    Word Offset = address_cache[3:2]
    Byte Offset = address_cache[1:0]
    */
    input   [31:0]  write_data_cache,
    input           Done,
    input   [31:0]  read_data_mem,
    output  [31:0]  read_data_cache,
    output          hit_miss,
    output          read_write_mem,
    output  [9:0]   address_mem,
    output  [31:0]  write_data_mem
);

    reg [7:0] cache_mem[3:0][15:0];
    reg [3:0] Tag;
    reg [1:0] Index, word_offset, byte_offset;
    reg valid_bits[3:0];
    reg dirty_bits[3:0];
    reg [3:0] tags[3:0];
    reg d;
    integer i, j;

    initial begin
        for (i = 0; i < 4 ; i = i+1) begin
            for (j = 0; j < 16 ; j = j+1) begin
                cache_mem[i][j] = 8'b0;
                valid_bits[i] = 0;
                dirty_bits[i] = 0;
                tags[i] = 4'b0;
            end
        end
    end

    always @(*) begin
        if (valid_bits[Index] == 1) begin    // Block valid
            if (tags[Index] == Tag) begin   // Tag matches - hit
                if (read_write_cache == 0) begin    // Reading operation
                    if (byte_offset == 2'b0) begin // Word operation
                        read_data_cache = {cache_mem[Index][word_offset * 4 + 3],
                                           cache_mem[Index][word_offset * 4 + 2],
                                           cache_mem[Index][word_offset * 4 + 1],
                                           cache_mem[Index][word_offset * 4]};
                    end
                    else begin  // Byte operation
                        read_data_cache = {24'b0, cache_mem[Index][word_offset * 4 + byte_offset]};
                    end
                end
                else begin  // Writing operation
                    cache_mem[Index][word_offset * 4 + byte_offset] = write_data_cache[7:0];
                    if (byte_offset == 2'b0) begin // Word operation
                        cache_mem[Index][word_offset * 4 + 1] = write_data_cache[15:8];
                        cache_mem[Index][word_offset * 4 + 2] = write_data_cache[23:16];
                        cache_mem[Index][word_offset * 4 + 3] = write_data_cache[31:24];
                    end
                end
                hit_miss = 1;
            end
            else begin // Tag doesn't match - miss
                hit_miss = 0;
                if (dirty_bits[Index] == 0) begin // Block not dirty
                    read_write_mem = read_write_cache;
                    address_mem = address_cache;
                    if (read_write_cache == 0) begin // Reading operation
                        if (d) begin // Main mem operation completed
                            /* Write from main mem to cache */
                            cache_mem[Index][word_offset * 4]       =   read_data_mem[7:0];
                            cache_mem[Index][word_offset * 4 + 1]   =   read_data_mem[15:8];
                            cache_mem[Index][word_offset * 4 + 2]   =   read_data_mem[23:16];
                            cache_mem[Index][word_offset * 4 + 3]   =   read_data_mem[31:24];
                            read_data_cache = read_data_mem; // Read from main mem
                            hit_miss = 1;
                            d = 0;
                        end
                    end
                    else begin // Writing operation
                        cache_mem[Index][word_offset * 4 + byte_offset] = write_data_cache[7:0];
                        write_data_mem = {24'b0, write_data_cache[7:0]};
                        if (byte_offset == 2'b0) begin // Word operation
                            cache_mem[Index][word_offset * 4 + 1] = write_data_cache[15:8];
                            cache_mem[Index][word_offset * 4 + 2] = write_data_cache[23:16];
                            cache_mem[Index][word_offset * 4 + 3] = write_data_cache[31:24];
                            write_data_mem = write_data_cache;
                        end
                        if (d) begin // Main mem operation completed
                            hit_miss = 1;
                        end
                    end
                end
            end
        end
        else begin
        end
    end

    always @(posedge Done) begin
        d <= 1;
    end

    assign Tag         = address_cache[9:6];
    assign Index       = address_cache[5:4];
    assign word_offset = address_cache[3:2];
    assign byte_offset = address_cache[1:0];

    // always @(*) begin
    //     if (address_cache[1:0] == 2'b0) byte_address = address_cache[5:4] * 16 + address_cache[3:2] * 4;
    //     else byte_address = address_cache[5:4] * 16 + address_cache[3:2] * 4 + address_cache[1:0];
    // end

endmodule
