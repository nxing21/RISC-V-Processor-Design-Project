module dcache
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

    output  logic   [31:0]  load_data,
    output  logic           load_resp,
    output  logic           store_resp,
    output  logic           sb_full
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

    logic   [31:0]  sb_ufp_addr;
    logic   [3:0]   sb_ufp_rmask;
    logic   [3:0]   sb_ufp_wmask;
    logic   [31:0]  sb_ufp_wdata;


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

    dstage_1 stage_1_i (
        .rst(rst),
        .ufp_addr(sb_ufp_addr),
        .ufp_rmask(sb_ufp_rmask),
        .ufp_wmask(sb_ufp_wmask),
        .ufp_wdata(sb_ufp_wdata),
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
        .dfp_write_read(dfp_write_read)
    );

    dstage_2 stage_2_i (
        .rst(rst),
        .stage_reg(stage_reg),
        .valid_out(valid_out),
        .tag_out(tag_out),
        .data_out(data_out),
        .lru_read(lru_read),
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
        .dfp_write_read(dfp_write_read)
    );

    store_buffer store_buffer_i (
        .clk(clk),
        .rst(rst),
        .store_data(ufp_wdata),
        .store_addr(ufp_addr),
        .load_addr(ufp_addr),
        .store_mask(ufp_wmask),
        .load_mask(ufp_rmask),
        .ufp_resp(ufp_resp),
        .ufp_rdata(ufp_rdata),
        .full(sb_full),
        .load_data(load_data),
        .load_resp(load_resp),
        .store_resp(store_resp),
        .sb_ufp_addr(sb_ufp_addr),
        .sb_ufp_rmask(sb_ufp_rmask),
        .sb_ufp_wmask(sb_ufp_wmask),
        .sb_ufp_wdata(sb_ufp_wdata)
    );

    generate for (genvar i = 0; i < 4; i++) begin : arrays
        mp_cache_data_array data_array (
            .clk0       (clk),
            .csb0       ('0),
            .web0       (web_in[i]),
            .wmask0     (data_array_wmask),
            .addr0      ((read_halt || write_done) ? stage_reg.set_no : stage_reg_next.set_no),
            .din0       (data_in[i]),
            .dout0      (data_out[i])
        );
        mp_cache_tag_array tag_array (
            .clk0       (clk),
            .csb0       ('0),
            .web0       (web_in[i]),
            .addr0      ((read_halt || write_done) ? stage_reg.set_no : stage_reg_next.set_no),
            .din0       (tag_in[i]),
            .dout0      (tag_out[i])
        );
        valid_array valid_array (
            .clk0       (clk),
            .rst0       (rst),
            .csb0       ('0),
            .web0       (web_in[i]),
            .addr0      ((read_halt || write_done) ? stage_reg.set_no : stage_reg_next.set_no),
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