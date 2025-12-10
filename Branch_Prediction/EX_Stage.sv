`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/29 14:29:45
// Design Name: 
// Module Name: EX_Stage
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

`include "ISA_Define.sv"

module EX_Stage(
    // Global Signals
    input  logic clk,
    input  logic rstn,

    // Forwarding Signals
    input  logic [ 1:0] forward_A,
    input  logic [ 1:0] forward_B,
    input  logic [31:0] fdata_WB,

    // ID -> EX Signals
    input  logic [31:0] pc_ID,
    input  logic [31:0] rdata1_ID,
    input  logic [31:0] rdata2_ID,
    input  logic [ 4:0] rd_ID,
    input  logic        regwrite_ID,
    input  logic        alumuxsel_ID,
    input  logic        datawe_ID,
    input  logic [ 2:0] wbsel_ID,
    input  logic        branch_ID,
    input  logic        jal_ID,
    input  logic        jalr_ID,
    input  logic [ 3:0] alucontrol_ID,
    input  logic [ 2:0] strb_ID,
    input  logic [31:0] immext_ID,
    input  logic [31:0] pcnext_ID,

    // EX -> MEM Signals
    output logic        regwrite_EX,
    output logic        datawe_EX,
    output logic [ 2:0] wbsel_EX,
    output logic [ 2:0] strb_EX,
    output logic [ 4:0] rd_EX,
    output logic [31:0] aluout_EX,
    output logic [31:0] rdata2_EX,
    output logic [31:0] immext_EX,
    output logic [31:0] pcimmaui_EX,
    output logic [31:0] pcnext_EX,

    // EX -> IF Signals
    output logic [31:0] pcimm_EX,
    output logic        pcmuxsel_EX,

    // Forwarding Signals
    output logic [ 4:0] memread_EX,

    // Branch Hazard Signals
    output logic        branch_EX,
    output logic        btaken_EX,
    output logic        jal_EX,
    output logic        jalr_EX,
    output logic [31:0] ctarget
);

    // Registers & Wires
    logic [31:0] foutA;
    logic [31:0] foutB;
    logic [31:0] alumuxout;
    logic [31:0] pcmuxout;
    logic [31:0] aluout;
    logic        btaken;

    // Forwarding Signals
    assign memread_EX = (wbsel_ID == 3'b001) ? 1'b1 : 1'b0;

    // Branch Hazard Signals
    assign branch_EX = branch_ID;
    assign btaken_EX = btaken;
    assign jal_EX    = jal_ID;
    assign jalr_EX   = jalr_ID;
    assign ctarget   = (btaken) ? pcimm_EX : pcnext_ID;

    // Adder & AND/OR Gate
    assign pcimm_EX    = pcmuxout + immext_ID;
    assign pcmuxsel_EX = jal_ID | jalr_ID;

    // Pipeline Delay EX -> MEM
    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            regwrite_EX <= 1'b0;
            datawe_EX   <= 1'b0;
            wbsel_EX    <= 3'd0;
            strb_EX     <= 3'd0;
            rd_EX       <= 5'd0;
            aluout_EX   <= 32'd0;
            rdata2_EX   <= 32'd0;
            immext_EX   <= 32'd0;
            pcimmaui_EX <= 32'd0;
            pcnext_EX   <= 32'd0;
        end else begin
            regwrite_EX <= regwrite_ID;
            datawe_EX   <= datawe_ID;
            wbsel_EX    <= wbsel_ID;
            strb_EX     <= strb_ID;
            rd_EX       <= rd_ID;
            aluout_EX   <= aluout;
            rdata2_EX   <= foutB;
            immext_EX   <= immext_ID;
            pcimmaui_EX <= pcimm_EX;
            pcnext_EX   <= pcnext_ID;
        end
    end

    Mux_3x1 U_Forwarding_A(
        .sel(forward_A),
        .in_1(rdata1_ID),
        .in_2(fdata_WB),
        .in_3(aluout_EX),
        .out(foutA)
    );

    Mux_3x1 U_Forwarding_B(
        .sel(forward_B),
        .in_1(rdata2_ID),
        .in_2(fdata_WB),
        .in_3(aluout_EX),
        .out(foutB)
    );

    Mux_2x1 U_PCMuxSel(
        .sel(jalr_ID),
        .in_1(pc_ID),
        .in_2(foutA),
        .out(pcmuxout)
    );

    Mux_2x1 U_ALUMuxSel(
        .sel(alumuxsel_ID),
        .in_1(foutB),
        .in_2(immext_ID),
        .out(alumuxout)
    );

    ALU U_ALU(
        .alucontrol(alucontrol_ID),
        .aluin_1(foutA),
        .aluin_2(alumuxout),
        .aluout(aluout),
        .branch(branch_ID),
        .btaken(btaken)
    );

endmodule

module ALU (
    input  logic [ 3:0] alucontrol,
    input  logic [31:0] aluin_1,
    input  logic [31:0] aluin_2,
    output logic [31:0] aluout,

    // Branch
    input  logic        branch,
    output logic        btaken
);
    
    // ALU Function
    always_comb begin
        case (alucontrol)
            `ADD : aluout = aluin_1 + aluin_2;
            `SUB : aluout = aluin_1 - aluin_2;
            `SLL : aluout = aluin_1 << aluin_2;
            `SRL : aluout = aluin_1 >> aluin_2;
            `SRA : aluout = $signed(aluin_1) >>> aluin_2;
            `SLT : aluout = ($signed(aluin_1) < $signed(aluin_2)) ? 32'd1 : 32'd0;
            `SLTU: aluout = (aluin_1 < aluin_2) ? 32'd1 : 32'd0;
            `XOR : aluout = aluin_1 ^ aluin_2;
            `OR  : aluout = aluin_1 | aluin_2;
            `AND : aluout = aluin_1 & aluin_2;
            default: aluout = 32'hxxxx_xxxx; 
        endcase
    end

    // Branch Function
    always_comb begin
        btaken = 1'b0;
        if (branch) begin
            case (alucontrol[2:0])
                `BEQ :   btaken = ($signed(aluin_1) == $signed(aluin_2)) ? 1'b1 : 1'b0;
                `BNE :   btaken = ($signed(aluin_1) != $signed(aluin_2)) ? 1'b1 : 1'b0;
                `BLT :   btaken = ($signed(aluin_1) <  $signed(aluin_2)) ? 1'b1 : 1'b0;
                `BGE :   btaken = ($signed(aluin_1) >= $signed(aluin_2)) ? 1'b1 : 1'b0;
                `BLTU:   btaken = (aluin_1 <  aluin_2) ? 1'b1 : 1'b0;
                `BGEU:   btaken = (aluin_1 >= aluin_2) ? 1'b1 : 1'b0;
            endcase
        end
    end

endmodule

module Mux_2x1 (
    input  logic        sel,
    input  logic [31:0] in_1,
    input  logic [31:0] in_2,
    output logic [31:0] out
);
    always_comb begin
        case (sel)
            1'b0: out = in_1;
            1'b1: out = in_2; 
            default: out = 32'd0;
        endcase
    end

endmodule

module Mux_3x1 (
    input  logic [ 1:0] sel,
    input  logic [31:0] in_1,
    input  logic [31:0] in_2,
    input  logic [31:0] in_3,
    output logic [31:0] out
);
    always_comb begin
        case (sel)
            2'b00: out = in_1;
            2'b01: out = in_2; 
            2'b10: out = in_3;
            default: out = 32'd0;
        endcase
    end
endmodule
