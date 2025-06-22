// N-bit Adder/Subtractor (active low subtract)
// CSE140L     lab 1
// combinational logic
module addsub #(parameter dw=8)		 // dw = data width
(
  input        [dw-1:0] dataa,
  input        [dw-1:0] datab,
  input                 add_sub,	 // if this is 1, add; else subtract
  output logic [dw-1:0] result
);

// fill in guts  (instructions)
// combinational logic, use blocking (=) assignment      
//add_sub       result  //
//1             dataa + datab;						
//0             dataa - datab;   

// fill in guts (my) 
  always_comb begin
    if (add_sub == 1)
      // add
      result = dataa + datab; // logic - full adder
    else
      // sub
      result = dataa - datab; // logic - ?

  end

endmodule
