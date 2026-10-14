================================================================================

4-BIT RISC CPU DATAPATH WITH 3-STAGE PIPELINE (IF - ID - EX)

Hardware Architecture Design & Verification Report

================================================================================



STUDENT INFORMATION:

- Name: Tran Quan Bao

- Roll Number: SE190570

- Target Tool: AMD Xilinx Vivado 2026.1

- Target Device: Artix-7 (xc7a35tcpg236-1)

- Verification Result: 88/88 Automated Simulation Checks PASSED (100%)



--------------------------------------------------------------------------------

1. ARCHITECTURAL OVERVIEW

--------------------------------------------------------------------------------

- Datapath: 4-bit data width, supporting signed and unsigned representations.

- ISA: Fixed 12-bit width RISC instruction architecture.

- Pipeline Structure: 3 sequential synchronous stages:

    1. IF (Instruction Fetch): Program counter, 16x12-bit ROM.

    2. ID (Instruction Decode): IF/ID register, instruction decoder.

    3. EX (Execute / Write-Back): ID/EX register, 4x4-bit RF (R0-R3), 4-bit ALU,

       Z/C flag register, branch resolution unit, 16x4-bit DMEM (RAM).

- Branch Hazard Handling: Resolved at EX stage via automatic 2-bubble flush

  logic (flush = is_jmp | (is_jz & zero_flag)). Discards 2 invalid prefetched 

  instructions in IF and ID.

- Throughput: 1 instruction per cycle (CPI = 1) once pipeline is primed.



--------------------------------------------------------------------------------

2. INSTRUCTION SET ENCODING (12 BITS)

--------------------------------------------------------------------------------

Format: [11:8] Opcode | [7:6] Rd | [5:4] Rs | [3:0] Immediate / Address



Registers: R0=2'b00, R1=2'b01, R2=2'b10, R3=2'b11



Opcode | Mnemonic | Syntax           | Operation                     | Flags

-------+----------+------------------+-------------------------------+-------

0000   | ADD      | ADD Rd, Rs       | Rd <= Rd + Rs                 | Z, C

0001   | SUB      | SUB Rd, Rs       | Rd <= Rd - Rs (Carry=no-borrow)| Z, C

0010   | AND      | AND Rd, Rs       | Rd <= Rd & Rs                 | Z

0011   | OR       | OR Rd, Rs        | Rd <= Rd | Rs                 | Z

0100   | XOR      | XOR Rd, Rs       | Rd <= Rd ^ Rs                 | Z

0101   | NOT      | NOT Rd           | Rd <= ~Rd                     | Z

0110   | LDI      | LDI Rd, imm      | Rd <= imm[3:0]                | None

0111   | MOV      | MOV Rd, Rs       | Rd <= Rs                      | None

1000   | LOAD     | LOAD Rd, addr    | Rd <= DMEM[addr]              | None

1001   | STORE    | STORE Rd, addr   | DMEM[addr] <= Rd              | None

1010   | JMP      | JMP addr         | PC <= addr                    | None

1011   | JZ       | JZ addr          | If Z=1: PC <= addr; else PC+1 | None

1100.. | NOP      | (Reserved)       | No Operation                  | None



--------------------------------------------------------------------------------

3. CONTROL UNIT TRUTH TABLE

--------------------------------------------------------------------------------

Opcode | Name  | alu_ctrl | alu_src | wb_sel | reg_we | mem_we | z_we | c_we | is_jmp | is_jz

-------+-------+----------+---------+--------+--------+--------+------+------+--------+------

0000   | ADD   | 000(ADD) |    0    |   0    |   1    |   0    |  1   |  1   |   0    |  0

0001   | SUB   | 001(SUB) |    0    |   0    |   1    |   0    |  1   |  1   |   0    |  0

0010   | AND   | 010(AND) |    0    |   0    |   1    |   0    |  1   |  0   |   0    |  0

0011   | OR    | 011(OR)  |    0    |   0    |   1    |   0    |  1   |  0   |   0    |  0

0100   | XOR   | 100(XOR) |    0    |   0    |   1    |   0    |  1   |  0   |   0    |  0

0101   | NOT   | 101(NOT) |    0    |   0    |   1    |   0    |  1   |  0   |   0    |  0

0110   | LDI   | 110(PASS)|    1    |   0    |   1    |   0    |  0   |  0   |   0    |  0

0111   | MOV   | 110(PASS)|    0    |   0    |   1    |   0    |  0   |  0   |   0    |  0

1000   | LOAD  | 110(PASS)|    1    |   1    |   1    |   0    |  0   |  0   |   0    |  0

1001   | STORE | 110(PASS)|    1    |   0    |   0    |   1    |  0   |  0   |   0    |  0

1010   | JMP   | 000(NOP) |    0    |   0    |   0    |   0    |  0   |  0   |   1    |  0

1011   | JZ    | 000(NOP) |    0    |   0    |   0    |   0    |  0   |  0   |   0    |  1

1100.. | NOP   | 000(NOP) |    0    |   0    |   0    |   0    |  0   |  0   |   0    |  0



--------------------------------------------------------------------------------

4. MODULE HIERARCHY

--------------------------------------------------------------------------------

cpu_top

├── PC_REG       (program_counter.v)

├── IMEM         (instruction_memory.v)

├── IR           (instruction_register.v)

├── CU           (control_unit.v)

│   ├── ID_DEC   (instruction_decoder.v)

│   └── BR_UNIT  (branch_unit.v)

├── ID_EX        (pipeline_register.v)

├── RF           (register_file.v)

├── ALU_CORE     (alu.v)

├── FLAGS        (flag_register.v)

├── DMEM         (data_memory.v)

├── PC_MUX       (mux2.v)

├── OPERAND_MUX  (mux2.v)

└── WB_MUX       (mux2.v)



--------------------------------------------------------------------------------

5. SIMULATION & VERIFICATION SUMMARY

--------------------------------------------------------------------------------

- tb_alu.v:            11/11 checks PASSED (Run time: 110 ns)

- tb_register_file.v:  11/11 checks PASSED (Run time: 67 ns)

- tb_control_unit.v:   22/22 checks PASSED (Run time: 22 ns)

- tb_cpu.v:            44/44 checks PASSED (Run time: 666 ns)

--------------------------------------------------------------------------------

TOTAL COVERAGE:        88/88 automated checks PASSED (100% Pass Rate)

================================================================================