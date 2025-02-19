

module reservation_station
import rv32i_types::*;
    (
        input logic  clk,
        input logic  rst,
        // input logic [31:0] instruction,
        
        input logic dispatch_valid,
        input logic [2:0] rs_select  , // select rs, inherit from dispatch, 
        input logic dispatch_ps_ready1   , // if the ps is ready
        input logic dispatch_ps_ready2,     // if the ps is ready
        input logic [PHYS_REG_BITS - 1:0] ps1      , // ps1, inherited from rename/dispatch
        input logic [PHYS_REG_BITS - 1:0] ps2      , // ps2, inherited from rename/dispatch
        input logic [ARCH_REG_BITS - 1:0] rd       ,// the arch dest register, inherited from free list, don't know width
        input logic [PHYS_REG_BITS - 1:0] pd       , // the phys dest register, inherited from free list, don't know width
        input logic [ROB_ADDR_WIDTH - 1:0] rob_entry , // rob entry, inherited from rob, don't know width
        input logic [PHYS_REG_BITS - 1:0] cdb_ps_id_add       ,   // cdb tells us if a busy register can be marked as unbusy
        input logic [PHYS_REG_BITS - 1:0] cdb_ps_id_multiply,
        input logic [PHYS_REG_BITS - 1:0] cdb_ps_id_divide,
        input logic [PHYS_REG_BITS - 1:0] cdb_ps_id_mem,
        input logic [PHYS_REG_BITS - 1:0] cdb_ps_id_branch,
        input decode_info_t decode_info_in,


        input logic add_fu_busy,            // from FU, let us know if FU is busy currently
        input logic multiply_fu_busy,
        input logic divide_fu_busy,
        input logic mem_fu_busy,
        input logic branch_fu_busy,
        
        
        // output logic add_regf_we,           //set based on if we are ready to issue from rs, not sure if we feed to regf or FU
        // output logic multiply_regf_we,
        // output logic divide_regf_we,
        
        output logic add_fu_ready,           // tell FU if we are ready to feed it inputs
        output logic divide_fu_ready,
        output logic multiply_fu_ready,
        output logic mem_fu_ready,
        output logic branch_fu_ready,

        output logic [ROB_ADDR_WIDTH - 1:0] add_rob_entry,
        output logic [ROB_ADDR_WIDTH - 1:0] multiply_rob_entry,
        output logic [ROB_ADDR_WIDTH - 1:0] divide_rob_entry,
        output logic [ROB_ADDR_WIDTH - 1:0] mem_rob_entry,
        output logic [ROB_ADDR_WIDTH - 1:0] branch_rob_entry,

        output logic [PHYS_REG_BITS - 1:0] add_pd,
        output logic [PHYS_REG_BITS - 1:0] multiply_pd,
        output logic [PHYS_REG_BITS - 1:0] divide_pd,
        output logic [PHYS_REG_BITS - 1:0] mem_pd,
        output logic [PHYS_REG_BITS - 1:0] branch_pd,

        output logic [ARCH_REG_BITS - 1:0] add_rd,
        output logic [ARCH_REG_BITS - 1:0] multiply_rd,
        output logic [ARCH_REG_BITS - 1:0] divide_rd,
        output logic [ARCH_REG_BITS - 1:0] mem_rd,
        output logic [ARCH_REG_BITS - 1:0] branch_rd,

        output logic add_full,      // if the RS is full
        output logic multiply_full,
        output logic divide_full,
        output logic mem_full,
        output logic branch_full,

        output decode_info_t add_decode_info_out,
        output decode_info_t multiply_decode_info_out,
        output decode_info_t divide_decode_info_out,
        output decode_info_t mem_decode_info_out,
        output decode_info_t branch_decode_info_out,

        output logic [PHYS_REG_BITS - 1:0] add_ps1,
        output logic [PHYS_REG_BITS - 1:0] add_ps2,

        output logic [PHYS_REG_BITS - 1:0] multiply_ps1,
        output logic [PHYS_REG_BITS - 1:0] multiply_ps2,

        output logic [PHYS_REG_BITS - 1:0] divide_ps1,
        output logic [PHYS_REG_BITS - 1:0] divide_ps2,

        output logic [PHYS_REG_BITS - 1:0] mem_ps1,
        output logic [PHYS_REG_BITS - 1:0] mem_ps2,

        output logic [PHYS_REG_BITS - 1:0] branch_ps1,
        output logic [PHYS_REG_BITS - 1:0] branch_ps2,

        
        // Not sure if CDB might output anything to the RS

        input  logic       regf_we_add,
        input  logic       regf_we_mul,
        input  logic       regf_we_div,
        input  logic       regf_we_br,
        input  logic       global_branch_signal,
        input  logic       regf_we_mem,
        input  logic [MEM_ADDR_WIDTH - 1:0]  mem_idx_in,
        output logic [MEM_ADDR_WIDTH - 1:0]  mem_idx_out

    );

    logic   regf_we_add_reg, regf_we_mul_reg, regf_we_div_reg, regf_we_br_reg, regf_we_mem_reg;

    //actual registers
    // assign mem_idx_out = mem_idx_in;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            regf_we_add_reg <= '0;
            regf_we_mul_reg <= '0;
            regf_we_div_reg <= '0;
            regf_we_br_reg  <= '0;
            regf_we_mem_reg <= '0;
        end else begin
            regf_we_add_reg <= regf_we_add;
            regf_we_mul_reg <= regf_we_mul;
            regf_we_div_reg <= regf_we_div;
            regf_we_br_reg <= regf_we_br;
            regf_we_mem_reg <= regf_we_mem;

        end
    end

    add_reservation_station_data add_reservation_station [NUM_ADD_REGISTERS];
    multiply_reservation_station_data multiply_reservation_station [NUM_MULTIPLY_REGISTERS];
    divide_reservation_station_data divide_reservation_station [NUM_DIVIDE_REGISTERS];
    mem_reservation_station_data mem_reservation_station [NUM_MEM_REGISTERS];
    branch_reservation_station_data branch_reservation_station [NUM_BRANCH_REGISTERS];
    
    // combinational wires
    add_reservation_station_data add_reservation_station_entry_next; // this is for writing a new entry
    multiply_reservation_station_data multiply_reservation_station_entry_next; // this is for writing a new entry
    divide_reservation_station_data divide_reservation_station_entry_next;
    mem_reservation_station_data mem_reservation_station_entry_next;
    branch_reservation_station_data branch_reservation_station_entry_next;

    add_reservation_station_data add_reservation_station_entry_new; // this is for updating an entry, changing it's busy and register flags 
    multiply_reservation_station_data multiply_reservation_station_entry_new; // this is for updating an entry, changing it's busy and register flags
    divide_reservation_station_data divide_reservation_station_entry_new;
    mem_reservation_station_data mem_reservation_station_entry_new;
    branch_reservation_station_data branch_reservation_station_entry_new;


    logic [31:0] next_free_entry; // next free entry

    // assert(entries[next_free_reg].valid != 1) // note left by Alex Maiorov during office hours

    logic [31:0] next_done_add_entry; // next done entry
    logic [31:0] next_done_multiply_entry;
    logic [31:0] next_done_divide_entry;
    logic [31:0] next_done_branch_entry;
    logic [31:0] next_done_mem_entry;


    logic [$clog2(MAX_ISSUES) :0] num_issues;

    logic add_fu_full;          // functional_unit full
    // logic add_fu_full_reg;
    logic multiply_fu_full;
    // logic multiply_fu_full_reg;      // functional_unit full
    logic divide_fu_full;
    // logic divide_fu_full_reg;
    logic branch_fu_full;

    logic mem_fu_full;


    logic [2:0] rs_select_reg; // reg equivalent of rs_select
    logic [PHYS_REG_BITS - 1:0] cdb_ps_id_add_reg;  //reg equivalent of cdb_ps_id_add
    logic [PHYS_REG_BITS - 1:0] cdb_ps_id_multiply_reg;
    logic [PHYS_REG_BITS - 1:0] cdb_ps_id_divide_reg;
    logic [PHYS_REG_BITS - 1:0] cdb_ps_id_branch_reg;
    logic [PHYS_REG_BITS - 1:0] cdb_ps_id_mem_reg;

    
    logic insert_add;
    logic insert_multiply;
    logic insert_divide;
    logic insert_branch;
    logic insert_mem;


    logic remove_add;
    logic remove_multiply;
    logic remove_divide;
    logic remove_branch;
    logic remove_mem;

    // logic busy_reg_dummy; //for testing purposes
    
    always_ff @ (posedge clk)
    begin
        cdb_ps_id_add_reg <= cdb_ps_id_add;
        cdb_ps_id_multiply_reg <= cdb_ps_id_multiply;
        cdb_ps_id_divide_reg <= cdb_ps_id_divide;
        cdb_ps_id_branch_reg <= cdb_ps_id_branch;
        cdb_ps_id_mem_reg <= cdb_ps_id_mem;

        /* * * * * * reset logic * * * * * * */
        if (rst)
        begin
            for (int i = 0 ; i < NUM_ADD_REGISTERS; i ++)
            begin
                add_reservation_station[i] <= '0;
            end
            for (int i = 0 ; i < NUM_MULTIPLY_REGISTERS; i++)
            begin
                multiply_reservation_station[i] <= '0;
            end
            for (int i = 0 ; i < NUM_DIVIDE_REGISTERS; i++)
            begin
                divide_reservation_station[i] <= '0;
            end
            for (int i = 0 ; i < NUM_BRANCH_REGISTERS; i++)
            begin
                branch_reservation_station[i] <= '0;
            end
            for (int i = 0 ; i < NUM_MEM_REGISTERS; i++)
            begin
                mem_reservation_station[i] <= '0;
            end
            rs_select_reg <= '0;
            // add_fu_full_reg <= '0;
            // multiply_fu_full_reg <= '0;
            // busy_reg_dummy <= 1'b0;
        end
        else
        begin

            
            /* * * * * * add entry  * * * * */

            // next_free_entry_reg <= next_free_entry; // track the next free entry
            rs_select_reg <= rs_select;             // which reservation station do we update?
            // add_fu_full_reg <= add_fu_full;                 //
            // multiply_fu_full_reg <= multiply_fu_full;
            // busy_reg_dummy <= add_reservation_station_entry_next.busy;
            if (insert_add && ~add_fu_full)
            begin
                add_reservation_station[next_free_entry] <= add_reservation_station_entry_next; // add a new entry
            end
            if (insert_multiply && ~multiply_fu_full)
            begin
                multiply_reservation_station[next_free_entry] <= multiply_reservation_station_entry_next;
            end
            if (insert_divide && ~divide_fu_full)
            begin
                divide_reservation_station[next_free_entry] <= divide_reservation_station_entry_next;
            end
            if (insert_branch && ~branch_fu_full)
            begin
                branch_reservation_station[next_free_entry] <= branch_reservation_station_entry_next;
            end
            if (insert_mem && ~mem_fu_full)
            begin
                mem_reservation_station[next_free_entry] <= mem_reservation_station_entry_next;
            end

            /* * * * * * * remove entry (if all three valids are high) * * * * * * * */
          
            if (remove_multiply)
            begin
               multiply_reservation_station[next_done_multiply_entry] <= multiply_reservation_station_entry_new;
            end
            if(remove_add)
            begin
                add_reservation_station[next_done_add_entry] <= add_reservation_station_entry_new;
            end
            if (remove_divide)
            begin
                divide_reservation_station[next_done_divide_entry] <= divide_reservation_station_entry_new;
            end
            if (remove_branch)
            begin
                branch_reservation_station[next_done_branch_entry] <= branch_reservation_station_entry_new;
            end
            if (remove_mem)
            begin
                mem_reservation_station[next_done_mem_entry] <= mem_reservation_station_entry_new;
            end
            // /* * * * * * * update entry (according to cdb_ps_id) * * * * *  */

            for (int i = 0; i < NUM_DIVIDE_REGISTERS; i++)
            begin
                // if ((regf_we_div && divide_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul && divide_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (regf_we_add && divide_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (regf_we_div && divide_reservation_station[i].ps1 == cdb_ps_id_divide) || (regf_we_mul && divide_reservation_station[i].ps1 == cdb_ps_id_multiply))
                if (divide_reservation_station[i].busy && ((regf_we_div_reg && divide_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && divide_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (divide_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (divide_reservation_station[i].ps1 == cdb_ps_id_branch_reg) || (divide_reservation_station[i].ps1 == cdb_ps_id_mem_reg)))
                begin
                    divide_reservation_station[i].ps1_v <= 1'b1;
                end
                // if ((regf_we_div && divide_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul && divide_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (regf_we_add && divide_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (regf_we_div && divide_reservation_station[i].ps2 == cdb_ps_id_divide) || (regf_we_mul && divide_reservation_station[i].ps2 == cdb_ps_id_multiply))
                if (divide_reservation_station[i].busy && ((regf_we_div_reg && divide_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && divide_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (divide_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (divide_reservation_station[i].ps2 == cdb_ps_id_branch_reg) || (divide_reservation_station[i].ps2 == cdb_ps_id_mem_reg)))
                begin
                    divide_reservation_station[i].ps2_v <= 1'b1;
                end
            end 

            for (int i = 0; i < NUM_MULTIPLY_REGISTERS; i++)
            begin
                // if ((regf_we_div && multiply_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul && multiply_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (multiply_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (regf_we_div && multiply_reservation_station[i].ps1 == cdb_ps_id_divide) || (regf_we_mul && multiply_reservation_station[i].ps1 == cdb_ps_id_multiply))
                if (multiply_reservation_station[i].busy && ((regf_we_div_reg && multiply_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && multiply_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (multiply_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (multiply_reservation_station[i].ps1 == cdb_ps_id_branch_reg) || ((multiply_reservation_station[i].ps1 == cdb_ps_id_mem_reg))))
                begin
                    multiply_reservation_station[i].ps1_v <= 1'b1;
                end
                // if ((regf_we_div && multiply_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul && multiply_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (multiply_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (regf_we_div && multiply_reservation_station[i].ps2 == cdb_ps_id_divide) || (regf_we_mul && multiply_reservation_station[i].ps2 == cdb_ps_id_multiply))
                if (multiply_reservation_station[i].busy && ((regf_we_div_reg && multiply_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && multiply_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (multiply_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (multiply_reservation_station[i].ps2 == cdb_ps_id_branch_reg) || (multiply_reservation_station[i].ps2 == cdb_ps_id_mem_reg)))
                begin
                    multiply_reservation_station[i].ps2_v <= 1'b1;
                end
            end 

            for (int i = 0 ; i < NUM_ADD_REGISTERS; i++)
            begin
                // if ((regf_we_div && add_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul && add_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (add_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (regf_we_div && add_reservation_station[i].ps1 == cdb_ps_id_divide) || (regf_we_mul && add_reservation_station[i].ps1 == cdb_ps_id_multiply))
                if (add_reservation_station[i].busy && ((regf_we_div_reg && add_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && add_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (add_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (add_reservation_station[i].ps1 == cdb_ps_id_branch_reg) || (add_reservation_station[i].ps1 == cdb_ps_id_mem_reg)))
                begin
                    add_reservation_station[i].ps1_v <= 1'b1;
                end
                // if ((regf_we_div && add_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul && add_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (add_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (regf_we_div && add_reservation_station[i].ps2 == cdb_ps_id_divide) || (regf_we_mul && add_reservation_station[i].ps2 == cdb_ps_id_multiply))
                if (add_reservation_station[i].busy && ((regf_we_div_reg && add_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && add_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (add_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (add_reservation_station[i].ps2 == cdb_ps_id_branch_reg) || (add_reservation_station[i].ps2 == cdb_ps_id_mem_reg)))
                begin
                    add_reservation_station[i].ps2_v <= 1'b1;
                end
            end

           
            
            for (int i = 0; i < NUM_MEM_REGISTERS; i++)
            begin
                // if ((regf_we_div && divide_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul && divide_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (regf_we_add && divide_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (regf_we_div && divide_reservation_station[i].ps1 == cdb_ps_id_divide) || (regf_we_mul && divide_reservation_station[i].ps1 == cdb_ps_id_multiply))
                if (mem_reservation_station[i].busy && ((regf_we_div_reg && mem_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && mem_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (mem_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (mem_reservation_station[i].ps1 == cdb_ps_id_branch_reg) || (mem_reservation_station[i].ps1 == cdb_ps_id_mem_reg)))
                begin
                    mem_reservation_station[i].ps1_v <= 1'b1;
                end
                // if ((regf_we_div && mem_reservation_station[i].ps2 == cdb_ps_id_mem_reg) || (regf_we_mul && mem_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (regf_we_add && mem_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (regf_we_div && mem_reservation_station[i].ps2 == cdb_ps_id_mem) || (regf_we_mul && mem_reservation_station[i].ps2 == cdb_ps_id_multiply))
                if (mem_reservation_station[i].busy && ((regf_we_div_reg && mem_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && mem_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (mem_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (mem_reservation_station[i].ps2 == cdb_ps_id_branch_reg) || (mem_reservation_station[i].ps2 == cdb_ps_id_mem_reg)))
                begin
                    mem_reservation_station[i].ps2_v <= 1'b1;
                end
            end 
            

            for (int i = 0; i < NUM_BRANCH_REGISTERS; i++)
            begin
                // if ((regf_we_div && divide_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul && divide_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (regf_we_add && divide_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (regf_we_div && divide_reservation_station[i].ps1 == cdb_ps_id_divide) || (regf_we_mul && divide_reservation_station[i].ps1 == cdb_ps_id_multiply))
                if (branch_reservation_station[i].busy && ((regf_we_div_reg && branch_reservation_station[i].ps1 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && branch_reservation_station[i].ps1 == cdb_ps_id_multiply_reg) || (branch_reservation_station[i].ps1 == cdb_ps_id_add_reg) || (branch_reservation_station[i].ps1 == cdb_ps_id_branch_reg) || (branch_reservation_station[i].ps1 == cdb_ps_id_mem_reg)))
                begin
                    branch_reservation_station[i].ps1_v <= 1'b1;
                end
                // if ((regf_we_div && divide_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul && divide_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (regf_we_add && divide_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (regf_we_div && divide_reservation_station[i].ps2 == cdb_ps_id_divide) || (regf_we_mul && divide_reservation_station[i].ps2 == cdb_ps_id_multiply))
                if (branch_reservation_station[i].busy && ((regf_we_div_reg && branch_reservation_station[i].ps2 == cdb_ps_id_divide_reg) || (regf_we_mul_reg && branch_reservation_station[i].ps2 == cdb_ps_id_multiply_reg) || (branch_reservation_station[i].ps2 == cdb_ps_id_add_reg) || (branch_reservation_station[i].ps2 == cdb_ps_id_branch_reg) || (branch_reservation_station[i].ps2 == cdb_ps_id_mem_reg)))
                begin
                    branch_reservation_station[i].ps2_v <= 1'b1;
                end
            end 

            if (global_branch_signal) begin
                for (int i = 0 ; i < NUM_ADD_REGISTERS; i ++)
                begin
                    add_reservation_station[i] <= '0;
                end
                for (int i = 0 ; i < NUM_MULTIPLY_REGISTERS; i++)
                begin
                    multiply_reservation_station[i] <= '0;
                end
                for (int i = 0 ; i < NUM_DIVIDE_REGISTERS; i++)
                begin
                    divide_reservation_station[i] <= '0;
                end
                for (int i = 0 ; i < NUM_BRANCH_REGISTERS; i++)
                begin
                    branch_reservation_station[i] <= '0;
                end
                for (int i = 0 ; i < NUM_MEM_REGISTERS; i++)
                begin
                    mem_reservation_station[i] <= '0;
                end
            end
        end
    end



    /* * * * * * * * * * * Input logic, add entry * * * * * * * * * * * * * * */
    always_comb
    begin
        insert_add = 1'b0;
        insert_multiply = 1'b0;
        insert_divide = 1'b0;
        insert_branch = 1'b0;
        insert_mem = 1'b0;
        add_reservation_station_entry_next = add_reservation_station[0];
        multiply_reservation_station_entry_next = multiply_reservation_station[0];
        divide_reservation_station_entry_next = divide_reservation_station[0];
        branch_reservation_station_entry_next = branch_reservation_station[0];
        mem_reservation_station_entry_next = mem_reservation_station[0];

        next_free_entry = '0;

        /* * * * * * * We selected Add RS * * * * * * */
        if (dispatch_valid)
        begin
            if (rs_select == 3'd0) 
            begin
                insert_add = 1'b1;
                add_reservation_station_entry_next.busy = 1'b1; // mark as busy
                // add_reservation_station_entry_next.ps1_v = dispatch_ps_ready1;
                // add_reservation_station_entry_next.ps2_v = dispatch_ps_ready2;
                add_reservation_station_entry_next.ps1 = ps1;
                add_reservation_station_entry_next.ps2 = ps2;
                add_reservation_station_entry_next.pd = pd;
                add_reservation_station_entry_next.rd = rd;
                add_reservation_station_entry_next.rob_entry = rob_entry;
                add_reservation_station_entry_next.decode_info = decode_info_in;

                add_reservation_station_entry_next.ps1_v = ((regf_we_add && cdb_ps_id_add == ps1) || (regf_we_mul && cdb_ps_id_multiply == ps1) || (regf_we_div && cdb_ps_id_divide == ps1) || (regf_we_br && cdb_ps_id_branch == ps1) || (regf_we_mem && cdb_ps_id_mem == ps1)) ? '1 : dispatch_ps_ready1;
                add_reservation_station_entry_next.ps2_v = ((regf_we_add && cdb_ps_id_add == ps2) || (regf_we_mul && cdb_ps_id_multiply == ps2) || (regf_we_div && cdb_ps_id_divide == ps2) || (regf_we_br && cdb_ps_id_branch == ps2) || (regf_we_mem && cdb_ps_id_mem == ps2)) ? '1 : dispatch_ps_ready2;
                for (int unsigned i = 0; i < NUM_ADD_REGISTERS; i++)
                begin
                    if (~add_reservation_station[i].busy)
                    begin
                        next_free_entry = i;
                        break;
                    end
                end
            end

        /* * * * * * * We selected Multiply RS * * * * * * */

            else if (rs_select == 3'd1) 
            begin
                insert_multiply = 1'b1;
                multiply_reservation_station_entry_next.busy = 1'b1; // mark as busy
                // multiply_reservation_station_entry_next.ps1_v = dispatch_ps_ready1;
                // multiply_reservation_station_entry_next.ps2_v = dispatch_ps_ready2;
                multiply_reservation_station_entry_next.ps1 = ps1;
                multiply_reservation_station_entry_next.ps2 = ps2;
                multiply_reservation_station_entry_next.pd = pd;
                multiply_reservation_station_entry_next.rd = rd;
                multiply_reservation_station_entry_next.rob_entry = rob_entry;
                multiply_reservation_station_entry_next.decode_info = decode_info_in;

                // multiply_reservation_station_entry_next.ps1_v = (cdb_ps_id_add == ps1 || cdb_ps_id_multiply == ps1 || cdb_ps_id_divide == ps1) ? '1 : dispatch_ps_ready1;
                // multiply_reservation_station_entry_next.ps2_v = (cdb_ps_id_add == ps2 || cdb_ps_id_multiply == ps2 || cdb_ps_id_divide == ps2) ? '1 : dispatch_ps_ready2;
                multiply_reservation_station_entry_next.ps1_v = ((regf_we_add && cdb_ps_id_add == ps1) || (regf_we_mul && cdb_ps_id_multiply == ps1) || (regf_we_div && cdb_ps_id_divide == ps1) || (regf_we_br && cdb_ps_id_branch == ps1) || (regf_we_mem && cdb_ps_id_mem == ps1)) ? '1 : dispatch_ps_ready1;
                multiply_reservation_station_entry_next.ps2_v = ((regf_we_add && cdb_ps_id_add == ps2) || (regf_we_mul && cdb_ps_id_multiply == ps2) || (regf_we_div && cdb_ps_id_divide == ps2) || (regf_we_br && cdb_ps_id_branch == ps2) || (regf_we_mem && cdb_ps_id_mem == ps2)) ? '1 : dispatch_ps_ready2;
                for (int unsigned i = 0; i < NUM_MULTIPLY_REGISTERS; i++)
                begin
                    if (~multiply_reservation_station[i].busy)
                    begin
                        next_free_entry = i;
                        break;
                    end
                end
            end

            else if (rs_select == 3'd2) 
            begin
                insert_divide = 1'b1;
                divide_reservation_station_entry_next.busy = 1'b1; // mark as busy
                // divide_reservation_station_entry_next.ps1_v = dispatch_ps_ready1;
                // divide_reservation_station_entry_next.ps2_v = dispatch_ps_ready2;
                divide_reservation_station_entry_next.ps1 = ps1;
                divide_reservation_station_entry_next.ps2 = ps2;
                divide_reservation_station_entry_next.pd = pd;
                divide_reservation_station_entry_next.rd = rd;
                divide_reservation_station_entry_next.rob_entry = rob_entry;
                divide_reservation_station_entry_next.decode_info = decode_info_in;

                // divide_reservation_station_entry_next.ps1_v = (cdb_ps_id_add == ps1 || cdb_ps_id_multiply == ps1 || cdb_ps_id_divide == ps1) ? '1 : dispatch_ps_ready1;
                // divide_reservation_station_entry_next.ps2_v = (cdb_ps_id_add == ps2 || cdb_ps_id_multiply == ps2 || cdb_ps_id_divide == ps2) ? '1 : dispatch_ps_ready2;
                divide_reservation_station_entry_next.ps1_v = ((regf_we_add && cdb_ps_id_add == ps1) || (regf_we_mul && cdb_ps_id_multiply == ps1) || (regf_we_div && cdb_ps_id_divide == ps1) || (regf_we_br && cdb_ps_id_branch == ps1) || (regf_we_mem && cdb_ps_id_mem == ps1)) ? '1 : dispatch_ps_ready1;
                divide_reservation_station_entry_next.ps2_v = ((regf_we_add && cdb_ps_id_add == ps2) || (regf_we_mul && cdb_ps_id_multiply == ps2) || (regf_we_div && cdb_ps_id_divide == ps2) || (regf_we_br && cdb_ps_id_branch == ps2) || (regf_we_mem && cdb_ps_id_mem == ps2)) ? '1 : dispatch_ps_ready2;
                
                for (int unsigned i = 0; i < NUM_DIVIDE_REGISTERS; i++)
                begin
                    if (~divide_reservation_station[i].busy)
                    begin
                        next_free_entry = i;
                        break;
                    end
                end
            end

            else if (rs_select == 3'd3) 
            begin
                insert_branch = 1'b1;
                branch_reservation_station_entry_next.busy = 1'b1; // mark as busy
                branch_reservation_station_entry_next.ps1 = ps1;
                branch_reservation_station_entry_next.ps2 = ps2;
                branch_reservation_station_entry_next.pd = pd;
                branch_reservation_station_entry_next.rd = rd;
                branch_reservation_station_entry_next.rob_entry = rob_entry;
                branch_reservation_station_entry_next.decode_info = decode_info_in;
                branch_reservation_station_entry_next.ps1_v = ((regf_we_add && cdb_ps_id_add == ps1) || (regf_we_mul && cdb_ps_id_multiply == ps1) || (regf_we_div && cdb_ps_id_divide == ps1) || (regf_we_br && cdb_ps_id_branch == ps1)|| (regf_we_mem && cdb_ps_id_mem == ps1)) ? '1 : dispatch_ps_ready1;
                branch_reservation_station_entry_next.ps2_v = ((regf_we_add && cdb_ps_id_add == ps2) || (regf_we_mul && cdb_ps_id_multiply == ps2) || (regf_we_div && cdb_ps_id_divide == ps2) || (regf_we_br && cdb_ps_id_branch == ps2)|| (regf_we_mem && cdb_ps_id_mem == ps2)) ? '1 : dispatch_ps_ready2;
            
                for (int unsigned i = 0; i < NUM_BRANCH_REGISTERS; i++)
                begin
                    if (~branch_reservation_station[i].busy)
                    begin
                        next_free_entry = i;
                        break;
                    end
                end
            end
            else if (rs_select == 3'd4) 
            begin
                insert_mem = 1'b1;
                mem_reservation_station_entry_next.busy = 1'b1; // mark as busy
                mem_reservation_station_entry_next.ps1 = ps1;
                mem_reservation_station_entry_next.ps2 = ps2;
                mem_reservation_station_entry_next.pd = pd;
                mem_reservation_station_entry_next.rd = rd;
                mem_reservation_station_entry_next.rob_entry = rob_entry;
                mem_reservation_station_entry_next.decode_info = decode_info_in;
                mem_reservation_station_entry_next.ps1_v = ((regf_we_add && cdb_ps_id_add == ps1) || (regf_we_mul && cdb_ps_id_multiply == ps1) || (regf_we_div && cdb_ps_id_divide == ps1) || (regf_we_br && cdb_ps_id_branch == ps1)|| (regf_we_mem && cdb_ps_id_mem == ps1)) ? '1 : dispatch_ps_ready1;
                mem_reservation_station_entry_next.ps2_v = ((regf_we_add && cdb_ps_id_add == ps2) || (regf_we_mul && cdb_ps_id_multiply == ps2) || (regf_we_div && cdb_ps_id_divide == ps2) || (regf_we_br && cdb_ps_id_branch == ps2)|| (regf_we_mem && cdb_ps_id_mem == ps2)) ? '1 : dispatch_ps_ready2;
                mem_reservation_station_entry_next.mem_idx = mem_idx_in;
                
                for (int unsigned i = 0; i < NUM_MEM_REGISTERS; i++)
                begin
                    if (~mem_reservation_station[i].busy)
                    begin
                        next_free_entry = i;
                        break;
                    end
                end
            end
        end
    end
    /* * * * * * * * * Input logic, remove entry * * * * * * */
  
    always_comb
    begin
        num_issues = '0;
        // add_regf_we = 1'b0;
        // multiply_regf_we = 1'b0;
        // divide_regf_we = 1'b0;

        add_reservation_station_entry_new = add_reservation_station[0];
        multiply_reservation_station_entry_new = multiply_reservation_station[0];
        divide_reservation_station_entry_new = divide_reservation_station[0];
        branch_reservation_station_entry_new = branch_reservation_station[0];
        mem_reservation_station_entry_new = mem_reservation_station[0];

        next_done_multiply_entry = '0;
        next_done_add_entry = '0;
        next_done_divide_entry = '0;
        next_done_branch_entry = '0;
        next_done_mem_entry = '0;


        multiply_fu_ready = 1'b0;
        add_fu_ready = 1'b0;
        divide_fu_ready = 1'b0;
        branch_fu_ready = 1'b0;
        mem_fu_ready = 1'b0;

        add_pd = '0;
        multiply_pd = '0;
        divide_pd = '0;
        branch_pd = '0;
        mem_pd = '0;

        add_rob_entry = '0;
        multiply_rob_entry = '0;
        divide_rob_entry = '0;
        branch_rob_entry = '0;
        mem_rob_entry = '0;

        add_rd = '0;
        multiply_rd  = '0;
        divide_rd = '0;
        branch_rd = '0;
        mem_rd = '0;

        remove_add = 1'b0;
        remove_multiply = 1'b0;
        remove_divide = 1'b0;
        remove_branch = 1'b0;
        remove_mem = 1'b0;

        add_decode_info_out = '0;
        multiply_decode_info_out = '0;
        divide_decode_info_out = '0;
        branch_decode_info_out = '0;
        mem_decode_info_out = '0;

        add_ps1 = '0;
        add_ps2 = '0;

        multiply_ps1 = '0;
        multiply_ps2 = '0;

        divide_ps1 = '0;
        divide_ps2 = '0;

        branch_ps2 = '0;
        branch_ps1 = '0;

        mem_ps2 = '0;
        mem_ps1 = '0;

        mem_idx_out = '0;
        
        if (~multiply_fu_busy && (num_issues <= 3'd5))
        begin
            for (int unsigned i = 0; i < NUM_MULTIPLY_REGISTERS; i++)
            begin
                if (multiply_reservation_station[i].busy && multiply_reservation_station[i].ps1_v && multiply_reservation_station[i].ps2_v)
                begin    
                    next_done_multiply_entry = i;
                    multiply_reservation_station_entry_new = multiply_reservation_station[i];
                    multiply_reservation_station_entry_new.busy = 1'b0;
                    // multiply_regf_we = 1'b1;
                    multiply_fu_ready = 1'b1;
                    multiply_pd = multiply_reservation_station_entry_new.pd;
                    multiply_rd = multiply_reservation_station_entry_new.rd;
                    multiply_rob_entry = multiply_reservation_station_entry_new.rob_entry;
                    multiply_decode_info_out = multiply_reservation_station_entry_new.decode_info;
                    num_issues = num_issues + 1'd1;
                    remove_multiply = 1'b1;
                    multiply_ps1 = multiply_reservation_station_entry_new.ps1;
                    multiply_ps2 = multiply_reservation_station_entry_new.ps2;
                    break;
                end
            end
        end

        if (~add_fu_busy && (num_issues <= 3'd5))
        begin
            for (int unsigned i = 0; i < NUM_ADD_REGISTERS; i++)
            begin
                if (add_reservation_station[i].busy && add_reservation_station[i].ps1_v && add_reservation_station[i].ps2_v)
                begin
                    next_done_add_entry = i;
                    add_reservation_station_entry_new = add_reservation_station[i];
                    add_reservation_station_entry_new.busy = 1'b0;
                    // add_regf_we = 1'b1;
                    add_fu_ready = 1'b1;
                    add_pd = add_reservation_station_entry_new.pd;
                    add_rd = add_reservation_station_entry_new.rd;
                    add_rob_entry = add_reservation_station_entry_new.rob_entry;
                    add_decode_info_out = add_reservation_station_entry_new.decode_info;
                    remove_add = 1'b1;
                    num_issues = num_issues + 1'd1;
                    add_ps1 = add_reservation_station_entry_new.ps1;
                    add_ps2 = add_reservation_station_entry_new.ps2;
                    break;
                end
            end
        end
        if (~divide_fu_busy && (num_issues <= 3'd5))
        begin
            for (int unsigned i = 0; i < NUM_DIVIDE_REGISTERS; i++)
            begin
                if (divide_reservation_station[i].busy && divide_reservation_station[i].ps1_v && divide_reservation_station[i].ps2_v)
                begin    
                    next_done_divide_entry = i;
                    divide_reservation_station_entry_new = divide_reservation_station[i];
                    divide_reservation_station_entry_new.busy = 1'b0;
                    // divide_regf_we = 1'b1;
                    divide_fu_ready = 1'b1;
                    divide_pd = divide_reservation_station_entry_new.pd;
                    divide_rd = divide_reservation_station_entry_new.rd;
                    divide_rob_entry = divide_reservation_station_entry_new.rob_entry;
                    divide_decode_info_out = divide_reservation_station_entry_new.decode_info;
                    num_issues = num_issues + 1'd1;
                    remove_divide = 1'b1;
                    divide_ps1 = divide_reservation_station_entry_new.ps1;
                    divide_ps2 = divide_reservation_station_entry_new.ps2;
                    break;
                end
            end
        end
        if (~branch_fu_busy && (num_issues <= 3'd5))
        begin
            for (int unsigned i = 0; i < NUM_BRANCH_REGISTERS; i++)
            begin
                if (branch_reservation_station[i].busy && branch_reservation_station[i].ps1_v && branch_reservation_station[i].ps2_v)
                begin    
                    next_done_branch_entry = i;
                    branch_reservation_station_entry_new = branch_reservation_station[i];
                    branch_reservation_station_entry_new.busy = 1'b0;
                    branch_fu_ready = 1'b1;
                    branch_pd = branch_reservation_station_entry_new.pd;
                    branch_rd = branch_reservation_station_entry_new.rd;
                    branch_rob_entry = branch_reservation_station_entry_new.rob_entry;
                    branch_decode_info_out = branch_reservation_station_entry_new.decode_info;
                    num_issues = num_issues + 1'd1;
                    remove_branch = 1'b1;
                    branch_ps1 = branch_reservation_station_entry_new.ps1;
                    branch_ps2 = branch_reservation_station_entry_new.ps2;
                    break;
                end
            end
        end

        if (~mem_fu_busy && (num_issues <= 3'd5))
        begin
            for (int unsigned i = 0; i < NUM_MEM_REGISTERS; i++)
            begin
                if (mem_reservation_station[i].busy && mem_reservation_station[i].ps1_v && mem_reservation_station[i].ps2_v)
                begin    
                    next_done_mem_entry = i;
                    mem_reservation_station_entry_new = mem_reservation_station[i];
                    mem_reservation_station_entry_new.busy = 1'b0;
                    mem_fu_ready = 1'b1;
                    mem_pd = mem_reservation_station_entry_new.pd;
                    mem_rd = mem_reservation_station_entry_new.rd;
                    mem_rob_entry = mem_reservation_station_entry_new.rob_entry;
                    mem_decode_info_out = mem_reservation_station_entry_new.decode_info;
                    num_issues = num_issues + 1'd1;
                    remove_mem = 1'b1;
                    mem_ps1 = mem_reservation_station_entry_new.ps1;
                    mem_ps2 = mem_reservation_station_entry_new.ps2;
                    mem_idx_out = mem_reservation_station_entry_new.mem_idx;
                    break;
                end
            end
        end

        /**
        * Add more as time goes on. WE NEED to output stuff in this logic
        */
    end


    /* * * * * * * * * Full Logic * * * * * * * * * */

    always_comb
    begin
        add_fu_full = 1'd1;
        multiply_fu_full = 1'd1;
        divide_fu_full = 1'd1;
        branch_fu_full = 1'd1;
        mem_fu_full = 1'd1;

        for (int i = 0; i < NUM_ADD_REGISTERS; i++)
        begin
            if (~add_reservation_station[i].busy)
            begin
                add_fu_full = 1'b0;
                break;
            end
        end
        for (int i = 0; i < NUM_MULTIPLY_REGISTERS; i++)
        begin
            if (~multiply_reservation_station[i].busy)
            begin
                multiply_fu_full = 1'b0;
                break;
            end
        end
        for (int i = 0; i < NUM_DIVIDE_REGISTERS; i++)
        begin
            if (~divide_reservation_station[i].busy)
            begin
                divide_fu_full = 1'b0;
                break;
            end
        end
        for (int i = 0; i < NUM_BRANCH_REGISTERS; i++)
        begin
            if (~branch_reservation_station[i].busy)
            begin
                branch_fu_full = 1'b0;
                break;
            end
        end
        for (int i = 0; i < NUM_MEM_REGISTERS; i++)
        begin
            if (~mem_reservation_station[i].busy)
            begin
                mem_fu_full = 1'b0;
                break;
            end
        end
    end 

    /* * * * * * * * * Output logic * * * * * * * * * */
    assign add_full = add_fu_full;
    assign multiply_full = multiply_fu_full;
    assign divide_full = divide_fu_full;
    assign branch_full = branch_fu_full;
    assign mem_full = mem_fu_full;

endmodule : reservation_station