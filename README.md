# 4-Bit Full Adder with Registered D Flip-Flop Output

[![Language](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)](https://en.wikipedia.org/wiki/SystemVerilog)
[![Simulator](https://img.shields.io/badge/Simulator-ModelSim%20%2F%20Questa-orange.svg)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-simulation.html)
[![Verification](https://img.shields.io/badge/Status-Verified-brightgreen.svg)](#simulation-results)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A synchronous digital hardware design implemented in **SystemVerilog** featuring a **4-bit Full Adder** integrated with a **5-bit D Flip-Flop (DFF) register**. The design captures both the 4-bit addition sum and the carry-out bit synchronously at the rising edge of the system clock, with support for an asynchronous active-high reset.

---

## Table of Contents

- [Overview](#overview)
- [Architecture & Design Details](#architecture--design-details)
  - [Block Diagram](#block-diagram)
  - [Port Descriptions](#port-descriptions)
- [Theory of Operation](#theory-of-operation)
- [Testbench & Verification](#testbench--verification)
  - [Test Vectors](#test-vectors)
  - [Simulation Results](#simulation-results)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Running with ModelSim / QuestaSim (CLI)](#running-with-modelsim--questasim-cli)
  - [Running with ModelSim GUI](#running-with-modelsim-gui)
- [File Structure](#file-structure)
- [Author](#author)
- [License](#license)

---

## Overview

In high-speed digital circuit design and pipelined architectures, registering the combinational logic outputs eliminates transient glitches, isolates combinational propagation delays, and improves timing closure.

This project implements:
1. **Combinational Stage:** A 4-bit binary adder with carry-in ($C_{in}$) computing a 5-bit result ($Sum = A + B + C_{in}$).
2. **Sequential Stage:** A 5-bit positive-edge-triggered D Flip-Flop register with asynchronous reset ($rst$) to store the sum and carry-out.

---

## Architecture & Design Details

### Block Diagram

```
                 +--------------------------------------------+
                 |                 adder_dff                  |
                 |                                            |
    A [3:0] ---->| +------------------+                       |
    B [3:0] ---->| | 4-Bit Full Adder |   Sum [4:0]           |
    Cin -------->| |   (A + B + Cin)  |============\          |
                 | +------------------+            |          |
                 |                                 v          |
                 |                     +--------------------+ |
    clk -------->|-------------------->|> 5-Bit DFF Register|===> Q [4:0]
    rst -------->|-------------------->| (Async Reset)      | |  (Carry + Sum)
                 |                     +--------------------+ |
                 +--------------------------------------------+
```

### Port Descriptions

| Port Name | Direction | Data Type | Bit Width | Description |
|:----------|:---------:|:---------:|:---------:|:------------|
| `A`       | `input`   | `logic`   | `[3:0]`   | 4-bit operand input A |
| `B`       | `input`   | `logic`   | `[3:0]`   | 4-bit operand input B |
| `Cin`     | `input`   | `logic`   | `1`       | Carry-in bit |
| `clk`     | `input`   | `logic`   | `1`       | System clock (rising edge active) |
| `rst`     | `input`   | `logic`   | `1`       | Asynchronous active-high reset |
| `Q`       | `output`  | `logic`   | `[4:0]`   | Registered 5-bit output (`Q[4]` = Carry Out, `Q[3:0]` = Sum) |

---

## Theory of Operation

1. **Addition Operation:**
   The combinational logic evaluates:
   $$\text{Sum}[4:0] = A[3:0] + B[3:0] + C_{in}$$
   - The maximum possible value is $15 + 15 + 1 = 31$ (`5'b11111`), fitting completely within 5 bits without overflow.
   - Bit `Sum[4]` serves as the final carry-out bit.

2. **Registering and Timing:**
   - **Reset (`rst = 1`):** The output `Q` is immediately cleared to `5'b00000` asynchronously, without waiting for a clock transition.
   - **Normal Operation (`rst = 0`):** On each rising edge of `clk` (`posedge clk`), `Q` updates with the evaluated `Sum`.

---

## Testbench & Verification

The testbench (`adder_dfftb.sv`) verifies the operational correctness of the design across multiple corner cases, carry-in combinations, maximum value additions, and asynchronous reset recovery.

### Test Vectors

| Test Case | Description | `A` (dec / bin) | `B` (dec / bin) | `Cin` | Expected Sum (`Sum`) | Expected Registered `Q` |
|:---------:|:------------|:---------------:|:---------------:|:-----:|:--------------------:|:-----------------------:|
| **Init**  | Reset Assertion | `0` (`0000`) | `0` (`0000`) | `0` | `0` (`00000`) | `5'b00000` (immediate) |
| **Test 1**| Basic Addition | `3` (`0011`) | `2` (`0010`) | `0` | `5` (`00101`) | `5'b00101` (at posedge) |
| **Test 2**| Basic Addition | `5` (`0101`) | `3` (`0011`) | `0` | `8` (`01000`) | `5'b01000` (at posedge) |
| **Test 3**| Carry Out Generation | `15` (`1111`) | `1` (`0001`) | `0` | `16` (`10000`) | `5'b10000` (at posedge) |
| **Test 4**| Addition with Carry In | `10` (`1010`) | `5` (`0101`) | `1` | `16` (`10000`) | `5'b10000` (at posedge) |
| **Test 5**| Maximum Value Corner | `15` (`1111`) | `15` (`1111`) | `1` | `31` (`11111`) | `5'b11111` (at posedge) |
| **Test 6**| Async Reset Mid-Run | `15` (`1111`) | `15` (`1111`) | `1` | `31` (`11111`) | `5'b00000` (immediate) |

### Simulation Results

Simulation trace log captured using ModelSim Intel FPGA Edition:

```text
# Loading sv_std.std
# Loading work.adder_dff_tb
# Loading work.adder_dff
# run -all
# Time=0  | A=0000 B=0000 Cin=0 | rst=1 clk=0 | Q=00000
# Time=5  | A=0000 B=0000 Cin=0 | rst=1 clk=1 | Q=00000
# Time=10 | A=0011 B=0010 Cin=0 | rst=0 clk=0 | Q=00000
# Time=15 | A=0011 B=0010 Cin=0 | rst=0 clk=1 | Q=00101
# Time=20 | A=0101 B=0011 Cin=0 | rst=0 clk=0 | Q=00101
# Time=25 | A=0101 B=0011 Cin=0 | rst=0 clk=1 | Q=01000
# Time=30 | A=1111 B=0001 Cin=0 | rst=0 clk=0 | Q=01000
# Time=35 | A=1111 B=0001 Cin=0 | rst=0 clk=1 | Q=10000
# Time=40 | A=1010 B=0101 Cin=1 | rst=0 clk=0 | Q=10000
# Time=45 | A=1010 B=0101 Cin=1 | rst=0 clk=1 | Q=10000
# Time=50 | A=1111 B=1111 Cin=1 | rst=0 clk=0 | Q=10000
# Time=55 | A=1111 B=1111 Cin=1 | rst=0 clk=1 | Q=11111
# Time=60 | A=1111 B=1111 Cin=1 | rst=1 clk=0 | Q=00000
# Time=65 | A=1111 B=1111 Cin=1 | rst=1 clk=1 | Q=00000
# Time=70 | A=1111 B=1111 Cin=1 | rst=0 clk=0 | Q=00000
# Time=75 | A=1111 B=1111 Cin=1 | rst=0 clk=1 | Q=11111
# ** Note: $finish    : adder_dfftb.sv(62)
#    Time: 80 ps  Iteration: 0  Instance: /adder_dff_tb
```

---

## Getting Started

### Prerequisites

You need a SystemVerilog simulator such as:
- **ModelSim / QuestaSim** (Intel FPGA Edition or Siemens EDA)
- **VCS** / **Xcelium** / **Icarus Verilog** / **Vivado Simulator**

### Running with ModelSim / QuestaSim (CLI)

1. Open your terminal in the repository root directory.
2. Compile the design and testbench:
   ```bash
   vlog -sv adder_dff.sv adder_dfftb.sv
   ```
3. Run the simulation:
   ```bash
   vsim -c -do "run -all; quit" adder_dff_tb
   ```

### Running with ModelSim GUI

1. Open ModelSim and set the working directory to this project folder.
2. Create a new work library:
   ```tcl
   vlib work
   ```
3. Compile all SystemVerilog files:
   ```tcl
   vlog -sv adder_dff.sv adder_dfftb.sv
   ```
4. Load the testbench and add signals to the waveform viewer:
   ```tcl
   vsim work.adder_dff_tb
   add wave -r /*
   run -all
   ```

---

## File Structure

```text
4-Bit-Full-Adder-DFF-SystemVerilog/
├── adder_dff.sv        # Top-level SystemVerilog module (Adder + DFF)
├── adder_dfftb.sv      # SystemVerilog verification testbench
├── .gitignore          # Git ignore rules for simulation/build files
└── README.md           # Project documentation and simulation guide
```

---

## Author

- **Kailash** - [GitHub Profile](https://github.com/Kailash2407)

## License

This project is open-source and available under the [MIT License](LICENSE).
