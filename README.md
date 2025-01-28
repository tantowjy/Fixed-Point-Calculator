# Calculator Fixed Point

A 16-bit fixed-point FPGA-based digital calculator that displays results on a 7-segment display. It supports basic arithmetic operations (addition, subtraction, multiplication, and division) with 16-bit fixed-point numbers (1-bit signed, 9-bit integer, 6-bit fractional). Results are represented as 16-bit fixed-point numbers (1-bit signed, 10-bit integer, 6-bit fractional) and shown on the display as decimal values with 2-digit integers and 2-digit fractions.

## Hardware
- Device : Altera DE1-SoC 
- Seri   : 5CSEMA5F31C6

## Software
- Quartus Prime 18.1
- ModelSim 10.5b

## How to Run and Deploy on FPGA
1. Open [calculator.qpf](/src/calculator.qpf) in Intel Quartus.
2. Set [math_calculator_fsm.v](/src/math_calculator_fsm.v) as the top-level entity, select `Project > Set as Top-Level Entity`.
3. To initialize the pin planner, select `Assignments > Pin Planner`.
4. Set up a pin planner, one key button for the clock, and ten swiths for the buttons according to [this](#button).
5. Compile the program, select `Processing > Start Compilation`.
6. To deploy on FPGA, select `Tools > Programmer`.
7. Add your FPGA devices and _calculator.sof_ file on [output_files](/src/output_files/) folder.
8. Click `Start` to deploy program on FPGA.

## Information

### Button
|       | SW9 | SW8 | SW7 | SW6 | SW5 | SW4 | SW3 | SW2 | SW1 | SW0 |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| zero  |     |     |     |     |     |     |     |     |     | x   |
| one   |     |     |     |     |     |     |     |     | x   |     |
| two   |     |     |     |     |     |     |     | x   |     |     |
| three |     |     |     |     |     |     | x   |     |     |     |
| four  |     |     |     |     |     | x   |     |     |     |     |
| five  |     |     |     |     | x   |     |     |     |     |     |
| six   |     |     |     | x   |     |     |     |     |     |     |
| seven |     |     | x   |     |     |     |     |     |     |     |
| eight |     | x   |     |     |     |     |     |     |     |     |
| nine  | x   |     |     |     |     |     |     |     |     |     |
| add   | x   |     |     |     |     |     |     |     |     | x   |
| sub   | x   |     |     |     |     |     |     |     | x   |     |
| mul   | x   |     |     |     |     |     |     | x   |     |     |
| div   | x   |     |     |     |     |     | x   |     |     |     |
| equal | x   | x   |     |     |     |     |     |     |     |     |
| clear | x   | x   | x   |     |     |     |     |     |     |     |


### Limit
| Parameter | Min (dec) | Max (dec) |
| :-------- | :------:  | :-------: |
| Input 1   | 0.00      | 9.99      |
| Input 2   | 0.00      | 9.99      |
| Result    | -99.99    | 99.99     |