module controlUnit(
    input logic [31:0] instr,
);

    always_comb begin 
        opCode = instr[6:0];
        funct3 = instr[13:11];
        funct7 = intrs[31:24];
        case (opCode)
            7'b0110011: //rs1 and rs2 op category
            begin
                case (funct3)
                    3'b000: aluOp = 6'b000000; //ADD
                    3'b001: 
                    3'b010
                    3'b011
                    3'b100
                    3'b101
                    3'b110
                    3'b111: //AND | ANDN
                    begin 
                        case(funct7)
                        7'b0000000 aluOp = 6'b000011; //AND
                        7'b0100000 aluOp = 6'b000101; //ANDN

                        default: 6'b111111;
                        endcase
                    end
                    default: ;
                endcase
            end
            7'b0010011: //rs1 and imm op category
            7'b0000011: //LOAD op category
            7'b0100011: //STORE op category
            7'b1100011: //BRANCH op category
            7'b1101111: //JAL op
            7'b1100111: //JALR op
            7'b0110111: //LUI op
            7'b0010111: //AUIPC op
        endcase
        
    end

endmodule

module decompressor();
    //TODO: implement decompressor logic for Zca extension
endmodule