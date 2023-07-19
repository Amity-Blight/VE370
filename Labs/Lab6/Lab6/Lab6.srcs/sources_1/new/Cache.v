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
    input       [127:0]  read_data_mem,
    output reg  [31:0]  read_data_cache,
    output reg          hit_miss,
    output reg          read_write_mem,
    output reg  [9:0]   address_mem,
    output reg  [127:0]  write_data_mem
);

    reg [7:0] cache_mem[3:0][15:0]; // 4 blocks in total; 4 words in a block, namely 16 bytes in a block;
    wire [3:0] Tag;
    wire [1:0] Index, word_offset, byte_offset;
    reg valid_bits[3:0];
    reg dirty_bits[3:0];
    reg [3:0] tags[3:0];
    reg d;
    integer i, j;

    initial begin
        hit_miss = 1;
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
            if (tags[Index] == Tag) begin   // Tag matches - HIT
                address_mem = {Tag, Index, 4'b0};
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
            else begin // Tag doesn't match - MISS
                hit_miss = 0;
                if (dirty_bits[Index] == 0) begin // Block not dirty
                    read_write_mem = 0;
                    address_mem = {Tag, Index, 4'b0};
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
                else begin // Block dirty
                    /* Write back */
                    read_write_mem = 1;
                    address_mem = {tags[Index], Index, 4'b0};
                    write_data_mem = {cache_mem[Index][15], cache_mem[Index][14], cache_mem[Index][13], cache_mem[Index][12],
                                    cache_mem[Index][11], cache_mem[Index][10], cache_mem[Index][9], cache_mem[Index][8],
                                    cache_mem[Index][7], cache_mem[Index][6], cache_mem[Index][5], cache_mem[Index][4],
                                    cache_mem[Index][3], cache_mem[Index][2], cache_mem[Index][1], cache_mem[Index][0]};
                    #1
                    if (Done) begin // Write back completed
                        #2
                        dirty_bits[Index] = 0;
                        read_write_mem = 0;
                        address_mem = {Tag, Index, 4'b0};
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
            end
        end
        else begin // Block invalid
            read_write_mem = 0;
            address_mem = {Tag, Index, 4'b0};
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
                valid_bits[Index] = 1;
                hit_miss = 1;
            end
        end
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
