// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module top_level_lab2_part1(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
		Alarmon,
		Pulse,		  // assume 1/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
  output logic Buzz);	           // alarm sounds

  // assigned by ct_mod
  logic[6:0] TSec, TMin, THrs,     // clock/time // reg clock
             AMin, AHrs;		   // alarm setting
  logic[6:0] Min, Hrs;        // display of clock time


  logic Szero, Mzero, Hzero, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, AMen, AHen;     // alarm:time:enable   
  logic Buzz1;	                   // intermediate Buzz signal


  // m_wakeup is Amin (LHS is A-time)
  // m_display is Tmin (RHS is T-time)
  // Amin, AHrs - alarm time 
  // Tmin, THrs - clock time 
  
  // timeset enable
  assign TMen = (Timeset && Minadv) ? 1 : Szero; // when timeset is 1 ; alarmset=0 ; regular clock=0
  // we want seconds to also be maxed out for rollover (00:59:59) before we actually go to (01:00:00) 
  assign THen = (Timeset && Hrsadv) ? 1 : Mzero && Szero;  

  // alarm enables
  // when alarmset=1 ; regular clock = 1; set alarm enabled, else disabled
  assign AMen = (Alarmset && Minadv) ? 1 : 0; // else when alarmset reaches 59sec; increment min by 1, and reset seconds
  assign AHen = (Alarmset && Hrsadv) ? 1 : 0;

  
  // alarmset // when Alarmset on : replace display clk time w/ alarm clk time
  assign Min = (Timeset==0 && Alarmset==1) ? AMin : TMin; 
  assign Hrs = (Timeset==0 && Alarmset==1) ? AHrs : THrs; 


// be sure to set parameters on ct_mod_N modules
// seconds counter runs continuously, but stalls when Timeset is on 
 ct_mod_N #(.N(60)) Sct(
    .clk(Pulse), .rst(Reset), .en(!Timeset), .ct_out(TSec), .z(Szero) 
    ); 

// minutes counter -- runs at either 1/sec or 1/60sec -- once per ...
  ct_mod_N #(.N(60)) Mct(
    .clk(Pulse), .rst(Reset), .en(TMen), .ct_out(TMin), .z(Mzero) // .z is the action
    );
  

// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N #(.N(24)) Hct(
	.clk(Pulse), .rst(Reset), .en(THen), .ct_out(THrs), .z(Hzero)
    );


// alarm set registers -- either hold or advance 1/sec
  ct_mod_N #(.N(60)) Mreg(
    .clk(Pulse), .rst(Reset), .en(AMen), .ct_out(AMin), .z() // Minadv, because we want to advance 1/sec
    ); 


  ct_mod_N #(.N(24)) Hreg(
    .clk(Pulse), .rst(Reset), .en(AHen), .ct_out(AHrs), .z() // advance Hrsadv
    ); 

// display drivers (2 digits each, 6 digits total)
  // Seconds display driver
  lcd_int Sdisp(
    .bin_in (TSec)  ,
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

  // Minutes display driver
  lcd_int Mdisp(
    .bin_in (Min) ,
	.Segment1  (M1disp),
	.Segment0  (M0disp)
	);

  // Hours display driver
  lcd_int Hdisp(
    .bin_in (Hrs),
	.Segment1  (H1disp),
	.Segment0  (H0disp)
	);


// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .buzz(Buzz1)
	);

  // Fig. 2 : S5 is Alarmon ; extra condition before setting Buzz = 1; 
  always_comb begin 
    // when alarm is on
    if (Alarmon==1) begin
      Buzz = Buzz1; // buzzer is on
    end else begin
      Buzz = 0;     // else buzzer off
    end  
  end

endmodule