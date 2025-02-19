module execute
import rv32i_types::*;
#(
    parameter PHYS_REG_BITS = 6
)
(
    input   logic           clk,
    input   logic           rst,
    input   logic   [31:0]  rs1_v_add, rs2_v_add, rs1_v_mul, rs2_v_mul, rs1_v_div, rs2_v_div, rs1_v_br, rs2_v_br,rs1_v_mem, rs2_v_mem,
    input   decode_info_t   decode_info_add, decode_info_mul, decode_info_div, decode_info_br, decode_info_mem,
    input   logic           start_add, start_mul, start_div, start_br, start_mem,

    input logic [MEM_ADDR_WIDTH - 1:0] mem_idx_in,
    output logic [$clog2(MEM_QUEUE_DEPTH) - 1:0] mem_idx_out,

    // ADD PORTS
    input   logic   [ROB_ADDR_WIDTH -1:0]   rob_idx_add,
    input   logic   [PHYS_REG_BITS - 1:0]   pd_s_add,
    input   logic   [ARCH_REG_BITS - 1:0]   rd_s_add,
    output  cdb_t           cdb_add,
    output  logic           busy_add,

    // MULT PORTS
    input   logic   [ROB_ADDR_WIDTH - 1:0]   rob_idx_mul,
    input   logic   [PHYS_REG_BITS - 1:0]   pd_s_mul,
    input   logic   [ARCH_REG_BITS - 1:0]   rd_s_mul,
    output  cdb_t           cdb_mul,
    output  logic           busy_mul,

    // DIV PORTS
    input   logic   [ROB_ADDR_WIDTH -1:0]   rob_idx_div,
    input   logic   [PHYS_REG_BITS - 1:0]   pd_s_div,
    input   logic   [ARCH_REG_BITS - 1:0]   rd_s_div,
    output  cdb_t           cdb_div,
    output  logic           busy_div,

    // BR PORTS
    input   logic   [ROB_ADDR_WIDTH -1:0]   rob_idx_br,
    input   logic   [PHYS_REG_BITS - 1:0]   pd_s_br,
    input   logic   [ARCH_REG_BITS - 1:0]   rd_s_br,
    output  cdb_t           cdb_br,
    output  logic           busy_br,

    input   logic           global_branch_signal,

    // input   logic           global_branch_signal,

    // MEM PORTS
    // input   logic   [5:0]   rob_idx_mem,
    // input   logic   [5:0]   pd_s_mem,
    // input   logic   [4:0]   rd_s_mem,
    // output  cdb_t           cdb_mem,
    output  logic           addr_valid,
    output  logic           busy_mem,
    output logic    [31:0]  store_wdata,
    output logic    [31:0]  calculated_address,
    output  logic   [31:0]  fu_rs1_v_mem, fu_rs2_v_mem
);

    logic   valid_add, valid_mul, valid_div, valid_br, valid_mem;
    
    // cdb_t   cdb_add, cdb_mul, cdb_div;

    logic   [ROB_ADDR_WIDTH -1:0]   rob_add_reg, rob_mul_reg, rob_div_reg,  rob_br_reg, rob_mem_reg;
    logic   [PHYS_REG_BITS - 1:0]   pd_add_reg, pd_mul_reg, pd_div_reg,     pd_br_reg, pd_mem_reg;
    logic   [ARCH_REG_BITS - 1:0]   rd_add_reg, rd_mul_reg, rd_div_reg,     rd_br_reg, rd_mem_reg;
    

    logic   [31:0]  rd_v_add, rd_v_mul, rd_v_div, rd_v_br;//, rd_v_mem;

    logic           mul_1, mul_2, mul_3, mul_4;
    logic [NUM_DIV_CYCLES: 0]          divs;
    logic           div_1, div_2, div_3, div_4;

    logic           pc_select;
    logic   [31:0]  pc_branch;


    // logic           busy_add;

    always_ff @(posedge clk) begin
        if (rst) begin
            rob_add_reg <= '0;
            pd_add_reg <= '0;
            rd_add_reg <= '0;
            rob_br_reg <= '0;
            pd_br_reg <= '0;
            rd_br_reg <= '0;
           
            rob_mul_reg <= '0;
            pd_mul_reg <= '0;
            rd_mul_reg <= '0;
            rob_mem_reg <= '0;
            pd_mem_reg <= '0;
            rd_mem_reg <= '0;
        end else if (start_mul) begin
            rob_mul_reg <= rob_idx_mul;
            pd_mul_reg <= pd_s_mul;
            rd_mul_reg <= rd_s_mul;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rob_div_reg <= '0;
            pd_div_reg <= '0;
            rd_div_reg <= '0;
        end else if (start_div) begin
            rob_div_reg <= rob_idx_div;
            pd_div_reg <= pd_s_div;
            rd_div_reg <= rd_s_div;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            mul_1 <= 1'b0;
            mul_2 <= 1'b0;
            mul_3 <= 1'b0;
            mul_4 <= 1'b0;

            for (int i = 0; i <= NUM_DIV_CYCLES; i++)
            begin
                divs[i] <= 1'b0;
            end
            // div_1 <= 1'b0;
            // div_2 <= 1'b0;
            // div_3 <= 1'b0;
            // div_4 <= 1'b0;
        end else begin
            mul_1 <= start_mul;
            mul_2 <= mul_1;
            mul_3 <= mul_2;
            mul_4 <= mul_3;


            divs[0] <= start_div;
            for (int i = 1; i <= NUM_DIV_CYCLES; i++)
            begin
                divs[i] <= divs[i-1];
            end
            // div_2 <= div_1;
            // div_3 <= div_2;
            // div_4 <= div_3;
        end
    end

    fu_add fu_add_i (
        .rs1_v(rs1_v_add),
        .rs2_v(rs2_v_add),
        .decode_info(decode_info_add),     // PHYS REGFILE
        .rd_v(rd_v_add),
        .start(~global_branch_signal && start_add),
        .valid(valid_add),
        .busy(busy_add)
    );

    fu_mult fu_mul_i (
        .clk(clk),
        .rst(rst),
        .rs1_v(rs1_v_mul),
        .rs2_v(rs2_v_mul),
        .decode_info(decode_info_mul),     // PHYS REGFILE
        .rd_v(rd_v_mul),
        .start(~global_branch_signal && start_mul),
        .valid(valid_mul),
        .hold(mul_1 || mul_2 || mul_3 || mul_4),
        .global_branch_signal(global_branch_signal)
    );

    fu_div_rem fu_div_i (
        .clk(clk),
        .rst(rst),
        .rs1_v(rs1_v_div),
        .rs2_v(rs2_v_div),
        .decode_info(decode_info_div),     // PHYS REGFILE
        .rd_v(rd_v_div),
        .start(~global_branch_signal && start_div),
        .valid(valid_div),
        .hold(|divs),
        // .hold(div_1 || div_2 || div_3 || div_4)
        .global_branch_signal(global_branch_signal)
    );

    fu_br fu_br_i (
        .rs1_v(rs1_v_br),
        .rs2_v(rs2_v_br),
        .decode_info(decode_info_br),     // PHYS REGFILE
        .rd_v(rd_v_br),
        .start(~global_branch_signal && start_br),
        .valid(valid_br),
        .busy(busy_br),
        .pc_select(pc_select),
        .pc_branch(pc_branch)
    );

    fu_mem fu_mem_i(
        .rs1_v(rs1_v_mem), .rs2_v(rs2_v_mem),
    //    .decode_info(decode_info_mem),
        .start(~global_branch_signal && start_mem),
        .addr_valid(valid_mem),
        .busy(busy_mem),
        .mem_addr(calculated_address),
        .i_imm(decode_info_mem.i_imm),
        .dispatch_mem_idx(mem_idx_in),
        .mem_idx_out(mem_idx_out),
        .store_wdata(store_wdata),
        .fu_rs1_v_mem(fu_rs1_v_mem), .fu_rs2_v_mem(fu_rs2_v_mem)
    );

    always_comb 
    begin
        busy_mul = mul_1 || mul_2 || mul_3 || mul_4;
        busy_div = |divs;
        cdb_add = '0;
        cdb_mul = '0;
        cdb_div = '0;
        cdb_br = '0;

        cdb_add.rob_idx = rob_idx_add;
        cdb_add.pd_s = pd_s_add;
        cdb_add.rd_s = rd_s_add;
        cdb_add.rd_v = rd_v_add;
        cdb_add.valid = valid_add;
        cdb_add.inst = decode_info_add.inst;
        cdb_add.pc_select = '0;
        cdb_add.pc_branch = '0;

        cdb_mul.rob_idx = rob_mul_reg;
        cdb_mul.pd_s = pd_mul_reg;
        cdb_mul.rd_s = rd_mul_reg;
        cdb_mul.rd_v = rd_v_mul;
        cdb_mul.valid = valid_mul;
        cdb_mul.inst = decode_info_mul.inst;
        cdb_mul.pc_select = '0;
        cdb_mul.pc_branch = '0;

        cdb_div.rob_idx = rob_div_reg;
        cdb_div.pd_s = pd_div_reg;
        cdb_div.rd_s = rd_div_reg;
        cdb_div.rd_v = rd_v_div;
        cdb_div.valid = valid_div;
        cdb_div.inst = decode_info_div.inst;
        cdb_div.pc_select = '0;
        cdb_div.pc_branch = '0;

        cdb_br.rob_idx = rob_idx_br;
        cdb_br.pd_s = pd_s_br;
        cdb_br.rd_s = rd_s_br;
        cdb_br.rd_v = rd_v_br;
        cdb_br.valid = valid_br;
        cdb_br.inst = decode_info_br.inst;
        cdb_br.pc_select = pc_select;
        cdb_br.pc_branch = pc_branch;

        addr_valid = valid_mem;

        // cdb_add = global_branch_signal ? '0 : cdb_add;
        // cdb_br = global_branch_signal ? '0 : cdb_br;


        if (global_branch_signal) begin
            cdb_add = '0;
            cdb_mul = '0;
            cdb_div = '0;
            cdb_br = '0;
        end
    end

endmodule : execute