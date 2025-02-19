module prefetch
import rv32i_types::*;

(
    input   logic           clk, rst,
    input   logic   [31:0]  pc,
    input   logic           dfp_read,

    output  logic           prefetch_valid,
    output  logic   [31:0]  prefetch_pc,

    input   logic           branch_signal,
    output  logic           flip_prefetch,
    input   logic   [31:0]  stream_prefetch_addr
);

    logic           dfp_read_reg;
    logic           missed, missed_reg;
    logic   [31:0]  last_addr, last_addr_reg;
    logic   [7:0]   neg_counter, neg_counter_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            dfp_read_reg <= '0;
            missed_reg <= '0;
            last_addr_reg <= '0;
            neg_counter_reg <= '0;
        end else begin
            dfp_read_reg <= dfp_read;
            missed_reg <= missed;
            last_addr_reg <= last_addr;
            neg_counter_reg <= neg_counter;
        end
    end

    always_comb begin
        last_addr = last_addr_reg;
        neg_counter = neg_counter_reg;

        if (rst) begin
            flip_prefetch = '0;

        end else begin
            if (stream_prefetch_addr != '0) begin
                if (stream_prefetch_addr < last_addr_reg) begin
                    neg_counter = neg_counter_reg + 8'd1;
                end else begin
                    neg_counter = '0;
                end

                last_addr = stream_prefetch_addr;
            end

            flip_prefetch = (neg_counter > 4);
        end
    end

    always_comb begin
        prefetch_valid = '0;
        prefetch_pc = flip_prefetch ? pc - 32'd32 : pc + 32'd32;
        prefetch_pc[4:0] = '0;

        missed = (rst) ? '0 : missed_reg;

        if (branch_signal) begin
            missed = '1;
        end

        if (dfp_read_reg && !dfp_read) begin
            if (!missed) begin
                prefetch_valid = '1;
            end
            missed = ~missed;
        end
    end

endmodule : prefetch