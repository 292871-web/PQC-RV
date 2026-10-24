# RISC-V PQC Microcontroller Architecture Specification

## 1. System Overview
This project is an IoT-optimized RISC-V microcontroller featuring native hardware acceleration for Post-Quantum Cryptography (PQC), specifically targeting lattice-based schemes (e.g., ML-KEM/Kyber) and SHA-3/Keccak hashing. 

The system relies on a **Hardware/Software Co-design** philosophy: the CPU handles program flow and standard arithmetic, while a tightly-coupled hardware accelerator handles cryptographic heavy lifting to optimize for PPA (Power, Performance, Area) in battery-powered IoT devices.

## 2. Base ISA Configuration (The YAML Definition)
To explicitly define the hardware capabilities and avoid toolchain redundancies, the baseline CPU configuration is:
**`rv32i_zca_zicsr_zmmul_zbb`**

*   **`rv32i`**: 32-bit base integer instruction set (32 registers).
*   **`zca`**: Compressed instructions (equivalent to `C` but strictly defined without floating-point dependencies) to reduce code size.
*   **`zicsr`**: Control and Status Registers.
*   **`zmmul`**: Hardware multiplication only (omitting hardware division from the full `M` extension to save silicon area).
*   **`zbb`**: Basic bit manipulation.

## 3. Tightly-Coupled PQC Accelerator (Xpqc)
The PQC accelerator is a stateful, tightly-coupled execution unit implemented via the RISC-V **Custom-0** opcode space (`0x0B`). 

### Internal State & Execution Lifecycle
Because PQC operations (e.g., Keccak-f[1600] permutation, 256-coefficient NTT) exceed the capacity of standard 32-bit CPU registers, the `Xpqc` accelerator maintains its own internal memory and accumulators. 
`Xpqc` instructions are therefore structured as a lifecycle:
1.  **INIT:** Reset the internal accelerator state (e.g., zero out the Keccak sponge).
2.  **LOAD:** Push 32-bit words from CPU registers (`rs1`, `rs2`) into the accelerator's internal buffers.
3.  **COMPUTE:** Trigger a multi-cycle mathematical operation (stalls the EX stage or sets a BUSY flag in a CSR).
4.  **EXTRACT:** Pull the 32-bit result words from the accelerator back into the CPU destination register (`rd`).

## 4. Excluded Features & Rationale
*   **No Vector Extension (RVV):** Adding 32 wide vector registers would destroy the silicon area budget. The dedicated `Xpqc` state machine handles parallelism natively.
*   **No Zknh (Standard SHA-2 Crypto):** This project is strictly scoped to lattice-based schemes (ML-KEM, ML-DSA) which rely on SHA-3/Keccak (SHAKE128/256). Support for SLH-DSA (which can utilize SHA-2) is out of scope for this silicon revision, making `Zknh` unnecessary.
  
## 5. IP & Licensing
The RTL, firmware, and architecture are developed as a solo clean-room implementation to maintain 100% intellectual property ownership. External code contributions are not accepted. The project is distributed under the PolyForm Small Business 1.0.0 license.

---

## 6. Pipeline
3-stage (IF / ID / EX), no forwarding, no branch prediction.
Stall on EX for multi-cycle `Xpqc` instructions (stall counter in ID stage).

## 7. Memory
- 32 KB I-TCM (Instruction Tightly-Coupled Memory)
- 32 KB D-TCM (Data Tightly-Coupled Memory)
- External: Wishbone 32-bit bus to 512 KB SRAM + 4 MB SPI Flash
- No MMU, no caches (TCM is zero-wait-state)

## 8. Bus
Wishbone 32-bit, single-master (CPU), peripherals at `0x1000_0000+`

## 9. Peripherals
- UART (16550-compatible, TX/RX, 16-byte FIFO)
- GPIO (32-bit, input/output/IRQ)
- Timer (32-bit free-running + 2 compare channels)
- SPI (master, for flash)

## 10. PQC Accelerator — Instruction Set
*Draft representation of stateful custom opcodes under Custom-0 (0x0B):*
| Instruction | funct3 | rs1 / rs2 | rd | Description |
| :--- | :--- | :--- | :--- | :--- |
| `pqc.k.init` | `000` | - | - | Zeroes the 1600-bit Keccak state. |
| `pqc.k.absorb`| `001` | Data words | - | Absorbs two 32-bit words into the state. |
| `pqc.k.perm` | `010` | - | - | Triggers Keccak-f[1600] (EX stage stalls for ~24 cycles). |
| `pqc.k.sqz` | `011` | - | Dest | Squeezes a 32-bit word from the state to `rd`. |
| `pqc.ntt.ld` | `100` | Addr, Data | - | Loads polynomial coefficient into internal NTT RAM. |
| `pqc.ntt.run` | `101` | - | - | Executes in-place NTT on internal RAM (multi-cycle stall). || Instruction | funct3 | rs1 / rs2 | rd | Description |
| :--- | :--- | :--- | :--- | :--- |
| `pqc.k.init` | `000` | - | - | Zeroes the 1600-bit Keccak state. |
| `pqc.k.absorb`| `001` | Data words | - | Absorbs two 32-bit words into the state. |
| `pqc.k.perm` | `010` | - | - | Triggers Keccak-f[1600] (EX stage stalls for ~24 cycles). |
| `pqc.k.sqz` | `011` | - | Dest | Squeezes a 32-bit word from the state to `rd`. |
| `pqc.ntt.ld` | `100` | Addr, Data | - | Loads polynomial coefficient into internal NTT RAM. |
| `pqc.ntt.run` | `101` | - | - | Executes in-place NTT on internal RAM (multi-cycle stall). |

## 11. Performance Targets
- F_max: 50 MHz (7 nm) / 25 MHz (FPGA)
- ML-KEM-512 Encaps: ≤ 20,000 cycles
- ML-KEM-512 Decaps: ≤ 30,000 cycles
- SHAKE128 (1600-bit): ≤ 50 cycles per permutation

## 12. Verification
- Testbench-first: each block has a cocotb test suite
- C reference model for ISA + PQC operations
- riscv-tests (rv32im) as system-level regression
- GitHub Actions: lint (Verilator `--lint-only`) + sim on every push
