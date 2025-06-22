// CSE140L  
// What does this do? 
// When does "z" go high? 
module ct_mod_D(      // ct_mod_D is just called, without any "D" mod value. // instead we have TMo0
  input clk, rst, en,
  input[6:0] TMo0,    // input // should be the case value *below* (i.e. which # month it is -- to select 28/30/31)
                      // doesn't read Month 0 as the first, but rather Month 1. So, we have to modify the input at higher level call
  output logic[6:0] ct_out,
  output logic      z);

  always_ff @(posedge clk)
    if(rst)
	  ct_out <= 0;
	else if(en)
	  case(TMo0)
        1:        ct_out <= (ct_out+1)%28;  // Feb
        3,5,8,10: ct_out <= (ct_out+1)%30;
        default:  ct_out <= (ct_out+1)%31;
      endcase  	  

  always_comb case(TMo0)
    1:        z = ct_out==27;
    3,5,8,10: z = ct_out==29;
    default:  z = ct_out==30;
  endcase
endmodule

// call method of this function should be: 
/*
ct_mod_D Date_ct(
    .clk(Pulse), .rst(Reset), .en(), .TMo0(), .ct_out(), .z() 
    );
*/


