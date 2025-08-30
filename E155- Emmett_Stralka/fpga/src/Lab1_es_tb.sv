`timescale 1ns/1ps

module Lab1_es_tb;

  // DUT inputs
  logic clk;
  logic [3:0] s;

  // DUT outputs
  logic [6:0] seg;
  logic [2:0] led;

  // Expected values from test vectors
  logic [3:0] s_exp;
  logic [1:0] led_exp;
  logic [6:0] seg_exp;

  // For bookkeeping
  integer vectornum, errors;
  logic [17:0] testvectors [0:15]; // 4 + 2 + 7 = 13 bits per vector, store as 18 bits for alignment

  // Instantiate DUT
  Lab1_es dut (
    .clk(clk),
    .s(s),
    .seg(seg),
    .led(led)
  );

  // Generate a 12 MHz clock (period ~83 ns, approximated for sim)
  initial clk = 0;
  always #41 clk = ~clk;

  // Load test vectors
  initial begin
    $readmemb("lab1.tv", testvectors);
    vectornum = 0;
    errors = 0;
  end

  // Apply test vectors on clock rising edge
  always @(posedge clk) begin
    {s_exp, led_exp, seg_exp} = testvectors[vectornum];
    s = s_exp;
  end

  // Check results on clock falling edge
  always @(negedge clk) begin
    if ((led[1:0] !== led_exp) || (seg !== seg_exp)) begin
      $display("ERROR @ vector %0d: s=%b | led=%b (exp %b) seg=%b (exp %b)",
               vectornum, s, led[1:0], led_exp, seg, seg_exp);
      errors++;
    end
    vectornum++;
    if (vectornum == 16) begin
      $display("Simulation complete: %0d tests, %0d errors", vectornum, errors);
      $finish;
    end
  end

endmodule
