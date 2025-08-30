// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Testbench for Lab1_es module

module Lab1_es_tb();
    logic clk, reset;
    logic [3:0] s;
    logic [6:0] seg, seg_expected;
    logic [2:0] led, led_expected;
    logic [31:0] vectornum, errors;
    logic [12:0] testvectors[10000:0];

    // Instantiate device under test
    Lab1_es dut(clk, s, seg, led);
    
    // Generate clock
    always begin
        clk = 1; #5; clk = 0; #5;
    end
    
    // Load test vectors and initialize
    initial begin
        $readmemb("Lab1_es.tv", testvectors);
        vectornum = 0; errors = 0;
        reset = 1; #22; reset = 0;
    end
    
    // Apply test vectors on rising edge
    always @(posedge clk) begin
        #1;
        {s, led_expected[0:1], seg_expected} = testvectors[vectornum];
    end
    
    // Check results on falling edge
    always @(negedge clk)
    if (~reset) begin
        if (led[1:0] !== led_expected[0:1] || seg !== seg_expected) begin
            $display("Error: inputs = %b", s);
            $display(" outputs = %b %b (%b %b expected)", led[1:0], seg, led_expected[0:1], seg_expected);
            errors = errors + 1;
        end
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 13'bx) begin
            $display("%d tests completed with %d errors", vectornum, errors);
            $stop;
        end
    end
endmodule
