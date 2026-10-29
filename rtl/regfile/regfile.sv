module regfile (
    // Write Enable
    input  logic clk,
    input  logic we,       
    // Write Port
    input  logic [4:0] rdAddrI,
    input  logic [31:0] rdDataI,
    // Read Port 1
    input  logic [4:0] rs1AddrI,
    output logic [31:0] rs1DataO,
    // Read Port 2
    input  logic [4:0] rs2AddrI,
    output logic [31:0] rs2DataO
);

    logic [31:0] rf [31:1];

    always_ff @(posedge clkI) begin
        if (weI && (rdAddrI != 5'b0)) begin
            rf[rdAddrI] <= rdDataI;
        end
    end

    assign rs1DataO = (rs1AddrI != 5'b0) ? rf[rs1AddrI] : 32'b0;
    assign rs2DataO = (rs2AddrI != 5'b0) ? rf[rs2AddrI] : 32'b0;

endmodule