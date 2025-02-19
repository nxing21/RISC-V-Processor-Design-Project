module cacheline_adapter
import rv32i_types::*;
(
    input   logic               clk,
    input   logic               rst,

    input   logic   [63:0]      bmem_rdata,
    input   logic               bmem_rvalid,
    input   logic   [255:0]     full_burst,
    input   logic               mem_valid,
    output  logic   [255:0]     cache_wdata,
    output  logic               cache_valid,
    output  logic               d_cache_valid,
    output  logic   [63:0]      bmem_wdata,
    output  logic               bmem_write
);

    enum int unsigned {
        start,
        one, 
        two,
        three
    } state, state_next;

    logic   [255:0] cache_wdata_reg;
    logic   [255:0] cache_wdata_next;
    logic   [1:0]   burst_num, burst_num_reg;

    logic   [255:0] mem_wdata_reg, mem_wdata_next;

    always_ff @(posedge clk) begin
        if (rst) begin
            burst_num_reg <= '0;
            cache_wdata_reg <= '0;
            state <= start;
            mem_wdata_reg <= '0;
        end else begin
            burst_num_reg <= burst_num;
            cache_wdata_reg <= cache_wdata;
            state <= state_next;
            mem_wdata_reg <= mem_wdata_next;
        end
    end

    always_comb begin
        state_next = start;
        mem_wdata_next = mem_wdata_reg;
        bmem_write = 1'b1;
        bmem_wdata = '0;
        d_cache_valid = '0;

        case (state)
            start:
            begin
                if (mem_valid) begin
                    state_next = one;
                    mem_wdata_next = full_burst;
                    bmem_wdata = full_burst[63:0];
                    bmem_write = 1'b1;
                end else begin
                    state_next = start;
                    mem_wdata_next = '0;
                    bmem_wdata = '0;
                    bmem_write = 1'b0;
                end
            end

            one:
            begin
                state_next = two;
                mem_wdata_next = mem_wdata_reg;
                bmem_wdata = mem_wdata_reg[127:64];
                bmem_write = 1'b1;
            end

            two:
            begin
                state_next = three;
                mem_wdata_next = mem_wdata_reg;
                bmem_wdata = mem_wdata_reg[191:128];
                bmem_write = 1'b1;
            end
            
            three:
            begin
                state_next = start;
                mem_wdata_next = mem_wdata_reg;
                bmem_wdata = mem_wdata_reg[255:192];
                bmem_write = 1'b1;
                d_cache_valid = '1;
            end
        endcase    
    end

    always_comb begin
        if (rst || !bmem_rvalid) begin
            cache_wdata = '0;
            cache_valid = '0;
            burst_num = '0;

        end else begin
            cache_wdata = cache_wdata_reg;
            cache_wdata[burst_num_reg * 64 +: 64] = bmem_rdata;
            burst_num = burst_num_reg + 2'b01;

            cache_valid = (burst_num_reg == 3) ? '1 : '0;
        end
    end

endmodule : cacheline_adapter
