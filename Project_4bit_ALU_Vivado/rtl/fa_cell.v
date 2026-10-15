`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: fa_cell
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-28
//////////////////////////////////////////////////////////////////////////////////
module fa_cell(
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire p = a ^ b;     // p = a XOR b
    wire g = a & b;     // g = a AND b

    assign sum  = p ^ cin;             // sum = a ^ b ^ cin
    assign cout = g | (p & cin);       // cout = (a & b) | ((a ^ b) & cin)

endmodule
