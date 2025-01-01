module decimal_to_binary_tb;
    reg [7:0] decimal_int;
    reg [3:0] decimal_input_a;
    reg [3:0] decimal_input_b;
    wire [15:0] output_num;

    // Instantiate the module
    decimal_to_binary uut (
        .decimal_int(decimal_int),
        .decimal_input_a(decimal_input_a),
        .decimal_input_b(decimal_input_b),
        .output_num(output_num)
    );

    initial begin
        // Test cases
        decimal_int = 4'd0;
        decimal_input_a = 4'd6; 
        decimal_input_b = 4'd2; #10; // Expected binary output: 0.1001 (0.62)

        $stop;
    end

endmodule 