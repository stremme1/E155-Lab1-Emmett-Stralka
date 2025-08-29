module Lab1_ES (
    input  logic        clk,    // 12 MHz onboard oscillator (HSOSC)
    input  logic [3:0]  s,      // DIP switches
    output logic [6:0]  seg,    // 7-segment display segments (A-G)
    output logic [2:0]  led     // 3 LEDs
);

    // --- Seven-segment display decoder ---
    seven_segment u7seg (
        .num(s),   // Display the hex digit from switches
        .seg(seg)
    );

    // --- LEDs based on switch logic ---
    // LED[0]: XOR of S1 and S0
    assign led[0] = s[1] ^ s[0];

    // LED[1]: AND of S3 and S2
    assign led[1] = s[3] & s[2];

    // --- LED[2]: Blink at 2.4 Hz ---
    // Calculate half period for 12 MHz input clock:
    // HALF_PERIOD = (12_000_000 / 2) / 2.4 Hz ≈ 2_500_000 cycles
    localparam int HALF_PERIOD = 2_500_000;

    logic [23:0] divcnt = 0;    // 24-bit counter for clock division
    logic        blink_state = 0;

    always_ff @(posedge clk) begin
        if (divcnt == HALF_PERIOD - 1) begin
            divcnt      <= 0;
            blink_state <= ~blink_state; // toggle LED
        end else begin
            divcnt <= divcnt + 1;
        end
    end

    assign led[2] = blink_state;

endmodule
