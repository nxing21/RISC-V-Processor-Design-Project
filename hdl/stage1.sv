module stage_1
import rv32i_types::*;
(
    input   logic           clk, rst,
    input   logic   [31:0]  ufp_addr,
    input   logic   [3:0]   ufp_rmask,
    input   logic   [3:0]   ufp_wmask,
    // output  logic   [31:0]  ufp_rdata,
    input   logic   [31:0]  ufp_wdata,
    // output  logic           ufp_resp,

    // output  logic   [31:0]  dfp_addr,
    // output  logic           dfp_read,
    input   logic           dfp_write,
    input   logic   [255:0] dfp_rdata,
    // output  logic   [255:0] dfp_wdata,
    input   logic           dfp_resp,

    input   logic           read_halt,
    input   logic   [2:0]   lru_read,
    output  logic           web[4],
    output  logic   [255:0] data_in[4],
    output  logic   [23:0]  tag_in[4],
    output  logic           valid_in[4],
    
    input   stage_reg_t     stage_reg,
    output  stage_reg_t     stage_reg_next,

    input   logic   [1:0]   write_way,
    output  logic           write_done,
    input   logic           write_done_reg,
    input   logic           write_halt,
    output  logic   [31:0]  data_array_wmask,
    output  logic   [1:0]   index,
    input   logic           dirty_halt,
    output  logic           dfp_switch,
    input   logic           dfp_write_read,

    input   logic           prefetch,
    input   logic           prefetch_stall,
    output  logic           prefetch_save_addr,
    input   logic           prefetch_read_halt,
    input   logic   [31:0]  prefetch_addr,
    output  logic           prefetch_write,
    input   logic           branch_signal
);

    // logic   [1:0]   index;
    logic           prefetch_next;

    always_ff @(posedge clk) begin
        if (rst) begin
            prefetch_save_addr <= '0;
        end else begin
            prefetch_save_addr <= prefetch_next;
        end
    end
    
    always_comb begin
        write_done = '0;
        data_array_wmask = '1;
        dfp_switch = '0;
        prefetch_next = '0;
        prefetch_write = '0;
        
        for (int i = 0; i < 4; i++) begin
            web[i] = '1;
            data_in[i] = '0;
            tag_in[i] = '0;
            valid_in[i] = '0;
        end

        if (rst) begin
            stage_reg_next = '0;
            index = 2'b00;

        end else begin
            if (lru_read[0]) begin
                if (lru_read[1]) begin
                    index = 2'b00;
                end else begin
                    index = 2'b01;
                end
            end else begin
                if (lru_read[2]) begin
                    index = 2'b10;
                end else begin
                    index = 2'b11;
                end
            end
            stage_reg_next = stage_reg;

            if ((dfp_write_read || dfp_write) && dfp_resp) begin
                dfp_switch = '1;
            end

            if (write_halt) begin
                web[write_way] = '0;
                data_in[write_way][8*stage_reg.offset +: 32] = stage_reg.wdata & { {8{stage_reg.wmask[3]}}, {8{stage_reg.wmask[2]}}, {8{stage_reg.wmask[1]}}, {8{stage_reg.wmask[0]}} };
                tag_in[write_way] = {1'b1, stage_reg.tag};
                valid_in[write_way] = '1;
                write_done = '1;
                data_array_wmask = '0;
                data_array_wmask[stage_reg.offset +: 4] = stage_reg.wmask;
            end
            
            if (read_halt) begin
                if (dfp_resp && !dirty_halt) begin
                    if (prefetch_read_halt) begin
                        web[index] = '0;
                        data_in[index] = dfp_rdata;
                        tag_in[index] = {1'b0, prefetch_addr[31:9]};
                        valid_in[index] = '1;
                        prefetch_write = '1;
                    end else begin
                        web[index] = '0;
                        data_in[index] = dfp_rdata;
                        tag_in[index] = {1'b0, stage_reg.tag};
                        valid_in[index] = '1;
                    end
                end
                
            end else begin
                if ((write_done_reg == 1 && (stage_reg.rmask != 0 || stage_reg.wmask != 0)) || prefetch_stall) begin
                    // stall for one cycle
                end else begin
                    stage_reg_next.addr = ufp_addr;
                    stage_reg_next.tag = ufp_addr[31:9];
                    stage_reg_next.set_no = ufp_addr[8:5];
                    stage_reg_next.offset = ufp_addr[4:0];
                    stage_reg_next.rmask = ufp_rmask;
                    stage_reg_next.wmask = ufp_wmask;
                    stage_reg_next.wdata = ufp_wdata;
                    stage_reg_next.prefetch = branch_signal ? '0 : prefetch;

                    prefetch_next = prefetch;
                end
            end
        end
    end

endmodule : stage_1