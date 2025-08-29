module Lab1_ES (
    input  logic        clk,    // 48 MHz oscillator
    input  logic [3:0]  s,      // switches
    output logic [6:0]  seg,    // 7-seg display
    output logic [2:0]  led     // 3 LEDs
);

    // Instantiate seven-seg decoder
    sevensegment u7seg (
        .num (s),   // display hex digit from switches
        .seg (seg)
    );

    // LED[0]: XOR of S1 and S0
    assign led[0] = s[1] ^ s[0];

    // LED[1]: AND of S3 and S2
    assign led[1] = s[3] & s[2];

    // LED[2]: Blink at 2.4 Hz
    localparam int HALF_PERIOD = 10_000_000; // toggle interval (48 MHz / 10e6 = 2.4 Hz)

    logic [23:0] divcnt = 0;    // clock divider
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
