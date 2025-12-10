`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/09 12:26:11
// Design Name: 
// Module Name: Branch_Predictor
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


module Branch_Predictor(
    // Global Signals
    input  logic clk,
    input  logic rstn,

    // IF Stage Signals
    input  logic [31:0] pc,
    input  logic        is_branch,
    output logic        prediction,

    // EX Stage Signals
    input  logic [31:0] pc_EX,
    input  logic        branch_EX,
    input  logic        btaken_EX
);

    // Branch History Register
    logic [1:0] history [0:63];

    // Index Calculation
    logic [5:0] index_IF, index_EX;
    
    assign index_IF = pc[7:2];
    assign index_EX = pc_EX[7:2];

    // Prediction Logic
    logic [1:0] counter_IF;
    assign counter_IF = history[index_IF];

    // Predict taken if MSB = 1 (counter >= 2)
    // 00, 01 => Not Taken
    // 10, 11 => Taken
    assign prediction = is_branch & counter_IF[1];

    // Update Logic
    logic [1:0] counter_EX;
    logic [1:0] counter_next;

    // Read current counter
    assign counter_EX = history[index_EX];

    // State transition (Saturating counter)
    always_comb begin
        case (counter_EX)
            2'b00: counter_next = btaken_EX ? 2'b01 : 2'b00; // Stay at 00 or move to 01
            2'b01: counter_next = btaken_EX ? 2'b10 : 2'b00; // Move to 10 or 00
            2'b10: counter_next = btaken_EX ? 2'b11 : 2'b01; // Move to 11 or 01
            2'b11: counter_next = btaken_EX ? 2'b11 : 2'b10; // Stay at 11 or move to 10
            default: counter_next = 2'b01; // Weakly Not Taken
        endcase
    end

    // Write back to history
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 64; i++) begin
                history[i] <= 2'b01;
            end
        end else if (branch_EX) begin
            history[index_EX] <= counter_next;
        end
    end

endmodule
