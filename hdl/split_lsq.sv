// module split_lsq
// import rv32i_types::*;
// #(
//     parameter QUEUE_DEPTH = MEM_QUEUE_DEPTH
// )
// (
//     input   logic           clk,
//     input   logic           rst,

//     // rename/dispatch inputs
//     input   logic   [31:0]  inst,
//     input   logic   [6:0]   opcode,
//     input   logic   [2:0]   funct3,
//     input   logic   [PHYS_REG_BITS - 1:0]   phys_reg_in,
//     input   logic           enqueue_valid,
//     input   logic   [ROB_ADDR_WIDTH- 1:0]   rob_num,
//     input   logic   [ARCH_REG_BITS - 1:0]   rd_dispatch,

//     // adder inputs
//     input   logic   [31:0]  addr,
//     input   logic           addr_valid,
//     input   logic   [$clog2(QUEUE_DEPTH) - 1:0]   mem_idx_in,
//     input   logic   [31:0]  store_wdata,
//     input   logic   [31:0]  rs1_rdata,
//     input   logic   [31:0]  rs2_rdata,
//     input   logic           mem_type,           // 0: load, 1: store

//     // rob inputs
//     input   logic   [ROB_ADDR_WIDTH - 1:0]   commited_rob,

//     // dcache inputs
//     input   logic   [31:0]  data_in,
//     input   logic           data_valid,

//     // outputs
//     output  logic           full,
//     output  cdb_t           cdb_mem,

//     // rename/dispatch outputs
//     output  logic   [$clog2(QUEUE_DEPTH) - 1 :0]   mem_load_idx_out,    // load idx out
//     output  logic   [$clog2(QUEUE_DEPTH) - 1 :0]   mem_store_idx_out,   // store idx out

//     // dcache outputs
//     output  logic   [31:0]  d_addr,
//     output  logic   [3:0]   d_rmask,
//     output  logic   [3:0]   d_wmask,
//     output  logic   [31:0]  d_wdata
// );

//     localparam ADDR_WIDTH = $clog2(QUEUE_DEPTH);

//     logic   [ADDR_WIDTH:0]      load_tail_reg;              // extra bit for overflow
//     logic   [ADDR_WIDTH:0]      load_head_reg;              // extra bit for overflow
//     logic   [ADDR_WIDTH:0]      store_tail_reg;              // extra bit for overflow
//     logic   [ADDR_WIDTH:0]      store_head_reg;              // extra bit for overflow

//     logic   [ADDR_WIDTH:0]      load_tail_next;             // combinational
//     logic   [ADDR_WIDTH:0]      load_head_next;             // combinational
//     logic   [ADDR_WIDTH:0]      store_tail_next;             // combinational
//     logic   [ADDR_WIDTH:0]      store_head_next;             // combinational

//     lsq_entry_t     load_mem [QUEUE_DEPTH];     // extra bit for validity | QUEUE_DEPTH entries with each entry begin DATA_WIDTH+1 size
//     lsq_entry_t     store_mem [QUEUE_DEPTH];     // extra bit for validity | QUEUE_DEPTH entries with each entry begin DATA_WIDTH+1 size

//     lsq_entry_t     enqueue_mem_next;
//     lsq_entry_t     dequeue_mem_next;
//     lsq_entry_t     cache_mem_next;

//     logic           enqueue_reg;
//     logic           dequeue_reg;

//     logic   [ROB_ADDR_WIDTH - 1:0]   rob_num_next;
//     logic   [31:0]  data_in_next;

//     logic           enqueue_valid_next;
//     logic           data_valid_next;
//     logic           addr_valid_next;
//     logic   [ADDR_WIDTH - 1 :0]   mem_idx_in_next;
//     logic   [31:0]  addr_next;
//     logic   [31:0]  store_wdata_next;

//     logic           accessing_cache;

//     logic   [6:0]   opcode_next;
//     logic           load_in_cache, load_in_cache_reg;
//     logic           store_in_cache, store_in_cache;
//     logic           mem_type_next;

//     always_ff @ (posedge clk) begin
//         enqueue_reg <= enqueue_valid;
//         dequeue_reg <= data_valid;

//         if (rst) begin
//             load_tail_reg <= '1;
//             load_head_reg <= '1;
//             store_tail_reg <= '1;
//             store_head_reg <= '1;

//             for (int i = 0; i < QUEUE_DEPTH; i++) begin
//                 load_mem[i] <= '0;
//                 store_mem[i] <= '0;
//             end

//             load_in_cache_reg <= '0;
//             store_in_cache_reg <= '0;

