module stage_2
import rv32i_types::*;
(
    input   logic           clk, rst,
    input   stage_reg_t     stage_reg,
    input   logic           valid_out[4],
    input   logic   [23:0]  tag_out[4],
    input   logic   [255:0] data_out[4],
    input   logic   [2:0]   lru_read,
    // input   logic           dfp_resp,
    input   logic           dfp_resp_reg,

    output  logic   [31:0]  dfp_addr,
    output  logic           dfp_read,
    output  logic           dfp_write,
    output  logic   [255:0] dfp_wdata,

    output  logic           ufp_resp,
    output  logic   [31:0]  ufp_rdata,
    output  logic   [2:0]   lru_write,
    output  logic           lru_web,
    output  logic           read_halt,

    output  logic   [1:0]   write_way,
    output  logic           write_halt,
    input   logic           write_done_reg,
    input   logic   [1:0]   index,
    output  logic           dirty_halt,
    input   logic           dfp_switch_reg,
    input   logic           dfp_write_read,
    
    output  logic           false_resp,
    output  logic           prefetch_stall,
    input   logic           allow_prefetch,
    input   logic           prefetch_save_addr,
    output  logic           prefetch_read_halt,
    output  logic   [31:0]  prefetch_addr,
    input   logic           branch_signal,
    input   logic           full_stall,
    output  logic   [31:0]  stream_prefetch_addr,

    output  logic   [31:0]  performance_addr,
    output  logic           performance_valid
);

    logic           cache_hit;
    logic   [31:0]  rmask_ext;
    logic   [2:0]   way;

    logic           prefetch, prefetch_reg;
    logic   [31:0]  prefetch_addr_reg;
    logic           branch_signal_next, branch_signal_reg;
    logic           full_stall_next, full_stall_reg;
    logic           dfp_read_reg;

    logic   [31:0]  performance_addr_reg;

    assign  full_stall_next = full_stall;

    always_ff @(posedge clk) begin
        if (rst) begin
            prefetch_reg <= '0;
            prefetch_addr_reg <= '0;
            branch_signal_reg <= '0;
            full_stall_reg <= '0;
            dfp_read_reg <= '0;

            performance_addr_reg <= '0;

        end else begin
            prefetch_reg <= prefetch;
            prefetch_addr_reg <= prefetch_addr;
            branch_signal_reg <= branch_signal_next;
            full_stall_reg <= full_stall_next;
            dfp_read_reg <= dfp_read;

            performance_addr_reg <= performance_addr;
        end
    end

    always_comb begin
        dfp_read = '0;
        dfp_write = '0;
        ufp_rdata = '0;
        lru_write = '0;
        lru_web = '1;
        read_halt = '0;
        write_way = '0;
        write_halt = '0;
        dirty_halt = '0;
        dfp_wdata = '0;
        cache_hit = '0;
        rmask_ext = 'x;
        way = '0;

        false_resp = '0;
        prefetch_stall = '0;
        prefetch_read_halt = '0;
        prefetch_addr = '0;
        branch_signal_next = branch_signal ? '1 : branch_signal_reg;
        stream_prefetch_addr = '0;

        performance_addr = performance_addr_reg;
        performance_valid = '0;

        if (rst) begin
            dfp_addr = '0;
            ufp_resp = '0;
            prefetch = '0;

        end else begin
            dfp_addr = stage_reg.addr;
            dfp_addr[4:0] = 5'b00000;

            cache_hit = '0;
            rmask_ext = { {8{stage_reg.rmask[3]}}, {8{stage_reg.rmask[2]}}, {8{stage_reg.rmask[1]}}, {8{stage_reg.rmask[0]}} };
            way = lru_read;

            prefetch = stage_reg.prefetch ? '1 : prefetch_reg;
            prefetch_addr = prefetch_addr_reg;

            if (stage_reg.prefetch) begin
                performance_addr = stage_reg.addr;
                performance_valid = '1;
            end

            for (int i = 0; i < 4; i++) begin
                if (valid_out[i] && tag_out[i][22:0] == stage_reg.tag && !write_done_reg) begin
                    if (stage_reg.rmask != 0) begin
                        ufp_rdata = data_out[i][stage_reg.offset*8 +: 32] & rmask_ext;
                        cache_hit = '1;
                    end

                    if (stage_reg.wmask != 0) begin
                        write_halt = '1;
                        cache_hit = '1;
                    end

                    if (i == 0) begin
                        way[0] = '0;
                        way[1] = '0;
                        write_way = 2'b00;
                    end else if (i == 1) begin
                        way[0] = '0;
                        way[1] = '1;
                        write_way = 2'b01;
                    end else if (i == 2) begin
                        way[0] = '1;
                        way[2] = '0;
                        write_way = 2'b10;
                    end else begin
                        way[0] = '1;
                        way[2] = '1;
                        write_way = 2'b11;
                    end
                end
            end

            if ((stage_reg.rmask != 0 || stage_reg.wmask != 0) && !write_done_reg) begin
                if (!cache_hit) begin
                        read_halt = '1;

                        if (valid_out[index] && tag_out[index][23] == 1 && !dfp_write_read) begin
                            dfp_write = dfp_switch_reg ? '0 : '1;
                            dfp_addr[31:9] = dfp_switch_reg ? dfp_addr[31:9] : tag_out[index][22:0];
                            dfp_read = dfp_switch_reg ? '1 : '0;
                            dfp_wdata = data_out[index];
                            dirty_halt = '1;
                        
                        end else begin
                            dfp_read = dfp_resp_reg ? '0 : '1;
                        end
                    // end

                end else begin
                    lru_write = way;
                    lru_web = '0;
                end
            end 

            if (dfp_read && !dfp_read_reg && !branch_signal_reg && (!prefetch || branch_signal_next)) begin
                stream_prefetch_addr = dfp_addr;
            end

            if (allow_prefetch && (prefetch || prefetch_reg) && ((prefetch_addr_reg - 32'd4 == stage_reg.addr && !full_stall_reg) || branch_signal_reg)) begin
                read_halt = '1;
                prefetch_stall = '1;
                prefetch_read_halt = '1;
            end
            
            if (dfp_resp_reg) begin
                prefetch = '0;
                branch_signal_next = '0;
            end else if (prefetch) begin
                dfp_read = '1;

                if (prefetch_save_addr) begin
                    prefetch_addr = stage_reg.addr;
                end
            end

            ufp_resp = (stage_reg.prefetch) ? '1 : cache_hit;
            ufp_resp = (prefetch_stall) ? '0 : ufp_resp;
            false_resp = stage_reg.prefetch ? '1 : '0;
        end
    end

endmodule : stage_2