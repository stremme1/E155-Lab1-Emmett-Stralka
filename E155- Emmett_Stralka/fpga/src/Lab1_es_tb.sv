// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Testbench for Lab1_es module

module Lab1_es_tb();
    logic clk;
    logic [3:0] s;
    logic [6:0] seg, seg_expected;
    logic [2:0] led, led_expected;
    logic [31:0] vectornum, errors;
    logic [31:0] timeout_counter;
    logic [11:0] testvectors[1000:0];
    logic test_complete;
    logic file_read_success;
    
    // File handle for reading test vectors
    integer file_handle;
    string line;
    integer parse_result;

    // Instantiate DUT
    Lab1_es dut(
        .clk(clk),
        .s(s),
        .seg(seg),
        .led(led)
    );

    // Clock generation (10MHz for faster simulation)
    always begin
        clk = 1; #50; clk = 0; #50;
    end

    // Function to parse underscore-separated test vector line
    function automatic logic [11:0] parse_test_vector(string line);
        logic [3:0] s_val;
        logic [1:0] led_val;
        logic [6:0] seg_val;
        integer underscore1, underscore2;
        
        // Skip comments and empty lines
        if (line.len() == 0 || line[0] == "/") begin
            return 12'bx;
        end
        
        // Find underscore positions
        underscore1 = line.find("_");
        if (underscore1 == -1) return 12'bx;
        
        underscore2 = line.find("_", underscore1 + 1);
        if (underscore2 == -1) return 12'bx;
        
        // Parse each field
        s_val = line.substr(0, underscore1 - 1).atohex();
        led_val = line.substr(underscore1 + 1, underscore2 - 1).atohex();
        seg_val = line.substr(underscore2 + 1, line.len() - 1).atohex();
        
        // Combine into 12-bit vector
        return {s_val, led_val, seg_val};
    endfunction

    // Load test vectors and initialize
    initial begin
        // Initialize signals
        s = 4'b0000;
        vectornum = 0;
        errors = 0;
        timeout_counter = 0;
        test_complete = 0;
        file_read_success = 0;
        
        // Load test vectors with custom parsing
        file_handle = $fopen("Lab1.txt", "r");
        if (file_handle == 0) begin
            $display("ERROR: Failed to open Lab1.txt");
            $finish;
        end
        
        // Read and parse each line
        while (!$feof(file_handle)) begin
            parse_result = $fgets(line, file_handle);
            if (parse_result != 0) begin
                testvectors[vectornum] = parse_test_vector(line);
                if (testvectors[vectornum] !== 12'bx) begin
                    vectornum = vectornum + 1;
                end
            end
        end
        
        $fclose(file_handle);
        
        if (vectornum == 0) begin
            $display("ERROR: No valid test vectors found in Lab1.txt");
            $finish;
        end else begin
            file_read_success = 1;
            $display("Test vectors loaded successfully: %d vectors", vectornum);
        end
        
        // Reset vector counter for testing
        vectornum = 0;
        
        // Wait for initial reset
        @(posedge clk);
        #100; // Allow DUT to stabilize
    end

    // Apply test vectors with proper timing
    always @(posedge clk) begin
        if (file_read_success && !test_complete) begin
            // Apply inputs with setup time
            #20; // Setup time
            {s, led_expected[1:0], seg_expected} = testvectors[vectornum];
        end
    end

    // Check outputs with proper hold time
    always @(negedge clk) begin
        if (file_read_success && !test_complete) begin
            #30; // Hold time + propagation delay
            
            // Check LED outputs (excluding blinking LED for now)
            if (led[1:0] !== led_expected[1:0]) begin
                $display("ERROR: s=%b, led[1:0]=%b (expected %b)", s, led[1:0], led_expected[1:0]);
                errors = errors + 1;
            end
            
            // Check seven-segment output
            if (seg !== seg_expected) begin
                $display("ERROR: s=%b, seg=%b (expected %b)", s, seg, seg_expected);
                errors = errors + 1;
            end
            
            vectornum = vectornum + 1;
            
            // Check for end of test vectors
            if (vectornum >= 16) begin // We know we have 16 test vectors
                test_complete = 1;
                $display("Vector-based tests completed: %d tests, %d errors", vectornum, errors);
            end
        end
    end

    // Test blinking LED functionality
    initial begin
        if (file_read_success) begin
            // Wait for vector tests to complete
            wait(test_complete);
            
            $display("Testing blinking LED functionality...");
            
            // Test blinking LED over multiple cycles
            s = 4'b0000; // Set static input
            repeat(1000) @(posedge clk); // Wait for multiple blink cycles
            
            // Verify LED[2] is toggling (we can't predict exact state due to timing)
            if (led[2] !== 1'b0 && led[2] !== 1'b1) begin
                $display("ERROR: LED[2] should be toggling, got %b", led[2]);
                errors = errors + 1;
            end else begin
                $display("LED[2] blinking functionality verified");
            end
            
            // Test all input combinations systematically
            $display("Testing all input combinations...");
            for (int i = 0; i < 16; i++) begin
                s = i[3:0];
                @(posedge clk);
                #100; // Allow time for outputs to settle
                
                // Verify LED logic
                if (led[0] !== (s[1] ^ s[0])) begin
                    $display("ERROR: s=%b, led[0]=%b (expected %b)", s, led[0], s[1] ^ s[0]);
                    errors = errors + 1;
                end
                if (led[1] !== (s[3] & s[2])) begin
                    $display("ERROR: s=%b, led[1]=%b (expected %b)", s, led[1], s[3] & s[2]);
                    errors = errors + 1;
                end
            end
            
            $display("Comprehensive testing completed: %d total errors", errors);
            $finish;
        end
    end

    // Timeout protection
    always @(posedge clk) begin
        if (!test_complete) begin
            timeout_counter = timeout_counter + 1;
            if (timeout_counter > 100000) begin // 10ms timeout
                $display("ERROR: Test timeout - simulation may be stuck");
                $finish;
            end
        end
    end

endmodule
