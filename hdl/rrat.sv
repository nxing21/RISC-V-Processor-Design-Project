module rrat
import rv32i_types::*;

(
    input   logic   clk, rst,
    input   logic   [ARCH_REG_BITS - 1:0]   rd,
    input   logic   [PHYS_REG_BITS-1:0] pd,
    input   logic   regf_we,
    output  logic   enqueue,
    output  logic   [PHYS_REG_BITS-1:0] old_pd,
    output  logic   [PHYS_REG_BITS-1:0] rrat_out[32]
);

    logic [PHYS_REG_BITS-1:0] rrat[32]; // holds mapping from arch register to phys register
    // logic [PHYS_REG_BITS-1:0] rrat_init[32];
    logic [PHYS_REG_BITS-1:0] rrat_next[32];

    // logic [5:0] temp;
    // always_comb begin
    //     temp = 6'b0;
    //     for (int i = 0; i < 32; i++) begin
    //         rrat_init[i] = temp;
    //         temp = temp + 6'b000001;
    //     end
    // end

    always_comb begin
        rrat_next = rrat;

        old_pd = regf_we ? rrat_next[rd] : '0;
        rrat_next[rd] = regf_we ? pd : rrat_next[rd];
        enqueue = (old_pd != 0) ? regf_we : 1'b0;

        rrat_next[0] = '0;

        rrat_out = rrat_next;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rrat[0] <=  6'd0;
            rrat[1] <=  6'd1;
            rrat[2] <=  6'd2;
            rrat[3] <=  6'd3;
            rrat[4] <=  6'd4;
            rrat[5] <=  6'd5;
            rrat[6] <=  6'd6;
            rrat[7] <=  6'd7;
            rrat[8] <=  6'd8;
            rrat[9] <=  6'd9;
            rrat[10] <=  6'd10;
            rrat[11] <=  6'd11;
            rrat[12] <=  6'd12;
            rrat[13] <=  6'd13;
            rrat[14] <=  6'd14;
            rrat[15] <=  6'd15;
            rrat[16] <=  6'd16;
            rrat[17] <=  6'd17;
            rrat[18] <=  6'd18;
            rrat[19] <=  6'd19;
            rrat[20] <=  6'd20;
            rrat[21] <=  6'd21;
            rrat[22] <=  6'd22;
            rrat[23] <=  6'd23;
            rrat[24] <=  6'd24;
            rrat[25] <=  6'd25;
            rrat[26] <=  6'd26;
            rrat[27] <=  6'd27;
            rrat[28] <=  6'd28;
            rrat[29] <=  6'd29;
            rrat[30] <=  6'd30;
            rrat[31] <=  6'd31;
        end else begin
            rrat <= rrat_next;
        end
    end

endmodule : rrat
