module sevenseg_ca (input  logic [3:0] num,
                    output logic [6:0] seg); 

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
            4'd0: seg = 7'b0000001; // 0 
            4'd1: seg = 7'b1001111; // 1
            4'd2: seg = 7'b0010010; // 2
            4'd3: seg = 7'b0000110; // 3
            4'd4: seg = 7'b1001100; // 4
            4'd5: seg = 7'b0100100; // 5
            4'd6: seg = 7'b0100000; // 6
            4'd7: seg = 7'b0001111; // 7 
            4'd8: seg = 7'b0000000; // 8
            4'd9: seg = 7'b0000100; // 9
            default: seg = 7'b1111111; // blank (all OFF)
        endcase
    end
endmodule