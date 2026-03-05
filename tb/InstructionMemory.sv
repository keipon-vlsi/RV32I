module InstructionMemory
(
    output logic [31:0] instruction_data_o,
    input  logic [31:0] instruction_address_i
);

    logic [31:0] instruction [0:63];

    // initial
    // begin
    //     $readmemh("R.txt", instruction);
    // end

    always_comb
    begin
        instruction_data_o = instruction[instruction_address_i[7:2]];
    end

endmodule