// // import rv32i_types::*;


// module top_tb;


// timeunit 1ps;
//     timeprecision 1ps;
//     // parameter DATA_WIDTH = 32; 
//     // parameter QUEUE_DEPTH = 64;
//     int clock_half_period_ps = getenv("ECE411_CLOCK_PERIOD_PS").atoi() / 2;

//     bit clk;
//     always #(clock_half_period_ps) clk = ~clk;

//     bit rst;


//     initial begin
//         $fsdbDumpfile("dump.fsdb");
//         $fsdbDumpvars(0, "+all");
//         rst = 1'b1;
//         repeat (2) @(posedge clk);
//         rst <= 1'b0;
//     end

//     logic [32 - 1:0] wdata_in;
//     logic enqueue_in;
//     logic [32 - 1:0] rdata_out;
//     logic dequeue_in;
//     logic full_out;
//     logic empty_out;


// task generate_reset;
//     begin
//         rst = 1'b1;
//         repeat (2) @ (posedge clk);
//         rst <= 1'b0;
//     end
// endtask;

// queue #(.DATA_WIDTH(32), .QUEUE_DEPTH(64)) dut(
//     .clk(clk),
//     .rst(rst),
//     .wdata_in(wdata_in),
//     .enqueue_in(enqueue_in),
//     .rdata_out(rdata_out),
//     .dequeue_in(dequeue_in),
//     .full_out(full_out),
//     .empty_out(empty_out)
// );


// task standard_task( input logic [32 - 1:0] write_data1, input logic enqueue, input logic dequeue);
//     begin
//         wdata_in = write_data1;
//         enqueue_in = enqueue;
//         dequeue_in = dequeue;
//         @ (posedge clk);
//         wdata_in = 'x;
//         enqueue_in = 1'b0;
//         dequeue_in = 1'b0;
//     end
// endtask

// task queue_test1;
//     begin
//         standard_task( 32'hcafebabe, 1'b1,  1'b0);
//         standard_task( 32'hecebcafe, 1'b1,  1'b0);
//         standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     end
// endtask

// task queue_test_overflow;
//     begin
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     standard_task( 32'hcafeface, 1'b1,  1'b0);
//     standard_task( 32'hcafebabe, 1'b1,  1'b0);
//     standard_task( 32'hecebcafe, 1'b1,  1'b0);
//     standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     end
// endtask

// task queue_test_overflow_then_dequeue;
//     begin
//         queue_test_overflow;
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//     end
// endtask


// task queue_test_underflow;
//     begin
//         standard_task( 32'hecebcafe, 1'b1,  1'b0);
//         standard_task( 32'hbabebeef, 1'b1,  1'b0);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//     end
// endtask

// task queue_test_underflow_many_times;
//     begin
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//         standard_task('x, 1'b0,1'b1);
//     end
// endtask

// task queue_test_underflow_then_enqueue;
//     begin
//         queue_test_underflow;
//         standard_task( 32'hecebcafe, 1'b1,  1'b0);
//         standard_task( 32'hbabebeef, 1'b1,  1'b0);
//         standard_task( 32'hecebcafe, 1'b1,  1'b0);
//         standard_task( 32'hbabebeef, 1'b1,  1'b0);
//     end
// endtask

// task queue_test_overflow_then_underflow;
//     begin
//             queue_test_overflow;
//             queue_test_underflow_many_times;
//             queue_test1;
//             standard_task( 32'hbabebeef, 1'b0,  1'b1);
//             standard_task( 32'hbabebeef, 1'b0,  1'b1);
//             standard_task( 32'hbabebeef, 1'b0,  1'b1);
//             standard_task( 32'hbabebeef, 1'b0,  1'b1);
//             standard_task( 32'hbabebeef, 1'b0,  1'b1);
//             standard_task( 32'hbabebeef, 1'b0,  1'b1);

//     end

// endtask;

// task queue_test_underflow_then_overflow;
    
//     begin
//         queue_test_underflow;
//         queue_test_overflow;
//     end

// endtask

// initial
// begin
//     generate_reset;
//     // queue_test1;
//     // queue_test_overflow;
//     // queue_test_overflow_then_dequeue;
//     // queue_test_underflow;
//     // queue_test_underflow_then_enqueue;
//     // queue_test_overflow_then_underflow;
//         queue_test_underflow_then_overflow;
//     #100000;
//     $finish;
// end

// endmodule