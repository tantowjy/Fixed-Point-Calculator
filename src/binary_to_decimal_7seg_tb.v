module binary_to_decimal_7seg_tb;
    reg [15:0] binary_in;
    wire [6:0] seg_sign, seg_tens, seg_units, seg_tenths, seg_hundredths;

    // Instantiate the Unit Under Test (UUT)
    binary_to_decimal_7seg uut (
        .binary_in(binary_in),
        .seg_sign(seg_sign),
        .seg_tens(seg_tens),
        .seg_units(seg_units),
        .seg_tenths(seg_tenths),
        .seg_hundredths(seg_hundredths)
    );

    // Test vectors and expected outputs
    initial begin
        // Initialize input
        binary_in = 16'd0;

        // Apply test cases
        #10; binary_in = 16'b0001010111_001000; // 87.125 
        #10; binary_in = 16'b1110101000_100000; // -87.500 

        // Stop simulation
        #10 $stop;
    end

endmodule 