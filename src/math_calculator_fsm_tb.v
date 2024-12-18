module math_calculator_fsm_tb;
    reg clk;
    reg [7:0] button;                   // Input tombol 8-bit
    wire clear;                         // Tombol "Clear" (output dari modul)
    wire [3:0] button_num;              // Output angka dari tombol
    wire [2:0] button_op;               // Output operator dari tombol
    wire equal;                         // Tombol "=" (output dari modul)
    wire [15:0] result_temp, result;    // Output hasil sementara dan akhir

    // Instantiate the math_calculator3 module
    math_calculator_fsm uut (
        .clk(clk),
        .button(button),
        .clear(clear),
        .button_num(button_num),
        .button_op(button_op),
        .equal(equal),
        .result_temp(result_temp),
        .result(result)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        button = 8'b0;

        // Apply reset using button 'Clear'
        button = 8'b0000_0100; #10;  // btnClear
        button = 8'b0;

        // Test sequence: 5 + 3 = 8 C
        // Input first number (5)
        button = 8'b0001_0110; #10;  // btnFive
        button = 8'b0;
        // Input operation (ADD)
        button = 8'b0011_0111; #10;  // btnAdd
        button = 8'b0;
        // Input second number (3)
        button = 8'b0010_0101; #10;  // btnThree
        button = 8'b0;
        // Wait for result (EQUAL)
        button = 8'b0010_0100; #10;  // btnEqual
        button = 8'b0;
        // Clear the calculator
        button = 8'b0000_0100; #10;  // btnClear
        button = 8'b0;

        // Test sequence: 5 - 3 + 2 = 4
        // Input first number (5)
        button = 8'b0001_0110; #10;  // btnFive
        button = 8'b0;
        // Input operation (SUB)
        button = 8'b0011_0110; #10;  // btnSub
        button = 8'b0;
        // Input second number (3)
        button = 8'b0010_0101; #10;  // btnThree
        button = 8'b0;
        // Input operation (ADD)
        button = 8'b0011_0111; #10;  // btnAdd
        button = 8'b0;
        // Input third number (2)
        button = 8'b0001_0101; #10;  // btnTwo
        button = 8'b0;
        // Wait for result (EQUAL)
        button = 8'b0010_0100; #10;  // btnEqual
        button = 8'b0;

        // Test sequence: 6 / 3 = 2 * 8 = 16
        // Input first number (6)
        button = 8'b0010_0110; #10;  // btnSix
        button = 8'b0;
        // Input operation (DIV)
        button = 8'b0011_0100; #10;  // btnDiv
        button = 8'b0;
        // Input second number (3)
        button = 8'b0010_0101; #10;  // btnThree
        button = 8'b0;
        // Wait for result (EQUAL)
        button = 8'b0010_0100; #10;  // btnEqual
        button = 8'b0;
        // Input operation (MUL)
        button = 8'b0011_0101; #10;  // btnMul
        button = 8'b0;
        // Input third number (8)
        button = 8'b0001_0111; #10;  // btnEight
        button = 8'b0;
        // Wait for result (EQUAL)
        button = 8'b0010_0100; #10;  // btnEqual
        button = 8'b0;
        // Clear the calculator
        button = 8'b0000_0100; #10;  // btnClear
        button = 8'b0;

        // Finish simulation
        $stop;
    end

endmodule

