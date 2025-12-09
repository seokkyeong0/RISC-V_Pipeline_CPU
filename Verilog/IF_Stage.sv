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


module IF_Stage(
    // Global Signals
    input  logic        clk,
    input  logic        rstn,

    // Hazard Signal
    input  logic        stall,
    input  logic        flush,

    // IF -> ID Signals
    output logic [31:0] instr_IF,
    output logic [31:0] pc_IF,
    output logic [31:0] pcnext_IF,

    // EX -> IF Signals
    input  logic [31:0] pcimm_EX,
    input  logic        pcmuxsel_EX
);

    // Registers & Wires
    logic [31:0] pc_current, pc_next;
    logic [31:0] instr_code;
    logic [31:0] pcmuxout;

    // Pipeline Delay IF -> ID
    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            instr_IF  <= 32'd0;
            pc_IF     <= 32'd0;
            pcnext_IF <= 32'd0;
        end else if (flush) begin
            instr_IF  <= 32'h00000013; // NOP
        end else if (!stall) begin
            instr_IF  <= instr_code;
            pc_IF     <= pc_current;
            pcnext_IF <= pc_next;
        end
    end

    Mux_2x1 U_PCMuxSel(
        .sel(pcmuxsel_EX),
        .in_1(pc_next),
        .in_2(pcimm_EX),
        .out(pcmuxout)
    );

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
        .pc_in(pcmuxout),
        .pc_out(pc_current)
    );

    // PC Adder
    PC_Adder U_PC_Adder(
        .pc(pc_current),
        .plus(4),
        .pc_next(pc_next)
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
    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            pc_out <= 0;
        end else if (!stall) begin
            pc_out <= pc_in;
        end
    end

endmodule

module PC_Adder (
    input  logic [31:0] pc,
    input  logic [31:0] plus,
    output logic [31:0] pc_next
);

    // PC Address adder
    assign pc_next = pc + plus;
    
endmodule


module Instruction_ROM(
    input  logic [31:0] instr_addr,
    output logic [31:0] instr_code
);

    // ROM
    logic [31:0] rom [0:1023];

    // Read instructions from instr_code.mem
    initial begin
        for(int i = 0; i < 1024; i++) begin
            rom[i] <= 32'h00000013;
        end
        $readmemh("instr_code.mem", rom);
    end

    // Output instruction code
    assign instr_code = rom[instr_addr[31:2]];
    
endmodule
