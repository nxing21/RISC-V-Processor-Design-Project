// // import rv32i_types::*;


// module top_tb;


// timeunit 1ps;
// timeprecision 1ps;
// // int clock_half_period_ps = getenv("ECE411_CLOCK_PERIOD_PS").atoi() / 2;

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

// logic   [4:0]   rd_dispatch, rs1, rs2, rd_cdb;

// logic   [5:0]     pd_dispatch, pd_cdb;
// logic   [5:0]     ps1, ps2;
// logic   ps1_valid, ps2_valid;

// logic   regf_we_dispatch, regf_we_cdb;


// task generate_reset;
//     begin
//         rst = 1'b1;
//         repeat (2) @ (posedge clk);
//         rst <= 1'b0;
//     end
// endtask;

// rat #(.PHYS_REG_BITS(6)) dut(
//     .*
// );

// task test_rat;
//     begin
//         rd_dispatch <= 5'b01011;
//         rs1 <= 5'b01101;
//         rs2 <= 5'b11101;
//         rd_cdb <= 5'b00111;
//         pd_cdb <= 6'b111111;
//         pd_dispatch <= 6'b100100;
//         regf_we_dispatch <= 1'b0;
//         regf_we_cdb <= 1'b0;
//         repeat (2) @ (posedge clk);
//         regf_we_dispatch <= 1'b1;
//         regf_we_cdb <= 1'b1;
//         repeat (1) @ (posedge clk);
//         regf_we_dispatch <= 1'b0;
//         regf_we_cdb <= 1'b0;
//         repeat (2) @ (posedge clk);
//         rd_cdb <= 5'b01011;
//         pd_cdb <= 6'b100100;
//         regf_we_cdb <= 1'b1;
//         repeat (1) @ (posedge clk);
//         regf_we_dispatch <= 1'b0;
//         regf_we_cdb <= 1'b0;
//     end
// endtask

// initial
// begin
//     generate_reset;
//     test_rat;
//     #100000;
//     $finish;
// end

// endmodule