module sevenseg_ca (
    input  logic [3:0] num,     
    output logic [6:0] seg 
);

// 0 = 
// 1 = B,C
// 2 = A,B,G,E,D
// 3 = A,B,C,G,D
// 4 = B,C,F,G
// 5 = A,C,D,F,G
// 6 = C,D,E,F,G
// 7 = A,B,C
// 8 = A,B,C,D,E,F,G
// 9 = A,B,C,D,F,G

    always_comb begin
        unique case (num)
            4'd0: seg = 7'b1000000; // A,B,C,D,E,F ON; G OFF
            4'd1: seg = 7'b1111001; // B,C ON
            4'd2: seg = 7'b0100100; // A,B,G,E,D
            4'd3: seg = 7'b0110000; // A,B,C,G,D
            4'd4: seg = 7'b0011001; // B,C,F,G
            4'd5: seg = 7'b0010010; // A,C,D,F,G
            4'd6: seg = 7'b0000010; // A,C,D,E,F,G
            4'd7: seg = 7'b1111000; // A,B,C
            4'd8: seg = 7'b0000000; // all on
            4'd9: seg = 7'b0010000; // A,B,C,D,F,G
            default: seg = 7'b1111111; // blank (all OFF)
        endcase
    end
endmodule