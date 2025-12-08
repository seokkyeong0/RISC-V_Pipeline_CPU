`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/07 15:38:13
// Design Name: 
// Module Name: Hazard_Detection
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


module Hazard_Detection(
    // ID Stage
    input  logic [4:0] rs1_ID,
    input  logic [4:0] rs2_ID,

    // EX Stage
    input  logic [4:0] rs1_EX,
    input  logic [4:0] rs2_EX,
    input  logic       load_EX,
    input  logic [4:0] rd_EX,
    input  logic       regwrite_EX,
    input  logic       btaken_EX,

    // MEM Stage
    input  logic [4:0] rd_MEM,
    input  logic       regwrite_MEM,

    // WB Stage
    input  logic [4:0] rd_WB,
    input  logic       regwrite_WB,

    // Hazard Signals
    output logic [1:0] forward_A, // Forwarding rs1
    output logic [1:0] forward_B, // Forwarding rs2
    output logic       stall    , // Pipeline Stall
    output logic       flush      // Flush
);

    // Data Hazard Detection
    always_comb begin
        // Forward A (rs1)
        if (regwrite_MEM && (rd_MEM != 0) && (rd_MEM == rs1_EX))
            forward_A = 2'b10; // Forwarding at EX Stage
        else if (regwrite_WB && (rd_WB != 0) && (rd_WB == rs1_EX))
            forward_A = 2'b01; // Forwarding at MEM Stage
        else
            forward_A = 2'b00; // No Forwarding

        // Forward B (rs2)
        if (regwrite_MEM && (rd_MEM != 0) && (rd_MEM == rs2_EX))
            forward_B = 2'b10;
        else if (regwrite_WB && (rd_WB != 0) && (rd_WB == rs2_EX))
            forward_B = 2'b01;
        else
            forward_B = 2'b00;
    end

    // Load Use Hazard Detection
    assign stall = load_EX && (rd_EX != 0) &&
                   ((rd_EX == rs1_ID) || (rd_EX == rs2_ID));

    // Control Hazard Detection
    assign flush = btaken_EX;

endmodule