`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: logic_unit
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-30
//////////////////////////////////////////////////////////////////////////////////
module result_mux(
    input  wire [3:0] opcode,       // 4-bit operation code
    input  wire [3:0] sum,          // adder/subtractor result
    input  wire [3:0] out_and,      // bitwise and result
    input  wire [3:0] out_or,       // bitwise or result
    input  wire [3:0] out_xor,      // bitwise xor result
    input  wire [3:0] out_not,      // bitwise not result
    input  wire [3:0] shl_val,      // shift left result
    input  wire [3:0] shr_val,      // shift right result
    input  wire [3:0] md_hi,        // mul/div high byte (product high or remainder)
    input  wire [3:0] md_lo,        // mul/div low byte (product low or quotient)
    output reg  [7:0] final_res     // 8-bit multiplexed alu output
);

    // select alu output based on opcode
    always @(*) begin
        case (opcode)
            4'b0000, 4'b0001: final_res = {4'b0000, sum};      // add , sub
            4'b0010:          final_res = {4'b0000, out_and};  // and
            4'b0011:          final_res = {4'b0000, out_or};   // or
            4'b0100:          final_res = {4'b0000, out_xor};  // xor
            4'b0101:          final_res = {4'b0000, out_not};  // not
            4'b0110:          final_res = {4'b0000, shl_val};  // shift left
            4'b0111:          final_res = {4'b0000, shr_val};  // shift right
            4'b1000, 4'b1001: final_res = {md_hi, md_lo};      // mul , div
            default:          final_res = 8'h00;               // default output
        endcase
    end
endmodule
