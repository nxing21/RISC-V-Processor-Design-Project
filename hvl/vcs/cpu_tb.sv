// module top_tb;
//     //---------------------------------------------------------------------------------
//     // Waveform generation.
//     //---------------------------------------------------------------------------------
//     initial begin
//         $fsdbDumpfile("dump.fsdb");
//         $fsdbDumpvars(0, "+all");
//     end

//     //---------------------------------------------------------------------------------
//     // TODO: Declare cpu port signals:
//     //---------------------------------------------------------------------------------
//     logic               clk;
//     logic               rst;
//     // logic   [31:0]      bmem_addr,
//     // logic               bmem_read,
//     // logic               bmem_write,
//     // logic   [63:0]      bmem_wdata,
//     logic               bmem_ready;

//     logic   [31:0]      bmem_raddr;
//     // logic   [63:0]      bmem_rdata,
//     // logic               bmem_rvalid

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
//     mem_itf_banked mem_itf(.*); 
//     dram_w_burst_frfcfs_controller banked_memory_i(.itf(mem_itf));

//     mon_itf #(.CHANNELS(8)) mon_itf(.*);
//     monitor #(.CHANNELS(8)) monitor(.itf(mon_itf));

//     cpu dut(
//         .clk        (clk),
//         .rst        (rst),
//         .bmem_addr  (mem_itf.addr),
//         .bmem_read  (mem_itf.read),
//         .bmem_write (mem_itf.write),

//         .bmem_ready (bmem_ready),
//         .bmem_raddr (mem_itf.raddr),
//         .bmem_rdata (mem_itf.rdata),
//         .bmem_rvalid(mem_itf.rvalid)

//         // .ufp_addr   (ufp_addr),
//         // .ufp_rmask  (ufp_rmask),
//         // .ufp_wmask  (ufp_wmask),
//         // .ufp_rdata  (ufp_rdata),
//         // .ufp_wdata  (ufp_wdata),
//         // .ufp_resp   (ufp_resp),

//         // .dfp_addr   (mem_itf.addr[0]),
//         // .dfp_read   (mem_itf.read[0]),
//         // .dfp_write  (mem_itf.write[0]),
//         // .dfp_rdata  (mem_itf.rdata[0]),
//         // .dfp_wdata  (mem_itf.wdata[0]),
//         // .dfp_resp   (mem_itf.resp[0])
//     );

//     //---------------------------------------------------------------------------------
//     // TODO: Write tasks to test various functionalities:
//     //---------------------------------------------------------------------------------

//     task cpu_basic;
//         begin
//             bmem_ready <= '1;

//             repeat (500) @(posedge clk);

//             // bmem_ready <= '0;
//         end
//     endtask

//     //---------------------------------------------------------------------------------
//     // TODO: Main initial block that calls your tasks, then calls $finish
//     //---------------------------------------------------------------------------------

//     initial begin
//         reset();

//         cpu_basic();

//         repeat (10) @(posedge clk);

//         $finish;
//     end
// endmodule : top_tb