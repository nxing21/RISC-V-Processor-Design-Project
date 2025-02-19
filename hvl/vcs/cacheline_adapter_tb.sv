// module top_tb;
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
//     logic   [63:0]  bmem_rdata;
//     logic           bmem_rvalid;
//     logic   [255:0] cache_wdata;
//     logic           cache_valid;

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

//     cacheline_adapter dut(
//         .clk        (clk),
//         .rst        (rst),
//         .bmem_rdata (bmem_rdata),
//         .bmem_rvalid(bmem_rvalid),
//         .cache_wdata(cache_wdata),
//         .cache_valid(cache_valid)
//     );

//     //---------------------------------------------------------------------------------
//     // TODO: Write tasks to test various functionalities:
//     //---------------------------------------------------------------------------------

//     task normal;
//         begin
//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (5) @(posedge clk);

//             bmem_rdata = 64'hCAFEBABE14159265;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hDEADBEEF12345678;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hFECEBECE87654321;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hABCDABCD12341234;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (2) @(posedge clk);

//             bmem_rdata = 64'hCAFEBABE14159265;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hDEADBEEF12345678;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hFECEBECE87654321;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hABCDABCD12341234;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hCAFEBABE14159265;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hDEADBEEF12345678;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hFECEBECE87654321;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hABCDABCD12341234;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (5) @(posedge clk);
//         end
//     endtask

//     task inconsistent_rvalid;
//         begin
//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (5) @(posedge clk);

//             bmem_rdata = 64'hCAFEBABE14159265;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hCAFEBABE14159265;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hCAFEBABE14159265;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hDEADBEEF12345678;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hFECEBECE87654321;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 64'hABCDABCD12341234;
//             bmem_rvalid = '1;
//             repeat (1) @(posedge clk);

//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (5) @(posedge clk);

//             bmem_rdata = 'x;
//             bmem_rvalid = '0;
//             repeat (1) @(posedge clk);
//         end
//     endtask

//     //---------------------------------------------------------------------------------
//     // TODO: Main initial block that calls your tasks, then calls $finish
//     //---------------------------------------------------------------------------------

//     initial begin
//         reset();

//         // normal();
//         inconsistent_rvalid();

//         repeat (10) @(posedge clk);

//         $finish;
//     end
// endmodule : top_tb