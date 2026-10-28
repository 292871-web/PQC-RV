module ALU(logic input[31:0] PC, logic input [31:0] imm, logic input [31:0] a, input [31:0] b, input [3:0] op, output logic [31:0] result);

    always_comb begin
        case (op)
            5'b00000: result = a + b; // ADD
            5'b00001: result = a + imm; // ADDI
            5'b00010: result = a - b; // SUB
            5'b00011: result = a & b; // AND
            5'b00100: result = a & imm; // ANDI
            5'b00101: result = a & ~b; // ANDN
            5'b00110: result = a | b; // OR
            5'b00111: result = a | imm; // ORI
            5'b01000: result = a ^ b; // XOR
            5'b01001: result = a ^ imm[25:10]; // XORI
            5'b01010: result = PC + (imm[32:12] << 12); // AUIPC
            5'b01011: result = {imm[31:12], 12'h0}; // LUI
            5'b01100: result = a << b[4:0]; // SLL
            5'b01101: result = a << imm[4:0]; // SLLI
            5'b01110: result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0; // SLT
            5'b01111: result = ($signed(a) < $signed(imm)) ? 32'h1 : 32'h0; // SLTI
            5'b10000: result = (a < b) ? 32'h1 : 32'h0; // SLTIU
            5'b10001: result = (a < imm) ? 32'h1 : 32'h0; // SLTU
            5'b10010: result = $signed(a) >>> b[4:0]; // SRA
            5'b10100: result = a >> b[4:0]; // SRL
            5'b10101: result = a >> imm[4:0]; // SRLI
            5'b10110: result = ; // CLZ
            5'b10111: result = ; // CLZW
            5'b11000: result = ; // CPOP
            5'b11001: result = ; // CPOPW
            5'b11010: result = ; // CTZ
            5'b11011: result = ; // CTZW
            5'b11100: result = ; // MAX
            5'b11101: result = ; // MAXU
            5'b11110: result = ; // MIN
            5'b11111: result = ; // MINU
            5'b100000: result = ; // ORC.B
            5'b100001: result = ; // ORN
            5'b100010: result = ; // REV8
            5'b100011: result = ; // ROL
            5'b100100: result = ; // ROLW
            5'b100101: result = ; // ROR
            5'b100110: result = ; // RORI
            5'b100111: result = ; // RORW
            5'b101000: result = ; // RORIW
            5'b101001: result = ; // SEXT.B
            5'b101010: result = ; // SEXT.H
            5'b101011: result = ~(a ^ b); // XNOR
            5'b101100: result = ; // ZEXT.H
            5'b101101: result = ; // ZEXT.H.RV32
            5'b101110: result = ; // C.ADD
            5'b101111: result = ; // C.ADDI
            5'b110000: result = ; // C.ADDI16SP
            5'b110001: result = ; // C.ADDI4SPN
            5'b110010: result = ; // C.ADDW
            5'b110011: result = ; // C.ADDIW
            5'b110100: result = ; // C.AND
            5'b110101: result = ; // C.ANDI
            5'b110110: result = ; // C.LI
            5'b110111: result = ; // C.LUI
            5'b111000: result = ; // C.MV
            5'b111001: result = ; // C.OR
            5'b111010: result = ; // C.SLLI
            5'b111011: result = ; // C.SRLI
            5'b111100: result = ; // C.SRAI
            5'b111101: result = ; // C.SUB
            5'b111110: result = ; // C.SUBW
            5'b111111: result = ; // C.XOR

            default: result = 32'h00000000; // Default case
        endcase
    end

endmodule