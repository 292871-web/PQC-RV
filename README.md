# PQC-RV
An testbench-driven RISC-V MCU with native post-quantum cryptography acceleration for IoT.

## Goal

Build an open-source RISC-V MCU (RV32IM) that is **PQC-accelerated by design**:
- Tightly-coupled NTT + Keccak accelerators via custom RISC-V instructions
- Supports ML-KEM, ML-DSA, and SLH-DSA (all three NIST PQC standards)
- Target: ≤ X cycles for ML-KEM-512 Encaps at Y MHz
- Full peripheral set (UART, GPIO, Timer) for standalone IoT operation
- Testbench-first development: every block verified before integration
- CI: full regression on every commit (Icarus/Verilator + cocotb)

## Non-goals (v1)

- Side-channel resistance (timing/power hardening) — future work
- Secure boot / PUF / TEE — out of scope
- 64-bit or vector extensions
- ASIC tapeout (FPGA-verified only)

## ⚖️ License

This project is licensed under the **PolyForm Small Business 1.0.0** license. 

We believe in supporting the hardware community and growing startups. Therefore, this project is **100% free to use for hobbyists, academics, and small businesses** (defined as organizations with fewer than 100 individuals AND under $1M USD in annual revenue). 

**For Large Corporations / Big Tech:** If your organization exceeds the limits stated above, you do not have the right to use this project under the free tier. You must purchase a separate commercial license. Please contact me directly at p.gralakmv@gmail.com for commercial licensing inquiries.
