`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: logic_unit
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-29
//////////////////////////////////////////////////////////////////////////////////
module control_unit(
    input  wire [3:0] opcode,       // 4-bit operation code
    output wire       sub,          // subtract control 
    output wire       arith,        // arithmetic operation (add/sub)
    output wire       is_shl,       // shift left operation
    output wire       is_shr,       // shift right operation      
    output wire       is_div,       // division operation
    output wire       is_muldiv     // multiply or divide operation
);
    assign sub       = (opcode == 4'b0001);         // 1: sub
    assign arith     = (opcode[3:1] == 3'b000);     // 0000: add, 0001: sub
    assign is_shl    = (opcode == 4'b0110);         // 0110 in code: shift left
    assign is_shr    = (opcode == 4'b0111);         // 0111: shift right
    assign is_div    = (opcode == 4'b1001);         // 1001: division
    assign is_muldiv = (opcode[3:1] == 3'b100);     // 1000: mul, 1001: div
endmodule
