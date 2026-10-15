`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: logic_unit
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-30
//////////////////////////////////////////////////////////////////////////////////
module flag_gen(
    input  wire [7:0] result,       // 8-bit alu result
    input  wire       arith,        // arithmetic operation flag
    input  wire       is_shl,       // shift left op flag
    input  wire       is_shr,       // shift right op flag
    input  wire       is_muldiv,    // multiply or divide op flag
    input  wire       c3,           // carry-in to msb (bit 3)
    input  wire       c4,           // carry-out from msb
    input  wire       shl_drop,     // drop bit from shift l
    input  wire       shr_drop,     // drop bit from shift r
    output wire       carry,        // carry / borrow / shifted bit flag
    output wire       zero,         // zero result flag
    output wire       overflow,     // signed arithmetic overflow flag
    output wire       negative      // negative sign flag
);

    // carry flag from adder/subtractor or shifter drop
    assign carry    = (arith & c4) | (is_shl & shl_drop) | (is_shr & shr_drop);

    // signed overflow flag: c3 xor c4 (valid only for add/sub)
    assign overflow = arith & (c3 ^ c4);

    // zero flag: high when all 8 result bits are zero
    assign zero     = (result == 8'h00);

    // negative flag: msb sign bit for 4-bit operations
    assign negative = ~is_muldiv & result[3];
endmodule
