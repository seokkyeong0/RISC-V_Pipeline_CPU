`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/29 14:27:50
// Design Name: 
// Module Name: CPU_Core
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


module CPU_Core(
    input logic clk,
    input logic rstn
);

    ////////////////////////////////////////////
    // Instruction Signals
    ////////////////////////////////////////////

    // IF -> ID Signals
    logic [31:0] instr_IF_ID;

    ////////////////////////////////////////////
    // R,I -Type Signals
    ////////////////////////////////////////////

    // ID -> EX Signals
    logic [31:0] rdata1_ID_EX;
    logic [31:0] rdata2_ID_EX;
    logic [ 4:0] rd_ID_EX;
    logic        regwrite_ID_EX;
    logic        alumuxsel_ID_EX;
    logic [ 3:0] alucontrol_ID_EX;
    logic [31:0] immext_ID_EX;

    // EX -> MEM Signals
    logic        regwrite_EX_MEM;
    logic [ 4:0] rd_EX_MEM;
    logic [31:0] aluout_EX_MEM;

    // MEM -> WB Signals
    logic        regwrite_MEM_WB;
    logic [ 4:0] rd_MEM_WB;
    logic [31:0] aluout_MEM_WB;

    // WB -> ID Signals
    logic        regwrite_WB_ID;
    logic [ 4:0] rd_WB_ID;
    logic [31:0] wbout_WB_ID;

    ////////////////////////////////////////////
    // S,L-Type Signals
    ////////////////////////////////////////////

    // ID -> EX Signals
    logic        datawe_ID_EX;
    logic [ 2:0] wbsel_ID_EX;
    logic [ 2:0] strb_ID_EX;

    // EX -> MEM Signals
    logic        datawe_EX_MEM;
    logic [ 2:0] wbsel_EX_MEM;
    logic [ 2:0] strb_EX_MEM;
    logic [31:0] rdata2_EX_MEM;

    // MEM -> WB Signals
    logic [ 2:0] wbsel_MEM_WB;
    logic [31:0] rdata_MEM_WB;

    ////////////////////////////////////////////
    // B-Type Signals
    ////////////////////////////////////////////
    
    // IF -> ID Signals
    logic [31:0] pc_IF_ID;

    // ID -> EX Signals
    logic        branch_ID_EX;
    logic [31:0] pc_ID_EX;

    // EX -> IF Signals
    logic [31:0] pcimm_EX_IF;
    logic        pcmuxsel_EX_IF;

    ////////////////////////////////////////////
    // U-Type Signals
    ////////////////////////////////////////////

    // EX -> MEM Signals
    logic [31:0] pcimmaui_EX_MEM;
    logic [31:0] immext_EX_MEM;

    // MEM -> WB Signals
    logic [31:0] pcimmaui_MEM_WB;
    logic [31:0] immext_MEM_WB;

    ////////////////////////////////////////////
    // J-Type Signals
    ////////////////////////////////////////////

    // IF -> ID Signals
    logic [31:0] pcnext_IF_ID;

    // ID -> EX Signals
    logic [31:0] pcnext_ID_EX;
    logic        jal_ID_EX;
    logic        jalr_ID_EX;

    // EX -> MEM Signals
    logic [31:0] pcnext_EX_MEM;

    // MEM -> WB Signals
    logic [31:0] pcnext_MEM_WB;

    ////////////////////////////////////////////
    // Data Hazard Signals
    ////////////////////////////////////////////

    // ID Stage (stall)
    logic [ 4:0] rs1_ID;
    logic [ 4:0] rs2_ID;

    // EX Stage
    logic [ 4:0] rs1_EX;
    logic [ 4:0] rs2_EX;
    logic [ 4:0] memread_EX;

    // Forwarding Select
    logic [ 1:0] forward_A;
    logic [ 1:0] forward_B;

    // Stall 
    logic        stall;

    ////////////////////////////////////////////
    // Data Hazard Signals
    ////////////////////////////////////////////

    // EX Stage
    logic        branch_EX;
    
    // Flush
    logic        flush;

    ////////////////////////////////////////////
    ////////////////////////////////////////////
    //       Pipeline CPU Core Instance       //
    ////////////////////////////////////////////
    ////////////////////////////////////////////

    ////////////////////////////////////////////
    // Instruction Fetch [Stage - 1]
    ////////////////////////////////////////////
    IF_Stage U_IF_Stage(
        // Global Signals
        .clk(clk),
        .rstn(rstn),

        // Hazard Signals
        .stall(stall),
        .flush(flush),

        // IF -> ID Signals
        .instr_IF(instr_IF_ID),
        .pc_IF(pc_IF_ID),
        .pcnext_IF(pcnext_IF_ID),

        // EX -> IF Signals
        .pcimm_EX(pcimm_EX_IF),
        .pcmuxsel_EX(pcmuxsel_EX_IF)
    );

    ////////////////////////////////////////////
    // Instruction Decode [Stage - 2]
    ////////////////////////////////////////////
    ID_Stage U_ID_Stage(
        // Global Signals
        .clk(clk),
        .rstn(rstn),

        // Hazard Signals
        .stall(stall),
        .flush(flush),

        // IF -> ID Signals 
        .instr_IF(instr_IF_ID),
        .pc_IF(pc_IF_ID),
        .pcnext_IF(pcnext_IF_ID),

        // ID -> EX Signals
        .pc_ID(pc_ID_EX),
        .rdata1_ID(rdata1_ID_EX),
        .rdata2_ID(rdata2_ID_EX),
        .rd_ID(rd_ID_EX),
        .regwrite_ID(regwrite_ID_EX),
        .alumuxsel_ID(alumuxsel_ID_EX),
        .datawe_ID(datawe_ID_EX),
        .wbsel_ID(wbsel_ID_EX),
        .branch_ID(branch_ID_EX),
        .jal_ID(jal_ID_EX),
        .jalr_ID(jalr_ID_EX),
        .alucontrol_ID(alucontrol_ID_EX),
        .strb_ID(strb_ID_EX),
        .immext_ID(immext_ID_EX),
        .pcnext_ID(pcnext_ID_EX),

        // WB -> ID Signals
        .regwrite_WB(regwrite_WB_ID),
        .rd_WB(rd_WB_ID),
        .wdata_WB(wbout_WB_ID),

        // Forwarding Signals
        .rs1_ID(rs1_ID),
        .rs2_ID(rs2_ID),
        .rs1_EX(rs1_EX),
        .rs2_EX(rs2_EX)
    );

    ////////////////////////////////////////////
    // Execute [Stage - 3]
    ////////////////////////////////////////////
    EX_Stage U_EX_Stage(
        // Global Signals
        .clk(clk),
        .rstn(rstn),

        // Forwarding Signals
        .forward_A(forward_A),
        .forward_B(forward_B),
        .fdata_WB(wbout_WB_ID),

        // ID -> EX Signals
        .pc_ID(pc_ID_EX),
        .rdata1_ID(rdata1_ID_EX),
        .rdata2_ID(rdata2_ID_EX),
        .rd_ID(rd_ID_EX),
        .regwrite_ID(regwrite_ID_EX),
        .alumuxsel_ID(alumuxsel_ID_EX),
        .datawe_ID(datawe_ID_EX),
        .wbsel_ID(wbsel_ID_EX),
        .branch_ID(branch_ID_EX),
        .jal_ID(jal_ID_EX),
        .jalr_ID(jalr_ID_EX),
        .alucontrol_ID(alucontrol_ID_EX),
        .strb_ID(strb_ID_EX),
        .immext_ID(immext_ID_EX),
        .pcnext_ID(pcnext_ID_EX),

        // EX -> MEM Signals
        .regwrite_EX(regwrite_EX_MEM),
        .datawe_EX(datawe_EX_MEM),
        .wbsel_EX(wbsel_EX_MEM),
        .strb_EX(strb_EX_MEM),
        .rd_EX(rd_EX_MEM),
        .aluout_EX(aluout_EX_MEM),
        .rdata2_EX(rdata2_EX_MEM),
        .immext_EX(immext_EX_MEM),
        .pcimmaui_EX(pcimmaui_EX_MEM),
        .pcnext_EX(pcnext_EX_MEM),

        // EX -> IF Signals
        .pcimm_EX(pcimm_EX_IF),
        .pcmuxsel_EX(pcmuxsel_EX_IF),

        // Forwarding Signals
        .memread_EX(memread_EX),
        
        // Branch Hazard Signals
        .btaken_EX(btaken_EX)
    );

    ////////////////////////////////////////////
    // Memory [Stage - 4]
    ////////////////////////////////////////////
    MEM_Stage U_MEM_Stage(
        // Global Signals
        .clk(clk),
        .rstn(rstn),

        // EX -> MEM Signals
        .regwrite_EX(regwrite_EX_MEM),
        .rd_EX(rd_EX_MEM),
        .aluout_EX(aluout_EX_MEM),
        .datawe_EX(datawe_EX_MEM),
        .wbsel_EX(wbsel_EX_MEM),
        .strb_EX(strb_EX_MEM),
        .rdata2_EX(rdata2_EX_MEM),
        .immext_EX(immext_EX_MEM),
        .pcimmaui_EX(pcimmaui_EX_MEM),
        .pcnext_EX(pcnext_EX_MEM),

        // MEM -> WB Signals
        .regwrite_MEM(regwrite_MEM_WB),
        .wbsel_MEM(wbsel_MEM_WB),
        .rd_MEM(rd_MEM_WB),
        .aluout_MEM(aluout_MEM_WB),
        .rdata_MEM(rdata_MEM_WB),
        .immext_MEM(immext_MEM_WB),
        .pcimmaui_MEM(pcimmaui_MEM_WB),
        .pcnext_MEM(pcnext_MEM_WB)
    );

    ////////////////////////////////////////////
    // Write Back [Stage - 5]
    ////////////////////////////////////////////
    WB_Stage U_WB_Stage(
        // Global Signals
        .clk(clk),
        .rstn(rstn),

        // MEM -> WB Signals
        .regwrite_MEM(regwrite_MEM_WB),
        .wbsel_MEM(wbsel_MEM_WB),
        .rd_MEM(rd_MEM_WB),
        .aluout_MEM(aluout_MEM_WB),
        .rdata_MEM(rdata_MEM_WB),
        .immext_MEM(immext_MEM_WB),
        .pcimmaui_MEM(pcimmaui_MEM_WB),
        .pcnext_MEM(pcnext_MEM_WB),

        // WB Signals
        .regwrite_WB(regwrite_WB_ID),
        .rd_WB(rd_WB_ID),
        .wbout_WB(wbout_WB_ID)
    );

    ////////////////////////////////////////////
    // Data Hazard Detection Unit
    ////////////////////////////////////////////

    Hazard_Detection U_Hazard_Detection(
        // ID Stage
        .rs1_ID(rs1_ID),
        .rs2_ID(rs2_ID),

        // EX Stage
        .rs1_EX(rs1_EX),
        .rs2_EX(rs2_EX),
        .load_EX(memread_EX),
        .rd_EX(rd_ID_EX),
        .regwrite_EX(regwrite_ID_EX),
        .btaken_EX(btaken_EX),

        // MEM Stage
        .rd_MEM(rd_EX_MEM),
        .regwrite_MEM(regwrite_EX_MEM),

        // WB Stage
        .rd_WB(rd_MEM_WB),
        .regwrite_WB(regwrite_MEM_WB),

        // Hazard Signals
        .forward_A(forward_A),
        .forward_B(forward_B),
        .stall(stall),
        .flush(flush)
    );

endmodule
