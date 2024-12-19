module math_calculator_fsm (
    input clk,
    input [9:0] button,
    output reg clear,
    output reg [3:0] button_num,
    output reg [2:0] button_op,
    output reg equal,
    output reg [15:0] num_check,
    output reg [15:0] result_temp, result,
    output reg [6:0] sign, tens, units, tenths, hundredths
);

    reg [3:0] state;
    reg [1:0] input_state;
    reg [3:0] num_int;                  // Integer part
    reg [3:0] num_tenths;               // Tenths part
    reg [3:0] num_hundredths;           // Hundredths part
    reg signed [15:0] num1, num2;       // Q1.9.6
    reg [2:0] operation;
    reg [15:0] binary_in;

    // Wire
    wire [15:0] num_decimal_mul_tenths;
    wire [5:0] fractional_6bit_tenths;
    wire [15:0] num_decimal_mul_hundredths;
    wire [7:0] num_decimal_point_hundredths;
    wire [5:0] fractional_6bit_hundredths;
    wire [15:0] num;
    wire [31:0] mul_result;
    wire [6:0] seg_sign, seg_tens, seg_units, seg_tenths, seg_hundredths;

    // Definisi button
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

    // parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011;
    parameter S0 = 4'd0, S0_1 = 4'd1, S0_2 = 4'd2, S1 = 4'd3, S2 = 4'd4,
                S2_1 = 4'd5, S2_2 = 4'd6, S3 = 4'd7;

    // Logika pemetaan tombol ke nilai numerik dan operator
    always @(*) begin
        // Default values
        button_num = 4'b0;  // Nilai default untuk numerik (tidak dikenal)
        button_op = 3'b0;   // Nilai default untuk operator (tidak ada)
        equal = 1'b0;       // Default bukan tombol '='
        clear = 1'b0;       // Default bukan tombol 'Clear'

        case (button)
            // Numerik
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
                // Semua output tetap default jika tidak ada tombol dikenal
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
            // // 7-segment display
            // 4'h0: get_7seg = 7'b1000000;    // digit 0
            // 4'h1: get_7seg = 7'b1111001;    // digit 1
            // 4'h2: get_7seg = 7'b0100100;    // digit 2
            // 4'h3: get_7seg = 7'b0110000;    // digit 3
            // 4'h4: get_7seg = 7'b0011001;    // digit 4
            // 4'h5: get_7seg = 7'b0010010;    // digit 5
            // 4'h6: get_7seg = 7'b0000010;    // digit 6
            // 4'h7: get_7seg = 7'b1111000;    // digit 7
            // 4'h8: get_7seg = 7'b0000000;    // digit 8
            // 4'h9: get_7seg = 7'b0010000;    // digit 9
            // 4'ha: get_7seg = 7'b0001000;    // huruf A
            // 4'hb: get_7seg = 7'b0000011;    // huruf B
            // 4'hc: get_7seg = 7'b1000111;    // huruf L
            // 4'hd: get_7seg = 7'b0100001;    // huruf D
            // 4'he: get_7seg = 7'b1101010;    // huruf M
            // 4'hf: get_7seg = 7'b1000001;    // huruf U
            // default: get_7seg = 7'b1111111; // Blank

            // Check Number in Simulation
            4'h0: get_7seg = 7'b0000000; // 0
            4'h1: get_7seg = 7'b0000001; // 1
            4'h2: get_7seg = 7'b0000010; // 2
            4'h3: get_7seg = 7'b0000011; // 3
            4'h4: get_7seg = 7'b0000100; // 4
            4'h5: get_7seg = 7'b0000101; // 5
            4'h6: get_7seg = 7'b0000110; // 6
            4'h7: get_7seg = 7'b0000111; // 7
            4'h8: get_7seg = 7'b0001000; // 8
            4'h9: get_7seg = 7'b0001001; // 9
            4'ha: get_7seg = 7'b0001010; //10
            4'hb: get_7seg = 7'b0001011; //11
            4'hc: get_7seg = 7'b0001100; //12
            4'hd: get_7seg = 7'b0001101; //13
            4'he: get_7seg = 7'b0001110; //14
            4'hf: get_7seg = 7'b0001111; //15
            default: get_7seg = 7'b1111111; // Blank

        endcase
    endfunction

    // Multiplication result wire
    assign mul_result = num1 * {6'b0, button_num, 6'b0};

    // Combine decimal points tenths
    assign num_decimal_mul_tenths = {4'b0000, button_num} * 8'b00001010;
    assign fractional_6bit_tenths = (num_decimal_mul_tenths[7:0] * 64) / 100;

    // Combine decimal points hundredths
    assign num_decimal_mul_hundredths = num_tenths * 8'b00001010;
    assign num_decimal_point_hundredths = num_decimal_mul_hundredths[7:0] + {4'b0, button_num};
    assign fractional_6bit_hundredths = (num_decimal_point_hundredths * 64) / 100;

    // Decimal point to 6-bit binary
    decimal_to_binary uutdb (
        .decimal_input_a(num_tenths),
        .decimal_input_b(num_hundredths),
        .decimal_int(num_int),
        .output_num(num)
    );

    binary_to_decimal_7seg uutss (
        .binary_in(binary_in),
        .seg_sign(seg_sign),
        .seg_tens(seg_tens),
        .seg_units(seg_units),
        .seg_tenths(seg_tenths),
        .seg_hundredths(seg_hundredths)
    );

    // Update 7s display for operator state
    always @(*) begin
        if (button_op == ADD) begin
            sign <= 7'b1111111; tens <= 7'b1111111; units <= get_7seg(4'ha); 
            tenths <= get_7seg(4'hd); hundredths <= get_7seg(4'hd);
        end else if (button_op == SUB) begin
            sign <= 7'b1111111; tens <= 7'b1111111; units <= get_7seg(4'h5); 
            tenths <= get_7seg(4'hf); hundredths <= get_7seg(4'hb);
        end else if (button_op == MUL) begin
            sign <= 7'b1111111; tens <= 7'b1111111; units <= get_7seg(4'he); 
            tenths <= get_7seg(4'hf); hundredths <= get_7seg(4'hc);
        end else if (button_op == DIV) begin
            sign <= 7'b1111111; tens <= 7'b1111111; units <= get_7seg(4'hd); 
            tenths <= get_7seg(4'h1); hundredths <= get_7seg(4'hf);
        end
    end

    // Update 7s display for result
    always @(*) begin
        if (equal) begin
            binary_in <= result_temp;
            sign <= seg_sign; 
            tens <= seg_tens; 
            units <= seg_units; 
            tenths <= seg_tenths; 
            hundredths <= seg_hundredths;
        end
    end

    // Logika state dan operasi tetap sama
    always @(posedge clk or posedge clear) begin
        if (clear) begin
            // Inisialisasi variabel
            num1 <= 16'b0;
            num2 <= 16'b0;
            num_int <= 4'b0;
            num_tenths <= 4'b0;
            num_hundredths <= 4'b0;
            result_temp <= 16'b0;
            result <= 16'b0;
            binary_in <= 16'b0;
            sign <= 7'b1111111; tens <= 7'b1111111; units <= 7'b1111111; 
            tenths <= 7'b1111111; hundredths <= 7'b1111111;
            state <= S0;
        end else begin
            case (state)
                S0: begin
                    // // Update 7s display
                    units <= get_7seg(button_num);
                    tenths <= get_7seg(4'h0);
                    hundredths <= get_7seg(4'h0);

                    if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_int <= button_num;
                        num1 <= 16'b0;
                        num2 <= 16'b0;
                        num_tenths <= 4'b0;
                        num_hundredths <= 4'b0;
                        result_temp <= 16'b0;
                        result <= 16'b0;
                        state <= S0_1;
                    end
                end

                S0_1: begin
                    // Update 7s display
                    tenths <= get_7seg(button_num);
                    hundredths <= get_7seg(4'h0);

                    if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_tenths <= button_num;
                        state <= S0_2;
                    end
                end

                S0_2: begin
                    // Update 7s display
                    hundredths <= get_7seg(button_num);

                    if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_hundredths <= button_num;
                        state <= S1;
                    end
                end

                S1: begin
                    // Num from previous state
                    num1 <= num;

                    if (clear) begin
                        state <= S0;
                    end else if (button_op >= ADD && button_op <= DIV) begin
                        operation <= button_op;
                        state <= S2;
                    end
                end

                S2: begin
                    // Update 7s display
                    units <= get_7seg(button_num);
                    tenths <= get_7seg(4'h0);
                    hundredths <= get_7seg(4'h0);

                    if (clear) begin
                        state <= S0;
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin

                        // Pilih hasil operasi berdasarkan jenis operasi
                        case (operation)
                            ADD: result_temp <= num1 + {{6'b0, button_num, 6'b0}};
                            SUB: result_temp <= num1 - {{6'b0, button_num, 6'b0}};
                            // Multiplication: use 32-bit result, convert to 16-bit fixed-point
                            // Sign bit [31], Integer [20:12], Fractional [11:6]
                            MUL: result_temp <= {mul_result[31], mul_result[20:12], mul_result[11:6]};
                            // DIV: result_temp <= (button_num != 0) ? {{1'b0, num1[14:0]} * 16'd64} / {6'b0, button_num, 6'b0} : 16'b0;
                            DIV: result_temp <= (button_num != 0) ? (num1 << 6) / {6'b0, button_num, 6'b0} : 16'b0;
                        endcase
                        
                        state <= S3;
                    end
                end

                S3: begin
                    if (clear) begin
                        state <= S0;
                    end else if (equal) begin
                        result <= result_temp;                        
                        state <= S3; 
                    end else if (button_op >= ADD && button_op <= DIV) begin
                        num1 <= result_temp;
                        operation <= button_op;
                        state <= S2;  
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num1 <= {6'b0, button_num, 6'b0};
                        result_temp <= 16'b0;   // Set hasil sementara ke 0
                        result <= 16'b0;        // Set hasil ke 0
                        state <= S1;
                    end
                end
                
            endcase
        end
    end

endmodule 