//         end else begin
//             // enqueue
//             if (enqueue_valid_next) begin
//                 if (opcode_next == op_b_load) begin
//                     load_mem[load_tail_next[ADDR_WIDTH - 1:0]] <= enqueue_mem_next;
//                 end else begin
//                     store_mem[store_tail_next[ADDR_WIDTH - 1:0]] <= enqueue_mem_next;
//                 end
//             end
//             // dequeue
//             if (data_valid_next) begin
//                 if (load_in_cache) begin
//                     load_mem[load_head_next[ADDR_WIDTH - 1:0]] <= dequeue_mem_next;
//                 end else begin
//                     store_mem[store_head_next[ADDR_WIDTH - 1:0]] <= dequeue_mem_next;
//                 end
//             end
//             // adder done
//             if (addr_valid_next) begin
//                 if (mem_type_next == '0) begin
//                     load_mem[mem_idx_in_next].addr_ready <= 1'b1; 
//                     load_mem[mem_idx_in_next].addr <= addr_next;
//                     load_mem[mem_idx_in_next].shift_bits <= addr_next[1:0];
//                     load_mem[mem_idx_in_next].store_wdata <= store_wdata_next;
//                     load_mem[mem_idx_in_next].rs1_rdata <= rs1_rdata;
//                     load_mem[mem_idx_in_next].rs2_rdata <= rs2_rdata;
//                 end else begin
//                     store_mem[mem_idx_in_next].addr_ready <= 1'b1; 
//                     store_mem[mem_idx_in_next].addr <= addr_next;
//                     store_mem[mem_idx_in_next].shift_bits <= addr_next[1:0];
//                     store_mem[mem_idx_in_next].store_wdata <= store_wdata_next;
//                     store_mem[mem_idx_in_next].rs1_rdata <= rs1_rdata;
//                     store_mem[mem_idx_in_next].rs2_rdata <= rs2_rdata;
//                 end
//             end
//             // accessing cache
//             if (accessing_cache) begin
//                 mem[head_next[ADDR_WIDTH - 1:0]+1'b1].rmask <= cache_mem_next.rmask;
//                 mem[head_next[ADDR_WIDTH - 1:0]+1'b1].wmask <= cache_mem_next.wmask;
//                 mem[head_next[ADDR_WIDTH - 1:0]+1'b1].wdata <= cache_mem_next.wdata;
//             end
  
//             tail_reg <= tail_next;
//             head_reg <= head_next;

//             load_in_cache_reg <= load_in_cache;
//             store_in_cache_reg <= store_in_cache;
//         end
//     end

//     always_comb begin
//         tail_next = tail_reg;
//         head_next = head_reg;
//         enqueue_mem_next = '0;
//         dequeue_mem_next = '0;
//         cache_mem_next = '0;

//         full = '0;
//         cdb_mem = '0;

//         d_addr = '0;
//         d_rmask = '0;
//         d_wmask = '0;
//         d_wdata = '0;

//         enqueue_valid_next = enqueue_valid;

//         data_valid_next = data_valid;
//         addr_valid_next = addr_valid;
//         mem_idx_in_next = mem_idx_in;
//         addr_next = addr;
//         store_wdata_next = store_wdata;

//         mem_idx_out = tail_reg[ADDR_WIDTH - 1:0] + 1'b1;
//         accessing_cache = '0;

//         opcode_next = opcode;
//         load_in_cache = '0;
//         store_in_cache = '0;
//         mem_type_next = mem_type;

//         if (!rst) begin
//             full = (tail_reg[ADDR_WIDTH - 1:0] == head_reg[ADDR_WIDTH - 1:0]) && (tail_reg[ADDR_WIDTH] != head_reg[ADDR_WIDTH]);    // logic if queue full

//             // send dequeue inst same cycle; update queue next cycle
//             if (data_valid) begin
//                 head_next = head_reg + 1'd1;
//                 dequeue_mem_next = mem[head_reg[ADDR_WIDTH - 1:0]+1'b1];
//                 dequeue_mem_next.valid = 1'b0;

//                 cdb_mem.rob_idx = dequeue_mem_next.rob_num;
//                 cdb_mem.pd_s    = dequeue_mem_next.pd_s;
//                 cdb_mem.rd_s    = dequeue_mem_next.rd_s;
//                 cdb_mem.valid   = '1;
//                 cdb_mem.inst    = dequeue_mem_next.inst;
//                 cdb_mem.addr    = dequeue_mem_next.addr;
//                 cdb_mem.rmask   = dequeue_mem_next.rmask;
//                 cdb_mem.wmask   = dequeue_mem_next.wmask;
//                 cdb_mem.rdata   = (dequeue_mem_next.opcode == op_b_load)  ? data_in : '0;
//                 cdb_mem.wdata   = (dequeue_mem_next.opcode == op_b_store) ? dequeue_mem_next.wdata : '0;
//                 cdb_mem.rs1_rdata = dequeue_mem_next.rs1_rdata;
//                 cdb_mem.rs2_rdata = dequeue_mem_next.rs2_rdata;

