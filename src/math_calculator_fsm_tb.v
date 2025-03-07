module math_calculator_fsm_tb;
    reg clk;
    reg [9:0] button;                   
    wire clear;                                 
    wire [3:0] button_num;                      
    wire [2:0] button_op;                       
    wire equal;               
    wire signed [15:0] result_temp, result;
    wire [6:0] sign, tens, units, tenths, hundredths;

    // Instantiate the math_calculator_fsm module
    math_calculator_fsm uut (
        .clk(clk),
        .button(button),
        .clear(clear),
        .button_num(button_num),
        .button_op(button_op),
        .equal(equal),
        .result_temp(result_temp),
        .result(result),
        .sign(sign), 
        .tens(tens), 
        .units(units), 
        .tenths(tenths), 
        .hundredths(hundredths)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        button = 10'b0;

        // Apply reset using button 'Clear'
        button = 10'b11_1000_0000; #10;  // btnClear
        button = 10'b0;

        // Test sequence: 5.25 - 7.05 = / 2.00 C
        // Input first number (5.25)
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        button = 10'b00_0000_0100; #10;  // btnTwo
        button = 10'b0;
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        // Input operation (SUB)
        button = 10'b10_0000_0010; #10;  // btnSub
        button = 10'b0;
        // Input second number (7.05)
        button = 10'b00_1000_0000; #10;  // btnSeven
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        // Wait for result (EQUAL)
        button = 10'b11_0000_0000; #10;  // btnEqual
        button = 10'b0;
        // Input operation (MUL/DIV)
        button = 10'b10_0000_1000; #10;  // btnDiv
        button = 10'b0;
        // Input third number (2)
        button = 10'b00_0000_0100; #10;  // btnEight
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        // Wait for result (EQUAL)
        button = 10'b11_0000_0000; #10;  // btnEqual
        button = 10'b0;
        // Clear the calculator
        button = 10'b11_1000_0000; #10;  // btnClear
        button = 10'b0;

        // Test sequence: 5.25 + 3.25 = 8 C
        // Input first number (5.25)
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        button = 10'b00_0000_0100; #10;  // btnTwo
        button = 10'b0;
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        // Input operation (ADD)
        button = 10'b10_0000_0001; #10;  // btnAdd
        button = 10'b0;
        // Input second number (3.25)
        button = 10'b00_0000_1000; #10;  // btnThree
        button = 10'b0;
        button = 10'b00_0000_0100; #10;  // btnTwo
        button = 10'b0;
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        // Wait for result (EQUAL)
        button = 10'b11_0000_0000; #10;  // btnEqual
        button = 10'b0;
        // Clear the calculator
        button = 10'b11_1000_0000; #10;  // btnClear
        button = 10'b0;

        // Test sequence: 5.00 - 3.25 + 2.25 = 4
        // Input first number (5.00)
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        // Input operation (SUB)
        button = 10'b10_0000_0010; #10;  // btnSub
        button = 10'b0;
        // Input second number (3)
        button = 10'b00_0000_1000; #10;  // btnThree
        button = 10'b0;
        button = 10'b00_0000_0100; #10;  // btnTwo
        button = 10'b0;
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        // Input operation (ADD)
        button = 10'b10_0000_0001; #10;  // btnAdd
        button = 10'b0;
        // Input third number (2)
        button = 10'b00_0000_0100; #10;  // btnTwo
        button = 10'b0;
        button = 10'b00_0000_0100; #10;  // btnTwo
        button = 10'b0;
        button = 10'b00_0010_0000; #10;  // btnFive
        button = 10'b0;
        // Wait for result (EQUAL)
        button = 10'b11_0000_0000; #10;  // btnEqual
        button = 10'b0;

        // Test sequence: 6 / 3 = * 8 = 16
        // Input first number (6)
        button = 10'b00_0100_0000; #10;  // btnSix
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        // Input operation (DIV)
        button = 10'b10_0000_1000; #10;  // btnDiv
        button = 10'b0;
        // Input second number (3)
        button = 10'b00_0000_1000; #10;  // btnThree
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        // Wait for result (EQUAL)
        button = 10'b11_0000_0000; #10;  // btnEqual
        button = 10'b0;
        // Input operation (MUL)
        button = 10'b10_0000_0100; #10;  // btnMul
        button = 10'b0;
        // Input third number (8)
        button = 10'b01_0000_0000; #10;  // btnEight
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        button = 10'b00_0000_0001; #10;  // btnZero
        button = 10'b0;
        // Wait for result (EQUAL)
        button = 10'b11_0000_0000; #10;  // btnEqual
        button = 10'b0;
        // Clear the calculator
        button = 10'b11_1000_0000; #10;  // btnClear
        button = 10'b0;

        // Finish simulation
        $stop;
    end

endmodule 