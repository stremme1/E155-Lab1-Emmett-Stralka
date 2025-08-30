// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Testbench for seven_segment module

module seven_segment_tb();
    logic clk, reset;
    logic [3:0] num;
    logic [6:0] seg, seg_expected;
    logic [31:0] vectornum, errors;
    logic [10:0] testvectors[10000:0];

    // Instantiate device under test
    seven_segment dut(num, seg);
    
    // Generate clock
    always begin
        clk = 1; #5; clk = 0; #5;
    end
    
    // Load test vectors and initialize
    initial begin
        $readmemb("seven_segment.tv", testvectors);
        vectornum = 0; errors = 0;
        reset = 1; #22; reset = 0;
    end
    
    // Apply test vectors on rising edge
    always @(posedge clk) begin
        #1;
        {num, seg_expected} = testvectors[vectornum];
    end
    
    // Check results on falling edge
    always @(negedge clk)
    if (~reset) begin
        if (seg !== seg_expected) begin
            $display("Error: inputs = %b", num);
            $display(" outputs = %b (%b expected)", seg, seg_expected);
            errors = errors + 1;
        end
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 11'bx) begin
            $display("%d tests completed with %d errors", vectornum, errors);
            $stop;
        end
    end
endmodule
