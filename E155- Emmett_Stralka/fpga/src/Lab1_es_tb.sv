// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Testbench for Lab1_es module
// This testbench applies inputs to DUT and checks if outputs are as expected.
// User provides patterns of inputs & desired outputs called testvectors.

module Lab1_es_tb();
    logic clk, reset;
    // 'clk' & 'reset' are common names for the clock and the reset,
    // but they're not reserved.
    
    logic [3:0] s;
    logic [6:0] seg, seg_expected;
    logic [2:0] led, led_expected;
    // These variables represent 4-bit input, 7-bit segment output, 3-bit LED output,
    // and their expected values, respectively.
    
    logic [31:0] vectornum, errors;
    // '[31:0]' indicates that the following signals, vectornum and errors
    // in this case, are 32-bit long (start from bit 0 to bit 31) in little
    // endian order (the least significant bit at the lowest address or
    // [msb:lsb]).
    // vectornum shows the number of test vectors that has been applied.
    // errors represents the number of errors found.
    
    logic [12:0] testvectors[10000:0];
    // Above is a 13-bit binary array named testvectors with index 0 to 10000
    // (testvectors[0],testvectors[1],testvectors[2],...,testvectors[10000]).
    // In other words, testvectors contains 10001 elements, each of which is
    // a 13-bit binary number. The number of bits represent the sum of the
    // number of input and output bits (4-bit input + 2-bit LED + 7-bit segment = 13-bit testvector).
    // We will use 16 test vectors (found in .tv file below), however it doesn't hurt
    // to set up array to support more so we could easily add test vectors later.
    
    // Instantiate device under test (DUT).
    // Inputs: clk, s[3:0]. Outputs: seg[6:0], led[2:0].
    Lab1_es dut(clk, s, seg, led);
    
    // Generate clock.
    always
    // 'always' statement causes the statements in the block to be
    // continuously re-evaluated.
    begin
        // Create clock with period of 10 time units.
        // Set the clk signal HIGH(1) for 5 units, LOW(0) for 5 units
        clk = 1; #5;
        clk = 0; #5;
    end
    
    // Start of test.
    initial
    // 'initial' is used only in testbench simulation.
    begin
        // Load vectors stored as 0s and 1s (binary) in .tv file.
        $readmemb("Lab1_es.tv", testvectors);
        // $readmemb reads binarys, $readmemh reads hexadecimals.
        
        // Initialize the number of vectors applied & the amount of
        // errors detected.
        vectornum = 0;
        errors = 0;
        // Both signals hold 0 at the beginning of the test.
        
        // Pulse reset for 22 time units(2.2 cycles) so the reset
        // signal falls after a clk edge.
        reset = 1; #22;
        reset = 0;
        // The signal starts HIGH(1) for 22 time units then remains
        // LOW(0) for the rest of the test.
    end
    
    // Apply test vectors on rising edge of clk.
    always @(posedge clk)
    // Notice that this 'always' has the sensitivity list that controls when all
    // statements in the block will start to be evaluated. '@(posedge clk)' means
    // at positive or rising edge of clock.
    begin
        // Apply testvectors 1 time unit after rising edge of clock to
        // avoid data changes concurrently with the clock.
        #1;
        // Break the current 13-bit test vector into 4-bit input and 9-bit
        // expected outputs (2-bit LED + 7-bit segment).
        {s, led_expected[1:0], seg_expected} = testvectors[vectornum];
        // led[2] (blinking) is dynamic and not included in test vectors
    end
    
    // Check results on falling edge of clk.
    always @(negedge clk)
    // This line of code lets the program execute the following indented
    // statements in the block at the negative edge of clock.
    // Don't do anything during reset. Otherwise, check result.
    if (~reset) begin
        // Detect error by checking if outputs from DUT match
        // expectation.
        if (led[1:0] !== led_expected[1:0] || seg !== seg_expected) begin
            // If error is detected, print all inputs, outputs,
            // and expected outputs.
            $display("Error: inputs = %b", s);
            // '$display' prints any statement inside the quotation to
            // the simulator window.
            // %b, %d, and %h indicate values in binary, decimal, and
            // hexadecimal, respectively.
            // {s} creates a vector containing the input signal.
            $display(" outputs = %b %b (%b %b expected)", led[1:0], seg, led_expected[1:0], seg_expected);
            // Increment the count of errors.
            errors = errors + 1;
        end
        // In any event, increment the count of vectors.
        vectornum = vectornum + 1;
        // When the test vector becomes all 'x', that means all the
        // vectors that were initially loaded have been processed, thus
        // the test is complete.
        if (testvectors[vectornum] === 13'bx) begin
            // '==='&'!==' can compare unknown & floating values (X&Z),unlike
            // '=='&'!=', which can only compare 0s and 1s.
            // 13'bx is 13-bit binary of x's or xxxxxxxxxxxxx.
            // If the current testvector is xxxxxxxxxxxxx, report the number of
            // vectors applied & errors detected.
            $display("%d tests completed with %d errors", vectornum, errors);
            // Then stop the simulation.
            $stop;
        end
    end
    // In summary, new inputs are applied on the positive clock edge and the
    // outputs are checked against the expected outputs on the negative clock
    // edge. Errors are reported simultaneously. The process repeats until there
    // are no more valid test vectors in the testvectors arrays. At the end of
    // the simulation, the module prints the total number of test vectors applied and
    // the total number of errors detected.
endmodule
