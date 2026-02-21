## Project Status

### ✔ Completed
- **Single-Cycle RV32I Core**
  - Fully implemented synthesizable RTL
  - Instruction fetch, decode, execute, memory, and write-back in a single cycle
  - Directed testbenches validating arithmetic, logical, load/store, and control instructions
  - C code -> assembly test runs

### 🚧 Work in Progress
- **5-Stage Pipelined RV32I Core Verification**
  - SystemVerilog verification environment under development
    - Directed tests for pipeline sanity  
    - Spike Instruction Set Simulator and DUT equivalece tests
    - Functional Coverage and UVM testbench
    - Self-checking testbench framework being extended
    - SoC design explorations
    

## VSI (1TOPS Programme) — Future SoC Roadmap

This project is being developed under the **VLSI Society of India (VSI) – 1TOPS Programme**, with the long-term goal of evolving the current RISC-V core into a **tapeout-ready secure SoC prototype**.

## SoC architecture
![risc_soc_harvard](https://github.com/user-attachments/assets/ad6c2de4-68e1-4b47-8346-7d50ac6d4bae)


## RV32I 5 stage pipelined Architecture diagram
<img width="1790" height="893" alt="image" src="https://github.com/user-attachments/assets/64596263-c747-4112-aee7-fe5e01ed9585" />

