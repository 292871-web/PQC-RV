module ALU(input logic [31:0] pc, input logic [31:0] imm, input logic [31:0] rs1, input logic [31:0] rs2, input logic [5:0] op, output logic [31:0] result);
    logic [31:0] clzResult, ctzResult;
    CLZ clz (rs1, clzResult);
    CTZ ctz (rs1, ctzResult);
    // CPOP cpop ([31:0]rs1,[31:0] cpopResult);
    logic cpopResult;
    // ORCb ORCb ([31:0]rs1,[31:0] orcB_Result);
    logic orcB_Result;

    always_comb begin
        case (op)
            6'b000000: result = rs1 + rs2; // ADD
            6'b000001: result = rs1 + imm; // ADDI
            6'b000010: result = rs1 - rs2; // SUB
            6'b000011: result = rs1 & rs2; // AND
            6'b000100: result = rs1 & imm; // ANDI
            6'b000101: result = rs1 & ~rs2; // ANDN
            6'b000110: result = rs1 | rs2; // OR
            6'b000111: result = rs1 | imm; // ORI
            6'b001000: result = rs1 ^ rs2; // XOR
            6'b001001: result = rs1 ^ imm[25:10]; // XORI
            6'b001010: result = pc + (imm[32:12] << 12); // AUIPC
            6'b001011: result = {imm[31:12], 12'h0}; // LUI
            6'b001100: result = rs1 << rs2[4:0]; // SLL
            6'b001101: result = rs1 << imm[4:0]; // SLLI
            6'b001110: result = ($signed(rs1) < $signed(rs2)) ? 32'h1 : 32'h0; // SLT
            6'b001111: result = ($signed(rs1) < $signed(imm)) ? 32'h1 : 32'h0; // SLTI
            6'b010000: result = (rs1 < rs2) ? 32'h1 : 32'h0; // SLTIU
            6'b010001: result = (rs1 < imm) ? 32'h1 : 32'h0; // SLTU
            6'b010010: result = $signed(rs1) >>> rs2[4:0]; // SRA
            6'b010011: result = rs1 >> rs2[4:0]; // SRL
            6'b010100: result = rs1 >> imm[4:0]; // SRLI
            6'b010101: result = clzResult; // CLZ
            6'b010110: result = cpopResult; // CPOP TODO
            6'b010111: result = ctzResult; // CTZ 
            6'b011000: result = ($signed(rs1) > $signed(rs2)) ? $signed(rs1) : $signed(rs2); // MAX
            6'b011001: result = rs1 > rs2 ? rs1 : rs2; // MAXU
            6'b011010: result = ($signed(rs1) < $signed(rs2)) ? $signed(rs1) : $signed(rs2); // MIN
            6'b011011: result = rs1 < rs2 ? rs1 : rs2; // MINU
            6'b011100: result = orcB_Result; // ORC.B TODO
            6'b011101: result = rs1 | ~rs2; // ORN
            6'b011110: result = {rs1[7:0],rs1[15:8],rs1[23:16],rs1[31:0]}; // REV8
            6'b011111: result = (rs1 >> rs2[4:0] | rs1 << (6'd32 - rs2[4:0])); // ROL
            6'b100000: result = (rs1 << rs2[4:0] | rs1 >> (6'd32 - rs2[4:0])); // ROR
            6'b100001: result = (rs1 << imm[4:0] | rs1 >> (6'd32 - imm[4:0])); // RORI
            6'b100010: result = {{24{rs1[7]}},rs1[7:0]}; // SEXT.B
            6'b100011: result = {{16{rs1[15]}},rs1[15:0]}; // SEXT.H
            6'b100100: result = ~(rs1 ^ rs2); // XNOR
            6'b100101: result = {16'b0,rs1[15:0]}; // ZEXT.H

            default: result = 32'h00000000; // Default case
        endcase
    end

endmodule