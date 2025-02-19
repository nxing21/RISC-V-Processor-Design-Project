module cache_arbiter
(
    input   logic   clk,
    input   logic   rst,

    /* INSTRUCTION RELEVANT SIGNALS */
    input   logic   [31:0]  i_dfp_addr,
    input   logic           i_dfp_read,
    output  logic   [255:0] i_dfp_rdata,
    output  logic           i_dfp_resp,   

    // output logic i_dfp_write,            USELESS
    // input logic  [255:0] i_dfp_wdata,    USELESS

    /* DATA RELEVANT SIGNALS */
    input   logic   [31:0]  d_dfp_addr,
    input   logic           d_dfp_read,
    input   logic           d_dfp_write,
    output  logic   [255:0] d_dfp_rdata,
    input   logic   [255:0] d_dfp_wdata,
    output  logic           d_dfp_resp,           

    output  logic   [31:0]  bmem_addr,
    output  logic           bmem_read,
    output  logic           mem_valid,
    output  logic   [255:0] full_burst,
    input   logic           bmem_ready,
    
    input   logic   [255:0] cache_wdata,
    input   logic           cache_valid,
    input   logic           d_cache_valid
);

    // states
    enum int unsigned {
        idle,
        i,
        d
    } state, state_next;

    logic           d_dfp_read_next, d_dfp_read_reg, d_dfp_read_reg2;
    logic           d_dfp_write_next, d_dfp_write_reg, d_dfp_write_reg2;
    logic   [31:0]  d_dfp_addr_next, d_dfp_addr_reg;
    logic   [255:0] full_burst_next, full_burst_reg;

    logic           i_dfp_read_next, i_dfp_read_reg, i_dfp_read_reg2;
    logic   [31:0]  i_dfp_addr_next, i_dfp_addr_reg;
    logic           i_dfp_read_ff;

    logic           missed_i, missed_i_reg;
    logic           missed_d, missed_d_reg;
    logic   [31:0]  missed_i_addr, missed_i_addr_reg;
    logic   [31:0]  missed_d_addr, missed_d_addr_reg;
    logic           missed_rw, missed_rw_reg;

    always_ff @ (posedge clk) begin
        if (rst) begin
            state <= idle;
            d_dfp_read_reg   <= '0;
            d_dfp_read_reg2  <= '0;
            d_dfp_write_reg  <= '0;
            d_dfp_write_reg2 <= '0;
            i_dfp_read_reg   <= '0;
            i_dfp_read_reg2  <= '0;
            i_dfp_read_ff    <= '0;
            i_dfp_addr_reg   <= 32'h1eceb000;
            d_dfp_addr_reg   <= 32'h00000000;
            full_burst_reg   <= '0;

            missed_i_reg <= '0;
            missed_d_reg <= '0;
            missed_i_addr_reg <= '0;
            missed_d_addr_reg <= '0;
            missed_rw_reg <= '0;

        end else if (bmem_ready) begin
            state <= state_next;
            d_dfp_read_reg   <= d_dfp_read_next;
            d_dfp_read_reg2  <= d_dfp_read_reg;
            d_dfp_write_reg  <= d_dfp_write_next;
            d_dfp_write_reg2 <= d_dfp_write_reg;
            i_dfp_read_reg   <= i_dfp_read_next;
            i_dfp_read_reg2  <= i_dfp_read_reg;
            i_dfp_read_ff    <= i_dfp_read;
            i_dfp_addr_reg   <= i_dfp_addr_next;
            d_dfp_addr_reg   <= d_dfp_addr_next;
            full_burst_reg   <= full_burst_next;

            missed_i_reg <= missed_i;
            missed_d_reg <= missed_d;
            missed_i_addr_reg <= missed_i_addr;
            missed_d_addr_reg <= missed_d_addr;
            missed_rw_reg <= missed_rw;

        end else begin
            state <= state;
            d_dfp_read_reg   <= d_dfp_read_reg;
            d_dfp_read_reg2  <= d_dfp_read_reg2;
            d_dfp_write_reg  <= d_dfp_write_reg;
            d_dfp_write_reg2 <= d_dfp_write_reg2;
            i_dfp_read_reg   <= i_dfp_read_reg;
            i_dfp_read_reg2  <= i_dfp_read_reg2;
            i_dfp_read_ff    <= i_dfp_read_ff;
            i_dfp_addr_reg   <= i_dfp_addr_reg;
            d_dfp_addr_reg   <= d_dfp_addr_reg;
            full_burst_reg   <= full_burst_reg;

            missed_i_reg <= missed_i_reg;
            missed_d_reg <= missed_d_reg;
            missed_i_addr_reg <= missed_i_addr_reg;
            missed_d_addr_reg <= missed_d_addr_reg;
            missed_rw_reg <= missed_rw_reg;
        end
    end

    always_comb begin
        state_next = state;
        d_dfp_read_next  = d_dfp_read;
        d_dfp_write_next = d_dfp_write;
        i_dfp_read_next  = i_dfp_read;
        i_dfp_addr_next  = i_dfp_addr;
        d_dfp_addr_next  = d_dfp_addr;
        full_burst_next  = full_burst;

        d_dfp_resp  = '0;
        d_dfp_rdata = '0;
        i_dfp_resp  = '0;
        i_dfp_rdata = '0;
        bmem_read   = '0;
        bmem_addr   = '0;
        mem_valid   = '0;
        full_burst  = '0;

        missed_i = missed_i_reg;
        missed_d = missed_d_reg;
        missed_i_addr = missed_i_addr_reg;
        missed_d_addr = missed_d_addr_reg;
        missed_rw = missed_rw_reg;

        case (state)
            idle: 
            begin
                d_dfp_resp  = '0;
                d_dfp_rdata = '0;
                i_dfp_resp  = '0;
                i_dfp_rdata = '0;
                bmem_read   = '0;
                bmem_addr   = '0;
                mem_valid   = '0;
                full_burst  = '0;

                if (~d_dfp_read && ~d_dfp_write && ~i_dfp_read) begin
                    state_next = idle;
                    d_dfp_read_next  = '0;
                    d_dfp_write_next = '0;
                    i_dfp_read_next  = '0;

                end else if (d_dfp_read || d_dfp_write) begin
                    state_next = d;
                    d_dfp_read_next  = d_dfp_read;
                    d_dfp_write_next = d_dfp_write;
                    d_dfp_addr_next  = d_dfp_addr;
                    full_burst_next  = d_dfp_write ? d_dfp_wdata : full_burst_reg;
                    i_dfp_read_next  = '0;

                    if (i_dfp_read) begin
                        // GO TO I STATE AFTERWARDS
                        missed_i = '1;
                        missed_i_addr = i_dfp_addr;
                    end

                end else if (i_dfp_read) begin
                    state_next = i;
                    d_dfp_read_next  = '0;
                    d_dfp_write_next = '0;
                    i_dfp_read_next  = '1;
                    i_dfp_addr_next  = i_dfp_addr;

                // end else if ((d_dfp_read || d_dfp_write ) && i_dfp_read) begin
                //     state_next = d;
                //     d_dfp_read_next  = (d_dfp_read ? '1 : '0);
                //     d_dfp_write_next = d_dfp_write ? '1 : '0;
                //     d_dfp_addr_next  = d_dfp_addr;
                //     full_burst_next  = d_dfp_write ? d_dfp_wdata : full_burst_reg;
                //     i_dfp_read_next  = '1;
                //     i_dfp_addr_next  = i_dfp_addr;
                end
            end

            i:
            begin
                // send i_reg out to burst memory
                d_dfp_resp  = '0;
                d_dfp_rdata = '0;
                i_dfp_resp  = '0;
                i_dfp_rdata = '0;

                bmem_read  = (i_dfp_read_reg && !i_dfp_read_reg2) ? '1 : '0;
                bmem_addr  = missed_i ? missed_i_addr : i_dfp_addr_reg;
                mem_valid  = '0;
                full_burst = '0;

                missed_i = '0;
                
                if (cache_valid) begin
                    i_dfp_resp  = '1;
                    i_dfp_rdata = cache_wdata;

                end else begin
                    i_dfp_resp  = '0;
                    i_dfp_rdata = '0;
                end

                if (~d_dfp_read && ~d_dfp_write && ~i_dfp_read) begin
                    if (missed_d_reg) begin
                        state_next = d;
                        d_dfp_read_next  = missed_rw_reg ? '0 : '1;
                        d_dfp_write_next = missed_rw_reg ? '1 : '0;
                        d_dfp_addr_next  = missed_d_addr_reg;
                        i_dfp_read_next  = '0;

                    end else begin
                        state_next = idle;
                        d_dfp_read_next  = '0;
                        d_dfp_write_next = '0;
                        i_dfp_read_next  = '0;
                    end
                end

                else if (i_dfp_read) begin
                    state_next = i;
                    d_dfp_read_next  = '0;
                    d_dfp_write_next = '0;
                    i_dfp_read_next  = '1;
                    i_dfp_addr_next  = i_dfp_addr;

                    if ((d_dfp_read || d_dfp_write) && !missed_d_reg) begin
                        // GO TO D STATE AFTERWARDS
                        missed_d = '1;
                        missed_d_addr = d_dfp_addr;
                        missed_rw = d_dfp_write;
                    end

                end else if (d_dfp_read || d_dfp_write) begin
                    state_next = d;
                    d_dfp_read_next  = d_dfp_read  ? '1 : '0;
                    d_dfp_write_next = d_dfp_write ? '1 : '0;
                    d_dfp_addr_next  = d_dfp_addr;
                    i_dfp_read_next  = '0;
                    full_burst_next  = d_dfp_write ? d_dfp_wdata : full_burst_reg;
                end
            end
            
            d:
            begin
                // send d_reg out to burst memory
                d_dfp_resp  = '0;
                d_dfp_rdata = '0;
                i_dfp_resp  = '0;
                i_dfp_rdata = '0;

                bmem_read  = (d_dfp_read_reg && !d_dfp_read_reg2) ? '1 : '0;
                bmem_addr  = missed_d_reg ? missed_d_addr_reg : d_dfp_addr_reg;
                mem_valid  = (d_dfp_write_reg && !d_dfp_write_reg2);
                full_burst = full_burst_reg;

                missed_d = '0;

                if (d_cache_valid) begin
                    d_dfp_resp = '1;
                end

                if (cache_valid) begin
                    d_dfp_rdata = cache_wdata;
                    d_dfp_resp  = '1;
                end

                if (~d_dfp_read && ~d_dfp_write && ~i_dfp_read) begin
                    if (missed_i_reg) begin
                        state_next = i;
                        d_dfp_read_next  = '0;
                        d_dfp_write_next = '0;
                        i_dfp_read_next  = '1;
                        i_dfp_addr_next  = missed_i_addr_reg;

                    end else begin
                        state_next = idle;
                        d_dfp_read_next  = '0;
                        d_dfp_write_next = '0;
                        i_dfp_read_next  = '0;
                    end

                end else if (d_dfp_read || d_dfp_write) begin
                    state_next = d;
                    d_dfp_read_next  = d_dfp_read  ? '1 : '0;
                    d_dfp_write_next = d_dfp_write ? '1 : '0;
                    d_dfp_addr_next  = d_dfp_addr;
                    i_dfp_read_next  = '0;
                    full_burst_next  = d_dfp_write ? d_dfp_wdata : full_burst_reg;

                    if (i_dfp_read && !i_dfp_read_ff) begin
                        // GO TO I STATE AFTERWARDS
                        missed_i = '1;
                        missed_i_addr = i_dfp_addr;
                    end

                end else if (i_dfp_read) begin
                    state_next = i;
                    d_dfp_read_next  = '0;
                    d_dfp_write_next = '0;
                    i_dfp_read_next  = '1;
                    i_dfp_addr_next  = i_dfp_addr;
                end
            end
        endcase
    end
endmodule : cache_arbiter