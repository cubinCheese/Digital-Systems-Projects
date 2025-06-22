// load and store register
// sequential NOT combinational
module register # (parameter N = 8)
   (input                clk,   // implied input wire
    input                load,
    input                clear,
    input        [N-1:0] in,
    output logic [N-1:0] out
    );
	 
  always_ff @ (posedge clk, posedge clear)    begin
// fill in guts
//  if(...) out <= ... ;          // use <= nonblocking assignment!
//  else if(...) out <= ... ;
//   clear   load    out
// 	   1       0      0	   (clear output)
//     1       1      0
//     0       0     hold  (no change in output)    // is this automatic????
//     0       1      in   (update output)

if(clear==1) out <= 0; // clear output
// else if(clear==0 && load==0) out <= hold; Do i need to explicitly write this??? 
else if(clear==0 && load==1) out <= in; // update output with 'in'
	
// Aside: What would be the impact of leaving posedge clear out of 
//  the sensitivity list? ----> We would never clear output, unintended outputs will display.
end	
		
endmodule

