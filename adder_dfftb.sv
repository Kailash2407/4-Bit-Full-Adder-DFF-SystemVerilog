module adder_dff_tb;

    logic [3:0] A, B;
    logic Cin, clk, rst;
    logic [4:0] Q;

    // Instantiate the design
    adder_dff uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .clk(clk),
        .rst(rst),
        .Q(Q)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Apply test vectors
    initial begin
        $monitor("Time=%0t | A=%b B=%b Cin=%b | rst=%b clk=%b | Q=%b",
                 $time, A, B, Cin, rst, clk, Q);

        // Reset
        rst = 1;
        A = 0; B = 0; Cin = 0;
        #10;

        rst = 0;

        // Test 1: 3 + 2 + 0 = 5
        A = 4'b0011; B = 4'b0010; Cin = 0;
        #10;

        // Test 2: 5 + 3 + 0 = 8
        A = 4'b0101; B = 4'b0011; Cin = 0;
        #10;

        // Test 3: 15 + 1 + 0 = 16
        A = 4'b1111; B = 4'b0001; Cin = 0;
        #10;

        // Test 4: 10 + 5 + 1 = 16
        A = 4'b1010; B = 4'b0101; Cin = 1;
        #10;

        // Test 5: 15 + 15 + 1 = 31
        A = 4'b1111; B = 4'b1111; Cin = 1;
        #10;

        // Test asynchronous reset
        rst = 1;
        #10;

        rst = 0;
        #10;

        $finish;
    end

endmodule