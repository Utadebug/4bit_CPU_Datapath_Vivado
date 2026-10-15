`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: logic_unit
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-09-29
//////////////////////////////////////////////////////////////////////////////////
module muldiv_core(
    input  wire       clk,          // clock signal
    input  wire       rst,          // asynchronous reset
    input  wire       start,        // start pulse
    input  wire       is_div,       // 0: multiply, 1: divide
    input  wire [3:0] a,            // 4-bit operand a
    input  wire [3:0] b,            // 4-bit operand b

    output wire [3:0] add_in_a,     // shared adder input a
    output wire [3:0] add_in_b,     // shared adder input b
    output wire       add_in_sub,   // shared adder sub control
    input  wire [3:0] add_out_sum,  // shared adder sum output
    input  wire       add_out_c4,   // shared adder carry output

    output wire [3:0] hi_reg,       // high result (product high or remainder)
    output wire [3:0] lo_reg,       // low result (product low or quotient)
    output wire       busy,         // execution busy flag
    output reg        done,         // operation done flag
    output reg        div_by_zero   // divide by zero flag
);
    reg [3:0] acc;                  // accumulator register
    reg [3:0] q;                    // multiplier or quotient register
    reg [3:0] m;                    // multiplicand or divisor register

    reg [1:0] step_count;           // 4-step counter (0 to 3)
    reg       is_running;           // running state flag
    reg       div_mode;             // operation mode latch

    wire [3:0] div_acc_shifted;     // shifted accumulator with next bit
    wire       div_r_top;           // dropped msb of accumulator
    wire       fits;                // subtract condition check

    // shift left accumulator and bring in msb of q
    assign div_acc_shifted = {acc[2:0], q[3]};
    assign div_r_top       = acc[3];
    assign fits            = div_r_top | add_out_c4;

    // mux inputs to the shared adder/subtractor
    assign add_in_a   = div_mode ? div_acc_shifted : acc;
    assign add_in_b   = m;
    assign add_in_sub = div_mode;

    // output status assignments
    assign busy   = is_running;
    assign hi_reg = acc;
    assign lo_reg = q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc         <= 4'd0;
            q           <= 4'd0;
            m           <= 4'd0;
            step_count  <= 2'd0;
            is_running  <= 1'b0;
            div_mode    <= 1'b0;
            done        <= 1'b0;
            div_by_zero <= 1'b0;
        end else if (start && !is_running) begin
            // initialize registers and start operation
            is_running  <= 1'b1;
            done        <= 1'b0;
            div_mode    <= is_div;
            step_count  <= 2'd0;
            acc         <= 4'd0;
            div_by_zero <= is_div && (b == 4'd0);

            if (is_div) begin
                q <= a;             // load dividend
                m <= b;             // load divisor
            end else begin
                q <= b;             // load multiplier
                m <= a;             // load multiplicand
            end
        end else if (is_running) begin
            if (!div_mode) begin
                // multiplication step: shift-and-add
                if (q[0])
                    {acc, q} <= {add_out_c4, add_out_sum, q[3:1]};
                else
                    {acc, q} <= {1'b0, acc, q[3:1]};
            end else begin
                // division step: restoring shift-and-sub
                if (fits) begin
                    acc <= add_out_sum;
                    q   <= {q[2:0], 1'b1};
                end else begin
                    acc <= div_acc_shifted;
                    q   <= {q[2:0], 1'b0};
                end
            end

            // increment counter and check completion
            step_count <= step_count + 1'b1;
            if (step_count == 2'd3) begin
                is_running <= 1'b0;
                done       <= 1'b1;
            end
        end
    end
endmodule
