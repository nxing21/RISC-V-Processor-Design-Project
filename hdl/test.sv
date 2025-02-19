// module test
// import rv32i_types::*;
// (
//     input   logic               clk,
//     input   logic               rst,

//     output  logic   [31:0]      bmem_addr,
//     output  logic               bmem_read,
//     output  logic               bmem_write,
//     output  logic   [63:0]      bmem_wdata,
//     input   logic               bmem_ready,

//     input   logic   [31:0]      bmem_raddr,
//     input   logic   [63:0]      bmem_rdata,
//     input   logic               bmem_rvalid
// );

//     logic   [31:0]  pc, pc_next;

//     logic           cache_valid;
//     logic   [255:0] cache_wdata;

//     // dfp_rdata and dfp_resp from cacheline adapter
//     logic   [31:0]  ufp_addr;
//     logic   [3:0]   ufp_rmask;
//     logic   [3:0]   ufp_wmask;
//     logic   [31:0]  ufp_rdata;
//     logic   [31:0]  ufp_wdata;
//     logic           i_ufp_resp;

//     logic   [31:0]  dfp_addr;
//     logic           dfp_read, dfp_read_reg;
//     logic           dfp_write;
//     logic   [255:0] dfp_rdata;
//     logic   [255:0] dfp_wdata;
//     logic           dfp_resp;

//     logic   [31:0]  d_dfp_addr; // have to get from load
//     logic           d_dfp_read, d_dfp_read_reg; // have to get from load
//     logic           d_dfp_write;     // have to get from load
//     logic   [255:0] d_dfp_rdata;    // have to get from arbiter
//     logic   [255:0] d_dfp_wdata;    // have to get from store
//     logic           d_dfp_resp;     // have to get from arbiter

//     logic   [31:0]  mem_addr;       // from a load or store
//     logic   [3:0]   load_rmask;     // from a load 
//     logic   [3:0]   store_wmask;    // from a store
//     logic   [31:0]  load_rdata;     // from a load
//     logic   [31:0]  store_wdata;    // from a store
//     logic           d_ufp_resp;     // data cache should output this
    

//     logic           initial_flag, initial_flag_reg;     // for initial read AND full_stall reads
//     logic           full_stall;
    
//     logic   [31:0]  bmem_raddr_dummy;

//     /* CP2 SIGNALS */
//     logic   [31:0]  inst;
//     logic           rob_full;
//     logic           iqueue_empty;
//     logic   [4:0]   rd_dispatch, rs1, rs2;
//     logic   [5:0]   pd_dispatch, ps1, ps2;
//     logic           ps1_valid, ps2_valid;
//     logic           regf_we_dispatch;
//     logic   [5:0]   rob_num, rob_num_out;
//     logic   [4:0]   rd_rob;
//     logic   [5:0]   pd_rob;
//     logic           rob_valid;
//     logic   [31:0]  cdb_rd_v;
//     logic   [5:0]   old_pd;
//     logic           enqueue;
//     logic   [5:0]   phys_reg;
//     logic           dequeue;
//     logic           is_free_list_empty;

//     cdb_t           cdb_add, cdb_mul, cdb_div;
//     decode_info_t   decode_info ;

//     decode_info_t add_decode_info;
//     decode_info_t multiply_decode_info;
//     decode_info_t divide_decode_info;
    
//     logic    add_fu_ready;
//     logic multiply_fu_ready;
//     logic divide_fu_ready;

//     logic [5:0] add_rob_entry;
//     logic [5:0] multiply_rob_entry;
//     logic [5:0] divide_rob_entry;

//     logic [5:0] add_pd;
//     logic [5:0] multiply_pd;
//     logic [5:0] divide_pd;

//     logic [4:0] add_rd;
//     logic [4:0 ] multiply_rd;
//     logic [4:0] divide_rd;

//     logic   [1:0]   rs_signal;

//     logic           rs_add_full, rs_mul_full, rs_div_full;

