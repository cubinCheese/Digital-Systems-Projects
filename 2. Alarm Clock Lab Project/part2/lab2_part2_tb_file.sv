// testbench for lab2 part 2 -- alarm clock
// days, hours, minutes, and seconds
`include "lab2_part2_display_tb_file.sv"
module lab2_part2_tb_file #(parameter NS = 60, NH = 24);
  logic Reset    = 1,
        Clk      = 0,
        Timeset  = 0,
        Alarmset = 0,
		Minadv   = 0,
		Hrsadv   = 0,
        Dayadv   = 0,
		Alarmon  = 1,
		Pulse = 0;

  wire[6:0] S1disp, S0disp,
            M1disp, M0disp,
            H1disp, H0disp, D0disp;
  wire Buzz;
  int h1;
  lab2_part2_top_level sd(.*);             // our DUT itself

  initial begin
    h1 = $fopen("list.txt");
//    $monitor("buzz = %b  at time %t",Buzz,$time);
	#  2us  Reset    = 0;
	#  1us  Timeset  = 1;
	        Minadv   = 1;
	# 58us  Minadv   = 0;
	        Hrsadv   = 1;
	#  7us  Hrsadv   = 0;
	        Dayadv   = 1;
	#  4us  Dayadv   = 0;
	        Timeset  = 0;
//	force (.sd.Min = 'h5);
//	release(.sd.Min);
    lab2_part2_display_tb_file (.h1(h1),.seg_j(D0disp),.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .Buzz(Buzz));
	$fdisplay(h1,"time should be set to (4=Friday)0758");
	#  1us  Alarmset = 1;
	        Hrsadv   = 1;
	#  8us  Hrsadv   = 0;
	#  1us  Minadv   = 1;
	#  5us  Minadv   = 0;
	#  1us  Alarmset = 0;
    lab2_part2_display_tb_file (.h1(h1),.seg_j(D0disp),.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp), .Buzz(Buzz));
	$fdisplay(h1,"alarm should be set to 0805");
    for(int i=0; i<440; i++) 
	# 1us  lab2_part2_display_tb_file (.h1(h1),.seg_j(D0disp),.seg_d(H1disp),
    .seg_e(H0disp), .seg_f(M1disp),
    .seg_g(M0disp), .seg_h(S1disp),
    .seg_i(S0disp),.Buzz(Buzz));
	repeat(23) #3600us; // 23 * 1 hour delay
    #3200us;
   $fdisplay(h1,"(5=Saturday) Day increase successfully by hours reaching 24");
    for(int i=0; i<440; i++)
	#1us lab2_part2_display_tb_file (.h1(h1),.seg_j(D0disp),.seg_d(H1disp),
      .seg_e(H0disp), .seg_f(M1disp),
      .seg_g(M0disp), .seg_h(S1disp),
      .seg_i(S0disp), .Buzz(Buzz));
    repeat(23) #3600us; // 24hours
    #3200us;
	lab2_part2_display_tb_file (.h1(h1),.seg_j(D0disp),.seg_d(H1disp),
      .seg_e(H0disp), .seg_f(M1disp),
      .seg_g(M0disp), .seg_h(S1disp),
      .seg_i(S0disp), .Buzz(Buzz));
//    repeat(23) #3600us; //24hours
//    #3200us;
    $fdisplay(h1,"Buzz on Friday(4), but not on Sat and Sun (5,6), Buzz again on Mon 0.");
	lab2_part2_display_tb_file (.h1(h1),.seg_j(D0disp),.seg_d(H1disp),
      .seg_e(H0disp), .seg_f(M1disp),
      .seg_g(M0disp), .seg_h(S1disp),
      .seg_i(S0disp), .Buzz(Buzz));
    for(int i=0; i<440; i++)
	#1us lab2_part2_display_tb_file (.h1(h1),.seg_j(D0disp),.seg_d(H1disp),
      .seg_e(H0disp), .seg_f(M1disp),
      .seg_g(M0disp), .seg_h(S1disp),
      .seg_i(S0disp), .Buzz(Buzz));
    repeat(23) #3600us; // 24hours
    #3200us;
    for(int i=0; i<440; i++)
	#1us lab2_part2_display_tb_file (.h1(h1),.seg_j(D0disp),.seg_d(H1disp),
      .seg_e(H0disp), .seg_f(M1disp),
      .seg_g(M0disp), .seg_h(S1disp),
      .seg_i(S0disp), .Buzz(Buzz));
  	#3500us  $stop;
  end 
  always begin
    #500ns Pulse = 1;
	#500ns Pulse = 0;
  end

endmodule