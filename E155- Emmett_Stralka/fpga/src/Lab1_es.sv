// Emmett Stralka estralka@hmc.edu
// 08/29/25
// Lab1: Initializes dependencies for seven_segment and handles 3 LED operations

module Lab1_es(
     input logic reset, 
	 input logic [3:0]s,
     output logic [2:0]led, 
	 output logic [6:0]seg);

	seven_segment d(s, seg); // 7 segment display (combinational logic) 
   
   //LED assignment:
	assign led[0] = s[1]^s[0];   //XOR of S1 and S0
	assign led[1] = s[2] & s[3]; //AND of S3 and S2
	//LED[2]: Blink at 2.4Hz
   logic int_osc;
   logic [23:0] counter; //initializing counter
  
   // Internal high-speed oscillator
   HSOSC #(.CLKHF_DIV(2'b01)) 
         hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
  
   // Counter
   always_ff @(posedge int_osc, negedge reset) begin
     if(reset == 0) begin
		 counter <= 0;
		 led[2] <= 0;
	 end else begin           
		 if(counter == 23'd4_999_999)begin  //5M cycles to flip the LED
			 counter <= 0;
			 led[2] <= ~led[2]; //flip the LED
		 end else begin
			counter <= counter + 1;
		 end
		 end
     end 

  
endmodule
