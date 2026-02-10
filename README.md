## Project Status

### ✔ Completed
- **Single-Cycle RV32I Core**
  - Fully implemented synthesizable RTL
  - Instruction fetch, decode, execute, memory, and write-back in a single cycle
  - Directed testbenches validating arithmetic, logical, load/store, and control instructions
  - C code -> assembly test runs

### 🚧 Work in Progress
- **5-Stage Pipelined RV32I Core**
  - Pipeline stages: IF / ID / EX / MEM / WB
  - Hazard detection and forwarding unit **under active integration**
  - Control hazard handling and pipeline flushing **in progress**
  - SystemVerilog verification environment under development
    - Directed tests for pipeline sanity
    - Self-checking testbench framework being extended
    

## VSI (1TOPS Programme) — Future SoC Roadmap

This project is being developed under the **VLSI Society of India (VSI) – 1TOPS Programme**, with the long-term goal of evolving the current RISC-V core into a **tapeout-ready secure SoC prototype**.

### Tentative SoC Concept
**SEC-RV32-DMA: Secure DMA-Offloaded RISC-V SoC**

> ⚠️ Architecture under design exploration; specifications may evolve.

---

### System Architecture & Logic
- **RV32IM RISC-V Processor Core**
- **Dual-Master AHB-Lite Interconnect**
- **Fixed-Priority System Arbiter**
- **Dual-Bank Split SRAM** (2 × 64 KB)
- **Immutable Secure Boot ROM** (8 KB)
- **Block-Transfer DMA Controller**
- **Hardware-Sequenced Secure Boot FSM**

### Hardware Accelerators
- **AES-128 Symmetric Encryption Engine (IP ready)**
- **SHA-256 Integrity Verification Core**

---

### Peripheral & I/O Subsystem
- **JTAG TAP Controller & Debug Bridge**
- **AHB-to-APB Peripheral Bridge**
- **Buffered UART Interface** (16-byte FIFO)
- **System Timer & GPIO Controller**

---

### Verification & Reliability Features (Planned)
- Multi-Master Contention Stress Testbench
- Root-of-Trust Based Integrity Attestation
- Fault-Injection Aware Recovery Logic
- Bank-Parallelism Throughput Monitoring

---

## SoC Development Strategy (High-Level)

- Reuse verified **single-cycle and pipelined RV32 cores** as CPU options
- Incrementally integrate subsystems using **bottom-up verification**
- Prioritize **secure boot, DMA offload, and memory isolation**
- Maintain synthesizable RTL compatible with **ASIC toolflows**

---

## Tapeout Intent (Exploratory)

The long-term objective is to reach a **pre-tapeout quality RTL milestone**, including:
- Full chip integration and clean synthesis
- Lint, CDC, and basic formal checks
- Preliminary timing and area estimation
- Foundry-agnostic RTL suitable for academic MPW programs

> This roadmap reflects **design intent and learning goals**, not a committed fabrication schedule.

## RV32I % stage pipelined Architecture diagram
<img width="1790" height="893" alt="image" src="https://github.com/user-attachments/assets/64596263-c747-4112-aee7-fe5e01ed9585" />

