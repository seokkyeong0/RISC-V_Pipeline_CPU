`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/29 15:11:26
// Design Name: 
// Module Name: ISA_Define
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


// Opcode
`define R_Type  7'b0110011
`define I_Type  7'b0010011
`define S_Type  7'b0100011
`define L_Type  7'b0000011
`define B_Type  7'b1100011
`define LU_Type 7'b0110111
`define AU_Type 7'b0010111
`define J_Type  7'b1101111
`define JL_Type 7'b1100111

// R-Type Instruction
`define ADD  4'b0000
`define SUB  4'b1000
`define SLL  4'b0001
`define SRL  4'b0101
`define SRA  4'b1101
`define SLT  4'b0010
`define SLTU 4'b0011
`define XOR  4'b0100
`define OR   4'b0110
`define AND  4'b0111

// I-Type Instruction
`define ADDI  3'b000
`define SLTI  3'b010
`define SLTIU 3'b011
`define XORI  3'b100
`define ORI   3'b110
`define ANDI  3'b111
`define SLLI  3'b001
`define SRLI  3'b101
`define SRAI  3'b101

// S-Type Instruction
`define SB  3'b000
`define SH  3'b001
`define SW  3'b010

// L-Type Instruction
`define LB  3'b000
`define LH  3'b001
`define LW  3'b010
`define LBU 3'b100
`define LHU 3'b101

// B-Type Instruction
`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111
