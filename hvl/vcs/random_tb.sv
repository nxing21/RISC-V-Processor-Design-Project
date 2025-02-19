//-----------------------------------------------------------------------------
// Title                 : random_tb
// Project               : ECE 411 mp_verif
//-----------------------------------------------------------------------------
// File                  : random_tb.sv
// Author                : ECE 411 Course Staff
//-----------------------------------------------------------------------------
// IMPORTANT: If you don't change the random seed, every time you do a `make run`
// you will run the /same/ random test. SystemVerilog calls this "random stability",
// and it's to ensure you can reproduce errors as you try to fix the DUT. Make sure
// to change the random seed or run more instructions if you want more extensive
// coverage.
//------------------------------------------------------------------------------
module random_tb
    import rv32i_types::*;
    (
        mem_itf_banked.mem itf
    );
    
        `include "../../hvl/vcs/randinst.svh"
    
        RandInst gen0 = new();
        RandInst gen1 = new();

        RandInst gen2 = new();
        RandInst gen3 = new();

        RandInst gen4 = new();
        RandInst gen5 = new();

        RandInst gen6 = new();
        RandInst gen7 = new();

        // itf.rdata = ...

        
        // Do a bunch of LUIs to get useful register state.
        task init_register_state();
            for (int i = 0; i < 32; ++i) begin
                @(posedge itf.clk iff  itf.read);
                gen0.randomize() with {
                    instr.j_type.opcode == op_b_lui;
                    instr.j_type.rd == i[4:0];
                };

                gen1.randomize() with {
                    instr.j_type.opcode == op_b_lui;
                    instr.j_type.rd == i[4:0];
                };
    
                // Your code here: package these memory interactions into a task.
                itf.rdata <= {gen1.instr.word ,gen0.instr.word};
                itf.ready <= 1'b1;
                itf.rvalid <= 1'b1;
            end
        endtask : init_register_state
    
        // Note that this memory model is not consistent! It ignores
        // writes and always reads out a random, valid instruction.
        task run_random_instrs();
            repeat (50000) begin
                logic [255:0] four_bursts;
                // repeat (4) @ (posedge itf.clk)
                @(posedge itf.clk iff ( itf.read));
    
                // Always read out a valid instruction.
                // if (|itf.read) begin
                    gen0.randomize();
                    gen1.randomize();
                    gen2.randomize();
                    gen3.randomize();
                    gen4.randomize();
                    gen5.randomize();
                    gen6.randomize();
                    gen7.randomize();

                    four_bursts[31:0] <= gen0.instr.word;
                    four_bursts[63:32] <= gen1.instr.word;
                    four_bursts[95:64] <= gen2.instr.word;
                    four_bursts[127:96] <= gen3.instr.word;
                    four_bursts[159:128] <= gen4.instr.word;
                    four_bursts[191:160] <= gen5.instr.word;
                    four_bursts[223:192] <= gen6.instr.word;
                    four_bursts[255:224] <= gen7.instr.word;
                // end

                    @ (posedge itf.clk)
                    itf.rdata <= four_bursts[63:0];
                    itf.rvalid <= 1'b1;
                    itf.raddr <= itf.addr;
                    @ (posedge itf.clk);

                    itf.rdata <= four_bursts[127:64];
                    itf.rvalid <= 1'b1;
                    itf.raddr <= itf.addr;
                    @(posedge itf.clk);

                    itf.rdata <= four_bursts[191:128];
                    itf.rvalid <= 1'b1;
                    itf.raddr <= itf.addr;
                    @(posedge itf.clk);

                    itf.rdata <= four_bursts[255:192];
                // If it's a write, do nothing and just respond.
                    itf.rvalid <= 1'b1;
                    itf.raddr <= itf.addr;
                    @(posedge itf.clk) 
                    itf.raddr <= 'x;
                    itf.rvalid <= 1'b0;
                    itf.rdata <= 'x;
            end
        endtask : run_random_instrs
    
        always @(posedge itf.clk iff !itf.rst) begin
            if ($isunknown(itf.read) || $isunknown(itf.write)) begin
                $error("Memory Error: mask containes 1'bx");
                itf.error <= 1'b1;
            end
            if ((|itf.read) && (|itf.write)) begin
                $error("Memory Error: Simultaneous memory read and write");
                itf.error <= 1'b1;
            end
            if ((|itf.read) || (|itf.write)) begin
                if ($isunknown(itf.addr)) begin
                    $error("Memory Error: Address contained 'x");
                    itf.error <= 1'b1;
                end
                // Only check for 16-bit alignment since instructions are
                // allowed to be at 16-bit boundaries due to JALR.
                if (itf.addr[0] != 1'b0) begin
                    $error("Memory Error: Address is not 16-bit aligned");
                    itf.error <= 1'b1;
                end
            end
        end
    
        // A single initial block ensures random stability.
        initial begin
    
            // Wait for reset.
            itf.ready <= 1'b1;
            itf.rvalid <= 1'b0;
            @(posedge itf.clk iff itf.rst == 1'b0);
            itf.ready <= 1'b1;
            
            // Get some useful state into the processor by loading in a bunch of state.
            // init_register_state();
    
            // Run!
            run_random_instrs();
    
            // Finish up
            $display("Random testbench finished!");
            $finish;
        end
    
    endmodule : random_tb
    