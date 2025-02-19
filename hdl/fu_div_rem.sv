module fu_div_rem
import rv32i_types::*;
#(
    parameter PHYS_REG_BITS = 6
)
(
    input   logic           clk,
    input   logic           rst,
    input   logic   [31:0]  rs1_v, rs2_v,
    input   decode_info_t   decode_info,
    output  logic   [31:0]  rd_v,
    input   logic           start,
    output  logic           valid,
    input   logic           hold,
    input   logic           global_branch_signal
);

    logic   [31:0]  a;
    logic   [31:0]  b;

    logic   [32:0]  a_final, b_final;

    logic           complete_inst, complete_prev;
    logic   [32:0]  quotient_inst, remainder_inst;

    logic           flush, flush_next;

    decode_info_t decode_info_reg;

    logic           divide_by_0;

    always_ff @(posedge clk) begin
        if (rst) begin
            complete_prev <= 1'b0;
            decode_info_reg <= '0;
            flush <= '0;
        end else if (hold) begin
            complete_prev <= complete_inst;
            decode_info_reg <= decode_info_reg;
            flush <= flush_next;
        end else begin
            complete_prev <= complete_inst;
            decode_info_reg <= decode_info;
            flush <= '0;
        end
    end

    DW_div_seq #(
        33, 
        33,
        1, 
        NUM_DIV_CYCLES,
        0, 
        1, 
        1,    
        0
        )
    U1 (.clk(clk),
    .rst_n(~(rst)),
    .hold(1'b0),
    .start(start),
    .a(a_final),
    .b(b_final),
    .complete(complete_inst),
    .divide_by_0(divide_by_0),
    .quotient(quotient_inst),
    .remainder(remainder_inst) );

    always_comb begin
        rd_v = '0;
        a = '0;
        b = '0;
        a_final = '0;
        b_final = '0;

        valid = (complete_prev) ? 1'b0 : complete_inst;

        valid = flush ? 1'b0 : valid;

        flush_next = global_branch_signal ? 1'b1 : flush;
        a = rs1_v;
        b = rs2_v;
        unique case (decode_info.funct3)
            mult_div_f3_mul : begin
                
            end
            mult_div_f3_mulh : begin

            end
            mult_div_f3_mulhsu : begin

            end
            mult_div_f3_mulhu : begin

            end
            mult_div_f3_div : begin
                a_final = {a[31], a};
                b_final = {b[31], b};
            end
            mult_div_f3_divu : begin
                a_final = {1'b0, a};
                b_final = {1'b0, b};
            end
            mult_div_f3_rem : begin
                a_final = {a[31], a};
                b_final = {b[31], b};
            end
            mult_div_f3_remu : begin
                a_final = {1'b0, a};
                b_final = {1'b0, b};
            end
            default : begin
                
            end
        endcase

        unique case (decode_info_reg.funct3)
            mult_div_f3_mul : begin
                
            end
            mult_div_f3_mulh : begin

            end
            mult_div_f3_mulhsu : begin

            end
            mult_div_f3_mulhu : begin

            end
            mult_div_f3_div : begin
                rd_v = quotient_inst[31:0];
            end
            mult_div_f3_divu : begin
                rd_v = quotient_inst[31:0];
            end
            mult_div_f3_rem : begin
                rd_v = remainder_inst[31:0];
            end
            mult_div_f3_remu : begin
                rd_v = remainder_inst[31:0];
            end
            default : begin
                
            end
        endcase

        // if (divide_by_0 && (decode_info_reg.funct3 == mult_div_f3_div || decode_info_reg.funct3 == mult_div_f3_divu) && complete_inst) begin
        //     rd_v = '1; 
        // end
    end

endmodule : fu_div_rem