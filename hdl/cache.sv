module cache
import rv32i_types::*;
(
    input   logic           clk,
    input   logic           rst,

    // cpu side signals, ufp -> upward facing port
    input   logic   [31:0]  ufp_addr,
    input   logic   [3:0]   ufp_rmask,
    input   logic   [3:0]   ufp_wmask,
    output  logic   [31:0]  ufp_rdata,
    input   logic   [31:0]  ufp_wdata,
    output  logic           ufp_resp,

    // memory side signals, dfp -> downward facing port
    output  logic   [31:0]  dfp_addr,
    output  logic           dfp_read,
    output  logic           dfp_write,
    input   logic   [255:0] dfp_rdata,
    output  logic   [255:0] dfp_wdata,
    input   logic           dfp_resp,

    input   logic           allow_prefetch,
    input   logic           prefetch,
    output  logic           false_resp,
    input   logic           branch_signal,
    output  logic           prefetch_stall,
    input   logic           full_stall,
    output  logic   [31:0]  stream_prefetch_addr
);

    stage_reg_t     stage_reg;
    stage_reg_t     stage_reg_next;

    logic   [2:0]   dummy;
    logic           read_halt;
    logic           write_halt;
    logic           dirty_halt;

    logic   [1:0]   write_way;
    logic           write_done;

    logic   [2:0]   lru_read;
    logic           lru_web;
    logic   [2:0]   lru_write;

    logic           web_in[4];
    logic   [255:0] data_in[4], data_out[4];
    logic   [23:0]  tag_in[4], tag_out[4];
    logic           valid_in[4], valid_out[4];
    logic   [3:0]   array_addr[4];
    logic   [31:0]  data_array_wmask;

    logic           dfp_resp_reg;
    logic           write_done_reg;
    logic   [1:0]   index;
    logic           dfp_switch;
    logic           dfp_switch_reg;
    logic           dfp_write_read;

    // logic           prefetch_stall;
    logic           prefetch_save_addr;
    logic           prefetch_read_halt;
    logic   [31:0]  prefetch_addr;
    logic           prefetch_write;

    logic   [31:0]  performance_addr;
    logic           performance_valid;
    logic   [63:0]  performance_hits, performance_hits_reg, performance_misses, performance_misses_reg;
    logic           performance_counter, performance_counter_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            stage_reg <= '0;
            dfp_resp_reg <= '0;
            write_done_reg <= '0;
            dfp_switch_reg <= '0;
            dfp_write_read <= '0;
        end else begin
            stage_reg <= stage_reg_next;
            dfp_resp_reg <= dfp_resp;
            write_done_reg <= write_done;
            dfp_switch_reg <= dfp_switch;
            dfp_write_read <= dfp_switch_reg ? !dfp_write_read : dfp_write_read;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            performance_hits_reg <= '0;
            performance_misses_reg <= '0;
            performance_counter_reg <= '0;
        end else begin
            performance_hits_reg <= performance_hits;
            performance_misses_reg <= performance_misses;
            performance_counter_reg <= performance_counter;
        end
    end

    always_comb begin
        performance_hits = performance_hits_reg;
        performance_misses = performance_misses_reg;
        performance_counter = performance_counter_reg;

        if (performance_valid) begin
            performance_counter = '1;
        end

        if (branch_signal && performance_counter) begin
            performance_misses = performance_misses_reg + 64'd1;
            performance_counter = '0;
            
        end else if (performance_addr == ufp_addr && (ufp_rmask != '0 || ufp_wmask != '0) && performance_counter) begin
            performance_hits = performance_hits_reg + 64'd1;
            performance_counter = '0;
        end
    end 

    stage_1 stage_1_i (
        .clk(clk),
        .rst(rst),
        .ufp_addr(ufp_addr),
        .ufp_rmask(ufp_rmask),
        .ufp_wmask(ufp_wmask),
        .ufp_wdata(ufp_wdata),
        .dfp_resp(dfp_resp),
        .dfp_write(dfp_write),
        .dfp_rdata(dfp_rdata),
        .read_halt(read_halt),
        .lru_read(lru_read),
        .web(web_in),
        .data_in(data_in),
        .tag_in(tag_in),
        .valid_in(valid_in),
        .stage_reg(stage_reg),
        .stage_reg_next(stage_reg_next),
        .write_way(write_way),
        .write_done(write_done),
        .write_done_reg(write_done_reg),
        .write_halt(write_halt),
        .data_array_wmask(data_array_wmask),
        .index(index),
        .dirty_halt(dirty_halt),
        .dfp_switch(dfp_switch),
        .dfp_write_read(dfp_write_read),
        .prefetch(prefetch),
        .prefetch_stall(prefetch_stall),
        .prefetch_save_addr(prefetch_save_addr),
        .prefetch_read_halt(prefetch_read_halt),
        .prefetch_addr(prefetch_addr),
        .prefetch_write(prefetch_write),
        .branch_signal(branch_signal)
    );

    stage_2 stage_2_i (
        .clk(clk),
        .rst(rst),
        .stage_reg(stage_reg),
        .valid_out(valid_out),
        .tag_out(tag_out),
        .data_out(data_out),
        .lru_read(lru_read),
        // .dfp_resp(dfp_resp),
        .dfp_resp_reg(dfp_resp_reg),
        .dfp_addr(dfp_addr),
        .dfp_read(dfp_read),
        .dfp_write(dfp_write),
        .dfp_wdata(dfp_wdata),
        .ufp_resp(ufp_resp),
        .ufp_rdata(ufp_rdata),
        .lru_write(lru_write),
        .lru_web(lru_web),
        .read_halt(read_halt),
        .write_way(write_way),
        .write_halt(write_halt),
        .write_done_reg(write_done_reg),
        .index(index),
        .dirty_halt(dirty_halt),
        .dfp_switch_reg(dfp_switch_reg),
        .dfp_write_read(dfp_write_read),
        .false_resp(false_resp),
        .prefetch_stall(prefetch_stall),
        .allow_prefetch(allow_prefetch),
        .prefetch_save_addr(prefetch_save_addr),
        .prefetch_read_halt(prefetch_read_halt),
        .prefetch_addr(prefetch_addr),
        .branch_signal(branch_signal),
        .full_stall(full_stall),
        .stream_prefetch_addr(stream_prefetch_addr),

        .performance_addr(performance_addr),
        .performance_valid(performance_valid)
    );

    logic   [3:0]   arr_write_addr;
    always_comb begin
        if (prefetch_write) begin
            arr_write_addr = prefetch_addr[8:5];
        end else begin
            arr_write_addr = ((read_halt || write_done) ? stage_reg.set_no : stage_reg_next.set_no);
        end
    end

    generate for (genvar i = 0; i < 4; i++) begin : arrays
        mp_cache_data_array data_array (
            .clk0       (clk),
            .csb0       ('0),
            .web0       (web_in[i]),
            .wmask0     (data_array_wmask),
            .addr0      (arr_write_addr),
            .din0       (data_in[i]),
            .dout0      (data_out[i])
        );
        mp_cache_tag_array tag_array (
            .clk0       (clk),
            .csb0       ('0),
            .web0       (web_in[i]),
            .addr0      (arr_write_addr),
            .din0       (tag_in[i]),
            .dout0      (tag_out[i])
        );
        valid_array valid_array (
            .clk0       (clk),
            .rst0       (rst),
            .csb0       ('0),
            .web0       (web_in[i]),
            .addr0      (arr_write_addr),
            .din0       (valid_in[i]),
            .dout0      (valid_out[i])
        );
    end endgenerate

    lru_array lru_array (       // use port0 for reads and port1 for writes
        .clk0       (clk),
        .rst0       (rst),
        .csb0       ('0),
        .web0       ('1),
        .addr0      (stage_reg_next.set_no),
        .din0       ('0),
        .dout0      (lru_read),
        .csb1       ('0),
        .web1       (lru_web),
        .addr1      (stage_reg.set_no),
        .din1       (lru_write),
        .dout1      (dummy)
    );

endmodule