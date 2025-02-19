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

//     logic dispatch_valid;
//     logic [1:0] rs_select;
//     logic dispatch_ps_ready1;
//     logic dispatch_ps_ready2;
//     logic [5:0] ps1;
//     logic [5:0] ps2;
//     logic [4:0] rd;
//     logic [5:0] pd;
//     logic [5:0] rob_entry;
//     logic [5:0] cdb_ps_id;

//     logic add_fu_busy;
//     logic divide_fu_busy;
//     logic multiply_fu_busy;

//     logic add_regf_we;
//     logic multiply_regf_we;
//     logic divide_regf_we;

//     logic add_fu_ready;
//     logic multiply_fu_ready;
//     logic divide_fu_ready;

    
//      logic [5:0] add_rob_entry;
    
//       logic [5:0] multiply_rob_entry;
    
//        logic [5:0] divide_rob_entry;
//         logic [5:0] add_pd;
//         logic [5:0] multiply_pd;
//         logic [5:0] divide_pd;

//         logic [4:0] add_rd;
//         logic [4:0 ] multiply_rd;
//         logic [4:0] divide_rd;

//         logic add_full;      // if the RS is full
//         logic multiply_full;
//         logic divide_full;

//     logic [191:0] decode_info_in;
//     logic [191:0] add_decode_info_out;
//     logic [191:0] multiply_decode_info_out;
//     logic [191:0] divide_decode_info_out;
    
//     logic[5:0] add_ps1;
//     logic[5:0] add_ps2;

//     logic[5:0] multiply_ps1;
//     logic[5:0] multiply_ps2;

//     logic[5:0] divide_ps1;
//     logic[5:0] divide_ps2;
// reservation_station dut(
//     .clk(clk),
//     .rst(rst),
//     .dispatch_valid(dispatch_valid),
//     .rs_select(rs_select),
//     .dispatch_ps_ready1(dispatch_ps_ready1),
//     .dispatch_ps_ready2(dispatch_ps_ready2),
//     .ps1(ps1),
//     .ps2(ps2),
//     .rd(rd),
//     .pd(pd),
//     .rob_entry(rob_entry),
//     .cdb_ps_id(cdb_ps_id),
//     .decode_info_in(decode_info_in),
//     .add_fu_busy(add_fu_busy),
//     .multiply_fu_busy(multiply_fu_busy),
//     .divide_fu_busy(divide_fu_busy),

//     .add_regf_we(add_regf_we),
//     .multiply_regf_we(multiply_regf_we),
//     .divide_regf_we(divide_regf_we),

//     .add_fu_ready(add_fu_ready),
//     .divide_fu_ready(divide_fu_ready),
//     .multiply_fu_ready(multiply_fu_ready),

//     .add_rob_entry(add_rob_entry),
//     .multiply_rob_entry(multiply_rob_entry),
//     .divide_rob_entry(divide_rob_entry),

//     .add_pd(add_pd),
//     .multiply_pd(multiply_pd),
//     .divide_pd(divide_pd),

//     .add_rd(add_rd),
//     .multiply_rd(multiply_rd),
//     .divide_rd(divide_rd),

//     .add_full(add_full),
//     .multiply_full(multiply_full),
//     .divide_full(divide_full),

//     .add_decode_info_out(add_decode_info_out)
//      ,.multiply_decode_info_out(multiply_decode_info_out),
//      .divide_decode_info_out(divide_decode_info_out),

//      .add_ps1(add_ps1),
//      .add_ps2(add_ps2),

//      .multiply_ps1(multiply_ps1),
//      .multiply_ps2(multiply_ps2),

//      .divide_ps1(divide_ps1),
//      .divide_ps2(divide_ps2)
// );


// task standard_task( input logic [1:0] rs_select1, input logic dispatch_valid_t, input logic dispatch_ps_ready1_t, input logic dispatch_ps_ready2_t, input logic [5:0] ps1_t, input logic [5:0] ps2_t, input logic [4:0] rd_t, input logic [5:0] pd_t, input logic [5:0] rob_entry_t, input logic [5:0] cdb_ps_id_t, input logic add_fu_busy_t, input logic multiply_fu_busy_t,input logic divide_fu_busy_t);
//     begin
//         decode_info_in = '0;
//         rs_select = rs_select1;
//         dispatch_valid = dispatch_valid_t;
//         dispatch_ps_ready1 = dispatch_ps_ready1_t;
//         dispatch_ps_ready2 = dispatch_ps_ready2_t;
//         ps1 = ps1_t;
//         ps2 = ps2_t;
//         rd = rd_t;
//         pd = pd_t;
//         rob_entry = rob_entry_t;
//         cdb_ps_id = cdb_ps_id_t;
//         add_fu_busy  = add_fu_busy_t;
//         multiply_fu_busy = multiply_fu_busy_t;
//         divide_fu_busy = divide_fu_busy_t;
//         @ (posedge clk);
//         rs_select = '0;
//         dispatch_ps_ready1 = '0;
//         dispatch_ps_ready2 = '0;
//         ps1 = '0;
//         ps2 = '0;
//         rd = '0;
//         pd = '0;
//         dispatch_valid = 1'b0;
//         rob_entry = '0;
//         cdb_ps_id = '1;
//         add_fu_busy  = '0;
//         multiply_fu_busy = '0;
//         divide_fu_busy = '0;
//     end
// endtask

