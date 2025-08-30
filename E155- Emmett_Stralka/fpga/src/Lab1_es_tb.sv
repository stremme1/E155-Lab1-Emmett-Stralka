// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Testbench for Lab1_es module

module Lab1_es_tb();
    logic clk;
    logic [3:0] s;
    logic [6:0] seg, seg_expected;
    logic [1:0] led, led_expected; // led[2] blink ignored in vector
    logic [31:0] vectornum, errors;
    logic [11:0] testvectors[1000:0]; // 4 bits input + 2 leds + 7 seg bits

    // Instantiate DUT
    Lab1_es dut(.clk(clk), .s(s), .seg(seg), .led({led, /*led[2] ignored*/}));

    // Clock generation
    always begin
        clk = 1; #5; clk = 0; #5;
    end

    // Load test vectors
    initial begin
        $readmemb("lab1_es.txt", testvectors);
        vectornum = 0; errors = 0;
    end

    // Apply test vectors on rising edge
    always @(posedge clk) begin
        #1;
        {s, led_expected, seg_expected} = testvectors[vectornum];
    end

    // Check outputs on falling edge
    always @(negedge clk) begin
        if (led !== led_expected) begin
            $display("Error: s=%b, led=%b (expected %b)", s, led, led_expected);
            errors = errors + 1;
        end
        if (seg !== seg_expected) begin
            $display("Error: s=%b, seg=%b (expected %b)", s, seg, seg_expected);
            errors = errors + 1;
        end
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 12'bx) begin
            $display("%d tests completed with %d errors", vectornum, errors);
            $finish;
        end
    end
endmodule
