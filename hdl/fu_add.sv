module fu_add
import rv32i_types::*;
#(
    parameter PHYS_REG_BITS = 6
)
(
    input   logic   [31:0]  rs1_v, rs2_v,
    input   decode_info_t   decode_info,
    output  logic   [31:0]  rd_v,
    input   logic           start,
    output  logic           valid,
    output  logic           busy
);

    logic signed   [31:0] as;
    logic signed   [31:0] bs;
    logic unsigned [31:0] au;
    logic unsigned [31:0] bu;

    logic   [31:0]  a;
    logic   [31:0]  b;

    logic   [2:0]   aluop;
    logic   [2:0]   cmpop;

    logic   [31:0]  aluout;
    logic           br_en;

    assign as =   signed'(a);
    assign bs =   signed'(b);
    assign au = unsigned'(a);
    assign bu = unsigned'(b);

    always_comb begin
        unique case (aluop)
            alu_op_add: aluout = au +   bu;
            alu_op_sll: aluout = au <<  bu[4:0];
            alu_op_sra: aluout = unsigned'(as >>> bu[4:0]);
            alu_op_sub: aluout = au -   bu;
            alu_op_xor: aluout = au ^   bu;
            alu_op_srl: aluout = au >>  bu[4:0];
            alu_op_or : aluout = au |   bu;
            alu_op_and: aluout = au &   bu;
            default   : aluout = 'x;
        endcase
    end

    always_comb begin
        unique case (cmpop)
            branch_f3_beq : br_en = (au == bu);
            branch_f3_bne : br_en = (au != bu);
            branch_f3_blt : br_en = (as <  bs);
            branch_f3_bge : br_en = (as >=  bs);
            branch_f3_bltu: br_en = (au <  bu);
            branch_f3_bgeu: br_en = (au >=  bu);
            default       : br_en = 1'bx;
        endcase
    end

    always_comb begin
        rd_v = '0;
        a = '0;
        b = '0;
        cmpop = '0;
        aluop = '0;
        valid = 1'b0;
        busy = 1'b0;
        if (start) begin
            valid = 1'b1;
            busy = 1'b1;
            unique case (decode_info.opcode)
                op_b_imm : begin
                    a = rs1_v;
                    b = decode_info.i_imm;
                    unique case (decode_info.funct3)
                        arith_f3_slt: begin
                            cmpop = branch_f3_blt;
                            rd_v = {31'd0, br_en};
                        end
                        arith_f3_sltu: begin
                            cmpop = branch_f3_bltu;
                            rd_v = {31'd0, br_en};
                        end
                        arith_f3_sr: begin
                            if (decode_info.funct7[5]) begin
                                aluop = alu_op_sra;
                            end else begin
                                aluop = alu_op_srl;
                            end
                            rd_v = aluout;
                        end
                        default: begin
                            aluop = decode_info.funct3;
                            rd_v = aluout;
                        end
                    endcase
                end
                op_b_reg : begin
                    a = rs1_v;
                    b = rs2_v;
                    unique case (decode_info.funct3)
                        arith_f3_slt: begin
                            cmpop = branch_f3_blt;
                            rd_v = {31'd0, br_en};
                        end
                        arith_f3_sltu: begin
                            cmpop = branch_f3_bltu;
                            rd_v = {31'd0, br_en};
                        end
                        arith_f3_sr: begin
                            if (decode_info.funct7[5]) begin
                                aluop = alu_op_sra;
                            end else begin
                                aluop = alu_op_srl;
                            end
                            rd_v = aluout;
                        end
                        arith_f3_add: begin
                            if (decode_info.funct7[5]) begin
                                aluop = alu_op_sub;
                            end else begin
                                aluop = alu_op_add;
                            end
                            rd_v = aluout;
                        end
                        default: begin
                            aluop = decode_info.funct3;
                            rd_v = aluout;
                        end
                    endcase
                end
                op_b_lui : begin
                    a = '0;
                    b = '0;
                    rd_v = decode_info.u_imm;
                end
                op_b_auipc : 
                begin
                    a = '0;
                    b = '0;
                    rd_v = decode_info.pc + decode_info.u_imm;
                end

                default : begin
                    // do nothing
                end
            endcase
        end
        
    end

endmodule : fu_add
