`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: adder_sub_4bit
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-28
//////////////////////////////////////////////////////////////////////////////////
module adder_sub_4bit(
    input  wire [3:0] a,        // 4-bit input a
    input  wire [3:0] b,        // 4-bit input b
    input  wire       sub,      // sub = 0 => + | sub = 1 => -
    output wire [3:0] sum,      // result out 4 bit
    output wire       c3,       // carry in bit 3
    output wire       c4        // carry out bit 3
);
    wire [3:0] b_operand;       // B input (B | ~B)
    wire [4:0] carry;           // carry[0]=cin, carry[4]=cout

    assign carry[0] = sub;  // if sub = 1 => carry[0] = 1 => a + ~b + 1
                            // if sub = 0 => carry[0] = 1 => a + b + 0
    assign b_operand = b ^ {4{sub}}; // if sub = 0: b_operand = b ^ 4'b0000 = b
                                     // if sub = 1: b_operand = b ^ 4'b1111 = ~b
    // series 4 full adder
    genvar i;   // instantiate and chain 4 F_adder 
    generate
        for (i = 0; i < 4; i = i + 1) begin : fa_chain      // the loop
            fa_cell u_fa (
                .a   (a[i]),
                .b   (b_operand[i]),
                .cin (carry[i]),
                .sum (sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign c3 = carry[3];   // carry in to bit 3
    assign c4 = carry[4];   // final carry out
endmodule
