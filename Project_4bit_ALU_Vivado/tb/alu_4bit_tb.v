`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: alu_4bit_tb
// Designer:    Tran Quan Bao
// Roll Number: SE190570
// Date:        2026-10-01
//////////////////////////////////////////////////////////////////////////////////
module alu_4bit_tb;
    // testbench stimulus signals
    reg        clk = 0;              // system clock source
    reg        rst = 1;              // active-high reset
    reg        start = 0;            // pulse to trigger multi-cycle operation
    reg  [3:0] a = 0;                // 4-bit operand a
    reg  [3:0] b = 0;                // 4-bit operand b
    reg  [3:0] opcode = 0;           // operation selection code

    // dut monitored outputs
    wire [7:0] result;               // 8-bit computational output
    wire       carry;                // carry / borrow / shifted bit flag
    wire       zero;                 // zero result detection flag
    wire       overflow;             // signed 2's complement overflow flag
    wire       negative;             // signed negative msb flag
    wire       div_by_zero;          // division by zero exception flag
    wire       busy;                 // multi-cycle processing indicator
    wire       done;                 // operation completion flag

    // device under test instantiation
    alu_4bit dut (
        .clk         (clk),
        .rst         (rst),
        .start       (start),
        .a           (a),
        .b           (b),
        .opcode      (opcode),
        .result      (result),
        .carry       (carry),
        .zero        (zero),
        .overflow    (overflow),
        .negative    (negative),
        .div_by_zero (div_by_zero),
        .busy        (busy),
        .done        (done)
    );

    // 100 mhz clock generator (period = 10 ns)
    always #5 clk = ~clk;

    // reference software model variables for single-cycle operations
    reg [3:0] exp_r;                // expected 4-bit computation result
    reg       exp_c;                // expected carry bit
    reg       exp_v;                // expected overflow bit
    reg [4:0] t;                    // 5-bit temporary arithmetic register

    // golden behavioral model task
    task model;
        begin
            exp_c = 0; exp_v = 0; exp_r = 0;
            case (opcode)
                4'b0000: begin      // add operation: a + b
                    t     = {1'b0, a} + {1'b0, b};
                    exp_r = t[3:0]; 
                    exp_c = t[4];   // carry-out from msb
                    exp_v = (a[3] == b[3]) && (exp_r[3] != a[3]);
                end
                4'b0001: begin      // sub operation: a - b via 2's complement
                    t     = {1'b0, a} + {1'b0, ~b} + 5'd1;
                    exp_r = t[3:0]; 
                    exp_c = t[4];   // carry flag (1 = no borrow)
                    exp_v = (a[3] != b[3]) && (exp_r[3] != a[3]);
                end
                4'b0010: exp_r = a & b;                           // bitwise and
                4'b0011: exp_r = a | b;                           // bitwise or
                4'b0100: exp_r = a ^ b;                           // bitwise xor
                4'b0101: exp_r = ~a;                              // bitwise not
                4'b0110: begin exp_r = {a[2:0], 1'b0}; exp_c = a[3]; end // logical shift left
                4'b0111: begin exp_r = {1'b0, a[3:1]}; exp_c = a[0]; end // logical shift right
                default: exp_r = 4'd0;                            // default unmapped opcode
            endcase
        end
    endtask

    // task to drive multi-cycle multiply or divide execution
    task run_md(input [3:0] op, input [3:0] x, input [3:0] y);
        begin
            @(negedge clk);
            opcode = op; a = x; b = y; start = 1;
            @(negedge clk);
            start = 0;
            while (!done) begin
                @(negedge clk);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // TASKS IN MẪU THEO BẢNG CONSOLE (Table C1 & Table C2)
    // -------------------------------------------------------------------------
    task print_comb_sample(
        input [31:0] op_name,
        input [3:0]  op_code,
        input [3:0]  in_a,
        input [3:0]  in_b
    );
        begin
            opcode = op_code;
            a = in_a;
            b = in_b;
            #2; // đợi logic tổ hợp ổn định
            $display("  %-4s %4b | %2d  %2d | %8b (%2d) | C=%0d Z=%0d V=%0d N=%0d", 
                     op_name, opcode, a, b, result, result[3:0], carry, zero, overflow, negative);
        end
    endtask

    task print_seq_sample(
        input [31:0] op_name,
        input [3:0]  op_code,
        input [3:0]  in_a,
        input [3:0]  in_b
    );
        begin
            run_md(op_code, in_a, in_b);
            if (op_code == 4'b1000) begin // MUL
                $display("  %-4s %4b | %2d  %2d | %8b (%3d) | product = %0d, 4 cycles", 
                         op_name, opcode, a, b, result, result, result);
            end
            else if (op_code == 4'b1001) begin // DIV
                if (b == 0) begin
                    $display("  %-4s %4b | %2d  %2d | %8b        | quotient = %0d, remainder = %0d, dbz=%0d, 4 cycles", 
                             op_name, opcode, a, b, result, result[3:0], result[7:4], div_by_zero);
                end else begin
                    $display("  %-4s %4b | %2d  %2d | %8b        | quotient = %0d, remainder = %0d, dbz=%0d, 4 cycles", 
                             op_name, opcode, a, b, result, result[3:0], result[7:4], div_by_zero);
                end
            end
        end
    endtask

    // loop and test metrics variables
    integer i;                      // vector iteration index
    integer errors;                 // total accumulated error counter
    integer op_i;                   // opcode loop index
    reg [7:0] ab;                   // 8-bit combined input operand

    // main simulation sequence
    initial begin
        $display("\n============================================================");
        $display("   DIGITAL DESIGN PROJECT: 4-BIT ALU WITH MUL/DIV");
        $display("   Student Name : TRAN QUAN BAO");
        $display("   Roll Number  : SE190570");
        $display("   Date         : 2026-10-01");
        $display("============================================================\n");
        
        #12 rst = 0;                // release system reset
        errors  = 0;                // reset error counter

        // ---------------------------------------------------------------------
        // IN BẢNG SAMPLE RUNS RA TCL CONSOLE
        // ---------------------------------------------------------------------
        $display("  Op   code |  A   B |  result          | flags / notes");
        $display("  -----+----+----+---+------------------+-----------------------------");

        // Các ca mẫu Single-Cycle (Table C1)
        print_comb_sample("ADD ", 4'b0000, 4'd5,  4'd3);
        print_comb_sample("ADD ", 4'b0000, 4'd15, 4'd1);
        print_comb_sample("SUB ", 4'b0001, 4'd5,  4'd3);
        print_comb_sample("SUB ", 4'b0001, 4'd3,  4'd5);
        print_comb_sample("AND ", 4'b0010, 4'd12, 4'd10);
        print_comb_sample("OR  ", 4'b0011, 4'd12, 4'd10);
        print_comb_sample("XOR ", 4'b0100, 4'd12, 4'd10);
        print_comb_sample("NOT ", 4'b0101, 4'd12, 4'd0);
        print_comb_sample("SHL ", 4'b0110, 4'd11, 4'd0);
        print_comb_sample("SHR ", 4'b0111, 4'd11, 4'd0);

        // Các ca mẫu Multi-Cycle (Table C2)
        print_seq_sample("MUL ", 4'b1000, 4'd13, 4'd11);
        print_seq_sample("MUL ", 4'b1000, 4'd15, 4'd15);
        print_seq_sample("DIV ", 4'b1001, 4'd13, 4'd4);
        print_seq_sample("DIV ", 4'b1001, 4'd15, 4'd3);
        print_seq_sample("DIV ", 4'b1001, 4'd9,  4'd0);

        $display("  -----+----+----+---+------------------+-----------------------------\n");

        // ---------------------------------------------------------------------
        // TIẾP TỤC CHẠY EXHAUSTIVE VERIFICATION (3584 + 512 = 4096 CHECKS)
        // ---------------------------------------------------------------------
        // exhaustive verification of single-cycle operations (3584 tests)
        for (op_i = 0; op_i < 16; op_i = op_i + 1) begin
            if (op_i != 8 && op_i != 9) begin    // bypass multi-cycle opcodes
                for (i = 0; i < 256; i = i + 1) begin
                    opcode = op_i; 
                    {a, b} = i;                   // apply all 256 input combinations
                    #1;                           // wait for combinational propagation
                    model;                        // evaluate reference model
                    
                    // assert hardware result and flags against behavioral model
                    if (result !== {4'b0, exp_r} || 
                        carry !== exp_c || 
                        overflow !== exp_v || 
                        zero !== (exp_r == 0) || 
                        negative !== ((op_i < 8) ? exp_r[3] : 1'b0)) begin
                        errors = errors + 1;
                        if (errors <= 10)
                            $display("fail op=%b a=%0d b=%0d got %b expected %b", 
                                     opcode, a, b, result, exp_r);
                    end
                end
            end
        end

        // exhaustive verification of multi-cycle operations (512 tests)
        for (i = 0; i < 256; i = i + 1) begin
            ab = i;                               // generate {a, b} 4-bit pair

            // multiply check
            run_md(4'b1000, ab[7:4], ab[3:0]);
            if (result !== (ab[7:4] * ab[3:0]) || zero !== (result == 0)) begin
                errors = errors + 1;
                if (errors <= 10) 
                    $display("fail mul %0d*%0d got %0d", ab[7:4], ab[3:0], result);
            end

            // divide check
            run_md(4'b1001, ab[7:4], ab[3:0]);
            if (ab[3:0] == 0) begin
                if (div_by_zero !== 1'b1) begin
                    errors = errors + 1;
                    if (errors <= 10) 
                        $display("fail div %0d/0: dbz flag not asserted", ab[7:4]);
                end
            end else if (result[3:0] !== (ab[7:4] / ab[3:0]) || 
                         result[7:4] !== (ab[7:4] % ab[3:0]) || 
                         div_by_zero !== 1'b0) begin
                errors = errors + 1;
                if (errors <= 10) 
                    $display("fail div %0d/%0d got q=%0d r=%0d", 
                             ab[7:4], ab[3:0], result[3:0], result[7:4]);
            end
        end

        // print test results summary
        if (errors == 0)
            $display("\nPASS: 3584 single-cycle checks + 512 MUL/DIV checks, 0 errors\n");
        else
            $display("\nFAILED: %0d errors\n", errors);

        $finish;                                  // terminate simulation run
    end

endmodule