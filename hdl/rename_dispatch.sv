module rename_dispatch
import rv32i_types::*;

(
    input                   clk,
    input                   rst,
    input   logic   [31:0]  inst,
    input   logic   [31:0]  prog,
    input   logic           rob_full, rs_full_add, rs_full_mul, rs_full_div,  rs_full_br, rs_full_mem,  // May need to make multiple RS_full flags due to there being multiple stations

    input   logic           is_iqueue_empty,
    // to and from free list
    input   logic   [PHYS_REG_BITS - 1:0]   phys_reg,
    input   logic           is_free_list_empty,
    // input logic [63:0] order,
    output  logic           dequeue,
    output  logic           dequeue_free_list,
    // output logic [63:0] order_next,
    // to and from RAT
    output  logic   [ARCH_REG_BITS - 1:0]                   rd, rs1, rs2,
    output  logic   [PHYS_REG_BITS-1:0]     pd,
    input   logic   [PHYS_REG_BITS-1:0]     ps1, ps2,
    input   logic                           ps1_valid, ps2_valid,
    output  logic   [PHYS_REG_BITS-1:0]     ps1_out, ps2_out,
    output  logic                           ps1_valid_out, ps2_valid_out,
    output  logic                           regf_we,
    output  logic                           mem_regf_we,
    input   logic   [ROB_ADDR_WIDTH-1:0]     rob_num,     // USE THIS SOMEWHERE,
    output  logic   [ROB_ADDR_WIDTH-1:0]     rob_num_out,
    output  decode_info_t                   decode_info,
    output  logic   [2:0]                   rs_signal,
    output  logic   [31:0]                  dispatch_pc_rdata,
    output  logic   [31:0]                  dispatch_pc_wdata,
    // output  logic   [63:0]                  dispatch_order,    
    output  logic   [ARCH_REG_BITS - 1:0]                   dispatch_rs1_s,    
    output  logic   [ARCH_REG_BITS - 1:0]                   dispatch_rs2_s,    
    output  logic   [31:0]                  dispatch_inst,     
    output  logic                           dispatch_regf_we,
    // to and from memory queue
    input   logic   [MEM_ADDR_WIDTH  - 1:0]   mem_idx_in,
    output  logic   [MEM_ADDR_WIDTH - 1:0]   mem_idx_out,
    
    input   logic   [31:0]  global_branch_addr,
    input   logic           global_branch_signal
);

    // decode_info_t decode_info;
    logic   rob_full_reg;
    logic   is_free_list_empty_reg;
    logic   is_iqueue_empty_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            rob_full_reg <= '0;
            is_free_list_empty_reg <= '1;
            is_iqueue_empty_reg <= '1;
        end else begin
            rob_full_reg <= rob_full;
            is_free_list_empty_reg <= is_free_list_empty;
            is_iqueue_empty_reg <= is_iqueue_empty;
        end
    end

    always_comb begin
        rd = '0;
        rs1 = '0;
        rs2 = '0;
        dequeue = 1'b0;
        dequeue_free_list = '0;
        rs_signal = 3'b000;
        decode_info = '0;
        regf_we = 1'b0;
        mem_regf_we = 1'b0;

        ps1_out = ps1;
        ps2_out = ps2;
        ps1_valid_out = ps1_valid;
        ps2_valid_out = ps2_valid;
        // order_next = order;
        rob_num_out = rob_num;
        mem_idx_out = mem_idx_in;
        dispatch_inst = '0;
        dispatch_pc_rdata = '0;
        // dispatch_order = '0;
        dispatch_pc_wdata ='0;
        dispatch_rs1_s = '0;
        dispatch_rs2_s = '0; 
        dispatch_regf_we = '0;


        if (inst[6:0] == op_b_reg && inst[31:25] == 7'b0000001 && (inst[14:12] inside { mult_div_f3_mul, mult_div_f3_mulh, mult_div_f3_mulhsu, mult_div_f3_mulhu})) begin
        // if (inst[6:0] == op_b_reg && inst[31:25] == 7'b0000001 && (inst[14:12] == mult_div_f3_mul || inst[14:12] == mult_div_f3_mulh || inst[14:12] == mult_div_f3_mulhsu || inst[14:12] == mult_div_f3_mulhu)) begin
            rs_signal = 3'b001;
        end else if (inst[6:0] == op_b_reg && inst[31:25] == 7'b0000001 && (inst[14:12] == mult_div_f3_div || inst[14:12] == mult_div_f3_divu || inst[14:12] == mult_div_f3_rem || inst[14:12] == mult_div_f3_remu)) begin
            rs_signal = 3'b010;
        end else if (inst[6:0] inside {op_b_jal, op_b_jalr, op_b_br}) begin
            rs_signal = 3'b011;
        end else if (inst[6:0] inside {op_b_load, op_b_store}) begin
            rs_signal = 3'b100;
        end

        // if free list empty, instruction queue empty, ROB full, corresponding RS full, don't process instruction
        if (!is_free_list_empty_reg && !is_iqueue_empty_reg && !rob_full_reg && !((rs_full_add && (rs_signal == 3'b000)) || (rs_full_mul && (rs_signal == 3'b001)) || (rs_full_div && (rs_signal == 3'b010)) || (rs_full_br && (rs_signal == 3'b011)) || (rs_full_mem && (rs_signal == 3'b100)))) begin
        // if (!is_free_list_empty && !is_iqueue_empty && !rob_full && !rs_full_add && !rs_full_mul && !rs_full_div) begin
            dequeue = 1'b1;
            decode_info.funct3 = inst[14:12];
            decode_info.funct7 = inst[31:25];
            decode_info.opcode = inst[6:0];
            decode_info.i_imm  = decode_info.opcode == op_b_store ? {{21{inst[31]}}, inst[30:25], inst[11:7]} : {{21{inst[31]}}, inst[30:20]};
            decode_info.s_imm  = {{21{inst[31]}}, inst[30:25], inst[11:7]};
            decode_info.b_imm  = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            decode_info.u_imm  = {inst[31:12], 12'h000};
            decode_info.j_imm  = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            decode_info.rd_s   = inst[11:7];
            decode_info.rs1_s  = inst[19:15];
            decode_info.rs2_s  = inst[24:20];
            decode_info.inst   = inst;
            regf_we = 1'b1;
            dequeue_free_list = ((inst[6:0] == op_b_br) || (inst[11:7] == '0 && (inst[6:0] inside {op_b_auipc, op_b_lui, op_b_reg, op_b_imm, op_b_jal, op_b_jalr, op_b_load})) || inst[6:0] == op_b_store) ? 1'b0 : 1'b1; // also if store

            // if (decode_info.opcode == op_b_store) begin
            //     regf_we = '0;
            // end

            if (rs_signal == 3'b100 && !rs_full_mem)
            begin
                mem_regf_we = 1'b1;
            end

            rd = (inst[6:0] == op_b_br) ? '0 : decode_info.rd_s;
            rs1 = decode_info.rs1_s;
            rs2 = decode_info.rs2_s;

            dispatch_inst = inst;
            dispatch_pc_rdata = prog;
            dispatch_pc_wdata = global_branch_signal ? global_branch_addr : prog + 32'd4;
            dispatch_rs1_s = inst[19:15];
            dispatch_rs2_s = inst[24:20];
            dispatch_regf_we = regf_we;

            decode_info.pc = prog;
        end

        pd = ((inst[6:0] == op_b_br) || (inst[11:7] == '0 && (inst[6:0] inside {op_b_auipc, op_b_lui, op_b_reg, op_b_imm, op_b_jal, op_b_jalr, op_b_load})) || inst[6:0] == op_b_store) ? '0 : phys_reg;
        // pd = (inst[6:0] == op_b_br || inst[6:0] == op_b_store) ? '0 : phys_reg;
    end

endmodule : rename_dispatch
 