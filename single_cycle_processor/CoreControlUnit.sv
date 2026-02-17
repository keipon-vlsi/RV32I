import risc_v_32_i_pkg::*;

module CoreControlUnit #(parameter XLEN = 32)
(
    output logic                pc_mux_sel_o,
    output logic                reg_write_enable_o,
    output imm_select_e         imm_select_o,
    output logic                execute_port_a_sel_o,
    output logic                execute_port_b_sel_o,   
    output alu_select_e         alu_op_sel_o,
    output comp_select_e        comp_op_sel_o,
    output load_store_type_e    load_store_type_o,
    output logic                data_memory_write_enable_o,
    output write_data_select_e  reg_write_data_sel_o,
    input  logic [6:0]          op_code_i,
    input  logic [2:0]          funct3_i,
    input  logic                funct7_bit5_i,
    input  logic                branch_enable_i
);

    localparam OP_R_TYPE        = 7'b0110011;
    localparam OP_B_TYPE        = 7'b1100011;
    localparam OP_S_TYPE        = 7'b0100011;
    localparam OP_I_JALR_TYPE   = 7'b1100111;
    localparam OP_I_LOAD_TYPE   = 7'b0000011;
    localparam OP_I_ALU_TYPE    = 7'b0010011;
    localparam OP_I_FENCE_TYPE  = 7'b0001111;
    localparam OP_I_ECALL_TYPE  = 7'b1110011;
    localparam OP_U_LUI_TYPE    = 7'b0110111;
    localparam OP_U_AUIPC_TYPE  = 7'b0010111;
    localparam OP_J_TYPE        = 7'b1101111;

    always_comb
    begin
        unique case(op_code_i)
            // R-type
            OP_R_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_UNKNOWN_TYPE;
                execute_port_a_sel_o = 1'b1;

                unique case({funct7_bit5_i,funct3_i})
                    // add
                    4'b0000:
                        begin
                            alu_op_sel_o = OP_ADD;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                        end
                    // sub
                    4'b1000:
                        begin
                            alu_op_sel_o = OP_SUB;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                        end
                    // sll
                    4'b0001:
                            begin
                            alu_op_sel_o = OP_SLL;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    // slt
                    4'b0010:
                            begin
                            alu_op_sel_o = OP_UNKNOWN;
                            comp_op_sel_o = OP_BLT;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_BCU;
                            end
                    // sltu
                    4'b0011:
                            begin
                            alu_op_sel_o = OP_UNKNOWN;
                            comp_op_sel_o = OP_BLTU;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_BCU;
                            end
                    // xor
                    4'b0100:
                            begin
                            alu_op_sel_o = OP_XOR;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    // srl
                    4'b0101:
                            begin
                            alu_op_sel_o = OP_SRL;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    // sra
                    4'b1101:
                            begin
                            alu_op_sel_o = OP_SRA;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    // or
                    4'b0110:
                            begin
                            alu_op_sel_o = OP_OR;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    // and
                    4'b0111:
                            begin
                            alu_op_sel_o = OP_AND;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    default:
                            begin
                            alu_op_sel_o = OP_UNKNOWN;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                endcase

                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
            end

            // B-type
            OP_B_TYPE:
            begin
                pc_mux_sel_o = branch_enable_i;
                reg_write_enable_o = 1'b0;    
                imm_select_o = IMM_B_TYPE;
                execute_port_a_sel_o = 1'b0;    // select PC 
                execute_port_b_sel_o = 1'b0;    // select imm
                alu_op_sel_o = OP_ADD;          // PC + imm 

                unique case(funct3_i)
                    3'b000: comp_op_sel_o = OP_BEQ;
                    3'b001: comp_op_sel_o = OP_BNE;
                    3'b100: comp_op_sel_o = OP_BLT;
                    3'b101: comp_op_sel_o = OP_BGE;
                    3'b110: comp_op_sel_o = OP_BLTU;
                    3'b111: comp_op_sel_o = OP_BGEU;
                    default: comp_op_sel_o = OP_BUNKNOWN;
                endcase

                load_store_type_o = LS_N_A;         // Not a load/store instruction
                data_memory_write_enable_o = 1'b0;  // Don't write to memory
                reg_write_data_sel_o = RD_MUX_N_A;  // Don't write to register file
            end

            // S-type
            OP_S_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_S_TYPE;
                execute_port_a_sel_o = 1'b1;        // select rs1
                execute_port_b_sel_o = 1'b0;        // select imm
                alu_op_sel_o = OP_ADD;              // imm(rs1) = rs1 + imm
                comp_op_sel_o = OP_BUNKNOWN;        // Not a branch instruction

                unique case(funct3_i)
                    3'b000: load_store_type_o = S_B;
                    3'b001: load_store_type_o = S_H;
                    3'b010: load_store_type_o = S_W;
                endcase

                data_memory_write_enable_o = 1'b1;  // Enable writing to memory
                reg_write_data_sel_o = RD_MUX_N_A;  // Don't write to register file
            end

            // I-type (jalr)
            OP_I_JALR_TYPE:
            begin
                pc_mux_sel_o = 1'b1;            
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;        // select rs1
                execute_port_b_sel_o = 1'b0;        // select imm
                alu_op_sel_o = OP_ADD;              // imm(rs1) = rs1 + imm
                comp_op_sel_o = OP_BUNKNOWN;        // Not a branch instruction
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_PC_N;  // Write PC+4 to rd to return to caller
            end

            // I-type (load)
            OP_I_LOAD_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b1;          // Enable writing to register file
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;        // select rs1
                execute_port_b_sel_o = 1'b0;        // select imm
                alu_op_sel_o = OP_ADD;              // imm(rs1) = rs1 + imm
                comp_op_sel_o = OP_BUNKNOWN;

                unique case(funct3_i)
                    3'b000: load_store_type_o = L_B;
                    3'b001: load_store_type_o = L_H;
                    3'b010: load_store_type_o = L_W;
                    3'b100: load_store_type_o = L_BU;
                    3'b101: load_store_type_o = L_HU;
                    default: load_store_type_o = L_W;
                endcase

                data_memory_write_enable_o = 1'b0;  // Don't write to memory
                reg_write_data_sel_o = RD_MUX_DMEM;  // Write data read from memory to register file
            end

            // I-type (ALU)
            OP_I_ALU_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;

                unique case(funct3_i)
                    // addi
                    3'b000:
                        begin
                            alu_op_sel_o = OP_ADD;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b0;
                            reg_write_data_sel_o = RD_MUX_ALU;
                        end
                    // slti
                    3'b010:
                           begin
                           alu_op_sel_o = OP_UNKNOWN;
                           comp_op_sel_o = OP_BLT;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_BCU;
                           end
                    // sltiu
                    3'b011:
                           begin
                           alu_op_sel_o = OP_UNKNOWN;
                           comp_op_sel_o = OP_BLTU;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_BCU;
                           end
                    // xori
                    3'b100:
                           begin
                           alu_op_sel_o = OP_XOR;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                    // ori
                    3'b110:
                           begin
                           alu_op_sel_o = OP_OR;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                    // andi
                    3'b111:
                           begin
                           alu_op_sel_o = OP_AND;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                    // slli
                    3'b001:
                           begin
                           alu_op_sel_o = OP_SLL;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                    // srli/srai
                    3'b101:
                           begin
                           alu_op_sel_o = ((funct7_bit5_i)? OP_SRA : OP_SRL);
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                   default:
                           begin
                           alu_op_sel_o = OP_UNKNOWN;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                endcase

                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
            end
            // I-type (fence)
            OP_I_FENCE_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_UNKNOWN;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_N_A;
            end
            // I-type (ecall)
            OP_I_ECALL_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_UNKNOWN;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_N_A;
            end
            // U-type (lui)
            OP_U_LUI_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_U_TYPE;
                execute_port_a_sel_o = 1'b0;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_UNKNOWN;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_IMM;      // Write immediate value to register file
            end
            // U-type (auipc)
            OP_U_AUIPC_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_U_TYPE;
                execute_port_a_sel_o = 1'b0;            // select PC
                execute_port_b_sel_o = 1'b0;            // select imm
                alu_op_sel_o = OP_ADD;                  // PC + imm
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_ALU;
            end
            // J-type (jal)
            OP_J_TYPE:
            begin
                pc_mux_sel_o = 1'b1;                    // Select PC + imm as next PC
                reg_write_enable_o = 1'b1;              // Enable writing to register file
                imm_select_o = IMM_J_TYPE;
                execute_port_a_sel_o = 1'b0;            // select PC
                execute_port_b_sel_o = 1'b0;            // select imm
                alu_op_sel_o = OP_ADD;                  // PC + imm
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_PC_N;     // Write PC+4 to rd to return to caller
            end
            default:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_UNKNOWN_TYPE;
                execute_port_a_sel_o = 1'b0;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_UNKNOWN;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_N_A;
            end
        endcase
    end
endmodule

                    
