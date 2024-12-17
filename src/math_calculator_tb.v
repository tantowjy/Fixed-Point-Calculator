module math_calculator_tb;

reg clk;
reg rst;
reg signed [7:0] A, B;
// wire signed [7:0] Sum, Sub;
// wire signed [15:0] Prod;
// wire signed [7:0] Div;
wire signed [15:0] result_sum, result_sub, result_mul, result_div, result;

// Instantiate the math_calculator module
math_calculator calc (
    .clk (clk),
    .rst (rst),
    .A (A),
    .B (B),
    .result_sum (result_sum),
    .result_sub (result_sub),
    .result_mul (result_mul),
    .result_div (result_div)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    // Initialize signals
    clk = 1'b0;
    rst = 1'b1;
    A = 8'sd0;
    B = 8'sd0;

    // Reset the design
    #10 rst = 1'b0;

    // Test case 1
    #10 A = 8'sd10; B = 8'sd5;
    #10;
    
    // Test case 2
    #10 A = -8'sd3; B = 8'sd7;
    #10;

    // Test case 3
    #10 A = 8'sd15; B = -8'sd4;
    #10;

    // Test case 4
    #10 A = -8'sd8; B = -8'sd6;
    #10;

    // Finish simulation
    #20 $stop;
end

endmodule