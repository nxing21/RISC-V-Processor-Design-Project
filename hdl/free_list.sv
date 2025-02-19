module free_list
import rv32i_types::*;
#(
    parameter DATA_WIDTH = FREE_LIST_DATA_WIDTH,
    parameter QUEUE_DEPTH = FREE_LIST_DEPTH
)
(
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH - 1:0] wdata_in,
    input logic enqueue_in,

    output logic [DATA_WIDTH - 1:0] rdata_out,
    input logic dequeue_in,

    output logic empty_out,
    input logic global_branch_signal
);

    localparam ADDR_WIDTH = $clog2(QUEUE_DEPTH);

    logic   [$clog2(QUEUE_DEPTH):0] tail_reg;     // extra bit is for the overflow
    logic   [$clog2(QUEUE_DEPTH):0] head_reg;     // extra bit is for the overflow

    logic   [$clog2(QUEUE_DEPTH):0] tail_next;    // combinational
    logic   [$clog2(QUEUE_DEPTH):0] head_next;    // combinational

    logic   [DATA_WIDTH:0] mem [QUEUE_DEPTH];     // extra bit is for validity
    logic   [DATA_WIDTH:0] mem_next [QUEUE_DEPTH];
    logic   [DATA_WIDTH:0] enqueue_mem_next;
    logic   [DATA_WIDTH:0] dequeue_mem_next;

    logic   empty;  // wires, used in sequential logic and in returning output signals

    logic   enqueue_reg, enqueue_next;
    logic   dequeue_reg, dequeue_next;

    assign  empty_out = empty;

    always_ff @ (posedge clk) begin
        enqueue_reg <= enqueue_next;
        dequeue_reg <= dequeue_next;

        if (rst) begin
            tail_reg <= {1'b0, {$clog2(QUEUE_DEPTH){1'b1}}};
            head_reg <= '1;
            
            // i = 32, i < 64 and then and queue indexed at i-32 = i
            for (int i = QUEUE_DEPTH; i < 2 * QUEUE_DEPTH; i++) begin
                mem[i-32] <= physicalIndexing'(i);
            end

        end else begin
            if (enqueue_next) begin
                mem[tail_next[$clog2(QUEUE_DEPTH) - 1:0]] <= enqueue_mem_next;
            end
            
            if (dequeue_next) begin
                mem[head_next[$clog2(QUEUE_DEPTH) - 1:0]] <= dequeue_mem_next;
            end

            tail_reg <= tail_next;
            head_reg <= head_next;
        end
    end

    always_comb begin
        tail_next = tail_reg;
        head_next = head_reg;
        rdata_out = 'x;
        enqueue_mem_next = '0;
        dequeue_mem_next = '0;
        enqueue_next = enqueue_in;
        dequeue_next = dequeue_in;

        if (rst) begin
            empty = '1;
        end else begin
            empty = (tail_reg[ADDR_WIDTH - 1:0] == head_reg[ADDR_WIDTH - 1:0]) && (tail_reg[ADDR_WIDTH] == head_reg[ADDR_WIDTH ]);
        end

        if (dequeue_in) begin
            if (~empty) begin   // worry about the valid bit
                head_next = head_reg + 1'd1;
                dequeue_mem_next = mem[head_reg[ADDR_WIDTH - 1:0] + 1'b1];  // get current data out of the queue 
                dequeue_mem_next[DATA_WIDTH] = 1'b0;                        // not valid anymore
                rdata_out = dequeue_mem_next[DATA_WIDTH - 1:0];
            end else begin
                head_next = head_reg;
                dequeue_mem_next = mem[head_reg[ADDR_WIDTH - 1:0]];         // don't do anything
            end
        end
        
        if (enqueue_in) begin
            tail_next = tail_reg + 1'b1;
            head_next = (dequeue_in && !empty) ? head_reg + 1'd1 : head_reg;
            enqueue_mem_next = {1'b1, wdata_in};
        end

        // tail_next = global_branch_signal ? {1'b0, {$clog2(QUEUE_DEPTH){1'b1}}} : tail_next;
        head_next = global_branch_signal ? {~tail_next[5], tail_next[4:0]} : head_next;

        empty = (tail_next[ADDR_WIDTH - 1:0] == head_next[ADDR_WIDTH - 1:0]) && (tail_next[ADDR_WIDTH] == head_next[ADDR_WIDTH]);   // logic if queue empty
    end

endmodule : free_list
