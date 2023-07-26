`timescale 1ns / 1ps
module vm_test;
    reg          clock;
    
    // interface between cache and CPU
    wire [9:0]   physical_address;
    wire [13:0]  virtual_address;
    wire [31:0]  write_data_cache, physical_page_tag;
    // interface between cache and main memory
    wire [31:0]  read_data_cache;
    wire [9:0]   address_mem;
    wire [5:0]   virtual_page_tag;
    wire [5:0]   request_page_tag;

    wire [127:0] read_data_mem, write_data_mem;
    wire [9:0] address_cache;
    wire [5:0] VPN;
    wire [1:0] PPN_PT;
    wire hit_miss, read_write, Done, TLB_hit, read_write_mem, Page_Table_hit;
    
    processor                     CPU(
        .hit_miss(hit_miss),
        .clock(clock),
        .read_write(read_write),
        .address(virtual_address),
        .write_data(write_data_cache)
    );
    /*
        You can only modify the following parts:
        CACHE, TLB, MAIN_MEMORY, and PAGE_TABLE
        to adapt modules you designed to this testbench
    */
    Cache        cache(
        .read_write_cache(read_write),
        .address_cache(physical_address),
        .write_data_cache(write_data_cache),
        .Done(Done),
        .TLB_hit(TLB_hit),
        .read_data_mem(read_data_mem),
        .read_data_cache(read_data_cache),
        .hit_miss(hit_miss),
        .read_write_mem(read_write_mem),
        .address_mem(address_mem),
        .write_data_mem(write_data_mem)
    );
    TLB TLB(
        .virtual_address(virtual_address),
        .PPN_in(PPN_PT),
        .Page_Table_hit(Page_Table_hit),
        .VPN_out(VPN),
        .physical_address(physical_address),
        .TLB_hit(TLB_hit)
    );
    Main_Memory                      memory(
        .read_write_mem(read_write_mem),
        .address_mem(address_mem),
        .write_data_mem(write_data_mem),
        .read_data_mem(read_data_mem),
        .Done(Done)
    );
    Page_Table                    PT(
        .VPN_in(VPN),
        .PPN_out(PPN_PT),
        .Page_Table_hit(Page_Table_hit)
    );

    /*
        Do not modify the following code!!!
    */
    always #5 clock = ~clock;

    always @(posedge clock) begin
        $display("Request %d: ", CPU.request_num);
        $display("page fault: %b", PT.page_fault);
        $display("data read posedge: %H", read_data_cache);
        $display("contents in TLB: ");
        $display("block 00: tag: %2d, valid: %b, reference: %b, VPN: %1d", TLB.tags[0], TLB.valid_bits[0], TLB.ref_bits[0], TLB.ppn[0]);
        $display("block 01: tag: %2d, valid: %b, reference: %b, VPN: %1d", TLB.tags[1], TLB.valid_bits[1], TLB.ref_bits[1], TLB.ppn[1]);
        $display("block 10: tag: %2d, valid: %b, reference: %b, VPN: %1d", TLB.tags[2], TLB.valid_bits[2], TLB.ref_bits[2], TLB.ppn[2]);
        $display("block 11: tag: %2d, valid: %b, reference: %b, VPN: %1d", TLB.tags[3], TLB.valid_bits[3], TLB.ref_bits[3], TLB.ppn[3]);
        $display("contents in cache: ");
        $display("block 00: tag: %b, valid: %b, dirty: %b, word0: %H, word1: %H, word2: %H, word3: %H", cache.tags[0], cache.valid_bits[0], cache.dirty_bits[0], {cache.cache_mem[0][3], cache.cache_mem[0][2], cache.cache_mem[0][1], cache.cache_mem[0][0]}, {cache.cache_mem[0][7], cache.cache_mem[0][6], cache.cache_mem[0][5], cache.cache_mem[0][4]}, {cache.cache_mem[0][11], cache.cache_mem[0][10], cache.cache_mem[0][9], cache.cache_mem[0][8]}, {cache.cache_mem[0][15], cache.cache_mem[0][14], cache.cache_mem[0][13], cache.cache_mem[0][12]});
        $display("block 01: tag: %b, valid: %b, dirty: %b, word0: %H, word1: %H, word2: %H, word3: %H", cache.tags[1], cache.valid_bits[1], cache.dirty_bits[1], {cache.cache_mem[1][3], cache.cache_mem[1][2], cache.cache_mem[1][1], cache.cache_mem[1][0]}, {cache.cache_mem[1][7], cache.cache_mem[1][6], cache.cache_mem[1][5], cache.cache_mem[1][4]}, {cache.cache_mem[1][11], cache.cache_mem[1][10], cache.cache_mem[1][9], cache.cache_mem[1][8]}, {cache.cache_mem[1][15], cache.cache_mem[1][14], cache.cache_mem[1][13], cache.cache_mem[1][12]});
        $display("block 10: tag: %b, valid: %b, dirty: %b, word0: %H, word1: %H, word2: %H, word3: %H", cache.tags[2], cache.valid_bits[2], cache.dirty_bits[2], {cache.cache_mem[2][3], cache.cache_mem[2][2], cache.cache_mem[2][1], cache.cache_mem[2][0]}, {cache.cache_mem[2][7], cache.cache_mem[2][6], cache.cache_mem[2][5], cache.cache_mem[2][4]}, {cache.cache_mem[2][11], cache.cache_mem[2][10], cache.cache_mem[2][9], cache.cache_mem[2][8]}, {cache.cache_mem[2][15], cache.cache_mem[2][14], cache.cache_mem[2][13], cache.cache_mem[2][12]});
        $display("block 11: tag: %b, valid: %b, dirty: %b, word0: %H, word1: %H, word2: %H, word3: %H", cache.tags[3], cache.valid_bits[3], cache.dirty_bits[3], {cache.cache_mem[3][3], cache.cache_mem[3][2], cache.cache_mem[3][1], cache.cache_mem[3][0]}, {cache.cache_mem[3][7], cache.cache_mem[3][6], cache.cache_mem[3][5], cache.cache_mem[3][4]}, {cache.cache_mem[3][11], cache.cache_mem[3][10], cache.cache_mem[3][9], cache.cache_mem[3][8]}, {cache.cache_mem[3][15], cache.cache_mem[3][14], cache.cache_mem[3][13], cache.cache_mem[3][12]});
    end
    
    initial begin
        clock = 0;
        #160 $stop;
    end
endmodule
/*
    Do not modify the following code!!!
*/
module processor (
    input  hit_miss,
    input  clock,
    output read_write,
    output [13:0] address,
    output [31:0] write_data
);
    parameter  request_total = 14; // change this number to how many requests you want in your testbench
    reg [4:0]  request_num;
    reg        read_write_test[request_total-1:0];
    reg [13:0]  address_test[request_total-1:0];
    reg [31:0] write_data_test[request_total-1:0]; 
    initial begin
        #10 request_num = 0;
        read_write_test[0]  = 1; address_test[0]  = 14'b000100_100_0_1000; write_data_test[0]  = 1;       // sw, virtual page  4, TLB miss, mapped to physical page 2, physical tag 10100, cache miss in set 0 block 0,
        read_write_test[1]  = 1; address_test[1]  = 14'b000000_100_1_1100; write_data_test[1]  = 12'hdac; // sw, virtual page  0, TLB miss, mapped to physical page 1, physical tag 01100, cache miss in set 1 block 0,
        read_write_test[2]  = 1; address_test[2]  = 14'b000001_100_1_1000; write_data_test[2]  = 12'hfac; // sw, virtual page  1, TLB miss, mapped to physical page 3, physical tag 11100, cache miss in set 1 block 1,
        read_write_test[3]  = 1; address_test[3]  = 14'b000000_100_1_0101; write_data_test[3]  = 12'hfac; // sb, virtual page  0, TLB hit,  mapped to physical page 1, physical tag 01100, cache hit  in set 1 block 0,
        read_write_test[4]  = 0; address_test[4]  = 14'b000111_100_1_0101; write_data_test[4]  = 0;       // lb, virtual page  7, TLB miss, mapped to physical page 1, physical tag 01100, cache hit  in set 1 block 0,
        read_write_test[5]  = 0; address_test[5]  = 14'b001000_110_1_0101; write_data_test[5]  = 0;       // lb, virtual page  8, TLB miss, mapped to physical page 1, virtual page 4 replaced, write back entry with virtual tag 4,
                                                                                                          //                                                           physical tag 01110, cache miss in set 1, set 1 block 1 replaced and write back
        read_write_test[6]  = 0; address_test[6]  = 14'b000001_110_1_0100; write_data_test[6]  = 0;       // lw, virtual page  1, TLB hit,  mapped to physical page 3, physical tag 11110, cache miss in set 1, set 1 block 0 replaced and write back
        read_write_test[7]  = 1; address_test[7]  = 14'b000111_100_1_0111; write_data_test[7]  = 12'h148; // sb, virtual page  7, TLB hit,  mapped to physical page 1, physical tag 01100, cache miss in set 1, set 1 block 1 replaced
        read_write_test[8]  = 0; address_test[8]  = 14'b000000_100_1_1000; write_data_test[8]  = 0;       // lw, virtual page  0, TLB hit,  mapped to physical page 1, physical tag 01100, cache hit  in set 1 block 1,
        read_write_test[9]  = 0; address_test[9]  = 14'b001010_100_1_0100; write_data_test[9]  = 0;       // lw, virtual page 10, TLB miss, mapped to physical page 1, virtual page 8 replaced, write back entry with virtual tag 8,
                                                                                                          //                                                           physical tag 01100, cache hit  in set 1 block 1,
        read_write_test[10] = 0; address_test[10] = 14'b000000_110_1_0100; write_data_test[10] = 0;       // lw, virtual page  0, TLB hit,  mapped to physical page 1, physical tag 01110, cache miss in set 1, set 1 block 1 replaced
        read_write_test[11] = 0; address_test[11] = 14'b000100_100_0_1000; write_data_test[11] = 0;       // lw, virtual page  4, TLB miss, mapped to physical page 2, virtual page 1 replaced, write back entry with virtual tag 1,
                                                                                                          //                                                           physical tag 10100, cache hit  in set 1 block 0
        read_write_test[12] = 0; address_test[12] = 14'b000010_110_1_0100; write_data_test[12] = 0;       // lw, virtual page  2, TLB miss, page fault

        /* extra test for fun; it is acceptable that you have different result after the request below */
        read_write_test[13] = 0; address_test[13] = 14'b000111_100_1_1100; write_data_test[13] = 0;       // lw, virtual page  10, TLB hit, mapped to physical page 1, physcial tag 01100, cache hit in set 1 block 1
        // Notes: actually in this lab you are not required to handle page fault, but ideally you may just skip the request with page fault and deal with the next request normally (it only applies to this lab!!!)
        // In other words, nothing should be changed when there is a page fault in this lab, including TLB, page table, cache and memory.
        // But such requirement is cancelled considering your workload :)
    end
    always @(posedge clock) begin
        if (hit_miss == 1) request_num = request_num + 1;
        else request_num = request_num;
    end
    assign address      = address_test[request_num];
    assign read_write   = read_write_test[request_num];
    assign write_data   = write_data_test[request_num]; 
endmodule