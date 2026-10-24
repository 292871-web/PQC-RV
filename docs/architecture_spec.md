# RISC-V PQC Microcontroller Architecture Specification

## 1. System Overview
This project is an IoT-optimized RISC-V microcontroller featuring native hardware acceleration for Post-Quantum Cryptography (PQC), specifically targeting lattice-based schemes (ML-KEM/Kyber, ML-DSA/Dilithium). 

The system relies on a **Hardware/Software Co-design** philosophy: the CPU handles program flow and standard arithmetic, while a stateful, tightly-coupled hardware accelerator handles cryptographic heavy lifting to optimize for PPA (Power, Performance, Area) in battery-powered IoT devices.

## 2. Base ISA Configuration
To explicitly define the hardware capabilities and avoid toolchain redundancies, the baseline CPU configuration is defined in canonical order as:
**`rv32i_zbb_zca_zicsr_zmmul`**

*   **`rv32i`**: 32-bit base integer instruction set.
*   **`zbb`**: Basic bit manipulation.
*   **`zca`**: Compressed instructions to reduce code size.
*   **`zicsr`**: Control and Status Registers.
*   **`zmmul`**: Hardware multiplication only (omitting hardware division from the full `M` extension to save silicon area).

## 3. Tightly-Coupled PQC Accelerator (Xpqc)
The PQC accelerator is a stateful, tightly-coupled execution unit implemented via the RISC-V **Custom-0** opcode space (`0x0B`). 

Because PQC operations exceed the capacity of standard 32-bit CPU registers, the `Xpqc` accelerator maintains its own internal memory and accumulators. Firmware manages the accelerator via an INIT → LOAD (Block) → COMPUTE → STORE (Block) lifecycle.

## 4. Excluded Features & Rationale
*   **No Vector Extension (RVV):** Adding 32 wide vector registers would destroy the silicon area budget. The dedicated `Xpqc` state machine handles parallelism natively.
*   **No Zknh (Standard SHA-2 Crypto):** This project is strictly scoped to lattice-based schemes (ML-KEM, ML-DSA) which rely on SHA-3/Keccak (SHAKE128/256). Support for SLH-DSA (which can utilize SHA-2) is out of scope for this silicon revision.

## 5. Pipeline
3-stage (IF / ID / EX), no forwarding, no branch prediction.
Stall on EX for multi-cycle `Xpqc` instructions (stall counter managed in ID stage).

## 6. Memory & Reset
- **Reset Vector:** `0x0000_0000` (Boot ROM, which jumps to Flash or I-TCM).
- 32 KB I-TCM (Instruction Tightly-Coupled Memory).
- 32 KB D-TCM (Data Tightly-Coupled Memory).
- External: Wishbone 32-bit bus to 512 KB SRAM + 4 MB SPI Flash.
- No MMU, no caches (TCM is zero-wait-state).

## 7. Bus & Interrupts
- **Bus:** Wishbone 32-bit, single-master (CPU), peripherals at `0x1000_0000+`.
- **Interrupts:** Direct mapping to `mie`/`mip` CSRs with fixed priority (e.g., `mip[11]` = External/UART, `mip[7]` = Timer, `mip[3]` = GPIO). No external PLIC to minimize area.

## 8. Peripherals
- UART (16550-compatible, TX/RX, 16-byte FIFO).
- GPIO (32-bit, input/output/IRQ).
- Timer (32-bit free-running + 2 compare channels).
- SPI (master, for flash).

## 9. PQC Accelerator — Internal State & Instruction Set
**Internal Memory:** 4 KB of tightly-coupled SRAM inside the accelerator, organized as four 256-word polynomial slots. This allows multiple polynomials (e.g., s, e, a, r) to be loaded simultaneously to prevent coefficient shuttling bottlenecks.

*Table of stateful custom opcodes under Custom-0 (0x0B):*

| Instruction | funct3 | Operands | Description |
| :--- | :--- | :--- | :--- |
| `pqc.k.init` | `000` | - | Zeroes the 1600-bit Keccak state. |
| `pqc.k.absorb`| `001` | rs1, rs2 | Absorbs two 32-bit words into the state. |
| `pqc.k.perm` | `010` | - | Triggers Keccak-f[1600] permutation. |
| `pqc.k.sqz` | `011` | rd | Squeezes a 32-bit word from the state to `rd`. |
| `pqc.ntt.ld.blk`| `100`| rs1 (addr) | Block load 8 words from TCM to internal polynomial slot. |
| `pqc.ntt.st.blk`| `101`| rs1 (addr) | Block store 8 words from internal polynomial slot to TCM. |
| `pqc.ntt.run` | `110` | rs1 (slot) | Executes forward NTT on specified internal slot (~256 cycles). |
| `pqc.ntt.irun`| `111` | rs1 (slot) | Executes inverse NTT (iNTT). |
| `pqc.ntt.pmul`| `000`*| rs1, rs2 | Pointwise multiplication of two internal slots (*uses different funct7). |

## 10. Performance Targets
- F_max: 50 MHz (7 nm) / 25 MHz (FPGA).
- SHAKE128 (1600-bit): ≤ 50 cycles per permutation.
- **ML-KEM-512 Encaps: ≤ 20,000 cycles** (0.4 ms at 50 MHz).

*ML-KEM-512 Encapsulation Cycle Budget Justification:*
- 10 × NTT: 10 × 280 = 2,800
- 8 × iNTT: 8 × 280 = 2,240
- 6 × Pointwise Mul: 6 × 256 = 1,536
- Keccak (SHAKE128, ~4 perms): 4 × 50 = 200
- CBD sampling (software): ~3,000
- Coefficient load/store (block): ~4,000
- Control/overhead: ~2,000
- **TOTAL:** ~15,776 cycles (leaves ~20% headroom to 20K target).

## 11. Verification
- Testbench-first: each block has a cocotb test suite.
- C reference model for ISA + PQC operations.
- `riscv-arch-test` framework configured strictly for `rv32i_zbb_zca_zicsr_zmmul` (excluding standard `div`/`rem` regression tests).
- GitHub Actions: lint (Verilator `--lint-only`) + sim on every push.
