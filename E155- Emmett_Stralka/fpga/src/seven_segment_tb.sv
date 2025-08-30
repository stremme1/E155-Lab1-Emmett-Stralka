// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Testbench for seven_segment module

module seven_segment_tb();
    logic clk;
    logic [3:0] num;
    logic [6:0] seg, seg_expected;
    logic [31:0] vectornum, errors;
    logic [10:0] testvectors[1000:0]; // 4 bits input + 7 bits output

    // Instantiate DUT
    seven_segment dut(.num(num), .seg(seg));

    // Clock generation
    always begin
        clk = 1; #5; clk = 0; #5;
    end

    // Load test vectors
    initial begin
        $readmemb("seven_segment.tv.txt", testvectors);
        vectornum = 0; errors = 0;
    end

    // Apply test vectors on rising edge
    always @(posedge clk) begin
        #1; 
        {num, seg_expected} = testvectors[vectornum];
    end

    // Check outputs on falling edge
    always @(negedge clk) begin
        if (seg !== seg_expected) begin
            $display("Error: num=%b, seg=%b (expected %b)", num, seg, seg_expected);
            errors = errors + 1;
        end
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 11'bx) begin
            $display("%d tests completed with %d errors", vectornum, errors);
            $finish;
        end
    end
endmodule