// task rs_add_one_entry;
//     begin           //input logic [1:0] rs_select1, input logic dispatch_valid_t, input logic dispatch_ps_ready1_t, input logic dispatch_ps_ready2_t, input logic [31:0] ps1_t, input logic [31:0] ps2_t, input logic [31:0] rd_t, input logic [31:0] pd_t, input logic [31:0] rob_entry_t, input logic [31:0] cdb_ps_id_t, input logic add_fu_busy_t, input logic multiply_fu_busy_t, input logic divide_fu_busy_t)
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd32,                     6'd33,                  5'd2,                     6'd45,                         6'd0,                  6'd38,                         1'b0,                           1'b0,                    1'b0);

//     end
// endtask;
// task rs_add_entry_remove;
//     begin           //input logic [1:0] rs_select1, input logic dispatch_valid_t, input logic dispatch_ps_ready1_t, input logic dispatch_ps_ready2_t, input logic [31:0] ps1_t, input logic [31:0] ps2_t, input logic [31:0] rd_t, input logic [31:0] pd_t, input logic [31:0] rob_entry_t, input logic [31:0] cdb_ps_id_t, input logic add_fu_busy_t, input logic multiply_fu_busy_t, input logic divide_fu_busy_t)
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b1,                       6'd34,                     6'd35,                  5'd4,                     6'd63,                         6'd1,                  6'd40,                         1'b0,                           1'b0 ,                        1'b0);
//     end
// endtask;
 
// task rs_add_entry_remove_then_add_one;
//     begin           //input logic [1:0] rs_select1, input logic dispatch_valid_t, input logic dispatch_ps_ready1_t, input logic dispatch_ps_ready2_t, input logic [31:0] ps1_t, input logic [31:0] ps2_t, input logic [31:0] rd_t, input logic [31:0] pd_t, input logic [31:0] rob_entry_t, input logic [31:0] cdb_ps_id_t, input logic add_fu_busy_t, input logic multiply_fu_busy_t, input logic divide_fu_busy_t)
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b1,                       6'd34,                     6'd35,                  5'd4,                     6'd63,                         6'd1,                  6'd40,                         1'b0,                           1'b0             ,1'b0);
//         standard_task(2'd0,                             1'b1,                               1'b1,                                   1'b0                         ,6'd32                    ,6'd33,                5'd5,                       6'd63,                          6'd2     ,            6'd41,                         1'b0,                           1'b0,          1'b0);
//     end
// endtask;


// task rs_add_multiple_entries;
//     begin           //input logic [1:0] rs_select1, input logic dispatch_valid_t, input logic dispatch_ps_ready1_t, input logic dispatch_ps_ready2_t, input logic [31:0] ps1_t, input logic [31:0] ps2_t, input logic [31:0] rd_t, input logic [31:0] pd_t, input logic [31:0] rob_entry_t, input logic [31:0] cdb_ps_id_t, input logic add_fu_busy_t, input logic multiply_fu_busy_t, input logic divide_fu_busy_t)
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd32,                     6'd33,                  5'd2,                     6'd63,                         6'd0,                  6'd38,                         1'b0,                           1'b0             ,1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b1,                       6'd34,                     6'd35,                  5'd4,                     6'd63,                         6'd1,                  6'd40,                         1'b0,                           1'b0             ,1'b0);
//     end
// endtask;

// task rs_add_fill_entries;
//     begin
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b1,                       6'd34,                     6'd35,                  5'd4,                     6'd63,                         6'd1,                  6'd40,                         1'b0,                           1'b0                 ,1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd6,                     6'd33,                  5'd2,                     6'd63,                         6'd0,                  6'd38,                         1'b0,                           1'b0                 ,1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd36,                     6'd37,                  5'd6,                     6'd63,                         6'd2,                  6'd42,                         1'b0,                           1'b0                 ,1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd38,                     6'd39,                  5'd8,                     6'd63,                         6'd3,                  6'd44,                         1'b0,                           1'b0                 ,1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd34,                     6'd35,                  5'd4,                     6'd63,                         6'd1,                  6'd40,                         1'b0,                           1'b0                 ,1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd36,                     6'd37,                  5'd6,                     6'd63,                         6'd2,                  6'd38,                         1'b0,                           1'b0                 ,1'b0);
        
