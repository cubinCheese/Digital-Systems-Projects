// CSE140L  
// What does this do? 
// When does "z" go high? 
module ct_mod_N #(parameter N=60)(
  input clk, rst, en,
  output logic[6:0] ct_out,
  output logic      z);

  always_ff @(posedge clk)
    if(rst)
	  ct_out <= 0;
	else if(en)
	  ct_out <= (ct_out+'b1)%N;	  // modulo operator
  always_comb z = ct_out==(N-'b1);   // always @(*)   // always @(ct_out)
  // z becomes 1 when mod -- 00:59 --> 01:00
endmodule



