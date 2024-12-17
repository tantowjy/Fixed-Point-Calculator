module math_calculator (
    input clk,
    input rst,
    input signed [7:0] A, B,    // Q5.3
    output reg signed [15:0] result_sum, result_sub, result_mul, result_div, result
);
    
    // Internal signals
    reg signed [7:0] sum, sub, div;
    reg signed [15:0] mul;

    always @(posedge clk) begin
        if (rst) begin
            sum <= 0;
            sub <= 0;
            mul <= 0;
            div <= 0;
        end else begin
            sum <= A + B;         // Addition
            sub <= A - B;         // Subtraction
            mul <= A * B;         // Multiplication
            
            // Division with zero protection
            if (B != 0) 
                div <= A / B;     // Safe division
            else 
                div <= 0;         // Avoid division by zero
        end

        // Add 3 LSB zeros and extend to 16-bit outputs
        // 1-bit signed, 9-bit integer, 6-bit fractional
        result_sum <= { {5{sum[7]}}, sum[7:0], 3'b000 };    // Sign-extend and add 3 LSB zeros
        result_sub <= { {5{sub[7]}}, sub[7:0], 3'b000 };    // Sign-extend and add 3 LSB zeros
        result_mul <= mul;                                  // No modification for multiplication result
        result_div <= { {2{div[7]}}, div[7:0], 6'b000 };    // Sign-extend and add 3 LSB zeros
        
        // Unused output, assign default zero
        result <= 0;                        
    end

endmodule
