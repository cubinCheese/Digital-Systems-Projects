// 5:1 MULTIPLEXER	(combinational 5-way switch)
module mux5 (input        d0, d1, d2, d3, d4,
             input [2:0]  s, 
             output logic y);

always_comb begin   // always @(*)    // always @(d0, d1, d2, d3, d4, s);
// fill in guts
// when using always_comb, be sure to cover all cases & use =, not <=
// case(s)
//     0: y = ...;
//	 ...
//	 default: y = ...;  // shorthand for last N cases with same output
// endcase
//  s      y
//  0	  d0		s = 3'b000
//  1	  d1
//  2	  d2
//  3	  d3
//  4	  d4
//  5	   0
//  6	   0
//  7	   0	    s = 3'b111
case(s)

    0 : y = d0;		
    1 : y = d1;
    2 : y = d2;
    3 : y = d3;
    4 : y = d4; 
    5 : y = 0;  //equivalent to default : y = 0;
    6 : y = 0;
    7 : y = 0;  
    /*default: y = 0;*/

endcase

end
endmodule
