module CLZ(input logic [31:0] A, output logic[31:0] Y);

    logic [15:0] Y1;
    logic [7:0] Y2; 
    logic [3:0] Y3;
    logic [1:0] Y4;
    logic Y5;

    logic [4:0] S;

    assign {S[4], Y1} = (A[31:16]==16'b0) ? {1'b1, A[15:0]} : {1'b0, A[31:16]};
    assign {S[3], Y2} = (Y1[15:8]== 8'b0) ? {1'b1, Y1[7:0]} : {1'b0, Y1[15:8]};
    assign {S[2], Y3} = (Y2[7:4] == 4'b0) ? {1'b1, Y2[3:0]} : {1'b0, Y2[7:4]};
    assign {S[1], Y4} = (Y3[3:2] == 2'b0) ? {1'b1, Y3[1:0]} : {1'b0, Y3[3:2]};
    assign {S[0], Y5} = (Y4[1] == 1'b0) ? {1'b1, Y4[0]} : {1'b0, Y4[1]};
    assign Y = S + ~Y5;

endmodule

module CTZ(input logic [31:0] A, output logic[31:0] Y);

    logic [15:0] Y1;
    logic [7:0] Y2; 
    logic [3:0] Y3;
    logic [1:0] Y4;
    logic Y5;

    logic [4:0] S;

    assign {S[4], Y1} = (A[15:0]==16'b0) ? {1'b1, A[31:16]} : {1'b0, A[15:0]};
    assign {S[3], Y2} = (Y1[7:0]== 8'b0) ? {1'b1, Y1[15:8]} : {1'b0, Y1[7:0]};
    assign {S[2], Y3} = (Y2[3:0] == 4'b0) ? {1'b1, Y2[7:4]} : {1'b0, Y2[3:0]};
    assign {S[1], Y4} = (Y3[1:0] == 2'b0) ? {1'b1, Y3[3:2]} : {1'b0, Y3[1:0]};
    assign {S[0], Y5} = (Y4[0] == 1'b0) ? {1'b1, Y4[1]} : {1'b0, Y4[0]};
    assign Y = S + ~Y5;

endmodule

module CPOP(input logic [31:0] A, output logic [31:0] Y);
    //TODO: implement CPOP logic
endmodule

