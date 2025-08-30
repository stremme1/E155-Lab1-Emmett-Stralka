// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Lab1 inits dependencies seven_segment and handles 3 Led operations


module Lab1_es (
    input  logic        clk,    
    input  logic [3:0]  s,      
    output logic [6:0]  seg,    
    output logic [2:0]  led     
);

    // --- Seven-segment display decoder ---
    seven_segment d (
        s,   // connects to num
        seg  // connects to seg output
    );

    // --- LEDs based on switch logic ---
    assign led[0] = s[1] ^ s[0];  // XOR of S1 and S0
    assign led[1] = s[3] & s[2];  // AND of S3 and S2

    // --- LED[2]: Blink at 2.4 Hz ---
    localparam int HALF_PERIOD = 2_500_000; // for 12 MHz input clock
    logic [23:0] divcnt = 0;
    logic        blink_state = 0;

    always_ff @(posedge clk) begin
        if (divcnt == HALF_PERIOD - 1) begin
            divcnt <= 0;
            blink_state <= ~blink_state; // toggle LED
        end else begin
            divcnt <= divcnt + 1;
        end
    end

    assign led[2] = blink_state;

endmodule
