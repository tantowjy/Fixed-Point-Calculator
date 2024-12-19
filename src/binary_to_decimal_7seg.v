module binary_to_decimal_7seg (
    input [15:0] binary_in,           // 16-bit binary input
    output reg [6:0] seg_sign,        // Sign (7-segment output for the sign)
    output reg [6:0] seg_tens,         // 7-segment output for tens
    output reg [6:0] seg_units,       // 7-segment output for units
    output reg [6:0] seg_tenths,      // 7-segment output for tenths
    output reg [6:0] seg_hundredths  // 7-segment output for hundredths
);

    // Internal variables
    integer signed_value;
    integer int_decimal_value;
    integer hundreds, tens, units, tenths, hundredths; // Placeholders for digits

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

            // // Check Number in Simulation
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

    // Binary to decimal conversion and digit splitting
    always @(*) begin
        signed_value = binary_in[14:6];

        // Handle sign display for 7-segment (1 bit signed)
        if (binary_in[15] == 1) begin
            seg_sign = 7'b0111111; // Display '-' sign
        end else begin
            seg_sign = 7'b1111111; // Blank sign
        end

        // Extract digits from the binary input
        hundreds = signed_value / 100;                  // Get hundreds place
        tens = (signed_value / 10) % 10;                // Get tens place
        units = signed_value % 10;                      // Get units place

        // Convert binary input to fractional decimal and scale to 2 digits
        int_decimal_value = (binary_in[5] * 32) + 
                            (binary_in[4] * 16) + 
                            (binary_in[3] * 8) + 
                            (binary_in[2] * 4) + 
                            (binary_in[1] * 2) + 
                            (binary_in[0] * 1);

        // Scale fractional value to integer (e.g., 0.625 -> 62)
        int_decimal_value = (int_decimal_value * 100) / 64;

        // Extract tenths and hundredths place
        tenths = (int_decimal_value / 10) % 10;    // Extract tenths place
        hundredths = int_decimal_value % 10;      // Extract hundredths place

        // Map digits to 7-segment displays
        if (tens == 0) begin
            seg_tens = 7'b1111111;
        end else begin
            seg_tens = get_7seg(tens);
        end
        seg_units = get_7seg(units);
        seg_tenths = get_7seg(tenths);
        seg_hundredths = get_7seg(hundredths);
    end

endmodule
