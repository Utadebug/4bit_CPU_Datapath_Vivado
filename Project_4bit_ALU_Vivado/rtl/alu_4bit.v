`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: logic_unit
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-30
//////////////////////////////////////////////////////////////////////////////////
module alu_4bit(
    input  wire       clk,          // system clock
    input  wire       rst,          // asynchronous reset
    input  wire       start,        // start pulse for multi-cycle ops
    input  wire [3:0] a,            // 4-bit operation a
    input  wire [3:0] b,            // 4-bit op b
    input  wire [3:0] opcode,       // 4-bit op code
    output wire [7:0] result,       // 8-bit alu result
    output wire       carry,        // carry flag
    output wire       zero,         // zero flag
    output wire       overflow,     // overflow flag
    output wire       negative,     // negative flag
    output wire       div_by_zero,  // divide by zero error flag
    output wire       busy,         // multi-cycle execution busy flag
    output wire       done          // multi-cycle op done flag
);

    // control unit
    wire sub, arith, is_shl, is_shr, is_div, is_muldiv;
    control_unit u_ctrl (
        .opcode     (opcode),
        .sub        (sub),
        .arith      (arith),
        .is_shl     (is_shl),
        .is_shr     (is_shr),
        .is_div     (is_div),
        .is_muldiv  (is_muldiv)
    );

    // shared adder/subtractor input mux
    wire [3:0] md_add_a, md_add_b;
    wire       md_add_sub;
    wire [3:0] mux_add_a = busy ? md_add_a : a;     // mux operand a
    wire [3:0] mux_add_b = busy ? md_add_b : b;     // mux op b
    wire       mux_sub   = busy ? md_add_sub : sub; // mux sub control

    // 4-bit adder/subtractor core
    wire [3:0] sum_out;
    wire       c3, c4;
    adder_sub_4bit u_adder (
        .a   (mux_add_a),
        .b   (mux_add_b),
        .sub (mux_sub),
        .sum (sum_out),
        .c3  (c3),
        .c4  (c4)
    );

    // logic unit
    wire [3:0] out_and, out_or, out_xor, out_not;
    logic_unit u_logic (
        .a       (a),
        .b       (b),
        .out_and (out_and),
        .out_or  (out_or),
        .out_xor (out_xor),
        .out_not (out_not)
    );

    // shifter unit
    wire [3:0] shl_val, shr_val;
    wire       shl_drop, shr_drop;
    shifter_unit u_shifter (
        .a        (a),
        .shl_val  (shl_val),
        .shr_val  (shr_val),
        .shl_drop (shl_drop),
        .shr_drop (shr_drop)
    );

    // sequential multiplier/divider core
    wire [3:0] md_hi, md_lo;
    wire       core_dbz;
    muldiv_core u_muldiv (
        .clk         (clk),
        .rst         (rst),
        .start       (start & is_muldiv),
        .is_div      (is_div),
        .a           (a),
        .b           (b),
        .add_in_a    (md_add_a),
        .add_in_b    (md_add_b),
        .add_in_sub  (md_add_sub),
        .add_out_sum (sum_out),
        .add_out_c4  (c4),
        .hi_reg      (md_hi),
        .lo_reg      (md_lo),
        .busy        (busy),
        .done        (done),
        .div_by_zero (core_dbz)
    );

    // divide by zero status flag
    assign div_by_zero = is_div & core_dbz;

    // result multiplexer
    result_mux u_mux (
        .opcode    (opcode),
        .sum       (sum_out),
        .out_and   (out_and),
        .out_or    (out_or),
        .out_xor   (out_xor),
        .out_not   (out_not),
        .shl_val   (shl_val),
        .shr_val   (shr_val),
        .md_hi     (md_hi),
        .md_lo     (md_lo),
        .final_res (result)
    );

    // status flag generator
    flag_gen u_flags (
        .result    (result),
        .arith     (arith),
        .is_shl    (is_shl),
        .is_shr    (is_shr),
        .is_muldiv (is_muldiv),
        .c3        (c3),
        .c4        (c4),
        .shl_drop  (shl_drop),
        .shr_drop  (shr_drop),
        .carry     (carry),
        .zero      (zero),
        .overflow  (overflow),
        .negative  (negative)
    );
endmodule
