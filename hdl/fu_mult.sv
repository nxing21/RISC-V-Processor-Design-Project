module fu_mult
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

    logic           complete_inst, complete_prev;
    logic   [65:0]  product_inst;

    logic           flush, flush_next;

    logic   [32:0]  a_sext, a_zext, b_sext, b_zext;
    logic   [32:0]  a_final, b_final;

    decode_info_t decode_info_reg;

    assign  a_sext  =   {a[31], a};
    assign  a_zext  =   {1'b0, a};
    assign  b_sext  =   {b[31], b};
    assign  b_zext  =   {1'b0, b};

    // DW02_mult #(32, 32)
    // U1 ( .A(a), .B(b), .TC(TC), .PRODUCT(product_inst) );

    DW_mult_seq #(33,   33,   1,   3, // last input on this row is # cycles
                0,   1,   1,
                0) 
    U1 (.clk(clk),   .rst_n(~(rst)),   .hold(1'b0), 
        .start(start),   .a(a_final),   .b(b_final), 
        .complete(complete_inst),   .product(product_inst) );

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

    always_comb begin
        rd_v = '0;
        a_final = '0;
        b_final = '0;

        a = rs1_v;
        b = rs2_v;

        valid = (complete_prev) ? 1'b0 : complete_inst;

        valid = flush ? 1'b0 : valid;

        flush_next = global_branch_signal ? 1'b1 : flush;

        unique case (decode_info.funct3)
            mult_div_f3_mul : begin
                a_final = a_sext;
                b_final = b_sext;
            end
            mult_div_f3_mulh : begin
                a_final = a_sext;
                b_final = b_sext;
            end
            mult_div_f3_mulhsu : begin
                a_final = a_sext;
                b_final = b_zext;
            end
            mult_div_f3_mulhu : begin
                a_final = a_zext;
                b_final = b_zext;
            end
            mult_div_f3_div : begin

            end
            mult_div_f3_divu : begin

            end
            mult_div_f3_rem : begin

            end
            mult_div_f3_remu : begin

            end
            default : begin
                
            end
        endcase

        unique case (decode_info_reg.funct3)
            mult_div_f3_mul : begin
                rd_v = product_inst[31:0];
            end
            mult_div_f3_mulh : begin
                rd_v = product_inst[63:32];
            end
            mult_div_f3_mulhsu : begin
                rd_v = product_inst[63:32];
            end
            mult_div_f3_mulhu : begin
                rd_v = product_inst[63:32];
            end
            mult_div_f3_div : begin

            end
            mult_div_f3_divu : begin

            end
            mult_div_f3_rem : begin

            end
            mult_div_f3_remu : begin

            end
            default : begin
                
            end
        endcase
    end

endmodule : fu_mult