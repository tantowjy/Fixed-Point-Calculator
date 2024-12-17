module math_calculator (
    input clk,
    input rst,
    input signed [7:0] A, B,
    output reg signed [7:0] Sum, Sub,
    output reg signed [15:0] Prod,
    output reg signed [7:0] Div
);

    always @(posedge clk) begin
        if (rst) begin
            Sum <= 0;
            Prod <= 0;
        end else begin
            Sum <= A + B;
            Sub <= A - B;
            Prod <= A * B;
            Div <= A / B;
        end
    end

endmodule 