module ALU(logic input[31:0] PC, logic input [31:0] imm, logic input [31:0] a, input [31:0] b, input [5:0] op, output logic [31:0] result);
    
    CLZ clz(a, clzResult);
    CTZ ctz(a, ctzResult);
    CPOP cpop(a, cpopResult);
    ORCb ORCb(a, orcB_Result);

    always_comb begin
        case (op)
            6'b000000: result = a + b; // ADD
            6'b000001: result = a + imm; // ADDI
            6'b000010: result = a - b; // SUB
            6'b000011: result = a & b; // AND
            6'b000100: result = a & imm; // ANDI
            6'b000101: result = a & ~b; // ANDN
            6'b000110: result = a | b; // OR
            6'b000111: result = a | imm; // ORI
            6'b001000: result = a ^ b; // XOR
            6'b001001: result = a ^ imm[25:10]; // XORI
            6'b001010: result = PC + (imm[32:12] << 12); // AUIPC
            6'b001011: result = {imm[31:12], 12'h0}; // LUI
            6'b001100: result = a << b[4:0]; // SLL
            6'b001101: result = a << imm[4:0]; // SLLI
            6'b001110: result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0; // SLT
            6'b001111: result = ($signed(a) < $signed(imm)) ? 32'h1 : 32'h0; // SLTI
            6'b010000: result = (a < b) ? 32'h1 : 32'h0; // SLTIU
            6'b010001: result = (a < imm) ? 32'h1 : 32'h0; // SLTU
            6'b010010: result = $signed(a) >>> b[4:0]; // SRA
            6'b010011: result = a >> b[4:0]; // SRL
            6'b010100: result = a >> imm[4:0]; // SRLI
            6'b010101: result = clzResult; // CLZ
            6'b010110: result = cpopResult; // CPOP TODO
            6'b010111: result = ctzResult; // CTZ 
            6'b011000: result = ($signed(a) > $signed(b)) ? $signed(a) : $signed(b); // MAX
            6'b011001: result = a > b ? a : b; // MAXU
            6'b011010: result = ($signed(a) < $signed(b)) ? $signed(a) : $signed(b); // MIN
            6'b011011: result = a < b ? a : b; // MINU
            6'b011100: result = orcB_Result; // ORC.B TODO
            6'b011101: result = a | ~b; // ORN
            6'b011110: result = {a[7:0], a[15:8], a[23:16], a[31:0]}; // REV8
            6'b011111: result = (a >> b[4:0] | a << (6'd32 - b[4:0])); // ROL
            6'b100000: result = (a << b[4:0] | a >> (6'd32 - b[4:0])); // ROR
            6'b100001: result = (a << imm[4:0] | a >> (6'd32 - imm[4:0])); // RORI
            6'b100010: result = {{24'h{a[7]}}, a[7:0]}; // SEXT.B
            6'b100011: result = {{16'h{a[15]}}, a[15:0]}; // SEXT.H
            6'b100100: result = ~(a ^ b); // XNOR
            6'b100101: result = {16'b0, a[15:0]}; // ZEXT.H

            default: result = 32'h00000000; // Default case
        endcase
    end

endmodule