//     end
// endtask;

// task rs_add_perform_updation;
//     begin           //input logic [1:0] rs_select1, input logic dispatch_valid_t, input logic dispatch_ps_ready1_t, input logic dispatch_ps_ready2_t, input logic [31:0] ps1_t, input logic [31:0] ps2_t, input logic [31:0] rd_t, input logic [31:0] pd_t, input logic [31:0] rob_entry_t, input logic [31:0] cdb_ps_id_t, input logic add_fu_busy_t, input logic multiply_fu_busy_t, input logic divide_fu_busy_t)

//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd32,                     6'd33,                  5'd2,                     6'd63,                         6'd0,                  6'd38,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd6,                     6'd34,                  5'd2,                     6'd63,                         6'd0,                  6'd33,                         1'b0,                           1'b0,                1'b0);
//     end

// endtask;

// task rs_add_one_entry_multiply_one_entry;
//     begin           //input logic [1:0] rs_select1, input logic dispatch_valid_t, input logic dispatch_ps_ready1_t, input logic dispatch_ps_ready2_t, input logic [31:0] ps1_t, input logic [31:0] ps2_t, input logic [31:0] rd_t, input logic [31:0] pd_t, input logic [31:0] rob_entry_t, input logic [31:0] cdb_ps_id_t, input logic add_fu_busy_t, input logic multiply_fu_busy_t, input logic divide_fu_busy_t)
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd6,                     6'd33,                  5'd2,                     6'd63,                         6'd0,                  6'd38,                         1'b0,                           1'b0,            1'b0);
//         standard_task(2'd1,                           1'b1,                                    1'b1,                               1'b0,                       6'd6,                     6'd33,                  5'd2,                     6'd63,                         6'd0,                  6'd38,                         1'b0,                           1'b0,            1'b0);
//     end
// endtask;


// task add_entry_busy;
//     begin
//         rs_add_multiple_entries;
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd6,                     6'd33,                  5'd2,                     6'd63,                         6'd0,                  6'd38,                         1'b1,                           1'b0                 ,1'b0);
        
//     end
// endtask;

// task rs_add_fill_entries_multiply_fill_entries;
//     begin           //input logic [1:0] rs_select1, input logic dispatch_valid_t, input logic dispatch_ps_ready1_t, input logic dispatch_ps_ready2_t, input logic [31:0] ps1_t, input logic [31:0] ps2_t, input logic [31:0] rd_t, input logic [31:0] pd_t, input logic [31:0] rob_entry_t, input logic [31:0] cdb_ps_id_t, input logic add_fu_busy_t, input logic multiply_fu_busy_t, input logic divide_fu_busy_t)
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd6,                     6'd33,                  5'd2,                     6'd63,                         6'd0,                  6'd38,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd1,                           1'b1,                                    1'b1,                               1'b0,                       6'd6,                     6'd33,                  5'd2,                     6'd63,                         6'd0,                  6'd38,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd34,                     6'd35,                  5'd4,                     6'd63,                         6'd1,                  6'd40,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd1,                           1'b1,                                    1'b1,                               1'b0,                       6'd34,                     6'd35,                  5'd4,                     6'd63,                         6'd1,                  6'd40,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd36,                     6'd37,                  5'd6,                     6'd63,                         6'd2,                  6'd42,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd1,                           1'b1,                                    1'b1,                               1'b0,                       6'd36,                     6'd37,                  5'd6,                     6'd63,                         6'd2,                  6'd42,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd38,                     6'd39,                  5'd8,                     6'd63,                         6'd3,                  6'd44,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd1,                           1'b1,                                    1'b1,                               1'b0,                       6'd38,                     6'd39,                  5'd8,                     6'd63,                         6'd3,                  6'd44,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd0,                           1'b1,                                    1'b1,                               1'b0,                       6'd34,                     6'd35,                  5'd4,                     6'd63,                         6'd1,                  6'd40,                         1'b0,                           1'b0,                1'b0);
//         standard_task(2'd1,                           1'b1,                                    1'b1,                               1'b0,                       6'd36,                     6'd37,                  5'd6,                     6'd63,                         6'd2,                  6'd44,                         1'b0,                           1'b0,                1'b0);
//     end
// endtask;
// initial 
// begin
//     generate_reset;
//     rs_add_one_entry;
//     // rs_add_multiple_entries;
//     // rs_add_entry_remove;
//     // rs_add_entry_remove_then_add_one;
//     // rs_add_fill_entries;
//     // rs_add_perform_updation;
//     // rs_add_one_entry_multiply_one_entry;
//     // add_entry_busy;
//     // rs_add_fill_entries_multiply_fill_entries;
//     #100000;
//     $finish;
// end

// endmodule