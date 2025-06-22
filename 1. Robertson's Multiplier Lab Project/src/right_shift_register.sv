// Right shift register with an arithmetic or logical shift mode
module right_shift_register #(parameter WIDTH = 16)(
    input                    clk,
    input                    enable,
    input signed [WIDTH-1:0] in, // input to shift
    input                    mode, // arithmetic (0) or logical (1) shift
    output logic [WIDTH-1:0] out); // shifted input

	
	always @(posedge clk) begin
// fill in the guts	-- holds or shifts by 1 bit position
// this is a sequential operation, requiring nonblocking (<=) assignments
// if(...) out <= ...;
// else if(...) out <= ...;
//    enable   mode      out  
//    0       0         hold (no change in output)
//		0       1	        hold
//		1       1	        load and logical right shift      (append 0 on left, shift right, drop RHS LSB)
//		1		    0	        load and arithmetic right shift   (copy MSB ; append it on left, shift right, drop RHS LSB)

  // is an additionall if-else needed for out = hold? how do i call this?
  // verilog doesn't read 'in>>>' with signed bits, we have to explicitly decleare for 'in'
  if(enable==1 && mode==1) out <= in>>1; // >> for binary logical shift
  else if(enable==1 && mode==0) out <= in>>>1; // >>> for binary arithmetic shift

  end

/* logical right shift fills in 0s from the left
  logic[3:0] a, b;
  assign a = 4'b1000;	// = +8 decimal
  assign b = a>>1;      // b = 4'b0100  = +4 decimal
// arithmetic right shift preserves MSB (sign bit of a two's comp. number) 
// note input and output have to be declared type signed (two's comp)
  logic signed[3:0] a, b;
  assign a = 4'b1000;   // = -8 decimal
  assign b = a>>>1;     // b = 4'b1100 = -4 decimal
// alternative: use concatenation operator {}
  logic[3:0] a, b;
  assign a = 4'b1000;   // = +8 decimal
  assign b = {1'b0,a[3:1]}; // b = 4'b0100 = +4 decimal
  assign b = {a[3],a[3:1]}; // b = 4'b1100 = +12 decimal (or -4 decimal if two's comp.)
  Note that concat. forces the handling of the most significant bit, irrespective of signed or unsigned declaration of operands or outputs.
  It brute-force grabs the bits and manipulates them.
*/
endmodule
