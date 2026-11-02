module adder_dff (
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic       Cin,
    input  logic       clk,
    input  logic       rst,
    output logic [4:0] Q
);

    logic [4:0] Sum;

    // 4-bit Full Adder
    assign Sum = A + B + Cin;

    // 5-bit D Flip-Flop Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            Q <= 5'b00000;
        else
            Q <= Sum;
    end

endmodule