//     logic   [5:0]   ps1_out, ps2_out;
//     logic           ps1_valid_out, ps2_valid_out;

//     logic   [31:0]  rs1_v_add, rs1_v_mul, rs1_v_div, rs2_v_add, rs2_v_mul, rs2_v_div;

//     logic   [5:0]   add_ps1, add_ps2, multiply_ps1, multiply_ps2, divide_ps1, divide_ps2;
    
//     rob_entry_t rob_entry;

//     logic [63:0] order;
//     logic [63:0] order_next;

//     logic full_garbage;
//     logic empty_garbage;

    
//     logic [31:0] prog;

//     logic  [31:0]                    dispatch_pc_rdata;
//     logic  [31:0]                    dispatch_pc_wdata;
//     logic  [63:0]                    dispatch_order;
//     logic  [4:0]                     dispatch_rs1_s;
//     logic  [4:0]                     dispatch_rs2_s;
//     logic  [31:0]                    dispatch_inst;
//     logic                            dispatch_regf_we;

//     always_ff @(posedge clk) begin

//         bmem_raddr_dummy <= bmem_raddr; // useless
//         bmem_wdata <= '0;               // useless

//         if (rst) begin
//             pc <= 32'h1eceb000;
//             initial_flag_reg <= '1;
//             dfp_read_reg <= '0;
//             order  <= '0;
//         end else begin
//             pc <= pc_next;
//             initial_flag_reg <= initial_flag;
//             dfp_read_reg <= dfp_read;
//             order <= order_next;
//         end
//     end

//     always_comb begin
//         if (rst) begin
//             pc_next = pc;
//             initial_flag = '1;
//             ufp_rmask = '0;
//             bmem_read = '0;
            

//         end else begin
//             bmem_read = (!dfp_read_reg && dfp_read) ? '1 : '0;          // bmem_read high on rising dfp_read edge (DOESN'T MATCH TIMING DIAGRAM)

//             if ((initial_flag_reg || i_ufp_resp) && !full_stall && bmem_ready) begin
//                 pc_next = pc + 4;
//                 initial_flag = '0;
//                 ufp_rmask = '1;             
//             end else begin
//                 if (full_stall || !bmem_ready) begin
//                     pc_next = pc;
//                     initial_flag = '1;
//                     ufp_rmask = '0;
//                 end else begin
//                     pc_next = pc;
//                     initial_flag = '0;
//                     ufp_rmask = '0;
//                 end
//             end
//         end
//     end

//     cache cache_d (
//         .clk(clk),
//         .rst(rst),

//         .ufp_addr(d_addr),
//         .ufp_rmask(d_rmask),
//         .ufp_wmask(d_wmask),
//         .ufp_rdata(ufp_rdata),
//         .ufp_wdata(d_wdata),
//         .ufp_resp(ufp_resp),

//         .dfp_addr(),
//         .dfp_read(),
//         .dfp_write(),
//         .dfp_rdata(),        // CONNECT TO BMEM
//         .dfp_wdata(),
//         .dfp_resp()           // CONNECT TO BMEM
//     );

//     memory_queue memory_queue_i (
//         .clk(clk),
//         .rst(rst),
//         .opcode(),
//         .phys_reg_in(),
//         .enqueue_valid(),
//         .rob_num(),
//         .addr(),
//         .addr_valid(),
//         .mem_idx_in(),
//         .commited_rob(),
//         .commited_rob_valid(),
//         .data_in(ufp_rdata),
//         .data_valid(ufp_resp),
//         .rd_v(),
        
//         .phys_reg_out(),
//         .output_valid(),
//         .data_out(),
//         .full(),
//         .mem_idx_out(),
//         .d_addr(d_addr),
//         .d_rmask(d_rmask),
//         .d_wmask(d_wmask),
//         .d_wdata(d_wdata),
//         .rd_s()
//     );

// endmodule : test
