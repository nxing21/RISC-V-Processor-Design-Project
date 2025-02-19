// module top_tb;


// timeprecision 1ps;

// timeunit 1ps;
//     // parameter DATA_WIDTH = 32; 
//     // parameter QUEUE_DEPTH = 64;
//     int clock_half_period_ps;
//     initial begin
//         $value$plusargs("CLOCK_PERIOD_PS_ECE411=%d", clock_half_period_ps);
//         clock_half_period_ps = clock_half_period_ps / 2;
//     end
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




// task generate_reset;
//     begin
//         rst = 1'b1;
//         repeat (2) @ (posedge clk);
//         rst <= 1'b0;
//     end
// endtask;

// logic [31:0] i_dfp_addr;
// logic i_dfp_read;
// // logic i_dfp_write;// we will never write to instruction memory
//  logic  [255:0] i_dfp_rdata;
// // logic  [255:0] i_dfp_wdata,      // FILL WHEN WE WANT TO WRITE we will never write to instruction memory
//  logic i_dfp_resp;
// //A RELEVANT SIGNALS */
// logic [31:0] d_dfp_addr;
// logic d_dfp_read;
// logic d_dfp_write;
//  logic  [255:0] d_dfp_rdata;
// logic  [255:0] d_dfp_wdata;      // FILL WHEN WE WANT TO WRITE
//  logic d_dfp_resp;
//  logic [31:0] bmem_addr;
//  logic bmem_read;
//  logic mem_valid;
//  logic   [255:0]      full_burst;
// logic bmem_ready;
// logic [255:0] cache_wdata;
//  logic     cache_valid;
// cache_arbiter dut(
//     .clk(clk),
//     .rst(rst),
//     .i_dfp_addr(i_dfp_addr),
//     .i_dfp_read(i_dfp_read),// we will never write to instruction memory
//     .i_dfp_rdata(i_dfp_rdata),      // FILL WHEN WE WANT TO WRITE we will never write to instruction memory
//     .i_dfp_resp(i_dfp_resp),
    
//     .d_dfp_addr(d_dfp_addr),
//     .d_dfp_read(d_dfp_read),
//     .d_dfp_write(d_dfp_write),
//     .d_dfp_rdata(d_dfp_rdata),
//     .d_dfp_wdata(d_dfp_wdata),      // FILL WHEN WE WANT TO WRITE
//     .d_dfp_resp(d_dfp_resp),
//     .bmem_addr(bmem_addr),
//     .bmem_read(bmem_read),
//     .mem_valid(mem_valid),
//     .full_burst(full_burst),
//     .bmem_ready(bmem_ready),
//     .cache_wdata(cache_wdata),
//     .cache_valid(cache_valid)
// );

// task standard_task(logic [31:0] i_dfp_addr1,     logic i_dfp_read1,   logic [31:0] d_dfp_addr1,    logic d_dfp_read1,   logic d_dfp_write1,  logic  [255:0] d_dfp_wdata1,  logic bmem_ready1,   logic [255:0] cache_wdata1,  logic cache_valid1                      );
//     begin
//         i_dfp_addr  = i_dfp_addr1;
//         i_dfp_read  = i_dfp_read1;
//         d_dfp_addr  = d_dfp_addr1;
//         d_dfp_read  = d_dfp_read1;
//         d_dfp_write = d_dfp_write1;
//         d_dfp_wdata = d_dfp_wdata1;
//         bmem_ready  = bmem_ready1;
//         cache_wdata = cache_wdata1; 
//         cache_valid = cache_valid1;
//         @ (posedge clk);
//         i_dfp_addr= '0;
//         i_dfp_read= '0;
//         d_dfp_addr= '0;
//         d_dfp_read= '0;
//         d_dfp_write= '0;
//         d_dfp_wdata= '0;
//         bmem_ready= '1;
//         cache_wdata= '0;
//         cache_valid= '0;
//     end
// endtask;


// task cache_arbiter_idle;
//     begin
//         standard_task(32'h1eceb000, 1'b0, '0, 1'b0, 1'b0, '0, 1'b1, '1, 1'b1);
//     end
// endtask;
// task cache_arbiter_simple_inst;
//     begin
//         standard_task(32'h1eceb004, 1'b1, '0, 1'b0, 1'b0, '0, 1'b1, '1, 1'b1);
//     end
// endtask;

// task cache_arbiter_simple_data;
//     begin
//         standard_task('0, 1'b0, 32'h00004000, 1'b1, 1'b0, '0, 1'b1, '1, 1'b1);
//     end
// endtask;

// task cache_arbiter_idle_inst_data;
//     begin
//         cache_arbiter_idle;
//         cache_arbiter_simple_inst;
//         cache_arbiter_simple_data;
//     end
// endtask;

// task cache_arbiter_inst_and_data;
//     begin
//         cache_arbiter_idle;
//         standard_task(32'h1eceb018, 1'b1, 32'h00004004, 1'b1, 1'b0,'0, 1'b1,  '1, 1'b1);
//         standard_task(32'h1eceb01c, 1'b1, 32'h00004008, 1'b1, 1'b0,'0, 1'b1,  '1, 1'b1);
//         standard_task(32'h1eceb020, 1'b1, 32'h0000400c, 1'b1, 1'b0,'0, 1'b1,  '1, 1'b1);
//         standard_task(32'h1eceb024, 1'b1, 32'h00004010, 1'b0, 1'b1,'0, 1'b1,  '1, 1'b1);

//     end
// endtask;


// initial 
// begin
//     generate_reset;
//     cache_arbiter_inst_and_data;
//     #100000;
//     $finish;
// end

// endmodule