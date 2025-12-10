`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/01 10:35:44
// Design Name: 
// Module Name: tb_CPU_Core
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


module tb_CPU_Core();

    logic clk, rstn;

    CPU_Core DUT(
        .clk(clk),
        .rstn(rstn)
    );

    always #5 clk = ~clk;
    
    initial begin
        #00; clk = 0; rstn = 0;
        #10; rstn = 1;

        #3000; $finish;
    end

endmodule
