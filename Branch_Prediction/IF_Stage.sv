`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/29 14:29:21
// Design Name: 
// Module Name: IF_Stage
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

module IF_Stage(
    // Global Signals
    input  logic        clk,
    input  logic        rstn,

    // Hazard Signal
    input  logic        stall,
    input  logic        flush,

    // Branch Prediction Signals
    output logic [31:0] pc,
    output logic        is_branch,
    input  logic        prediction,
    input  logic        misprediction,
    input  logic [31:0] ctarget,
    output logic        prediction_IF,

    // IF -> ID Signals
    output logic [31:0] instr_IF,
    output logic [31:0] pc_IF,
    output logic [31:0] pcnext_IF,

    // EX -> IF Signals
    input  logic [31:0] pcimm_EX,
    input  logic        pcmuxsel_EX
);

    // Registers & Wires
    logic [31:0] pc_current;
    logic [31:0] pc_next;
    logic [31:0] pc_sequential;
    logic [31:0] instr_code;
    logic [31:0] pcmuxout;

    // Branch Signals
    assign pc = pc_current;
    assign is_branch = (instr_code[6:0] == `B_Type) ? 1'b1 : 1'b0;

    // Predict Target Calculation
    logic [31:0] imm_B;
    assign imm_B = {{19{instr_code[31]}}, 
                    instr_code[31], 
                    instr_code[7], 
                    instr_code[30:25], 
                    instr_code[11:8], 
                    1'b0};

    logic [31:0] predict_target;
    assign predict_target = pc_current + imm_B;
    assign pc_sequential = pc_current + 4;

    // PC Calculation
    logic [31:0] pc_pred;
    always_comb begin
        if (is_branch && prediction) pc_pred = predict_target;
        else pc_pred = pc_sequential;

        if (misprediction) pc_next = ctarget; // Misprediction Recovery
        else if (pcmuxsel_EX) pc_next = pcimm_EX; // JAL & JALR
        else pc_next = pc_pred; // PC Plus 4
    end

    // Pipeline Delay IF -> ID
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            instr_IF      <= 32'd0;
            pc_IF         <= 32'd0;
            pcnext_IF     <= 32'd0;
            prediction_IF <= 1'b0;
        end else if (flush) begin
            instr_IF      <= 32'h00000013; // NOP
            pc_IF         <= 32'd0;
            pcnext_IF     <= 32'd0;
            prediction_IF <= 1'b0;
        end else if (!stall) begin
            instr_IF      <= instr_code;
            pc_IF         <= pc_current;
            pcnext_IF     <= pc_sequential;
            prediction_IF <= is_branch & prediction;
        end
    end

    // Instruction ROM
    Instruction_ROM U_Instruction_ROM(
        .instr_addr(pc_current),
        .instr_code(instr_code)
    );

    // Program Counter
    Program_Counter U_Program_Counter(
        .clk(clk),
        .rstn(rstn),
        .stall(stall),
        .flush(flush),
        .pc_in(pc_next),
        .pc_out(pc_current)
    );

endmodule

module Program_Counter (
    input  logic        clk,
    input  logic        rstn,
    input  logic        stall,
    input  logic        flush,
    input  logic [31:0] pc_in,
    output logic [31:0] pc_out
);

    // Program Counter (Flip-Flop)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pc_out <= 0;
        end else if (!stall) begin
            pc_out <= pc_in;
        end
    end

endmodule

module Instruction_ROM(
    input  logic [31:0] instr_addr,
    output logic [31:0] instr_code
);

    // ROM
    logic [31:0] rom [0:1023];

    // Read instructions from instr_code.mem
    initial begin
        for (int i = 0; i < 1024; i++) begin
            // Initialize NOP
            rom[i] = 32'h00000013;
        end

        $readmemh("instr_code.mem", rom);
    end

    // Output instruction code
    assign instr_code = rom[instr_addr[31:2]];
    
endmodule