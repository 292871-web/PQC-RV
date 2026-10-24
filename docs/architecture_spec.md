# RISC-V PQC Microcontroller Architecture Specification

## 1. System Overview
This project is an IoT-optimized RISC-V microcontroller featuring native hardware acceleration for Post-Quantum Cryptography (PQC), specifically targeting lattice-based schemes (e.g., ML-KEM/Kyber) and SHA-3/Keccak hashing. 

The system relies on a **Hardware/Software Co-design** philosophy: the CPU handles program flow and standard arithmetic, while a tightly-coupled hardware accelerator handles cryptographic heavy lifting to optimize for PPA (Power, Performance, Area) in battery-powered IoT devices.

## 2. Base ISA Configuration (The YAML Definition)
For standard toolchain compatibility (GCC, Verilator, Cocotb), the baseline configuration of the CPU is defined as:
**`rv32imc_zbb_zca_zicsr_zmmul`**

*   **`rv32i`**: 32-bit base integer instruction set (32 registers).
*   **`m` / `zmmul`**: Hardware multiplication (critical for NTT/Polynomial math preparation).
*   **`c` / `zca`**: Compressed instructions to reduce code size and Flash memory power consumption.
*   **`zicsr`**: Control and Status Registers (required for system timers and custom PQC status flags).
*   **`zbb`**: Basic bit manipulation (speeds up byte-reversing and bitwise operations in software).

*Note: This standard string is what must be fed into the GCC compiler (`-march=`) and standard RTL generators.*

## 3. Tightly-Coupled PQC Accelerator (Xpqc)
Instead of using a memory-mapped peripheral over an AHB/AXI bus (which introduces bus latency), the PQC accelerator is implemented as a **Tightly-Coupled Custom Execution Unit**. Conceptually, this adds a custom non-standard extension to the ISA: `Xpqc`.

### Hardware-Software Interface
*   **Custom Opcodes:** The accelerator listens on the RISC-V **Custom-0** opcode space (`0x0B` / `0001011`).
*   **Direct Register Access:** PQC instructions operate directly on the CPU's general-purpose registers (`rs1`, `rs2`, `rd`), allowing zero-latency data transfers.
*   **Software Invocation:** Since GCC does not recognize `Xpqc` natively, firmware invokes the accelerator using C macros wrapping the `.insn` assembly directive.

## 4. Excluded Features & Rationale
To maintain strict IoT constraints, the following features were intentionally excluded:
*   **No Vector Extension (RVV):** Adding 32 wide vector registers would destroy the silicon area budget and power limits. The PQC accelerator handles the parallel mathematical workload instead of a general-purpose vector unit.
*   **No Zknh (Standard Scalar Crypto):** `Zknh` accelerates SHA-2 (SHA-256/512). Since modern PQC standards (NIST FIPS 203/204) strictly rely on SHA-3/Keccak (SHAKE128/256), dedicating silicon to SHA-2 was deemed wasteful.

## 5. IP & Licensing
The RTL, firmware, and architecture are developed as a solo clean-room implementation to maintain 100% intellectual property ownership. External code contributions are not accepted. The project is distributed under the PolyForm Small Business 1.0.0 license.
