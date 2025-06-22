// 2:1 mux (selector) of N-wide buses
// CSE140L
module mux2 #(parameter WIDTH = 8)
 (input        [WIDTH-1:0] d0, d1, // input
  input                    s, // selector
  output logic [WIDTH-1:0] y); // output
// fill in guts
// combinational (unclocked) logic -- use =, not <=
// always_comb if(...) y = ...;
// s   y
// 0   d0	y[7:0] = d0[7:0]       // y and d(#) have 8 bits as assigned above.
// 1   d1	y[7:0] = d1[7:0]

always_comb case(s)

  0 : y = d0; // when s=0 ; y =d0
  1 : y = d1;

endcase


/* above is equivalent to below?
always_comb begin

  if(s==0)
    y = d0; 
  else if (s==1)
    y = d1;

endcase
*/

endmodule


