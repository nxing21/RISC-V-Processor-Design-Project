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

//     logic   [31:0]  inst;

//     logic           rob_full, rs_full; // May need to make multiple RS_full flags due to there being multiple stations

//     logic           is_iqueue_empty;

//     // to and from free list
//     logic   [5:0]   phys_reg;
//     logic           is_free_list_empty;
//     logic           dequeue;

//     // to and from RAT
//     logic   [4:0]                   rd, rs1, rs2;
//     logic   [6-1:0]     pd;
//     logic   [6-1:0]     ps1, ps2;
//     logic                           ps1_valid, ps2_valid;
//     logic                           regf_we;


// task generate_reset;
//     begin
//         rst = 1'b1;
//         repeat (2) @ (posedge clk);
//         rst <= 1'b0;
//     end
// endtask;

// rename_dispatch #(.PHYS_REG_BITS(6)) dut(
//     .*
// );

// task fu_mult_test;
//     begin
//         rob_full <= 1'b0;
//         is_iqueue_empty <= 1'b0;
//         rs_full <= 1'b0;
//         is_free_list_empty <= 1'b0;
//         inst <= 32'b00000000110001000000000110000000;
//         repeat (2) @ (posedge clk);
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