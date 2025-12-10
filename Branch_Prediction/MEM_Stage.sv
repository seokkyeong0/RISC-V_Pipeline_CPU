`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/29 14:29:58
// Design Name: 
// Module Name: MEM_Stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MEM_Stage(
    // Global Signals
    input  logic clk,
    input  logic rstn,

    // EX -> MEM Signals
    input  logic        regwrite_EX,
    input  logic [ 4:0] rd_EX,
    input  logic [31:0] aluout_EX,
    input  logic        datawe_EX,
    input  logic [ 2:0] wbsel_EX,
    input  logic [ 2:0] strb_EX,
    input  logic [31:0] rdata2_EX,
    input  logic [31:0] immext_EX,
    input  logic [31:0] pcimmaui_EX,
    input  logic [31:0] pcnext_EX,

    // MEM -> WB Signals
    output logic        regwrite_MEM,
    output logic [ 2:0] wbsel_MEM,
    output logic [ 4:0] rd_MEM,
    output logic [31:0] aluout_MEM,
    output logic [31:0] rdata_MEM,
    output logic [31:0] immext_MEM,
    output logic [31:0] pcimmaui_MEM,
    output logic [31:0] pcnext_MEM
);

    // Registers & Wires
    logic [31:0] rdata;

    // Pipeline Delay MEM -> WB
    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            regwrite_MEM <= 1'b0;
            wbsel_MEM    <= 3'd0;
            rd_MEM       <= 5'd0;
            aluout_MEM   <= 32'd0;
            rdata_MEM    <= 32'd0;
            immext_MEM   <= 32'd0;
            pcimmaui_MEM <= 32'd0;
            pcnext_MEM   <= 32'd0;
        end else begin
            regwrite_MEM <= regwrite_EX;
            wbsel_MEM    <= wbsel_EX;
            rd_MEM       <= rd_EX;
            aluout_MEM   <= aluout_EX;
            rdata_MEM    <= rdata;
            immext_MEM   <= immext_EX;
            pcimmaui_MEM <= pcimmaui_EX;
            pcnext_MEM   <= pcnext_EX;
        end
    end

    // Data Memory
    Data_RAM U_Data_RAM (
        .clk(clk),
        .datawe(datawe_EX),
        .strb(strb_EX),
        .addr(aluout_EX),
        .wdata(rdata2_EX),
        .rdata(rdata)
    );

endmodule

module Data_RAM (
    input  logic        clk,
    input  logic        datawe,
    input  logic [ 2:0] strb,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);

    // Word-aligned memory (256)
    logic [31:0] mem [0:255];

    // S-Type (strb, offset)
    always_ff @(posedge clk) begin
        if (datawe) begin
            case (strb)
                3'b000: begin // SB
                    case (addr[1:0])
                        2'b00: mem[addr[31:2]][  7:0] = wdata[  7:0];
                        2'b01: mem[addr[31:2]][ 15:8] = wdata[ 15:8];
                        2'b10: mem[addr[31:2]][23:16] = wdata[23:16];
                        2'b11: mem[addr[31:2]][31:24] = wdata[31:24];
                    endcase
                end
                3'b001: begin // SH
                    case (addr[1:0])
                        2'b00: mem[addr[31:2]][ 15:0] = wdata[ 15:0];
                        2'b10: mem[addr[31:2]][31:16] = wdata[31:16];
                    endcase
                end  
                3'b010: begin // SW
                    mem[addr[31:2]] = wdata[31:0];
                end
                default: mem[addr[31:2]] = wdata[31:0]; 
            endcase
        end
    end

    // L-Type (strb, offset)
    always_comb begin
        rdata = mem[addr[31:2]][31:0];
        case (strb)
            3'b011: begin // LB
                case (addr[1:0])
                    2'b00: rdata = {{24{mem[addr[31:2]][ 7]}}, mem[addr[31:2]][  7:0]};
                    2'b01: rdata = {{24{mem[addr[31:2]][15]}}, mem[addr[31:2]][ 15:8]};
                    2'b10: rdata = {{24{mem[addr[31:2]][23]}}, mem[addr[31:2]][23:16]};
                    2'b11: rdata = {{24{mem[addr[31:2]][31]}}, mem[addr[31:2]][31:24]};
                endcase
            end
            3'b100: begin // LH
                case (addr[1:0])
                    2'b00: rdata = {{16{mem[addr[31:2]][15]}}, mem[addr[31:2]][ 15:0]};
                    2'b10: rdata = {{16{mem[addr[31:2]][31]}}, mem[addr[31:2]][31:16]};
                endcase
            end
            3'b101: begin // LW
                rdata = mem[addr[31:2]][31:0]; 
            end
            3'b110: begin // LBU
                case (addr[1:0])
                    2'b00: rdata = {24'b0, mem[addr[31:2]][  7:0]};
                    2'b01: rdata = {24'b0, mem[addr[31:2]][ 15:8]};
                    2'b10: rdata = {24'b0, mem[addr[31:2]][23:16]};
                    2'b11: rdata = {24'b0, mem[addr[31:2]][31:24]};
                endcase
            end
            3'b111: begin // LHU
                case (addr[1:0])
                    2'b00: rdata = {16'b0, mem[addr[31:2]][ 15:0]};
                    2'b10: rdata = {16'b0, mem[addr[31:2]][31:17]};
                endcase
            end
        endcase
    end

endmodule
