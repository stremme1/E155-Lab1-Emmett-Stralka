// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Lab1 top-level: instantiates seven_segment decoder and LED logic

module Lab1_ES (
    input  logic [3:0]  s,      // DIP switches
    output logic [6:0]  seg,    // 7-seg display (A–G)
    output logic [2:0]  led     // 3 LEDs
);

    // --- Onboard oscillator (12 MHz) ---
    logic clk;
    HSOSC #(
        .CLKHF_DIV("0b10")   // Divide by 4 → 12 MHz (default setting)
    ) osc_inst (
        .CLKHFPU(1'b1),      // Power up
        .CLKHFEN(1'b1),      // Enable
        .CLKHF(clk)          // Output clock
    );

    // --- Seven-segment display decoder ---
    seven_segment d (
        .num(s),   // hex digit from switches
        .seg(seg)  // 7-seg outputs
    );

    // --- LEDs based on switch logic ---
    assign led[0] = s[1] ^ s[0];  // XOR of S1 and S0
    assign led[1] = s[3] & s[2];  // AND of S3 and S2

    // --- LED[2]: Blink at 2.4 Hz ---
    // Half period = 12 MHz / (2 * 2.4 Hz) ≈ 2,500,000 cycles
    localparam int HALF_PERIOD = 2_500_000;
    logic [22:0] divcnt = 0;
    logic        blink_state = 0;

    always_ff @(posedge clk) begin
        if (divcnt == HALF_PERIOD - 1) begin
            divcnt      <= 0;
            blink_state <= ~blink_state;
        end else begin
            divcnt <= divcnt + 1;
        end
    end

    assign led[2] = blink_state;

endmodule
