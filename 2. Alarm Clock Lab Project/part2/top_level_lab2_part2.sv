// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module lab2_part2_top_level(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
        Dayadv,
		Alarmon,
		Pulse,		  // assume 1/sec.			   
// 6 decimal digit display (7 segment)
  output[6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
               D0disp,
  output logic Buzz);	           // alarm sounds

// assigned by ct_mod
  logic[6:0] TSec, TMin, THrs, TDays,     // clock/time // reg clock
             AMin, AHrs;		   // alarm setting
  logic[6:0] Min, Hrs, Days;
  logic days5, days6;

  logic Szero, Mzero, Hzero, Dzero, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, TDen, AMen, AHen;  // alarm:time:enable   ---- these are the only things we touch.
  logic Buzz1;	                   // intermediate Buzz signal

/* fill in the guts ...
*/
  assign TMen = (Timeset && Minadv) ? 1 : Szero; // when timeset is 1 ; alarmset=0 ; regular clock=0
  assign THen = (Timeset && Hrsadv) ? 1 : Mzero && Szero;  
  assign TDen = (Timeset && Dayadv) ? 1 : Hzero && Mzero && Szero; // hours, minutes, and seconds must be maxed out for Days to rollover


  // alarms
  // when alarmset=1 ; regular clock = 1; set AMen to Minadv or 
  assign AMen = (Alarmset && Minadv) ? 1 : 0;//Szero; // else when alarmset reaches 59sec; increment min by 1, and reset seconds
  assign AHen = (Alarmset && Hrsadv) ? 1 : 0;//Mzero && Szero; 

  // setting display
  assign Min = (Timeset==0 && Alarmset==1) ? AMin : TMin; 
  assign Hrs = (Timeset==0 && Alarmset==1) ? AHrs : THrs; // ^^^ Timeset / else Alarmset / else regular clock

  always_comb begin 
    // bool variables used for checking days 5 and 6.
    days5 = 7'b0000101==TDays; //days5 == true when TDays=5.
    days6 = 7'b0000110==TDays;

    Days = TDays; // assigning regular display days to counter incremented regular time of TDays.
  end

// be sure to set parameters on ct_mod_N modules
// seconds counter runs continuously, but stalls when Timeset is on 
 ct_mod_N #(.N(60)) Sct(
    .clk(Pulse), .rst(Reset), .en(!Timeset), .ct_out(TSec), .z(Szero) 
    ); // enable = timeset??

// minutes counter -- runs at either 1/sec or 1/60sec -- once per ...
  ct_mod_N #(.N(60)) Mct(
    .clk(Pulse), .rst(Reset), .en(TMen), .ct_out(TMin), .z(Mzero) // .z is the action
    );
  

// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N #(.N(24)) Hct(
	.clk(Pulse), .rst(Reset), .en(THen), .ct_out(THrs), .z(Hzero)
    );

// days counter
ct_mod_N #(.N(7)) Dct(
	.clk(Pulse), .rst(Reset), .en(TDen), .ct_out(TDays), .z(Dzero)
    );

// alarm set registers -- either hold or advance 1/sec
  ct_mod_N #(.N(60)) Mreg(
    .clk(Pulse), .rst(Reset), .en(AMen), .ct_out(AMin), .z() // Minadv, because we want to advance 1/sec
    ); 


  ct_mod_N #(.N(24)) Hreg(
    .clk(Pulse), .rst(Reset), .en(AHen), .ct_out(AHrs), .z() // advance Hrsadv
    ); 

// display drivers (2 digits each, 6 digits total)
  lcd_int Sdisp(
    .bin_in (TSec)  ,
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

  lcd_int Mdisp(
    .bin_in (Min) ,
	.Segment1  (M1disp),
	.Segment0  (M0disp)
	);

  lcd_int Hdisp(
    .bin_in (Hrs),
	.Segment1  (H1disp),
	.Segment0  (H0disp)
	);

  // Display driver for days (of the week)
  lcd_int Ddisp(
    .bin_in (Days),
	.Segment1  (),
	.Segment0  (D0disp)
	);


// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .buzz(Buzz1)
	);

  // Fig. 2 : S5 is Alarmon ; extra condition before setting Buzz = 1; 
  always_comb begin 

    if (Alarmon==1 && !days5 && !days6) begin
      Buzz = Buzz1;
    end else begin
      Buzz = 0;
    end  
    
  end
  // when the alarm buzzes, we want to increment the Days.
  // Amin - alarm time
  // tmin - clock time

endmodule