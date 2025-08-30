// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Testbench for seven_segment module

module seven_segment_tb();
    logic [3:0] num;
    logic [6:0] seg, seg_expected;
    logic [31:0] vectornum, errors;
    logic [10:0] testvectors[1000:0];
    logic test_complete;
    logic file_read_success;
    logic [31:0] timeout_counter;
    
    // File handle for reading test vectors
    integer file_handle;
    string line;
    integer parse_result;

    // Instantiate DUT
    seven_segment dut(.num(num), .seg(seg));

    // Function to parse underscore-separated test vector line
    function automatic logic [10:0] parse_test_vector(string line);
        logic [3:0] num_val;
        logic [6:0] seg_val;
        integer underscore_pos;
        
        // Skip comments and empty lines
        if (line.len() == 0 || line[0] == "/") begin
            return 11'bx;
        end
        
        // Find underscore position
        underscore_pos = line.find("_");
        if (underscore_pos == -1) return 11'bx;
        
        // Parse each field
        num_val = line.substr(0, underscore_pos - 1).atohex();
        seg_val = line.substr(underscore_pos + 1, line.len() - 1).atohex();
        
        // Combine into 11-bit vector
        return {num_val, seg_val};
    endfunction

    // Load test vectors and initialize
    initial begin
        // Initialize signals
        num = 4'b0000;
        vectornum = 0;
        errors = 0;
        timeout_counter = 0;
        test_complete = 0;
        file_read_success = 0;
        
        // Load test vectors with custom parsing
        file_handle = $fopen("seven_segment.txt", "r");
        if (file_handle == 0) begin
            $display("ERROR: Failed to open seven_segment.txt");
            $finish;
        end
        
        // Read and parse each line
        while (!$feof(file_handle)) begin
            parse_result = $fgets(line, file_handle);
            if (parse_result != 0) begin
                testvectors[vectornum] = parse_test_vector(line);
                if (testvectors[vectornum] !== 11'bx) begin
                    vectornum = vectornum + 1;
                end
            end
        end
        
        $fclose(file_handle);
        
        if (vectornum == 0) begin
            $display("ERROR: No valid test vectors found in seven_segment.txt");
            $finish;
        end else begin
            file_read_success = 1;
            $display("Test vectors loaded successfully: %d vectors", vectornum);
        end
        
        // Reset vector counter for testing
        vectornum = 0;
        
        // Allow initial propagation
        #10;
    end

    // Apply test vectors and check outputs with proper timing
    always begin
        if (file_read_success && !test_complete) begin
            // Apply input
            {num, seg_expected} = testvectors[vectornum];
            
            // Wait for combinational logic to settle
            #5;
            
            // Check output
            if (seg !== seg_expected) begin
                $display("ERROR: num=%b, seg=%b (expected %b)", num, seg, seg_expected);
                errors = errors + 1;
            end
            
            vectornum = vectornum + 1;
            
            // Check for end of test vectors
            if (vectornum >= 16) begin // We know we have 16 test vectors
                test_complete = 1;
                $display("Vector-based tests completed: %d tests, %d errors", vectornum, errors);
            end
        end else if (test_complete) begin
            // Prevent infinite loop after completion
            #1000;
        end else begin
            // Wait if file not loaded
            #100;
        end
    end

    // Comprehensive systematic testing
    initial begin
        if (file_read_success) begin
            // Wait for vector tests to complete
            wait(test_complete);
            
            $display("Performing comprehensive systematic testing...");
            
            // Test all 16 input combinations systematically
            for (int i = 0; i < 16; i++) begin
                num = i[3:0];
                #5; // Allow propagation
                
                // Verify output is valid (not all 1's which would be blank)
                if (seg === 7'b1111111) begin
                    $display("WARNING: num=%b produced blank display", num);
                end
                
                // Verify output is not undefined
                if (seg === 7'bx || seg === 7'bz) begin
                    $display("ERROR: num=%b produced undefined output %b", num, seg);
                    errors = errors + 1;
                end
            end
            
            // Test edge cases
            $display("Testing edge cases...");
            
            // Test invalid inputs (should be handled by default case)
            num = 4'bxxxx;
            #5;
            if (seg !== 7'b1111111) begin
                $display("ERROR: Invalid input should produce blank display, got %b", seg);
                errors = errors + 1;
            end
            
            num = 4'bzzzz;
            #5;
            if (seg !== 7'b1111111) begin
                $display("ERROR: High-Z input should produce blank display, got %b", seg);
                errors = errors + 1;
            end
            
            $display("Comprehensive testing completed: %d total errors", errors);
            $finish;
        end
    end

    // Timeout protection
    always begin
        if (!test_complete) begin
            timeout_counter = timeout_counter + 1;
            if (timeout_counter > 10000) begin // 50us timeout
                $display("ERROR: Test timeout - simulation may be stuck");
                $finish;
            end
        end
        #5;
    end

endmodule
