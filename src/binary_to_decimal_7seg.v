module binary_to_decimal_7seg (
    input [3:0] binary_in,          // 4-bit binary fractional input
    output reg [6:0] seg_tenths,    // Tenths place 7-segment output
    output reg [6:0] seg_hundredths // Hundredths place 7-segment output
);

    // Internal variables
    real decimal_value;             // Temporary real value for scaling
    integer int_decimal_value;      // Integer value for scaled decimal
    integer tenths, hundredths;     // Digits for tenths and hundredths place

    // 7-segment lookup table for digits 0-9
    function [6:0] get_7seg;
        input [3:0] digit;
        case (digit)
            // 7-Segment
            // 4'd0: get_7seg = 7'b1000000; // 0
            // 4'd1: get_7seg = 7'b1111001; // 1
            // 4'd2: get_7seg = 7'b0100100; // 2
            // 4'd3: get_7seg = 7'b0110000; // 3
            // 4'd4: get_7seg = 7'b0011001; // 4
            // 4'd5: get_7seg = 7'b0010010; // 5
            // 4'd6: get_7seg = 7'b0000010; // 6
            // 4'd7: get_7seg = 7'b1111000; // 7
            // 4'd8: get_7seg = 7'b0000000; // 8
            // 4'd9: get_7seg = 7'b0010000; // 9
            // default: get_7seg = 7'b1111111; // Blank

            // Check Number in Simulation
            4'd0: get_7seg = 7'b0000000; // 0
            4'd1: get_7seg = 7'b0000001; // 1
            4'd2: get_7seg = 7'b0000010; // 2
            4'd3: get_7seg = 7'b0000011; // 3
            4'd4: get_7seg = 7'b0000100; // 4
            4'd5: get_7seg = 7'b0000101; // 5
            4'd6: get_7seg = 7'b0000110; // 6
            4'd7: get_7seg = 7'b0000111; // 7
            4'd8: get_7seg = 7'b0001000; // 8
            4'd9: get_7seg = 7'b0001001; // 9
            default: get_7seg = 7'b0000000; // Blank
        endcase
    endfunction

    // Binary to decimal conversion and digit splitting
    always @(*) begin
        // Convert binary input to fractional decimal and scale to 2 digits
        decimal_value = (binary_in[3] * 0.5) + 
                        (binary_in[2] * 0.25) + 
                        (binary_in[1] * 0.125) + 
                        (binary_in[0] * 0.0625);

        // Scale fractional value to integer (e.g., 0.625 -> 62)
        int_decimal_value = $rtoi(decimal_value * 100);

        // Extract tenths and hundredths place
        tenths = (int_decimal_value / 10) % 10;    // Extract tenths place
        hundredths = int_decimal_value % 10;      // Extract hundredths place

        // Map to 7-segment display
        seg_tenths = get_7seg(tenths);
        seg_hundredths = get_7seg(hundredths);
    end

endmodule
