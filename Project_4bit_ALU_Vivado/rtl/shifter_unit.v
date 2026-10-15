`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: shifter_unit
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-28
//////////////////////////////////////////////////////////////////////////////////
module shifter_unit(
    input  wire [3:0] a,    // 4-bit input a
    output wire [3:0] shl_val,      // shift left result
    output wire [3:0] shr_val,      // shift right result
    output wire       shl_drop, // dropped bit on left shift
    output wire       shr_drop  // dropped bit on right shift
 );
    assign shl_val  = {a[2:0], 1'b0};       // shift left by 1 bit
    assign shr_val  = {1'b0, a[3:1]};       // shift right by 1 bit
    assign shl_drop = a[3];     // dropped left
    assign shr_drop = a[0];     // dropped right
 
endmodule