//                 if (dequeue_mem_next.opcode == op_b_load) begin
//                     unique case (mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].funct3)
//                         // rd_v = rd_wdata
//                         load_f3_lb : cdb_mem.rd_v = {{24{data_in[7 +8 *mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].shift_bits]}}   , data_in[8 *mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].shift_bits    +: 8 ]};
//                         load_f3_lbu: cdb_mem.rd_v = {{24{1'b0}}                                                , data_in[8 *mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].shift_bits    +: 8 ]};
//                         load_f3_lh : cdb_mem.rd_v = {{16{data_in[15+16*mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].shift_bits[1]]}}, data_in[16*mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].shift_bits[1] +: 16]};
//                         load_f3_lhu: cdb_mem.rd_v = {{16{1'b0}}                                                , data_in[16*mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].shift_bits[1] +: 16]};
//                         load_f3_lw : cdb_mem.rd_v = data_in;
//                         default    : cdb_mem.rd_v = 'x;
//                     endcase
//                 end else begin
//                     cdb_mem.rd_s = '0;
//                     cdb_mem.rd_v = '0;
//                 end

//             // ready to access cache
//             end else if (mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].valid == 1'b1 && mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].addr_ready == 1'b1) begin
//                 d_addr = mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].addr;
                
//                 if (mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].opcode == op_b_load && mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].rob_num == commited_rob) begin
//                     unique case (mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].funct3)
//                         load_f3_lb, load_f3_lbu: d_rmask = 4'b0001 << d_addr[1:0];
//                         load_f3_lh, load_f3_lhu: d_rmask = 4'b0011 << d_addr[1:0];
//                         load_f3_lw             : d_rmask = 4'b1111;
//                         default                : d_rmask = 'x;
//                     endcase

//                 end else if (mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].rob_num == commited_rob) begin
//                     unique case (mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].funct3)
//                         store_f3_sb: d_wmask = 4'b0001 << d_addr[1:0];
//                         store_f3_sh: d_wmask = 4'b0011 << d_addr[1:0];
//                         store_f3_sw: d_wmask = 4'b1111;
//                         default    : d_wmask = 'x;
//                     endcase
                    
//                     unique case (mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].funct3)
//                         store_f3_sb: d_wdata[8 *d_addr[1:0] +: 8 ] = mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].store_wdata[7 :0];
//                         store_f3_sh: d_wdata[16*d_addr[1]   +: 16] = mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].store_wdata[15:0];
//                         store_f3_sw: d_wdata = mem[head_reg[ADDR_WIDTH - 1:0]+1'b1].store_wdata;
//                         default    : d_wdata = 'x;
//                     endcase
//                 end

//                 cache_mem_next.rmask = d_rmask;
//                 cache_mem_next.wmask = d_wmask;
//                 cache_mem_next.wdata = d_wdata;

//                 d_addr[1:0] = 2'b0;
//                 accessing_cache = '1;
//             end
            
//             if (enqueue_valid) begin
//                 if (~full || data_valid) begin
//                     tail_next = tail_reg + 1'b1;
//                     head_next = (head_next == head_reg) ? head_reg : head_reg + 1'd1;   // don't change what dequeue set head_next to
//                     enqueue_mem_next.valid = 1'b1;
//                     enqueue_mem_next.addr_ready = 1'b0;
//                     enqueue_mem_next.addr = 32'bx;
//                     enqueue_mem_next.inst = inst;
//                     enqueue_mem_next.opcode = opcode;
//                     enqueue_mem_next.funct3 = funct3;
//                     enqueue_mem_next.pd_s = phys_reg_in;
//                     enqueue_mem_next.rob_num = rob_num;
//                     enqueue_mem_next.rd_s = rd_dispatch;

//                 end else begin
//                     tail_next = tail_reg; 
//                     head_next = (head_next == head_reg) ? head_reg : head_reg + 1'd1;   // don't change what dequeue set head_next to
//                     enqueue_mem_next = mem[tail_reg[ADDR_WIDTH - 1:0]+1'b1];
//                 end
//             end

//             full = (tail_next[ADDR_WIDTH - 1:0] == head_next[ADDR_WIDTH - 1:0]) && (tail_next[ADDR_WIDTH] != head_next[ADDR_WIDTH]);    // logic if queue full
//         end
//     end

// endmodule : split_lsq
