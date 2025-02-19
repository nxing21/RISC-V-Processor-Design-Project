// // import rv32i_types::*;


// module top_tb;

// timeunit 1ps;
// timeprecision 1ps;
// // int clock_half_period_ps = getenv("ECE411_CLOCK_PERIOD_PS").atoi() / 2;

// import rv32i_types::*;

// bit clk;
// always #1ns clk = ~clk;

// bit rst;


// initial begin
//     $fsdbDumpfile("dump.fsdb");
//     $fsdbDumpvars(0, "+all");
//     rst = 1'b1;
//     repeat (2) @(posedge clk);
//     rst <= 1'b0;
// end

//     logic           clk;
//     logic           rst;
//     logic   [31:0]  reg_rs1_v, reg_rs2_v;
//     decode_info_t   decode_info;
//     logic   [31:0]  cdb_rd_v;
//     logic           start_add, start_mul, start_div;

//     // ADD PORTS
//     logic   [5:0]   rob_idx_add;
//     logic   [5:0]   pd_s_add;
//     logic   [4:0]   rd_s_add;
//     cdb_t           cdb_add;

//     // MULT PORTS
//     logic   [5:0]   rob_idx_mul;
//     logic   [5:0]   pd_s_mul;
//     logic   [4:0]   rd_s_mul;
//     cdb_t           cdb_mul;

//     // DIV PORTS
//     logic   [5:0]   rob_idx_div;
//     logic   [5:0]   pd_s_div;
//     logic   [4:0]   rd_s_div;
//     cdb_t           cdb_div;


// task generate_reset;
//     begin
//         rst = 1'b1;
//         repeat (2) @ (posedge clk);
//         rst <= 1'b0;
//     end
// endtask;

// execute #(.PHYS_REG_BITS(6)) dut(
//     .*
// );

// task exec_test;
//     begin
//         reg_rs1_v <= 32'h00000004;
//         reg_rs2_v <= 32'h00000005;
//         start_add <= 1'b1;
//         decode_info.opcode = op_b_reg;
//         decode_info.funct3 = arith_f3_add;
//     end
// endtask

// initial
// begin
//     generate_reset;
//     exec_test;
//     #100000;
//     $finish;
// end

// endmodule