module binary_to_decimal_7seg_tb;

    reg [3:0] binary_in;
    wire [6:0] seg_tenths, seg_hundredths;

    binary_to_decimal_7seg uut (
        .binary_in(binary_in),
        .seg_tenths(seg_tenths),
        .seg_hundredths(seg_hundredths)
    );

    initial begin
        $monitor("Binary=%b, Tens=%b, Units=%b", binary_in, seg_tenths, seg_hundredths);

        // Test values
        binary_in = 4'b0000; #10; // Expect "00"
        binary_in = 4'b1010; #10; // Expect "62"
        binary_in = 4'b1111; #10; // Expect "93"

        $stop;
    end
endmodule
