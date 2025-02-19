module cpu
import rv32i_types::*;
(
    input   logic               clk,
    input   logic               rst,

    output  logic   [31:0]      bmem_addr,
    output  logic               bmem_read,
    output  logic               bmem_write,
    output  logic   [63:0]      bmem_wdata,
    input   logic               bmem_ready,

    input   logic   [31:0]      bmem_raddr,
    input   logic   [63:0]      bmem_rdata,
    input   logic               bmem_rvalid
);

    logic   [31:0]  pc, pc_next;
    logic           cache_valid; // If bursts are ready
    logic   [255:0] cache_wdata; // bursts (equivalent to dfp_rdata for icache)

    logic proper_enqueue_in;
    /* ufp signals to send to icache */
    logic   [31:0]  ufp_addr;
    logic   [3:0]   ufp_rmask;
    logic   [3:0]   ufp_wmask;
    logic   [31:0]  ufp_rdata;
    logic   [31:0]  ufp_wdata;
    logic           i_ufp_resp;

    /* dfp signals to send to dcache */
    logic   [31:0]  dfp_addr;
    logic           dfp_read, dfp_read_reg;
    logic           dfp_write;
    logic   [255:0] dfp_rdata;
    logic   [255:0] dfp_wdata;
    logic           dfp_resp;

    /* ufp signals to send to dcache from a load or store */
    logic   [31:0]  mem_addr;       // from a load or store
    logic   [3:0]   load_rmask;     // from a load 
    logic   [3:0]   store_wmask;    // from a store
    logic   [31:0]  load_rdata;     // from a load
    logic   [31:0]  store_wdata;    // from a store
    logic           d_ufp_resp;     // data cache should output this

    /* dfp signals to send to dcache */
    logic   [31:0]  d_dfp_addr; // have to get from load
    logic           d_dfp_read, d_dfp_read_reg; // have to get from load
    logic           d_dfp_write;     // have to get from load
    logic   [255:0] d_dfp_rdata;    // have to get from arbiter
    logic   [255:0] d_dfp_wdata;    // have to get from store
    logic           d_dfp_resp;     // have to get from arbiter

    logic    [31:0] fu_mem_store_wdata;             // if store inst and functional unit needs to output the data to store
    logic           initial_flag, initial_flag_reg;     // for initial read AND full_stall reads
    logic           full_stall;
    
    logic   [31:0]  bmem_raddr_dummy; // used to prevent warnings with bmem_raddr
    logic   [255:0] full_burst;       // full burst of data to send to bmem (d_dfp_wdata for d cache)
    logic           mem_valid;        // can write to memory

    /* CP2 SIGNALS */
    logic   [31:0]  inst;
    logic           rob_full;
    logic           iqueue_empty;
    logic   [ARCH_REG_BITS - 1:0]   rd_dispatch, rs1, rs2;
    logic   [PHYS_REG_BITS - 1:0]   pd_dispatch, ps1, ps2;
    logic           ps1_valid, ps2_valid;
    logic           regf_we_dispatch;

    /* specifically for memory instructions */
    logic           mem_regf_we_dispatch; 
    /*                                      */ 

    logic   [ROB_ADDR_WIDTH - 1:0]   rob_num, rob_num_out, rob_head;
    logic   [ARCH_REG_BITS - 1:0]   rd_rob;
    logic   [PHYS_REG_BITS - 1:0]   pd_rob;
    logic           rob_valid;
    logic   [31:0]  cdb_rd_v;
    logic   [PHYS_REG_BITS - 1:0]   old_pd;
    logic           enqueue;
    logic   [PHYS_REG_BITS - 1:0]   phys_reg;
    logic           dequeue, dequeue_free_list;
    logic           is_free_list_empty;

    /* cdb propagations*/
    cdb_t           cdb_add, cdb_mul, cdb_div, cdb_mem, cdb_br;
    decode_info_t   decode_info ;

    /* Decode info*/
    decode_info_t add_decode_info;
    decode_info_t multiply_decode_info;
    decode_info_t divide_decode_info;
    decode_info_t mem_decode_info;
    decode_info_t branch_decode_info;
    
    /* Functional unit ready*/
    logic   add_fu_ready;
    logic   multiply_fu_ready;
    logic   divide_fu_ready;
    logic   mem_fu_ready;
    logic   branch_fu_ready;

    /* rob entries*/
    logic   [ROB_ADDR_WIDTH - 1:0]   add_rob_entry;
    logic   [ROB_ADDR_WIDTH - 1:0]   multiply_rob_entry;
    logic   [ROB_ADDR_WIDTH - 1:0]   divide_rob_entry;
    logic   [ROB_ADDR_WIDTH - 1:0]   mem_rob_entry;
    logic   [ROB_ADDR_WIDTH - 1:0]   branch_rob_entry; 

    /* physical destination registers*/
    logic   [PHYS_REG_BITS - 1:0]   add_pd;
    logic   [PHYS_REG_BITS - 1:0]   multiply_pd;
    logic   [PHYS_REG_BITS - 1:0]   divide_pd;
    logic   [PHYS_REG_BITS - 1:0]   mem_pd;
    logic   [PHYS_REG_BITS - 1:0]   branch_pd;

    /* architectural destination registers */
    logic   [ARCH_REG_BITS - 1:0]   add_rd;
    logic   [ARCH_REG_BITS - 1:0]   multiply_rd;
    logic   [ARCH_REG_BITS - 1:0]   divide_rd;
    logic   [ARCH_REG_BITS - 1:0]   branch_rd;
    logic   [ARCH_REG_BITS - 1:0]   mem_rd;

    /* reservation station select signal*/
    logic   [2:0]   rs_signal;

    /*reservation station full signals*/
    logic           rs_add_full, rs_mul_full, rs_div_full, rs_mem_full, rs_br_full; 

    /* physical register source and valids*/
    logic   [PHYS_REG_BITS - 1:0]   ps1_out, ps2_out;
    logic           ps1_valid_out, ps2_valid_out;

    /* rs1_v, rs2_v*/
    logic   [31:0]  rs1_v_add, rs1_v_mul, rs1_v_div, rs1_v_mem, rs1_v_br, rs2_v_add, rs2_v_mul, rs2_v_div, rs2_v_mem, rs2_v_br; 
    
    /* ps1, ps2*/
    logic   [PHYS_REG_BITS - 1:0]   add_ps1, add_ps2, multiply_ps1, multiply_ps2, divide_ps1, divide_ps2, mem_ps1, mem_ps2, branch_ps1, branch_ps2; 
    
    /* output rob entry, contains rvfi data*/
    rob_entry_t rob_entry;

    /* order */
    logic [63:0] order;
    logic [63:0] order_next;

    /* outputs from pc queue, doesn't mean anything*/
    logic full_garbage;
    logic empty_garbage;
    
    /* pc for pc queue*/
    logic [31:0] prog;
    
    /* rvfi signals output from dispatch stage */
    logic   [31:0]  dispatch_pc_rdata;
    logic   [31:0]  dispatch_pc_wdata;
    logic   [63:0]  dispatch_order;
    logic   [ARCH_REG_BITS - 1:0]   dispatch_rs1_s;
    logic   [ARCH_REG_BITS - 1:0]   dispatch_rs2_s;
    logic   [31:0]  dispatch_inst;
    logic           dispatch_regf_we;

    /* load store queue, dispatch stage*/
    logic   [MEM_ADDR_WIDTH - 1:0]   queue_mem_idx, dispatch_mem_idx;

    /* rob idx for memory instructions (needed to know store) */
    logic   [ROB_ADDR_WIDTH - 1:0]   mem_rob_idx_in;

    /* reservation station, memory functional unit */
    logic   [MEM_ADDR_WIDTH - 1:0]   res_dispatch_mem_idx, fu_mem_idx;

     /* calculated address */
    logic [31:0]    calculated_address;
    
    /* branch enable, branch address */
    logic           global_branch_signal, global_branch_signal_reg;
    logic   [31:0]  global_branch_addr;

    /* RRAT */
    logic   [5:0]   rrat[32];

    /* memory queue full*/
    logic           mem_queue_full;

    /* valid address for load store queue */
    logic           addr_valid;

    logic   [31:0]  fu_rs1_v_mem, fu_rs2_v_mem;

    logic           d_cache_valid;

    /* prefetch stuff */
    logic           prefetch_valid, prefetch_valid_reg, undo_pc, undo_pc_reg;
    logic   [31:0]  prefetch_pc, saved_pc, saved_pc_reg;
    logic           false_resp, dummy_false_resp;
    logic   [31:0]  pc_in;
    logic           prefetch_stall, dummy_prefetch_stall;
    logic   [31:0]  stream_prefetch_addr, dummy_stream_prefetch_addr;
    logic           flip_prefetch;

    // assign  pc_in = pc - 32'd4;

    always_comb begin
        pc_in = pc - 32'd4;

        if (prefetch_valid_reg) begin
            if (flip_prefetch) begin
                pc_in = pc + 32'd32;
                pc_in[4:0] = '0;
            end else begin
                pc_in[4:0] = '0;
            end
        end
    end

    // assign global_branch_signal = cdb_br.pc_select;
    // assign global_branch_addr = cdb_br.pc_branch;

    assign proper_enqueue_in = (global_branch_signal_reg) ? 1'b0 : (i_ufp_resp && !false_resp);

    always_ff @(posedge clk) begin
        bmem_raddr_dummy <= bmem_raddr; // useless

        if (rst) begin
            pc <= 32'h1eceb000;
            initial_flag_reg <= '1;
            dfp_read_reg <= '0;
            order <= '0;
            global_branch_signal_reg <= '0;
            undo_pc_reg <= '0;
            saved_pc_reg <= '0;
            prefetch_valid_reg <= '0;

        end else begin
            pc <= pc_next;
            initial_flag_reg <= initial_flag;
            dfp_read_reg <= dfp_read;
            order <= order_next;
            global_branch_signal_reg <= (i_ufp_resp == '0 && global_branch_signal == '0) ? global_branch_signal_reg : global_branch_signal;
            undo_pc_reg <= undo_pc;
            saved_pc_reg <= saved_pc;
            prefetch_valid_reg <= prefetch_valid;
        end
    end

    always_comb begin
        undo_pc = undo_pc_reg;
        saved_pc = saved_pc_reg;

        if (rst) begin
            pc_next = pc;
            initial_flag = '1;
            ufp_rmask = '0;
            // bmem_read = '0;

        end else begin
            // bmem_read = (!dfp_read_reg && dfp_read) ? '1 : '0;          // bmem_read high on rising dfp_read edge (DOESN'T MATCH TIMING DIAGRAM)
            if (undo_pc_reg && !global_branch_signal) begin
                pc_next = saved_pc_reg;
                undo_pc = '0;
                saved_pc = '0;
                initial_flag = '0;
                ufp_rmask = '0;

            end else begin
                if ((initial_flag_reg || i_ufp_resp) && !full_stall && bmem_ready) begin
                    if (!prefetch_stall) begin
                        pc_next = pc + 4;
                        initial_flag = '0;
                        ufp_rmask = '1;   
                    end else begin
                        pc_next = pc;
                        initial_flag = '0;
                        ufp_rmask = '0;
                    end
                end else begin
                    if (full_stall || !bmem_ready) begin
                        pc_next = pc;
                        initial_flag = '1;
                        ufp_rmask = '0;
                    end else begin
                        pc_next = pc;
                        initial_flag = '0;
                        ufp_rmask = '0;
                    end
                end

                if (global_branch_signal) begin
                    pc_next = global_branch_addr;
                    undo_pc = '0;
                end else if (prefetch_valid) begin
                    pc_next = prefetch_pc;
                    undo_pc = '1;
                    saved_pc = pc;
                end
            end

            // pc_next = global_branch_signal ? global_branch_addr : pc_next;
        end
    end
    
    cache cache_i (
        .clk(clk),
        .rst(rst),

        .ufp_addr(pc),
        .ufp_rmask(ufp_rmask),
        .ufp_wmask('0),             // FILL WHEN WE WANT TO WRITE
        .ufp_rdata(ufp_rdata),
        .ufp_wdata('0),             // FILL WHEN WE WANT TO WRITE
        .ufp_resp(i_ufp_resp),

        .dfp_addr(dfp_addr),
        .dfp_read(dfp_read),
        .dfp_write(dfp_write),
        .dfp_rdata(cache_wdata),
        .dfp_wdata(dfp_wdata),      // FILL WHEN WE WANT TO WRITE
        .dfp_resp(dfp_resp),
        .allow_prefetch('1),
        .prefetch(prefetch_valid_reg),
        .false_resp(false_resp),
        .branch_signal(global_branch_signal),
        .prefetch_stall(prefetch_stall),
        .full_stall(full_stall),
        .stream_prefetch_addr(stream_prefetch_addr)
    );

    prefetch prefetch_i (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .dfp_read(dfp_read),
        .prefetch_valid(prefetch_valid),
        .prefetch_pc(prefetch_pc),
        .branch_signal(global_branch_signal || global_branch_signal_reg),
        .flip_prefetch(flip_prefetch),
        .stream_prefetch_addr(stream_prefetch_addr)
    );

    logic   [31:0]      sb_load_rdata;
    logic               sb_load_resp, sb_store_resp;
    logic               sb_full;

    dcache cache_d (
        .clk(clk),
        .rst(rst),

        .ufp_addr(mem_addr),
        .ufp_rmask(load_rmask),
        .ufp_wmask(store_wmask),
        .ufp_rdata(load_rdata),
        .ufp_wdata(store_wdata),
        .ufp_resp(d_ufp_resp),

        .dfp_addr(d_dfp_addr),
        .dfp_read(d_dfp_read),
        .dfp_write(d_dfp_write),
        .dfp_rdata(d_dfp_rdata),            // CONNECT TO BMEM
        .dfp_wdata(d_dfp_wdata),
        .dfp_resp(d_dfp_resp),              // CONNECT TO BMEM

        .load_data(sb_load_rdata),
        .load_resp(sb_load_resp),
        .store_resp(sb_store_resp),
        .sb_full(sb_full)
    );

    memory_queue memory_queue_i (
        .clk(clk),
        .rst(rst || global_branch_signal),
        .inst(dispatch_inst),
        .opcode(decode_info.opcode),
        .funct3(decode_info.funct3),
        .phys_reg_in(pd_dispatch),          // FROM RENAME DISPATCH
        .enqueue_valid(mem_regf_we_dispatch),   // FROM RENAME DISPATCH
        .rob_num(rob_num),
        .rd_dispatch(rd_dispatch),
        .addr(calculated_address),          // FROM ADDER
        .addr_valid(addr_valid),            // FROM ADDER
        .mem_idx_in(fu_mem_idx),            // FROM ADDER
        .store_wdata(fu_mem_store_wdata),   // FROM ADDER/REGFILE
        .rs1_rdata(fu_rs1_v_mem),
        .rs2_rdata(fu_rs2_v_mem),
        .commited_rob(rob_head),
        .data_in(load_rdata),
        // .data_valid(d_ufp_resp),
        
        // .phys_reg_out(cdb_mem.pd_s),        // OUTPUT RD_S
        // .output_valid(cdb_mem.valid),       // OUTPUT SOMEWHERE
        // .data_out(cdb_mem.rd_v),            // OUTPUT RD_V
        .full(mem_queue_full),
        .cdb_mem(cdb_mem),
        .mem_idx_out(queue_mem_idx),        // OUTPUT TO RENAME DISPATCH
        .d_addr(mem_addr),
        .d_rmask(load_rmask),
        .d_wmask(store_wmask),
        .d_wdata(store_wdata),

        .sb_data_in(sb_load_rdata),
        .sb_data_valid(sb_load_resp),
        .sb_store_resp(sb_store_resp),
        .sb_full(sb_full)
    );

    logic   cur_idle;

    cache_arbiter arbiter (
        .clk(clk),
        .rst(rst),
        .i_dfp_addr(dfp_addr),
        .i_dfp_read(dfp_read),
        .i_dfp_rdata(dfp_rdata),
        .i_dfp_resp(dfp_resp),

        .d_dfp_addr(d_dfp_addr),
        .d_dfp_read(d_dfp_read),
        .d_dfp_write(d_dfp_write),
        .d_dfp_rdata(d_dfp_rdata),
        .d_dfp_wdata(d_dfp_wdata),
        .d_dfp_resp(d_dfp_resp),

        .bmem_addr(bmem_addr),
        .bmem_read(bmem_read),
        .mem_valid(mem_valid),
        .full_burst(full_burst),
        .bmem_ready(bmem_ready),

        .cache_wdata(cache_wdata),
        .cache_valid(cache_valid),
        .d_cache_valid(d_cache_valid)
    );

    // outputs cache_valid if cache_wdata is ready
    cacheline_adapter cache_adapter_i (
        .clk(clk),
        .rst(rst),
        .bmem_rdata(bmem_rdata),
        .bmem_rvalid(bmem_rvalid),
        .full_burst(full_burst),
        .mem_valid(mem_valid),
        .cache_wdata(cache_wdata),
        .cache_valid(cache_valid),
        .d_cache_valid(d_cache_valid),
        .bmem_wdata(bmem_wdata),
        .bmem_write(bmem_write)
    );

    queue #(.DATA_WIDTH(32), .QUEUE_DEPTH(32)) queue_i (
        .clk(clk),
        .rst(rst),
        .wdata_in(ufp_rdata),
        .enqueue_in(proper_enqueue_in),
        .rdata_out(inst),
        .dequeue_in(dequeue),
        .full_out(full_stall),
        .empty_out(iqueue_empty),
        .global_branch_signal(global_branch_signal)
    );

    queue #(.DATA_WIDTH(32), .QUEUE_DEPTH(32)) queue_pc
    (
        .clk(clk),
        .rst(rst),
        .wdata_in(pc_in),
        .enqueue_in(proper_enqueue_in),
        .rdata_out(prog),
        .dequeue_in(dequeue),
        .full_out(full_garbage),
        .empty_out(empty_garbage),
        .global_branch_signal(global_branch_signal)
    );

    rename_dispatch rename_dispatch_i (
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .prog(prog),
        .rob_full(rob_full),
        .rs_full_add(rs_add_full), .rs_full_mul(rs_mul_full), .rs_full_div(rs_div_full), .rs_full_br(rs_br_full), .rs_full_mem(rs_mem_full), // TODO: Change this later for branch
        .is_iqueue_empty(iqueue_empty),
        .phys_reg(phys_reg),
        .is_free_list_empty(is_free_list_empty),
        // .order(order),
        .dequeue(dequeue),
        .dequeue_free_list(dequeue_free_list),
        // .order_next(order_next),
        .rd(rd_dispatch),
        .rs1(rs1),
        .rs2(rs2),
        .pd(pd_dispatch),
        .ps1(ps1),
        .ps2(ps2),
        .ps1_valid(ps1_valid),
        .ps2_valid(ps2_valid),
        .ps1_out(ps1_out),
        .ps2_out(ps2_out),
        .ps1_valid_out(ps1_valid_out),
        .ps2_valid_out(ps2_valid_out),
        .regf_we(regf_we_dispatch),
        .mem_regf_we(mem_regf_we_dispatch),
        .rob_num(rob_num),
        .rob_num_out(rob_num_out),
        .decode_info(decode_info),
        .rs_signal(rs_signal),
        .dispatch_pc_rdata(dispatch_pc_rdata),
        .dispatch_pc_wdata(dispatch_pc_wdata),
        // .dispatch_order(dispatch_order),
        .dispatch_rs1_s(dispatch_rs1_s),
        .dispatch_rs2_s(dispatch_rs2_s),
        .dispatch_inst(dispatch_inst),
        .dispatch_regf_we(dispatch_regf_we),
        .mem_idx_in(queue_mem_idx),
        .mem_idx_out(dispatch_mem_idx),          // PROPAGATE THIS INTO MEM ADDER
        .global_branch_addr(global_branch_addr),
        .global_branch_signal(global_branch_signal)
        );

    rat rat_i (
        .clk(clk),
        .rst(rst),
        .rd_dispatch(rd_dispatch),
        .rs1(rs1), .rs2(rs2),
        .rd_add(cdb_add.rd_s), .rd_mul(cdb_mul.rd_s), .rd_div(cdb_div.rd_s), .rd_br(cdb_br.rd_s), .rd_mem(cdb_mem.rd_s),
        .pd_dispatch(pd_dispatch),
        .pd_add(cdb_add.pd_s), .pd_mul(cdb_mul.pd_s), .pd_div(cdb_div.pd_s), .pd_br(cdb_br.pd_s), .pd_mem(cdb_mem.pd_s),
        .ps1(ps1),
        .ps2(ps2),
        .ps1_valid(ps1_valid),
        .ps2_valid(ps2_valid),
        .regf_we_dispatch(regf_we_dispatch),
        .regf_we_add(cdb_add.valid), .regf_we_mul(cdb_mul.valid), .regf_we_div(cdb_div.valid), .regf_we_br(cdb_br.valid), .regf_we_mem(cdb_mem.valid),
        .decode_info(decode_info),
        .rrat(rrat),
        .global_branch_signal(global_branch_signal_reg)
    );

    rob rob_i (
        .clk(clk),
        .rst(rst),
        .phys_reg_in(pd_dispatch),
        .arch_reg_in(rd_dispatch),
        .enqueue_valid(regf_we_dispatch),
        .pc_rdata(dispatch_pc_rdata),
        .pc_wdata(dispatch_pc_wdata),
        .order(order),
        .rs1_s(dispatch_rs1_s),
        .rs2_s(dispatch_rs2_s),
        .inst(dispatch_inst),
        .regf_we(dispatch_regf_we),
        .add_rob_idx_in(cdb_add.rob_idx),
        .add_cdb_valid(cdb_add.valid),
        .add_inst(cdb_add.inst),
        .mul_rob_idx_in(cdb_mul.rob_idx),
        .mul_cdb_valid(cdb_mul.valid),
        .mul_inst(cdb_mul.inst),
        .div_rob_idx_in(cdb_div.rob_idx),
        .div_cdb_valid(cdb_div.valid),
        .div_inst(cdb_div.inst),
        .br_rob_idx_in(cdb_br.rob_idx),
        .br_cdb_valid(cdb_br.valid),
        .br_inst(cdb_br.inst),
        .mem_rob_idx_in(cdb_mem.rob_idx),
        .mem_cdb_valid(cdb_mem.valid),
        .mem_inst(cdb_mem.inst),
        .order_next(order_next),

        .add_rs1_rdata(rs1_v_add),
        .add_rs2_rdata(rs2_v_add),
        .add_rd_wdata(cdb_add.rd_v),

        .multiply_rs1_rdata(rs1_v_mul),
        .multiply_rs2_rdata(rs2_v_mul),
        .multiply_rd_wdata(cdb_mul.rd_v),

        .divide_rs1_rdata(rs1_v_div),
        .divide_rs2_rdata(rs2_v_div),
        .divide_rd_wdata(cdb_div.rd_v),

        .branch_rs1_rdata(rs1_v_br),
        .branch_rs2_rdata(rs2_v_br),
        .branch_rd_wdata(cdb_br.rd_v),
        .branch_pc_branch(cdb_br.pc_branch),
        .branch_pc_select(cdb_br.pc_select),

        .mem_rs1_rdata(cdb_mem.rs1_rdata),
        .mem_rs2_rdata(cdb_mem.rs2_rdata),
        .mem_rd_wdata(cdb_mem.rd_v),

        .monitor_mem_addr(cdb_mem.addr),
        .monitor_mem_rmask(cdb_mem.rmask),
        .monitor_mem_wmask(cdb_mem.wmask),
        .monitor_mem_rdata(cdb_mem.rdata),
        .monitor_mem_wdata(cdb_mem.wdata),
        .rob_out(rob_entry),
        .dequeue_valid(rob_valid),
        .rob_num(rob_num),
        .rob_head(rob_head),
        .full(rob_full),
        .global_branch_signal(global_branch_signal),
        .global_branch_addr(global_branch_addr)
    );
    
    rrat rrat_i (
        .clk(clk),
        .rst(rst),
        .rd(rob_entry.rvfi.monitor_rd_addr),
        .pd(rob_entry.pd),
        .regf_we(rob_valid),
        .enqueue(enqueue),
        .old_pd(old_pd),
        .rrat_out(rrat)
    );

    free_list free_list_i (
        .clk(clk),
        .rst(rst),
        .wdata_in(old_pd),
        .enqueue_in(enqueue),
        .rdata_out(phys_reg),
        .dequeue_in(dequeue_free_list),
        .empty_out(is_free_list_empty),
        .global_branch_signal(global_branch_signal_reg)
    );

    phys_regfile phys_regfile_i (
        .clk(clk),
        .rst(rst),
        .regf_we_add(cdb_add.valid), .regf_we_mul(cdb_mul.valid), .regf_we_div(cdb_div.valid), .regf_we_br(cdb_br.valid), .regf_we_mem(cdb_mem.valid),
        .rd_v_add(cdb_add.rd_v), .rd_v_mul(cdb_mul.rd_v), .rd_v_div(cdb_div.rd_v), .rd_v_br(cdb_br.rd_v), .rd_v_mem(cdb_mem.rd_v),
        .rs1_add(add_ps1), .rs1_mul(multiply_ps1), .rs1_div(divide_ps1), .rs1_br(branch_ps1), .rs1_mem(mem_ps1),         // SHOULD BE PS
        .rs2_add(add_ps2), .rs2_mul(multiply_ps2), .rs2_div(divide_ps2), .rs2_br(branch_ps2), .rs2_mem(mem_ps2),         // SHOULD BE PS
        .rd_add(cdb_add.pd_s), .rd_mul(cdb_mul.pd_s), .rd_div(cdb_div.pd_s), .rd_br(cdb_br.pd_s), .rd_mem(cdb_mem.pd_s),
        .rs1_v_add(rs1_v_add), .rs1_v_mul(rs1_v_mul), .rs1_v_div(rs1_v_div), .rs1_v_br(rs1_v_br), .rs1_v_mem(rs1_v_mem),
        .rs2_v_add(rs2_v_add), .rs2_v_mul(rs2_v_mul), .rs2_v_div(rs2_v_div), .rs2_v_br(rs2_v_br), .rs2_v_mem(rs2_v_mem),
        .arch_s1_add(add_decode_info.rs1_s), .arch_s2_add(add_decode_info.rs2_s), .arch_rd_add(cdb_add.rd_s), .arch_rd_mul(cdb_mul.rd_s), .arch_rd_div(cdb_div.rd_s), .arch_rd_mem(cdb_mem.rd_s), .arch_s1_mem(mem_decode_info.rs1_s), .arch_s2_mem(mem_decode_info.rs2_s),
        .arch_s1_br(branch_decode_info.rs1_s), .arch_s2_br(branch_decode_info.rs2_s), .arch_rd_br(cdb_br.rd_s)
    );

    logic   start_add, start_mul, start_div, start_br , start_mem;
    logic   busy_add, busy_mul, busy_div, busy_br, busy_mem;

    execute execute_i (
        .clk(clk),
        .rst(rst),
        .rs1_v_add(rs1_v_add), .rs2_v_add(rs2_v_add), .rs1_v_mul(rs1_v_mul), .rs2_v_mul(rs2_v_mul), .rs1_v_div(rs1_v_div), .rs2_v_div(rs2_v_div), .rs1_v_br(rs1_v_br), .rs2_v_br(rs2_v_br), .rs1_v_mem(rs1_v_mem), .rs2_v_mem(rs2_v_mem),
        .decode_info_add(add_decode_info), .decode_info_mul(multiply_decode_info), .decode_info_div(divide_decode_info), .decode_info_br(branch_decode_info), .decode_info_mem(mem_decode_info),
        .start_add(start_add), .start_mul(start_mul), .start_div(start_div), .start_br(start_br), .start_mem(start_mem),
        .busy_add(busy_add), .busy_mul(busy_mul), .busy_div(busy_div), .busy_br(busy_br), .busy_mem(busy_mem),
        .rob_idx_add(add_rob_entry),
        .pd_s_add(add_pd),
        .rd_s_add(add_rd),
        .cdb_add(cdb_add),
        .rob_idx_mul(multiply_rob_entry),
        .pd_s_mul(multiply_pd),
        .rd_s_mul(multiply_rd),
        .cdb_mul(cdb_mul),
        .rob_idx_div(divide_rob_entry),
        .pd_s_div(divide_pd),
        .rd_s_div(divide_rd),
        .cdb_div(cdb_div),
        .rob_idx_br(branch_rob_entry),
        .pd_s_br(branch_pd),
        .rd_s_br(branch_rd),
        .cdb_br(cdb_br),
        // .rob_idx_mem(mem_rob_entry),
        // .pd_s_mem(mem_pd),
        // .rd_s_mem(mem_rd),
        // .cdb_mem(cdb_mem),
        .addr_valid(addr_valid),
        // .global_branch_signal(global_branch_signal),
        .mem_idx_in(res_dispatch_mem_idx),
        .mem_idx_out(fu_mem_idx),
        .store_wdata(fu_mem_store_wdata),
        .calculated_address(calculated_address),
        .fu_rs1_v_mem(fu_rs1_v_mem),
        .fu_rs2_v_mem(fu_rs2_v_mem),
        .global_branch_signal(global_branch_signal)
    );

    reservation_station reservation_stations_i (
        .clk(clk),
        .rst(rst),
        .dispatch_valid(regf_we_dispatch),
        .rs_select(rs_signal),
        .dispatch_ps_ready1(ps1_valid),
        .dispatch_ps_ready2(ps2_valid),
        .ps1(ps1),
        .ps2(ps2),
        .rd(rd_dispatch),
        .pd(pd_dispatch),
        .rob_entry(rob_num),
        .cdb_ps_id_add(cdb_add.pd_s),
        .cdb_ps_id_multiply(cdb_mul.pd_s),
        .cdb_ps_id_divide(cdb_div.pd_s),
        .cdb_ps_id_branch(cdb_br.pd_s),
        .cdb_ps_id_mem(cdb_mem.pd_s),
        .decode_info_in(decode_info),
        
        .add_fu_busy('0),     // WAS SET TO BUSY_ADD
        .multiply_fu_busy(busy_mul),
        .divide_fu_busy(busy_div),
        .branch_fu_busy('0),
        .mem_fu_busy('0), // WAS SET TO BUSY_MEM perhaps don't need?

        // .add_regf_we(),
        // .multiply_regf_we(),
        // .divide_regf_we(),


        .add_fu_ready(start_add),
        .multiply_fu_ready(start_mul),
        .divide_fu_ready(start_div),
        .branch_fu_ready(start_br),
        .mem_fu_ready(start_mem),
        
        .add_rob_entry(add_rob_entry),
        .multiply_rob_entry(multiply_rob_entry),
        .divide_rob_entry(divide_rob_entry),
        .branch_rob_entry(branch_rob_entry),
        .mem_rob_entry(mem_rob_entry),

        .add_pd(add_pd),
        .multiply_pd(multiply_pd), 
        .divide_pd(divide_pd),
        .branch_pd(branch_pd),
        .mem_pd(mem_pd),

        .add_rd(add_rd),
        .multiply_rd(multiply_rd),
        .divide_rd(divide_rd),
        .branch_rd(branch_rd),
        .mem_rd(mem_rd),

        .add_full(rs_add_full),
        .multiply_full(rs_mul_full),
        .divide_full(rs_div_full),
        .branch_full(rs_br_full),
        .mem_full(rs_mem_full),

        .add_decode_info_out(add_decode_info),
        .multiply_decode_info_out(multiply_decode_info),
        .divide_decode_info_out(divide_decode_info),
        .branch_decode_info_out(branch_decode_info),
        .mem_decode_info_out(mem_decode_info),

        .add_ps1(add_ps1),
        .add_ps2(add_ps2),
        .multiply_ps1(multiply_ps1),
        .multiply_ps2(multiply_ps2),
        .divide_ps1(divide_ps1),
        .divide_ps2(divide_ps2),
        .branch_ps1(branch_ps1),
        .branch_ps2(branch_ps2),
        .mem_ps1(mem_ps1),
        .mem_ps2(mem_ps2),

        .regf_we_add(cdb_add.valid),
        .regf_we_mul(cdb_mul.valid),
        .regf_we_div(cdb_div.valid),
        .regf_we_br(cdb_br.valid),
        .regf_we_mem(cdb_mem.valid),
        .mem_idx_in(dispatch_mem_idx),
        .mem_idx_out(res_dispatch_mem_idx),
        .global_branch_signal(global_branch_signal)
    );

endmodule : cpu