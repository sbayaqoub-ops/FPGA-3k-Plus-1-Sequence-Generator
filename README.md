# FPGA-3k-Plus-1-Sequence-Generator
FPGA implementation of a 3k+1 sequence generator using VHDL, RTL and ASM design, ModelSim, and Xilinx Vivado.

# FPGA 3k+1 Sequence Generator

A digital system that implements the **3k+1 (Collatz) sequence algorithm** on an FPGA using **VHDL**. The project was developed using both a direct **RTL implementation** and an **Algorithmic State Machine (ASM)** approach.

## Project Overview

The system searches for the smallest positive integer whose 3k+1 sequence contains at least **9 terms**.

For each term:

- If the number is even: `k → k / 2`
- If the number is odd: `k → 3k + 1`
- The sequence continues until the term reaches `1`

The design determines that the smallest qualifying starting value is **6**:

`6 → 3 → 10 → 5 → 16 → 8 → 4 → 2 → 1`

Sequence length: **9 terms**

## Design Implementations

### Part 1 — RTL Design

The first implementation directly describes the sequence-generation logic in VHDL using registers, counters, and control logic.

### Part 2 — ASM Design

The second implementation uses an **Algorithmic State Machine (ASM)** architecture. The design separates the control behavior into states and uses control/status signals to manage the datapath.

## Tools & Technologies

- VHDL
- FPGA Digital Design
- RTL Design
- Algorithmic State Machines (ASM)
- ModelSim
- Xilinx Vivado
- Seven-Segment Display Control

## Simulation

Both implementations were simulated in **ModelSim** to verify the sequence generation, term count, and control behavior before FPGA implementation.

Simulation waveform PDFs for both the RTL and ASM designs are included in this repository.

## FPGA Implementation

The design was synthesized using **Xilinx Vivado** and implemented on an FPGA development board. A multiplexed seven-segment display is used to display the current sequence information.

## Repository Structure

```text
src/
├── rtl/
│   └── three_k_plus_one.vhd
└── asm/
    └── three_k_plus_one_asm.vhd

part1_wave.pdf
part2_wave.pdf
project_report_COEN_313_40264986.pdf
