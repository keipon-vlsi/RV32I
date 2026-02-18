`timescale 1ns / 1ps

module tb_top;

    // ========================================================================
    // 1. Signal Declarations
    // ========================================================================
    logic clk;
    logic reset;
    logic [31:0] write_data;
    logic [31:0] data_address;
    logic write_enable;

    // ========================================================================
    // 2. DUT (Device Under Test) Instantiation
    // ========================================================================
    top u_top (
        .clk(clk),
        .reset(reset),
        .write_data(write_data),
        .data_address(data_address),
        .write_enable(write_enable)
    );

    // ========================================================================
    // 3. Clock Generation
    // ========================================================================
    initial begin
        clk = 0;
        // Generate 100MHz clock (10ns period)
        forever #5 clk = ~clk;
    end

    // ========================================================================
    // 4. Test Scenario
    // ========================================================================
    initial begin
        // Print header for the log
        $display("----------------------------------------------------------------------------------");
        $display("Time  | PC       | Instr    | Action");
        $display("----------------------------------------------------------------------------------");

        // --- Simulation Start ---
        reset = 1;
        #20;       // Hold reset for 20ns
        reset = 0; // Release reset

        // Run simulation for enough time to execute the program
        #1000;

        // --- Simulation End ---
        $display("----------------------------------------------------------------------------------");
        $display("Simulation Finished");
        $finish;
    end

    // ========================================================================
    // 5. Monitoring Logic (Hierarchical Access)
    // ========================================================================
    // Monitor signals at the negative edge of the clock to ensure stability.
    always @(negedge clk) begin
        if (!reset) begin
            // Basic Info: Time, Current PC, and Current Instruction
            // Using hierarchical reference "u_top.PrCore.xxx" to access internal signals.
            $write("%5t | %h | %h | ", $time, u_top.PrCore.PC, u_top.PrCore.instruction);

            // --- Case 1: Register Write (ALU Ops, Load, JAL/JALR) ---
            // Check if register write is enabled AND the destination register is not x0.
            if (u_top.PrCore.reg_write_enable && (u_top.PrCore.instruction[11:7] != 0)) begin
                $display("REG WRITE: x%0d <= %h", 
                         u_top.PrCore.instruction[11:7], // rd (destination register index)
                         u_top.PrCore.reg_data           // data to be written
                );
            end
            
            // --- Case 2: Memory Write (Store) ---
            // This uses the top-level output signal.
            else if (write_enable) begin
                $display("MEM WRITE: Mem[%h] <= %h", data_address, write_data);
            end

            // --- Case 3: Branch/Jump Taken ---
            // If pc_mux_sel is high, PC is updated from ALU output (Jump target).
            else if (u_top.PrCore.pc_mux_sel) begin
                 $display("BRANCH/JUMP: To %h", u_top.PrCore.alu_output);
            end

            // --- Case 4: No major architectural state change (NOP, Branch not taken) ---
            else begin
                $display(" - ");
            end
        end
    end

endmodule