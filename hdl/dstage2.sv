module dstage_2
import rv32i_types::*;
(
    input   logic           rst,
    input   stage_reg_t     stage_reg,
    input   logic           valid_out[4],
    input   logic   [23:0]  tag_out[4],
    input   logic   [255:0] data_out[4],
    input   logic   [2:0]   lru_read,
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
    input   logic           dfp_write_read
);

    logic           cache_hit;
    logic   [31:0]  rmask_ext;
    logic   [2:0]   way;
    // logic   [1:0]   idx;

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
        way  = '0;
        if (rst) begin
            dfp_addr = '0;
            ufp_resp = '0;

        end else begin
            dfp_addr = stage_reg.addr;
            dfp_addr[4:0] = 5'b00000;

            cache_hit = '0;
            rmask_ext = { {8{stage_reg.rmask[3]}}, {8{stage_reg.rmask[2]}}, {8{stage_reg.rmask[1]}}, {8{stage_reg.rmask[0]}} };
            way = lru_read;

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

                end else begin
                    lru_write = way;
                    lru_web = '0;
                end
            end

            ufp_resp = cache_hit;
        end
    end

endmodule : dstage_2