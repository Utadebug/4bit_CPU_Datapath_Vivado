# 4bit_CPU_Datapath_Vivado

A synthesizable 4-bit RISC CPU core featuring a 3-stage instruction pipeline (IF – ID – EX) implemented in Verilog HDL and verified on AMD Vivado.

<img width="482" height="251" alt="Screenshot 2026-10-15 095827" src="https://github.com/user-attachments/assets/34b53f95-5be4-4fff-8bb7-d80d0c2ecf12" />


## Features
- **Architecture:** 3-stage pipeline (Fetch, Decode, Execute/Write-Back) with 1 CPI throughput.
- **ISA:** 12-bit fixed instruction format supporting arithmetic, logic, data transfer, and control flow.
- **Hazard Handling:** 2-bubble pipeline flush mechanism resolving branch hazards at the EX stage.
- **ALU & Flags:** Shared adder/subtractor, logic unit, and independent Zero/Carry flags (ARM no-borrow convention).
- **Storage:** 4×4-bit general-purpose Register File (R0–R3) and 16×4-bit Data Memory (DMEM).
- **Verification:** 100% automated pass rate (88/88 checks) across module-level and system test suites.

## Simulation
1. Open the project in **AMD Vivado**.
2. Add files from `rtl/` and testbenches from `tb/`.
3. Run **Behavioral Simulation** (`sim_1`) to inspect the waveforms.
