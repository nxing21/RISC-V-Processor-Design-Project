// module top_tb;
// import rv32i_types::*;
//     //---------------------------------------------------------------------------------
//     // Waveform generation.
//     //---------------------------------------------------------------------------------
//     initial begin
//         $fsdbDumpfile("dump.fsdb");
//         $fsdbDumpvars(0, "+all");
//     end

//     //---------------------------------------------------------------------------------
//     // TODO: Declare cache port signals:
//     //---------------------------------------------------------------------------------
//     logic           clk;
//     logic           rst;

//     logic   [5:0]   phys_reg_in;
//     logic   [4:0]   arch_reg_in;
//     logic           enqueue_valid;
    
//     logic   [5:0]   rob_idx_in;
//     logic           cdb_valid;

//     rob_out_t       rob_out;
//     logic           dequeue_valid;

//     logic           full;

//     //---------------------------------------------------------------------------------
//     // TODO: Generate a clock:
//     //---------------------------------------------------------------------------------
//     initial clk = 1'b1;
//     always #1ns clk = ~clk;

//     //---------------------------------------------------------------------------------
//     // TODO: Write a task to generate reset:
//     //---------------------------------------------------------------------------------
//     task reset;
//         begin
//             rst = 1'b1;
//             repeat (2) @(posedge clk);
//             rst <= 1'b0;
//         end
//     endtask

//     //---------------------------------------------------------------------------------
//     // TODO: Instantiate the DUT and physical memory:
//     //---------------------------------------------------------------------------------

//     rob dut(
//         .clk        (clk),
//         .rst        (rst),

//         // rename/dispatch inputs
//         .phys_reg_in    (phys_reg_in),
//         .arch_reg_in    (arch_reg_in),
//         .enqueue_valid  (enqueue_valid),

//         // cdb inputs
//         .rob_idx_in     (rob_idx_in),
//         .cdb_valid      (cdb_valid),

//         // rrf outputs
//         .rob_out        (rob_out),
//         .dequeue_valid  (dequeue_valid),
        
//         // stall output
//         .full           (full)
//     );

//     //---------------------------------------------------------------------------------
//     // TODO: Write tasks to test various functionalities:
//     //---------------------------------------------------------------------------------

//     // enqueues then 3 dequeues all in order
//     task normal;
//         begin
//             phys_reg_in = 6'b000010;
//             arch_reg_in = 5'b00000;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b000100;
//             arch_reg_in = 5'b00001;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b001000;
//             arch_reg_in = 5'b00011;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = '0;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000001;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000010;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);
//         end
//     endtask

//     // overlapping enqueues and dequeues all in order
//     task overlapping;
//         begin
//             phys_reg_in = 6'b000010;
//             arch_reg_in = 5'b00000;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b000100;
//             arch_reg_in = 5'b00001;
//             enqueue_valid = '1;
//             rob_idx_in = '0;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b001000;
//             arch_reg_in = 5'b00011;
//             enqueue_valid = '1;
//             rob_idx_in = 6'b000001;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000010;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);
//         end
//     endtask

//     // enqueues then dequeues ooo
//     task normal_ooo;
//         begin
//             phys_reg_in = 6'b000010;
//             arch_reg_in = 5'b00000;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b000100;
//             arch_reg_in = 5'b00001;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b001000;
//             arch_reg_in = 5'b00011;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000001;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000010;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000000;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);
//         end
//     endtask

//     // overlapping enqueues and dequeues ooo
//     task overlapping_ooo;
//         begin
//             phys_reg_in = 6'b000010;
//             arch_reg_in = 5'b00000;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b000100;
//             arch_reg_in = 5'b00001;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b001000;
//             arch_reg_in = 5'b00011;
//             enqueue_valid = '1;
//             rob_idx_in = 6'b000001;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b010000;
//             arch_reg_in = 5'b00111;
//             enqueue_valid = '1;
//             rob_idx_in = 6'b000010;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000000;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000011;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);
//         end
//     endtask

//     // overflow
//     task overflow;
//         begin
//             phys_reg_in = 6'b000010;
//             arch_reg_in = 5'b00000;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (63) @(posedge clk);

//             phys_reg_in = 6'b000100;
//             arch_reg_in = 5'b00001;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b001000;
//             arch_reg_in = 5'b00011;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b010000;
//             arch_reg_in = 5'b00111;
//             enqueue_valid = '1;
//             rob_idx_in = 'x;
//             cdb_valid = '0;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000000;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 6'b100000;
//             arch_reg_in = 5'b01111;
//             enqueue_valid = '1;
//             rob_idx_in = 6'b000001;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);

//             phys_reg_in = 'x;
//             arch_reg_in = 'x;
//             enqueue_valid = '0;
//             rob_idx_in = 6'b000010;
//             cdb_valid = '1;
//             repeat (1) @(posedge clk);
//         end
//     endtask

//     //---------------------------------------------------------------------------------
//     // TODO: Main initial block that calls your tasks, then calls $finish
//     //---------------------------------------------------------------------------------

//     initial begin
//         reset();

//         // normal();
//         // overlapping();
//         // normal_ooo();
//         overlapping_ooo();
//         // overflow();

//         repeat (10) @(posedge clk);

//         $finish;
//     end
// endmodule : top_tb