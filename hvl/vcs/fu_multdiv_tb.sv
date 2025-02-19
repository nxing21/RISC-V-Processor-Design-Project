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

//     logic   [31:0]  rs1_v, rs2_v;
//     decode_info_t   decode_info;
//     logic   [31:0]  rd_v;
//     logic           start;
//     logic           valid;


// task generate_reset;
//     begin
//         rst = 1'b1;
//         repeat (2) @ (posedge clk);
//         rst <= 1'b0;
//     end
// endtask;

// fu_mult #(.PHYS_REG_BITS(6)) dut(
//     .*
// );

// task fu_mult_test;
//     begin
//         decode_info.opcode <= op_b_reg;
//         decode_info.funct3 <= mult_div_f3_mul;
//         rs1_v = 32'h00003;
//         rs2_v = 32'h00002;
//         start <= 1'b1;
//         repeat (1) @ (posedge clk);
//         start <= 1'b0;
//         repeat (4) @ (posedge clk);
//         start <= 1'b1;
//         rs2_v = 32'h00005;
//         repeat (1) @ (posedge clk);
//         start <= 1'b0;
//     end
// endtask

// initial
// begin
//     generate_reset;
//     fu_mult_test;
//     #100000;
//     $finish;
// end

// endmodule