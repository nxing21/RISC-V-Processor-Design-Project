module rat
import rv32i_types::*;

(
    input   logic   clk, rst,
    input   logic   [ARCH_REG_BITS - 1:0]   rd_dispatch, rs1, rs2, rd_add, rd_mul, rd_div, rd_br, rd_mem,

    input   logic   [PHYS_REG_BITS-1:0]     pd_dispatch, pd_add, pd_mul, pd_div, pd_br, pd_mem,
    output  logic   [PHYS_REG_BITS-1:0]     ps1, ps2,
    output  logic   ps1_valid, ps2_valid,

    input   logic   regf_we_dispatch,
    input   logic   regf_we_add, regf_we_mul, regf_we_div, regf_we_br, regf_we_mem,
    input   decode_info_t   decode_info,
    // input   logic   [PHYS_REG_BITS-1:0] rrat[32],
    // input   logic   global_branch_signal
    input   logic   global_branch_signal,
    input   logic   [PHYS_REG_BITS-1:0]     rrat[32]
);

    logic [PHYS_REG_BITS-1:0] rat[32]; // holds mapping from arch register to phys register
    logic valid[32];

    // logic [PHYS_REG_BITS-1:0] rat_init[32];

    logic [PHYS_REG_BITS-1:0] rat_next[32];
    logic valid_next[32];
    // logic valid_init[32];

    // logic [5:0] temp;
    // always_comb begin
    //     temp = 6'b0;
    //     for (int i = 0; i < 32; i++) begin
    //         rat_init[i] = temp;
    //         valid_init[i] = 1'b1;
    //         temp = temp + 6'b000001;
    //     end
    // end

    always_comb begin
        rat_next = rat;
        valid_next = valid;

        // CDB: set entry rd to valid if it still maps to pd
        if (regf_we_add && pd_add == rat[rd_add]) begin
            valid_next[rd_add] = 1'b1;
        end

        if (regf_we_mul && pd_mul == rat[rd_mul]) begin
            valid_next[rd_mul] = 1'b1;
        end

        if (regf_we_div && pd_div == rat[rd_div]) begin
            valid_next[rd_div] = 1'b1;
        end

        if (regf_we_br && pd_br == rat[rd_br]) begin
            valid_next[rd_br] = 1'b1;
        end

        if (regf_we_mem && pd_mem == rat[rd_mem]) begin
            valid_next[rd_mem] = 1'b1;
        end

        // Renames rd to pd, marking invalid
        if (regf_we_dispatch) begin
            rat_next[rd_dispatch] = (rd_dispatch != '0 && decode_info.opcode != op_b_store) ? pd_dispatch : rat_next[rd_dispatch];
            valid_next[rd_dispatch] = (rd_dispatch != '0 && decode_info.opcode != op_b_store) ? 1'b0 : valid_next[rd_dispatch];
        end

        // rat_next = global_branch_signal ? rrat : rat_next;

        // Map arch sources to phys sources
        if (decode_info.inst == 32'h13 || decode_info.inst == 0) begin
            ps1 = '0;
            ps2 = '0;
            ps1_valid = '1;
            ps2_valid = '1;
        end else begin
            ps1 = (decode_info.opcode == op_b_jal) ? '0 : rat[rs1];
            ps2 = (decode_info.opcode inside {op_b_imm, op_b_lui, op_b_auipc,  op_b_jal, op_b_jalr, op_b_load}) ? rat[rs1] : rat[rs2];
            ps1_valid = (decode_info.opcode == op_b_jal) ? 1'b1 : valid[rs1];
            ps2_valid = (decode_info.opcode inside {op_b_imm, op_b_lui, op_b_auipc, op_b_jal, op_b_jalr, op_b_load}) ? '1 : valid[rs2];
        end

        valid_next[0] = 1'b1;

        if (global_branch_signal) begin
            for (int i = 0; i < 32; i++) begin
                rat_next[i] = rrat[i];
                valid_next[i] = 1'b1;
            end
        end

        // rat_next = global_branch_signal ? rrat : rat_next;
        // valid_next = global_branch_signal ? '1 : valid_next;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            // rat <= rat_init;
            // valid <= valid_init;
            for (int i = 0;i < 32; i ++)
            begin
                valid[i] <= '0;
            end

            rat[0] <=  6'd0;
            rat[1] <=  6'd1;
            rat[2] <=  6'd2;
            rat[3] <=  6'd3;
            rat[4] <=  6'd4;
            rat[5] <=  6'd5;
            rat[6] <=  6'd6;
            rat[7] <=  6'd7;
            rat[8] <=  6'd8;
            rat[9] <=  6'd9;
            rat[10] <=  6'd10;
            rat[11] <=  6'd11;
            rat[12] <=  6'd12;
            rat[13] <=  6'd13;
            rat[14] <=  6'd14;
            rat[15] <=  6'd15;
            rat[16] <=  6'd16;
            rat[17] <=  6'd17;
            rat[18] <=  6'd18;
            rat[19] <=  6'd19;
            rat[20] <=  6'd20;
            rat[21] <=  6'd21;
            rat[22] <=  6'd22;
            rat[23] <=  6'd23;
            rat[24] <=  6'd24;
            rat[25] <=  6'd25;
            rat[26] <=  6'd26;
            rat[27] <=  6'd27;
            rat[28] <=  6'd28;
            rat[29] <=  6'd29;
            rat[30] <=  6'd30;
            rat[31] <=  6'd31;
        end else begin
            rat <= rat_next;
            valid <= valid_next;
        end
    end

endmodule : rat