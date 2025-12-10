`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/29 14:29:33
// Design Name: 
// Module Name: ID_Stage
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

module ID_Stage(
    // Global Signals
    input  logic        clk,
    input  logic        rstn,

    // Hazard Signal
    input  logic        stall,
    input  logic        flush,

    // Branch Prediction
    input  logic        prediction_IF,
    output logic        prediction_ID,

    // IF -> ID Signals
    input  logic [31:0] instr_IF,
    input  logic [31:0] pc_IF,
    input  logic [31:0] pcnext_IF,

    // ID -> EX Signals
    output logic [31:0] pc_ID,
    output logic [31:0] rdata1_ID,
    output logic [31:0] rdata2_ID,
    output logic [ 4:0] rd_ID,
    output logic        regwrite_ID,
    output logic        alumuxsel_ID,
    output logic        datawe_ID,
    output logic [ 2:0] wbsel_ID,
    output logic        branch_ID,
    output logic        jal_ID,
    output logic        jalr_ID,
    output logic [ 3:0] alucontrol_ID,
    output logic [ 2:0] strb_ID,
    output logic [31:0] immext_ID,
    output logic [31:0] pcnext_ID,

    // WB -> ID Signals
    input  logic        regwrite_WB,
    input  logic [ 4:0] rd_WB,
    input  logic [31:0] wdata_WB,

    // Forwarding Signals
    output logic [ 4:0] rs1_ID,
    output logic [ 4:0] rs2_ID,
    output logic [ 4:0] rs1_EX,
    output logic [ 4:0] rs2_EX
);

    // Registers & Wires
    logic [31:0] rdata_1;
    logic [31:0] rdata_2;
    logic [31:0] immext;

    // Control Signals
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [6:0] opcode;

    assign funct7 = instr_IF[31:25];
    assign funct3 = instr_IF[14:12];
    assign opcode = instr_IF[6:0];

    logic        regwrite;
    logic        alumuxsel;
    logic        datawe;
    logic [ 2:0] wbsel;
    logic        branch;
    logic        jal;
    logic        jalr;
    logic [ 3:0] alucontrol;
    logic [ 2:0] strb;

    // Register Address
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;

    assign rd  = (opcode == `S_Type || opcode == `B_Type) ? 5'b0 : instr_IF[11:7];
    assign rs1 = (opcode == `LU_Type || opcode == `AU_Type || opcode == `J_Type) ? 5'b0 : instr_IF[19:15];
    assign rs2 = (opcode == `R_Type || opcode == `S_Type || opcode == `B_Type) ? instr_IF[24:20] : 5'b0;;

    assign rs1_ID = rs1;
    assign rs2_ID = rs2;

    // Pipeline Delay ID -> EX
    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            pc_ID         <= 32'd0;
            rdata1_ID     <= 32'd0;
            rdata2_ID     <= 32'd0;
            rd_ID         <= 5'd0;
            regwrite_ID   <= 1'b0;
            alumuxsel_ID  <= 1'b0;
            datawe_ID     <= 1'b0;
            wbsel_ID      <= 3'd0;
            branch_ID     <= 1'b0;
            jal_ID        <= 1'b0;
            jalr_ID       <= 1'b0;
            alucontrol_ID <= 4'd0;
            strb_ID       <= 3'd0;
            immext_ID     <= 32'd0;
            pcnext_ID     <= 32'd0;
            rs1_EX        <= 5'd0;
            rs2_EX        <= 5'd0;
            prediction_ID <= 1'b0;
        end else if (stall || flush) begin
            regwrite_ID   <= 1'b0;
            alumuxsel_ID  <= 1'b0;
            datawe_ID     <= 1'b0;
            wbsel_ID      <= 3'd0;
            branch_ID     <= 1'b0;
            jal_ID        <= 1'b0;
            jalr_ID       <= 1'b0;
            alucontrol_ID <= 4'd0;
            strb_ID       <= 3'd0;
            prediction_ID <= 1'b0;
        end else begin
            pc_ID         <= pc_IF;
            rdata1_ID     <= rdata_1;
            rdata2_ID     <= rdata_2;
            rd_ID         <= rd;
            regwrite_ID   <= regwrite;
            alumuxsel_ID  <= alumuxsel;
            datawe_ID     <= datawe;
            wbsel_ID      <= wbsel;
            branch_ID     <= branch;
            jal_ID        <= jal;
            jalr_ID       <= jalr;
            alucontrol_ID <= alucontrol;
            strb_ID       <= strb;
            immext_ID     <= immext;
            pcnext_ID     <= pcnext_IF;
            rs1_EX        <= rs1_ID;
            rs2_EX        <= rs2_ID;
            prediction_ID <= prediction_IF;
        end
    end

    // Control Unit
    Control_Unit U_Control_Unit(
        .funct7(funct7),
        .funct3(funct3),
        .opcode(opcode),
        .rd(rd),
        .regwrite(regwrite),
        .alumuxsel(alumuxsel),
        .datawe(datawe),
        .wbsel(wbsel),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .alucontrol(alucontrol),
        .strb(strb)
    );

    // Register File
    Register_File U_Register_File(
        .clk(clk),
        .wenable(regwrite_WB),
        .rd(rd_WB),
        .wdata(wdata_WB),
        .rs_1(rs1_ID),
        .rs_2(rs2_ID),
        .rdata_1(rdata_1),
        .rdata_2(rdata_2)
    );

    Imm_Extender U_Imm_Extender(
        .imm(instr_IF),
        .immext(immext)
    );


endmodule

module Control_Unit (
    input  logic [ 6:0] funct7,
    input  logic [ 2:0] funct3,
    input  logic [ 6:0] opcode,
    input  logic [ 4:0] rd,
    output logic        regwrite,
    output logic        alumuxsel,
    output logic        datawe,
    output logic [ 2:0] wbsel,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic [ 3:0] alucontrol,
    output logic [ 2:0] strb
);

    logic [8:0] control_signals;
    assign {regwrite, alumuxsel, datawe, wbsel, branch, jal, jalr} = control_signals;

    always_comb begin
        case (opcode)
            `R_Type : control_signals = 9'b1_0_0_000_0_0_0;
            `I_Type : begin
                // NOP Detection
                if (rd == 5'b00000) control_signals = 9'b0_0_0_000_0_0_0;
                else control_signals = 9'b1_1_0_000_0_0_0;
            end
            `S_Type : control_signals = 9'b0_1_1_000_0_0_0;
            `L_Type : control_signals = 9'b1_1_0_001_0_0_0;
            `B_Type : control_signals = 9'b0_0_0_000_1_0_0;
            `LU_Type: control_signals = 9'b1_0_0_010_0_0_0;
            `AU_Type: control_signals = 9'b1_0_0_011_0_0_0;
            `J_Type : control_signals = 9'b1_0_0_100_0_1_0;
            `JL_Type: control_signals = 9'b1_0_0_100_0_1_1;
            default:  control_signals = 9'b0_0_0_000_0_0_0;
        endcase
    end

    always_comb begin
        case (opcode)
            `R_Type: alucontrol = {funct7[5], funct3};
            `I_Type: begin
                if({funct7[5], funct3} == 4'b1101) alucontrol = 4'b1101; 
                else alucontrol = {1'b0, funct3};
            end
            `B_Type: alucontrol = {1'b0, funct3};
            default: alucontrol = 4'b0000;
        endcase
    end

    always_comb begin
        case (opcode)
            `S_Type: begin
                case (funct3)
                    3'b000: strb = 3'b000;
                    3'b001: strb = 3'b001;
                    3'b010: strb = 3'b010;
                endcase
            end
            `L_Type: begin
                case (funct3)
                    3'b000: strb = 3'b011;
                    3'b001: strb = 3'b100;
                    3'b010: strb = 3'b101;
                    3'b100: strb = 3'b110;
                    3'b101: strb = 3'b111;
                endcase
            end
            default: strb = 3'b000; 
        endcase
    end
endmodule

module Register_File (
    input  logic        clk,
    input  logic        wenable,
    input  logic [ 4:0] rd,
    input  logic [31:0] wdata,
    input  logic [ 4:0] rs_1,
    input  logic [ 4:0] rs_2,
    output logic [31:0] rdata_1,
    output logic [31:0] rdata_2
);

    logic [31:0] reg_file [0:31];

    always_ff @(posedge clk) begin
        if (wenable) begin
            reg_file[rd] <= wdata;
        end
    end

    // Internal Forwarding Logics (WB-ID Hazard)
    assign rdata_1 = (rs_1 != 0) ? ((wenable && (rd == rs_1)) ? wdata : reg_file[rs_1]) : 32'd0;
    assign rdata_2 = (rs_2 != 0) ? ((wenable && (rd == rs_2)) ? wdata : reg_file[rs_2]) : 32'd0;
    
endmodule

module Imm_Extender (
    input  logic [31:0] imm,
    output logic [31:0] immext
);

    always_comb begin
        case (imm[6:0])
            `I_Type : immext = {{20{imm[31]}}, imm[31:20]};
            `S_Type : immext = {{20{imm[31]}}, imm[31:25], imm[11:7]};
            `L_Type : immext = {{20{imm[31]}}, imm[31:20]};
            `B_Type : immext = {{20{imm[31]}}, imm[7], imm[30:25], imm[11:8], 1'b0};
            `LU_Type: immext = {imm[31:12], 12'b0};
            `AU_Type: immext = {imm[31:12], 12'b0};
            `J_Type : immext = {{12{imm[31]}}, imm[19:12], imm[20], imm[30:21], 1'b0};
            `JL_Type: immext = {{20{imm[31]}}, imm[31:20]};
            default: immext = 32'd0;
        endcase
    end
    
endmodule
