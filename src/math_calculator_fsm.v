module math_calculator_fsm (
    input clk,
    input [9:0] button,
    
    // // Output for simulation
    // output reg clear,
    // output reg [3:0] button_num,
    // output reg [2:0] button_op,
    // output reg equal,
    // output reg signed [15:0] result_temp, result,
    
    output reg [6:0] sign, tens, units, tenths, hundredths
);

    // Register for FPGA implementation
    reg clear;
    reg [3:0] button_num;
    reg [2:0] button_op;
    reg equal;
    reg [15:0] result_temp, result;

    // Register for state
    reg [3:0] state;

    // Register for input number and operation
    reg [3:0] num_int;                  // Integer part
    reg [3:0] num_tenths;               // Tenths part
    reg [3:0] num_hundredths;           // Hundredths part
    reg signed [15:0] num1, num2;       // Q1.9.6
    reg [2:0] operation;

    // Registers for temporary 7s display values
    reg [6:0] display_sign, display_tens, display_units;
    reg [6:0] display_tenths, display_hundredths;
    reg [15:0] display_binary_in;

    // Wire for temporary input number conversion
    wire [15:0] num;

    // Wire for temporary result of multiplication and division
    wire signed [31:0] mul_result;
    wire signed [15:0] div_result;

    // Wire for temporary 7s display values
    wire [6:0] seg_sign, seg_tens, seg_units, seg_tenths, seg_hundredths;

    // Button definition
    parameter [9:0] btnZero   = 10'b00_0000_0001,
                    btnOne    = 10'b00_0000_0010,
                    btnTwo    = 10'b00_0000_0100,
                    btnThree  = 10'b00_0000_1000,
                    btnFour   = 10'b00_0001_0000,
                    btnFive   = 10'b00_0010_0000,
                    btnSix    = 10'b00_0100_0000,
                    btnSeven  = 10'b00_1000_0000,
                    btnEight  = 10'b01_0000_0000,
                    btnNine   = 10'b10_0000_0000,
                    btnAdd    = 10'b10_0000_0001, // '+' // 9 and 0
                    btnSub    = 10'b10_0000_0010, // '-' // 9 and 1
                    btnMul    = 10'b10_0000_0100, // '*' // 9 and 2
                    btnDiv    = 10'b10_0000_1000, // '/' // 9 and 3
                    btnEqual  = 10'b11_0000_0000, // 9 and 8
                    btnClear  = 10'b11_1000_0000; // 9, 8 and 7

    // State encoding
    parameter [3:0] NUM_0 = 4'd0, NUM_1 = 4'd1, NUM_2 = 4'd2, NUM_3 = 4'd3, NUM_4 = 4'd4,
                NUM_5 = 4'd5, NUM_6 = 4'd6, NUM_7 = 4'd7, NUM_8 = 4'd8, NUM_9 = 4'd9;
    
    parameter [2:0] ADD = 3'b001, SUB = 3'b010, MUL = 3'b011, DIV = 3'b100;

    parameter S0 = 4'd0, S0_1 = 4'd1, S0_2 = 4'd2, S1 = 4'd3, S2 = 4'd4,
                S2_1 = 4'd5, S2_2 = 4'd6, S3 = 4'd7;

    // Button mapping to numeric and operator values
    always @(*) begin
        // Default values
        button_num = 4'b0;  // Default for numeric
        button_op = 3'b0;   // Default for operator
        equal = 1'b0;       // Default ~button '='
        clear = 1'b0;       // Default ~button 'Clear'

        case (button)
            // Numeric
            btnZero:  button_num = NUM_0;
            btnOne:   button_num = NUM_1;
            btnTwo:   button_num = NUM_2;
            btnThree: button_num = NUM_3;
            btnFour:  button_num = NUM_4;
            btnFive:  button_num = NUM_5;
            btnSix:   button_num = NUM_6;
            btnSeven: button_num = NUM_7;
            btnEight: button_num = NUM_8;
            btnNine:  button_num = NUM_9;

            // Operator
            btnAdd:   button_op = ADD;
            btnSub:   button_op = SUB;
            btnMul:   button_op = MUL;
            btnDiv:   button_op = DIV;

            // Equal and Clear
            btnEqual: equal = 1'b1;
            btnClear: clear = 1'b1;

            default: begin
                // All outputs remain default if no buttons are recognized
                button_num = 4'b0;
                button_op = 3'b0;
                equal = 1'b0;
                clear = 1'b0;
            end
        endcase
    end
    
    // 7-segment lookup table for digits 0-9
    function [6:0] get_7seg;
        input [3:0] digit;
        case (digit)
            // 7-segment display
            4'h0: get_7seg = 7'b1000000;    // digit 0
            4'h1: get_7seg = 7'b1111001;    // digit 1
            4'h2: get_7seg = 7'b0100100;    // digit 2
            4'h3: get_7seg = 7'b0110000;    // digit 3
            4'h4: get_7seg = 7'b0011001;    // digit 4
            4'h5: get_7seg = 7'b0010010;    // digit 5
            4'h6: get_7seg = 7'b0000010;    // digit 6
            4'h7: get_7seg = 7'b1111000;    // digit 7
            4'h8: get_7seg = 7'b0000000;    // digit 8
            4'h9: get_7seg = 7'b0010000;    // digit 9
            4'ha: get_7seg = 7'b0001000;    // huruf A
            4'hb: get_7seg = 7'b0000011;    // huruf B
            4'hc: get_7seg = 7'b1000111;    // huruf L
            4'hd: get_7seg = 7'b0100001;    // huruf D
            4'he: get_7seg = 7'b1101010;    // huruf M
            4'hf: get_7seg = 7'b1000001;    // huruf U
            default: get_7seg = 7'b1111111; // Blank

            // // Check number in simulation
            // 4'h0: get_7seg = 7'b0000000; // 0
            // 4'h1: get_7seg = 7'b0000001; // 1
            // 4'h2: get_7seg = 7'b0000010; // 2
            // 4'h3: get_7seg = 7'b0000011; // 3
            // 4'h4: get_7seg = 7'b0000100; // 4
            // 4'h5: get_7seg = 7'b0000101; // 5
            // 4'h6: get_7seg = 7'b0000110; // 6
            // 4'h7: get_7seg = 7'b0000111; // 7
            // 4'h8: get_7seg = 7'b0001000; // 8
            // 4'h9: get_7seg = 7'b0001001; // 9
            // 4'ha: get_7seg = 7'b0001010; //10
            // 4'hb: get_7seg = 7'b0001011; //11
            // 4'hc: get_7seg = 7'b0001100; //12
            // 4'hd: get_7seg = 7'b0001101; //13
            // 4'he: get_7seg = 7'b0001110; //14
            // 4'hf: get_7seg = 7'b0001111; //15
            // default: get_7seg = 7'b1111111; // Blank

        endcase
    endfunction

    // Decimal point to 6-bit binary
    decimal_to_binary uutdb (
        .decimal_int(num_int),
        .decimal_input_a(num_tenths),
        .decimal_input_b(num_hundredths),
        .output_num(num)
    );

    binary_to_decimal_7seg uutss (
        .binary_in(display_binary_in),
        .seg_sign(seg_sign),
        .seg_tens(seg_tens),
        .seg_units(seg_units),
        .seg_tenths(seg_tenths),
        .seg_hundredths(seg_hundredths)
    );

    // Multiplication and division result wire
    assign mul_result = num1 * num2;
    assign div_result = (num1 << 6) / num2;

    // Combined display logic
    always @(*) begin
        if (equal) begin
            // Result display
            display_binary_in = result_temp;
            display_sign = seg_sign;
            display_tens = seg_tens;
            display_units = seg_units;
            display_tenths = seg_tenths;
            display_hundredths = seg_hundredths;
        end 
        
        if (button_op != 3'b0) begin
            // Operator display
            case (button_op)
                ADD: begin
                    display_tens = 7'b1111111;
                    display_units = get_7seg(4'ha);
                    display_tenths = get_7seg(4'hd);
                    display_hundredths = get_7seg(4'hd);
                end
                SUB: begin
                    display_tens = 7'b1111111;
                    display_units = get_7seg(4'h5);
                    display_tenths = get_7seg(4'hf);
                    display_hundredths = get_7seg(4'hb);
                end
                MUL: begin
                    display_tens = 7'b1111111;
                    display_units = get_7seg(4'he);
                    display_tenths = get_7seg(4'hf);
                    display_hundredths = get_7seg(4'hc);
                end
                DIV: begin
                    display_tens = 7'b1111111;
                    display_units = get_7seg(4'hd);
                    display_tenths = get_7seg(4'h1);
                    display_hundredths = get_7seg(4'hf);
                end
            endcase
        end 

    end

    always @(*) begin
        num2 <= num;

        // Arithmetic operation
        case (operation)
            ADD: result_temp <= num1 + num2;
            SUB: result_temp <= num1 - num2;
            // Multiplication: use 32-bit result, convert to 16-bit fixed-point
            // Sign bit [31], Integer [20:12], Fractional [11:6]
            MUL: result_temp <= {mul_result[31], mul_result[20:12], mul_result[11:6]};
            DIV: result_temp <= (num2 != 0) ? div_result : 16'b0;
        endcase
    end

    // State Machine
    always @(posedge clk or posedge clear) begin
        if (clear) begin
            num1 <= 16'b0;
            num_int <= 4'b0;
            num_tenths <= 4'b0;
            num_hundredths <= 4'b0;
            result <= 16'b0;
            sign <= 7'b1111111; tens <= 7'b1111111; units <= 7'b1111111; 
            tenths <= 7'b1111111; hundredths <= 7'b1111111;
            state <= S0;
        end else begin
            case (state)
                S0: begin
                    // Update 7s display
                    units <= get_7seg(button_num);
                    tenths <= get_7seg(4'h0);
                    hundredths <= get_7seg(4'h0);

                    if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_int <= button_num;
                        num1 <= 16'b0;
                        num_tenths <= 4'b0;
                        num_hundredths <= 4'b0;
                        result <= 16'b0;
                        state <= S0_1;
                    end
                end

                S0_1: begin
                    // Update 7s display
                    units <= get_7seg(num_int);
                    tenths <= get_7seg(button_num);
                    hundredths <= get_7seg(4'h0);

                    if (clear) begin
                        state <= S0;
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_tenths <= button_num;
                        state <= S0_2;
                    end
                end

                S0_2: begin
                    // Update 7s display
                    units <= get_7seg(num_int);
                    tenths <= get_7seg(num_tenths);
                    hundredths <= get_7seg(button_num);

                    if (clear) begin
                        state <= S0;
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_hundredths <= button_num;
                        state <= S1;
                    end
                end

                S1: begin
                    // Num from previous state
                    num1 <= num;

                    sign <= 7'b1111111;
                    units <= display_units;
                    tenths <= display_tenths;
                    hundredths <= display_hundredths;

                    if (clear) begin
                        state <= S0;
                    end else if (button_op >= ADD && button_op <= DIV) begin
                        operation <= button_op;
                        state <= S2;
                    end
                end

                S2: begin
                    // Update 7s display
                    sign <= 7'b1111111;
                    units <= get_7seg(button_num);
                    tenths <= get_7seg(4'h0);
                    hundredths <= get_7seg(4'h0);

                    if (clear) begin
                        state <= S0;
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_int <= button_num;
                        num_tenths <= 4'b0;
                        num_hundredths <= 4'b0;
                        result <= 16'b0;
                        state <= S2_1;
                    end
                end

                S2_1: begin
                    // Update 7s display
                    units <= get_7seg(num_int);
                    tenths <= get_7seg(button_num);
                    hundredths <= get_7seg(4'h0);

                    if (clear) begin
                        state <= S0;
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_tenths <= button_num;
                        state <= S2_2;
                    end
                end

                S2_2: begin
                    // Update 7s display
                    units <= get_7seg(num_int);
                    tenths <= get_7seg(num_tenths);
                    hundredths <= get_7seg(button_num);

                    if (clear) begin
                        state <= S0;
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_hundredths <= button_num;
                        state <= S3;
                    end
                end

                S3: begin
                    // Update 7s display
                    sign <= display_sign;
                    tens <= display_tens;
                    units <= display_units;
                    tenths <= display_tenths;
                    hundredths <= display_hundredths;

                    if (clear) begin
                        state <= S0;
                    end else if (equal) begin
                        result <= result_temp;
                        state <= S3; 
                    end else if (button_op >= ADD && button_op <= DIV) begin
                        sign <= 7'b1111111;
                        num1 <= result_temp;
                        operation <= button_op;
                        state <= S2;  
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_int <= button_num;

                        // Update 7s display
                        sign <= 7'b1111111;
                        tens <= 7'b1111111;
                        units <= get_7seg(button_num);
                        tenths <= get_7seg(4'h0);
                        hundredths <= get_7seg(4'h0);  

                        result <= 16'b0;
                        state <= S0_1;
                    end
                end
                
            endcase
        end
    end

endmodule 