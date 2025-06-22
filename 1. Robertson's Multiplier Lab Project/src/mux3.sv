// 3:1 mux    
// CSE140L	  
module mux3 #(parameter WIDTH = 8)
  (input       [WIDTH-1:0] d0, d1, d2,
   input       [1:0]       s, 	// s[1] s[0]
   output logic[WIDTH-1:0] y);

// fill in guts (combinational -- assign or always_comb, use =)
//  s[1]  s[0]  y
//  0     0    d0
//  0     1	   d1
//  1     0    d2
//  1     1	   d2

always_comb case(s) // syntax????

  // 0,1,2,3 -- translates into binary
  // have to use 2'b01 format if wanted to use binary for if...
  0 : y = d0; // when s[1]=0 and s[0]=0 ...
  1 : y = d1; 
  2 : y = d2;  
  3 : y = d2;

endcase


endmodule