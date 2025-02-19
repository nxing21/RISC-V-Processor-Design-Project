
import "DPI-C" function string getenv(input string env_name);
// import rv32i_types::*;

module top_tb;
    timeunit 1ps;
    timeprecision 1ps;
    // parameter DATA_WIDTH = 32; 
    // parameter QUEUE_DEPTH = 64;
    int clock_half_period_ps = getenv("ECE411_CLOCK_PERIOD_PS").atoi() / 2;

    bit clk;
    always #(clock_half_period_ps) clk = ~clk;

    bit rst;

    int timeout = 10000000; // in cycles, change according to your needs

    mem_itf_banked bmem_itf(.*);
    banked_memory banked_memory(.itf(bmem_itf));

    mon_itf #(.CHANNELS(8)) mon_itf(.*);
    monitor #(.CHANNELS(8)) monitor(.itf(mon_itf));

    // cpu dut(
    //     .clk            (clk),
    //     .rst            (rst),

    //     .bmem_addr  (bmem_itf.addr  ),
    //     .bmem_read  (bmem_itf.read  ),
    //     .bmem_write (bmem_itf.write ),
    //     .bmem_wdata (bmem_itf.wdata ),
    //     .bmem_ready (bmem_itf.ready ),
    //     .bmem_raddr (bmem_itf.raddr ),
    //     .bmem_rdata (bmem_itf.rdata ),
    //     .bmem_rvalid(bmem_itf.rvalid)
    // );

    `include "rvfi_reference.svh"

    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst <= 1'b0;
    end

    always @(posedge clk) begin
        for (int unsigned i=0; i < 8; ++i) begin
            if (mon_itf.halt[i]) begin
                $finish;
            end
        end
        if (timeout == 0) begin
            $error("TB Error: Timed out");
            $finish;
        end
        if (mon_itf.error != 0) begin
            repeat (5) @(posedge clk);
            $finish;
        end
        if (bmem_itf.error != 0) begin
            repeat (5) @(posedge clk);
            $finish;
        end
        timeout <= timeout - 1;
    end



    // logic [32 - 1:0] wdata_in;
    // logic enqueue_in;
    // logic [32 - 1:0] rdata_out;
    // logic dequeue_in;
    // logic full_out;
    // logic empty_out;


    task generate_reset;
        begin
            rst = 1'b1;
            repeat (2) @ (posedge clk);
            rst <= 1'b0;
        end
    endtask;

    // queue q(
    //     .clk(clk),
    //     .rst(rst),
    //     .wdata_in(wdata_in),
    //     .enqueue_in(enqueue_in),
    //     .rdata_out(rdata_out),
    //     .dequeue_in(dequeue_in),
    //     .full_out(full_out),
    //     .empty_out(empty_out)
    // );


    // task queue_test1( input logic [32 - 1:0] write_data1, input logic enqueue, input logic dequeue);
    //     begin
    //         wdata_in = write_data1;
    //         enqueue_in = enqueue;
    //         dequeue_in = dequeue;
    //     end
    // endtask

    // initial
    // begin
    //     queue_test1( 32'hcafebabe, 1'b1,  1'b0);
    //      #10000;
    //      $finish;
    // end


endmodule 
