module math_calculator_fsm (
    input clk,
    input [9:0] button,
    output reg clear,
    output reg [3:0] button_num,
    output reg [2:0] button_op,
    output reg equal,
    output reg [15:0] num_check,
    output reg [15:0] result_temp, result
);

    reg [3:0] state;
    reg [1:0] input_state;
    reg [3:0] num_int;                  // Integer part
    reg [3:0] num_tenths;               // Tenths part
    reg [3:0] num_hundredths;           // Hundredths part
    reg signed [15:0] num1, num2;       // Q1.9.6
    reg [2:0] operation;

    // Wire
    wire [15:0] num;
    wire [31:0] mul_result;

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

    // Multiplication result wire
    assign mul_result = num1 * {6'b0, button_num, 6'b0};

    // Decimal point to 6-bit binary
    decimal_to_binary uut (
        .decimal_input_a(num_tenths),
        .decimal_input_b(num_hundredths),
        .decimal_int(num_int),
        .output_num(num)
    );

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
            state <= S0;
        end else begin
            case (state)
                S0: begin
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
                    if (button_num >= NUM_0 && button_num <= NUM_9) begin
                        num_tenths <= button_num;
                        state <= S0_2;
                    end
                end

                S0_2: begin
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
                    if (clear) begin
                        state <= S0;
                    end else if (button_num >= NUM_0 && button_num <= NUM_9) begin

                        // Debugging
                        num_check <= num;
                        
                        // Pilih hasil operasi berdasarkan jenis operasi
                        case (operation)
                            ADD: result_temp <= num1 + {{6'b0, button_num, 6'b0}};
                            SUB: result_temp <= num1 - {{6'b0, button_num, 6'b0}};
                            // Multiplication: use 32-bit result, convert to 16-bit fixed-point
                            // Sign bit [31], Integer [20:12], Fractional [11:6]
                            MUL: result_temp <= {mul_result[31], mul_result[20:12], mul_result[11:6]};
                            DIV: result_temp <= (button_num != 0) ? {{1'b0, num1[14:0]} * 16'd64} / {6'b0, button_num, 6'b0} : 16'b0;
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