`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 16:17:31
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
    input               read_write_cache,
    input       [9:0]   address_cache,
    /*
    Tag         = address_cache[9:6]
    Index       = address_cache[5:4]
    Word Offset = address_cache[3:2]
    Byte Offset = address_cache[1:0]
    */
    input       [31:0]  write_data_cache,
    input               Done,
    input               TLB_hit,
    input       [127:0] read_data_mem,
    output reg  [31:0]  read_data_cache,
    output reg          hit_miss,
    output reg          read_write_mem,
    output reg  [9:0]   address_mem,
    output reg  [127:0] write_data_mem
);

    reg [7:0] cache_mem[3:0][15:0]; // 4 blocks in total; 4 words in a block, namely 16 bytes in a block;
    wire [4:0] Tag;
    wire [1:0] word_offset, byte_offset;
    wire set_index;
    reg valid_bits[3:0];
    reg dirty_bits[3:0];
    reg ref_bits[3:0];
    reg [4:0] tags[3:0];
    reg [1:0] Index;
    reg d;
    integer i, j;

    initial begin
        hit_miss = 0;
        for (i = 0; i < 4 ; i = i+1) begin
            for (j = 0; j < 16 ; j = j+1) begin
                cache_mem[i][j] = 8'b0;
                valid_bits[i] = 0;
                dirty_bits[i] = 0;
                ref_bits[i] = 0;
                tags[i] = 5'b0;
            end
        end
    end

    always @(*) begin
        if (valid_bits[set_index * 2] == 1 && tags[set_index * 2] == Tag) begin    // Set block 0 hit
            Index = set_index * 2;
            address_mem = {Tag, set_index, 4'b0};
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
                else begin // Byte operation
                    cache_mem[Index][word_offset * 4 + 1] = 8'b0;
                    cache_mem[Index][word_offset * 4 + 2] = 8'b0;
                    cache_mem[Index][word_offset * 4 + 3] = 8'b0;
                end
                dirty_bits[Index] = 1;
            end
            hit_miss = 1;
        end
        else if (valid_bits[set_index * 2 + 1] == 1 && tags[set_index * 2 + 1] == Tag) begin    // Set block 1 hit
            Index = set_index * 2 + 1;
            address_mem = {Tag, set_index, 4'b0};
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
                else begin // Byte operation
                    cache_mem[Index][word_offset * 4 + 1] = 8'b0;
                    cache_mem[Index][word_offset * 4 + 2] = 8'b0;
                    cache_mem[Index][word_offset * 4 + 3] = 8'b0;
                end
                dirty_bits[Index] = 1;
            end
            hit_miss = 1;
        end
        else begin // Cache miss
            hit_miss = 0;
            /* Find empty / LRU block */
            if (valid_bits[set_index * 2] == 0) Index = set_index * 2; // Set block 0 empty
            else if (valid_bits[set_index * 2 + 1] == 0) Index = set_index * 2 + 1; // Set block 1 empty
            else if (ref_bits[set_index * 2] == 0) Index = set_index * 2; // Set block 0 LRU
            else if (ref_bits[set_index * 2 + 1] == 0) Index = set_index * 2 + 1; // Set block 1 LRU
            /* Operate on the chose block */
            if (valid_bits[Index] == 1 && dirty_bits[Index] == 1) begin // Target block dirty
                /* Write back */
                read_write_mem = 1;
                address_mem = {tags[Index], set_index, 4'b0};
                write_data_mem = {cache_mem[Index][15], cache_mem[Index][14], cache_mem[Index][13], cache_mem[Index][12],
                                cache_mem[Index][11], cache_mem[Index][10], cache_mem[Index][9], cache_mem[Index][8],
                                cache_mem[Index][7], cache_mem[Index][6], cache_mem[Index][5], cache_mem[Index][4],
                                cache_mem[Index][3], cache_mem[Index][2], cache_mem[Index][1], cache_mem[Index][0]};
                #1
                if (Done) begin // Write back completed
                    #2
                    dirty_bits[Index] = 0;
                    read_write_mem = 0;
                    address_mem = {Tag, set_index, 4'b0};
                    if (Done) begin // Main mem operation completed
                        /* Read from main mem to cache */
                        cache_mem[Index][15] = read_data_mem[127:120];
                        cache_mem[Index][14] = read_data_mem[119:112];
                        cache_mem[Index][13] = read_data_mem[111:104];
                        cache_mem[Index][12] = read_data_mem[103:96];
                        cache_mem[Index][11] = read_data_mem[95:88];
                        cache_mem[Index][10] = read_data_mem[87:80];
                        cache_mem[Index][9] = read_data_mem[79:72];
                        cache_mem[Index][8] = read_data_mem[71:64];
                        cache_mem[Index][7] = read_data_mem[63:56];
                        cache_mem[Index][6] = read_data_mem[55:48];
                        cache_mem[Index][5] = read_data_mem[47:40];
                        cache_mem[Index][4] = read_data_mem[39:32];
                        cache_mem[Index][3] = read_data_mem[31:24];
                        cache_mem[Index][2] = read_data_mem[23:16];
                        cache_mem[Index][1] = read_data_mem[15:8];
                        cache_mem[Index][0] = read_data_mem[7:0];
                        tags[Index] = Tag;
                        if (read_write_cache == 0) begin // Reading operation
                            /* Read from cache */
                            if (byte_offset == 2'b0) begin // Word operation
                                read_data_cache = {cache_mem[Index][word_offset * 4 + 3],
                                                cache_mem[Index][word_offset * 4 + 2],
                                                cache_mem[Index][word_offset * 4 + 1],
                                                cache_mem[Index][word_offset * 4]};
                            end
                            else begin // Byte operation
                                read_data_cache = {24'b0, cache_mem[Index][word_offset * 4 + byte_offset]};
                            end
                        end
                        else begin // Writing operation
                            /* Write from CPU to cache */
                            cache_mem[Index][word_offset * 4 + byte_offset] = write_data_cache[7:0];
                            if (byte_offset == 2'b0) begin // Word operation
                                cache_mem[Index][word_offset * 4 + 1] = write_data_cache[15:8];
                                cache_mem[Index][word_offset * 4 + 2] = write_data_cache[23:16];
                                cache_mem[Index][word_offset * 4 + 3] = write_data_cache[31:24];
                            end
                            else begin // Byte operation
                                cache_mem[Index][word_offset * 4 + 1] = 8'b0;
                                cache_mem[Index][word_offset * 4 + 2] = 8'b0;
                                cache_mem[Index][word_offset * 4 + 3] = 8'b0;
                            end
                            dirty_bits[Index] = 1;
                        end
                        hit_miss = 1;
                    end
                end
            end
            else begin // Target block not dirty
                read_write_mem = 0;
                address_mem = {Tag, set_index, 4'b0};
                #1
                if (Done) begin // Main mem operation completed
                    /* Read from main mem to cache */
                    cache_mem[Index][15] = read_data_mem[127:120];
                    cache_mem[Index][14] = read_data_mem[119:112];
                    cache_mem[Index][13] = read_data_mem[111:104];
                    cache_mem[Index][12] = read_data_mem[103:96];
                    cache_mem[Index][11] = read_data_mem[95:88];
                    cache_mem[Index][10] = read_data_mem[87:80];
                    cache_mem[Index][9] = read_data_mem[79:72];
                    cache_mem[Index][8] = read_data_mem[71:64];
                    cache_mem[Index][7] = read_data_mem[63:56];
                    cache_mem[Index][6] = read_data_mem[55:48];
                    cache_mem[Index][5] = read_data_mem[47:40];
                    cache_mem[Index][4] = read_data_mem[39:32];
                    cache_mem[Index][3] = read_data_mem[31:24];
                    cache_mem[Index][2] = read_data_mem[23:16];
                    cache_mem[Index][1] = read_data_mem[15:8];
                    cache_mem[Index][0] = read_data_mem[7:0];
                    tags[Index] = Tag;
                    if (read_write_cache == 0) begin // Reading operation
                        /* Read from cache */
                        if (byte_offset == 2'b0) begin // Word operation
                            read_data_cache = {cache_mem[Index][word_offset * 4 + 3],
                                            cache_mem[Index][word_offset * 4 + 2],
                                            cache_mem[Index][word_offset * 4 + 1],
                                            cache_mem[Index][word_offset * 4]};
                        end
                        else begin // Byte operation
                            read_data_cache = {24'b0, cache_mem[Index][word_offset * 4 + byte_offset]};
                        end
                    end
                    else begin // Writing operation
                        /* Write from CPU to cache */
                        cache_mem[Index][word_offset * 4 + byte_offset] = write_data_cache[7:0];
                        if (byte_offset == 2'b0) begin // Word operation
                            cache_mem[Index][word_offset * 4 + 1] = write_data_cache[15:8];
                            cache_mem[Index][word_offset * 4 + 2] = write_data_cache[23:16];
                            cache_mem[Index][word_offset * 4 + 3] = write_data_cache[31:24];
                        end
                        else begin // Byte operation
                            cache_mem[Index][word_offset * 4 + 1] = 8'b0;
                            cache_mem[Index][word_offset * 4 + 2] = 8'b0;
                            cache_mem[Index][word_offset * 4 + 3] = 8'b0;
                        end
                        dirty_bits[Index] = 1;
                    end
                    hit_miss = 1;
                end
            end
            ref_bits[set_index * 2] = 0;
            ref_bits[set_index * 2 + 1] = 0;
            ref_bits[Index] = 1;
        end
        hit_miss = 1;
    end

    // always @(negedge TLB_hit) hit_miss = 0;

    assign Tag          = address_cache[9:5];
    assign set_index    = address_cache[4];
    assign word_offset  = address_cache[3:2];
    assign byte_offset  = address_cache[1:0];

    // always @(*) begin
    //     if (address_cache[1:0] == 2'b0) byte_address = address_cache[5:4] * 16 + address_cache[3:2] * 4;
    //     else byte_address = address_cache[5:4] * 16 + address_cache[3:2] * 4 + address_cache[1:0];
    // end

endmodule