module phys_regfile
import rv32i_types::*;
#(
    parameter PHYS_REG_BITS = 6
)
(
    input   logic           clk,
    input   logic           rst,
    input   logic           regf_we_add, regf_we_mul, regf_we_div, regf_we_mem, regf_we_br,
    input   logic   [31:0]  rd_v_add, rd_v_mul, rd_v_div, rd_v_mem, rd_v_br,
    input   logic   [PHYS_REG_BITS-1:0]   rs1_add, rs2_add, rs1_mul, rs2_mul, rs1_div, rs2_div, rs1_mem, rs2_mem, rs1_br, rs2_br, rd_add, rd_mul, rd_div, rd_mem, rd_br,
    output  logic   [31:0]  rs1_v_add, rs2_v_add, rs1_v_mul, rs2_v_mul, rs1_v_div, rs2_v_div, rs1_v_mem, rs2_v_mem, rs1_v_br, rs2_v_br,
    input   logic   [ARCH_REG_BITS - 1:0]   arch_s1_add, arch_s2_add,
    input   logic   [ARCH_REG_BITS - 1:0]   arch_s1_br, arch_s2_br,
    input   logic   [ARCH_REG_BITS - 1:0]   arch_s1_mem, arch_s2_mem,
    input   logic   [ARCH_REG_BITS - 1:0]   arch_rd_add, arch_rd_mul, arch_rd_div, arch_rd_br, arch_rd_mem
);

    logic   [31:0]  data [2**PHYS_REG_BITS];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                data[i] <= '0;
            end
        end
        
        if (!rst && (regf_we_add && (rd_add != 0))) begin
            data[rd_add] <= (arch_rd_add != 0) ? rd_v_add : '0;
        end

        if (!rst && (regf_we_mul && (rd_mul != 0))) begin
            data[rd_mul] <= (arch_rd_mul != 0) ? rd_v_mul : '0;
        end

        if (!rst && (regf_we_mem && (rd_mem != 0))) begin
            data[rd_mem] <= (arch_rd_mem != 0) ? rd_v_mem : '0;
        end

        if (!rst && (regf_we_div && (rd_div != 0))) begin
            data[rd_div] <= (arch_rd_div != 0) ? rd_v_div : '0;
        end

        if (!rst && (regf_we_br && (rd_br != 0))) begin
            data[rd_br] <= (arch_rd_br != 0) ? rd_v_br : '0;
        end
    end

    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         rs1_v <= 'x;
    //         rs2_v <= 'x;
    //     end else begin
    //         rs1_v <= (rs1_s != 5'd0) ? data[rs1_s] : '0;
    //         rs2_v <= (rs2_s != 5'd0) ? data[rs2_s] : '0;
    //     end
    // end

    logic   [5:0]   rs1_mul_1, rs1_mul_2, rs1_mul_3, rs1_mul_4;
    logic   [5:0]   rs2_mul_1, rs2_mul_2, rs2_mul_3, rs2_mul_4;


    logic [5:0] rs1_divs [NUM_DIV_CYCLES + 1];
    logic [5:0] rs2_divs [NUM_DIV_CYCLES + 1];

    logic   [5:0]   rs1_div_1, rs1_div_2, rs1_div_3, rs1_div_4;
    logic   [5:0]   rs2_div_1, rs2_div_2, rs2_div_3, rs2_div_4;

    always_ff @(posedge clk) begin
        if (rst) begin
            rs1_mul_1 <= '0;
            rs1_mul_2 <= '0;
            rs1_mul_3 <= '0;
            rs1_mul_4 <= '0;
            rs2_mul_1 <= '0;
            rs2_mul_2 <= '0;
            rs2_mul_3 <= '0;
            rs2_mul_4 <= '0;


            for (int i = 0; i <= NUM_DIV_CYCLES; i++)
            begin
                rs1_divs[i] <= '0;
                rs2_divs[i] <= '0;
            end
            // rs1_div_1 <= '0;
            // rs1_div_2 <= '0;
            // rs1_div_3 <= '0;
            // rs1_div_4 <= '0;
            // rs2_div_1 <= '0;
            // rs2_div_2 <= '0;
            // rs2_div_3 <= '0;
            // rs2_mul_4 <= '0;
        end else begin
            rs1_mul_1 <= rs1_mul;
            rs1_mul_2 <= rs1_mul_1;
            rs1_mul_3 <= rs1_mul_2;
            rs1_mul_4 <= rs1_mul_3;
            rs2_mul_1 <= rs2_mul;
            rs2_mul_2 <= rs2_mul_1;
            rs2_mul_3 <= rs2_mul_2;
            rs2_mul_4 <= rs2_mul_3;

            rs1_divs[0] <= rs1_div;
            rs2_divs[0] <= rs2_div;
            for (int i = 1; i <= NUM_DIV_CYCLES; i++)
            begin
                rs1_divs[i] <= rs1_divs[i - 1];
                rs2_divs[i] <= rs2_divs[i - 1];
            end

            // rs1_div_1 <= rs1_div;
            // rs1_div_2 <= rs1_div_1;
            // rs1_div_3 <= rs1_div_2;
            // rs1_div_4 <= rs1_div_3;
            // rs2_div_1 <= rs2_div;
            // rs2_div_2 <= rs2_div_1;
            // rs2_div_3 <= rs2_div_2;
            // rs2_div_4 <= rs2_div_3;
        end
    end

    logic   [5:0]   rs1_mul_f1, rs2_mul_f2;
    logic   [5:0]   rs1_div_f1, rs2_div_f2;

    always_comb begin
        rs1_mul_f1 = rst ? '0 : rs1_mul | rs1_mul_1 | rs1_mul_2 | rs1_mul_3 | rs1_mul_4;
        rs2_mul_f2 = rst ? '0 : rs2_mul | rs2_mul_1 | rs2_mul_2 | rs2_mul_3 | rs2_mul_4;
        rs1_div_f1 = '0;
        rs2_div_f2 = '0;
        if (rst)
        begin
            rs1_div_f1 = '0;
            rs2_div_f2 = '0;
        end
        else
        begin
            rs1_div_f1 = rs1_div;
            rs2_div_f2 = rs2_div;
            for (int i = 0; i <= NUM_DIV_CYCLES; i++)
            begin
                rs1_div_f1 = rs1_div_f1 | rs1_divs[i];
                rs2_div_f2 = rs2_div_f2 | rs2_divs[i];    
            end
        end
        
        //rs1_div | rs1_div_1 | rs1_div_2 | rs1_div_3 | rs1_div_4;
        //rs2_div | rs2_div_1 | rs2_div_2 | rs2_div_3 | rs2_div_4;

        rs1_v_add = (arch_s1_add != 0) ? data[rs1_add] : '0;
        rs2_v_add = (arch_s2_add != 0) ? data[rs2_add] : '0;

        rs1_v_mem = (arch_s1_mem != 0) ? data[rs1_mem] : '0;
        rs2_v_mem = (arch_s2_mem != 0) ? data[rs2_mem] : '0;

        rs1_v_br = (arch_s1_br != 0) ? data[rs1_br] : '0;
        rs2_v_br = (arch_s2_br != 0) ? data[rs2_br] : '0;

        rs1_v_mul = (rs1_mul_f1 > 0) ? data[rs1_mul_f1] : '0;
        rs2_v_mul = (rs2_mul_f2 > 0) ? data[rs2_mul_f2] : '0;

        rs1_v_div = (rs1_div_f1 > 0) ? data[rs1_div_f1] : '0;
        rs2_v_div = (rs2_div_f2 > 0) ? data[rs2_div_f2] : '0;
    end

endmodule : phys_regfile