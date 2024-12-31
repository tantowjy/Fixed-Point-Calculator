module decimal_to_binary (
    input [3:0] decimal_int,              // 1-digit decimal units
    input [3:0] decimal_input_a,          // 1-digit decimal tenths 
    input [3:0] decimal_input_b,          // 1-digit decimal hundredths
    output [15:0] output_num
);

    // Registers
    reg [7:0] num_tenths;
    reg [7:0] num_hundredths;
    reg [15:0] num_decimal_mul;
    reg [7:0] num_decimal_point;
    reg [5:0] fractional_6bit;
    reg [15:0] num_internal;

    assign output_num = num_internal;

    always @(*) begin
        // Default value
        num_internal <= 16'b0;
        
        num_tenths <= {4'b0, decimal_input_a};
        num_hundredths <= {4'b0, decimal_input_b};

        // Combine decimal points
        num_decimal_mul <= num_tenths * 8'b00001010;
        num_decimal_point <= num_decimal_mul[7:0] + num_hundredths;

        // Convert decimal point to 6-bit fractional
        fractional_6bit <= (num_decimal_point * 64) / 100;

        // Combine inputs into final number
        num_internal <= {6'b0, decimal_int, fractional_6bit};
    end

endmodule 