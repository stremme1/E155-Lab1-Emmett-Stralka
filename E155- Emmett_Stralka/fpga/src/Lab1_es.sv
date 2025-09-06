// Emmett Stralka [estralka@hmc.edu]
// 09/03/25
// Lab2_ES: Two 7-segment displays multiplexed with LED sum output


module Lab2_ES (
    input  logic        reset,    
    input  logic [3:0]  s0,
    input  logic [3:0]  s1,      
    output logic [6:0]  seg,    // Multiplexed seven-segment signal
    output logic [4:0]  led,    // LEDs show sum of s0 + s1
    output logic        select0,
    output logic        select1  // Power multiplexing control (PNP transistor control)
);

    // Internal clock derived from high-speed oscillator
    logic clk;
    HSOSC #(.CLKHF_DIV(2'b01))
        hf_osc (
            .CLKHFPU(1'b1),
            .CLKHFEN(1'b1),
            .CLKHF(clk)
        );

    // Internal signals
    logic display_select;
    logic [23:0] divcnt;
    logic [4:0] sum;
    logic [6:0] seg0_internal, seg1_internal;

    // Seven-segment display decoders (assuming ports: num, seg)
    seven_segment seven_segment0 (
        .num(s0),
        .seg(seg0_internal)
    );

    seven_segment seven_segment1 (
        .num(s1),
        .seg(seg1_internal)
    );

    // 2-to-1 multiplexer for the segment output (ports: d0, d1, select, y)
    MUX2 signal_mux (
        .d0(seg0_internal),
        .d1(seg1_internal),
        .select(display_select),
        .y(seg)
    );

    // 5-bit adder to sum s0 and s1 (ports: s1, s2, sum)
    five_bit_adder adder(
        .s1(s0),
        .s2(s1),
        .sum(sum)
    );

    // Assign sum to LED output
    assign led = sum;

    // Clock divider for ~100Hz multiplexing signal (assuming 12 MHz clk)
    localparam int HALF_PERIOD = 60_000;

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            divcnt <= 0;
            display_select <= 0;
        end else if (divcnt == HALF_PERIOD - 1) begin
            divcnt <= 0;
            display_select <= ~display_select;
        end else begin
            divcnt <= divcnt + 1;
        end
    end

    // Power multiplexing controls (PNP transistor active high)
    assign select0 = display_select;
    assign select1 = ~display_select;

endmodule
