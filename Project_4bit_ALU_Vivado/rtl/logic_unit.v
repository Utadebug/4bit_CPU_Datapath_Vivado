`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: logic_unit
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-28
//////////////////////////////////////////////////////////////////////////////////
module logic_unit(
    input  wire [3:0] a,    // 4-bit input a
    input  wire [3:0] b,    // 4-bit input b
    output wire [3:0] out_and,  // bitwise AND result:  a & b
    output wire [3:0] out_or,   // bitwise OR result:   a | b
    output wire [3:0] out_xor,  // bitwise XOR result:  a ^ b
    output wire [3:0] out_not   // bitwise NOT result:  ~a (invert a)
);
    assign out_and = a & b;     // a AND b
    assign out_or  = a | b;     // a OR b
    assign out_xor = a ^ b;     // a XOR b
    assign out_not = ~a;        // NOT a
endmodule
