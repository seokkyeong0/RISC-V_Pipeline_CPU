`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/29 14:28:45
// Design Name: 
// Module Name: WB_Stage
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


module WB_Stage(
    // Global Signals
    input logic clk,
    input logic rstn,

    // MEM -> WB Signals
    input logic        regwrite_MEM,
    input logic [ 2:0] wbsel_MEM,
    input logic [ 4:0] rd_MEM,
    input logic [31:0] aluout_MEM,
    input logic [31:0] rdata_MEM,
    input logic [31:0] immext_MEM,
    input logic [31:0] pcimmaui_MEM,
    input logic [31:0] pcnext_MEM,

    // WB Signals
    output logic        regwrite_WB,
    output logic [ 4:0] rd_WB,
    output logic [31:0] wbout_WB
);

    // Registers & Wires
    logic [31:0] wbmuxout;

    // Outputs
    assign regwrite_WB = regwrite_MEM;
    assign rd_WB       = rd_MEM;
    assign wbout_WB    = wbmuxout;

    // WriteBack MUX
    Mux_5x1 U_MUX_WriteBack (
        .wbsel(wbsel_MEM),
        .in_1(aluout_MEM),
        .in_2(rdata_MEM),
        .in_3(immext_MEM),
        .in_4(pcimmaui_MEM),
        .in_5(pcnext_MEM),
        .muxout(wbmuxout)
    );

endmodule

module Mux_5x1 (
    input  logic [ 2:0] wbsel,
    input  logic [31:0] in_1,
    input  logic [31:0] in_2,
    input  logic [31:0] in_3,
    input  logic [31:0] in_4,
    input  logic [31:0] in_5,
    output logic [31:0] muxout
);

    always_comb begin
        case (wbsel)
            3'd0: muxout = in_1; 
            3'd1: muxout = in_2; 
            3'd2: muxout = in_3; 
            3'd3: muxout = in_4; 
            3'd4: muxout = in_5; 
            default: muxout = 32'd0; 
        endcase
    end
    
endmodule