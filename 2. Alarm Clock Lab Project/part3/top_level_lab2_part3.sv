// CSE140L  
// see Structural Diagram in Lab2 Part 3 assignment writeup
// fill in missing connections and parameters
module top_level_lab2_part3(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
        Dayadv,
        Monthadv,
        Dateadv,
		Alarmon,
		Pulse,		  // assume 1/sec.
// 6 decimal digit display (7 segment)
  output[6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,     // hours display
               D0disp,             // day of week display
               Month1disp, Month0disp,     // 2-digit month display
               Date1disp, Date0disp,     // date display
  output logic Buzz);	           // alarm sounds

// assigned by ct_mod
  logic[6:0] TSec, TMin, THrs, TDays,     // clock/time 
             TDate, TMonth,     // Timeset for Day and Month
             AMin, AHrs;		   // alarm setting
  logic[6:0] Min, Hrs, Days,    
             Date, Month;
  logic days5, days6;

  logic Szero, Mzero, Hzero, Dzero, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        DateZero, MonthZero,
        TMen, THen, TDen, AMen, AHen,  // alarm:time:enable   ---- these are the only things we touch.
        TDateEn, TMonthEn; // Enable for Time: Date, Month
  logic Buzz1;	                   // intermediate Buzz signal

/* fill in the guts ...
*/
  // it should be noted that "Days" counter (carried over from part 2) has NOTHING to do with "day of month"
  // the "Days" counter is the "Days of the Week" -- resets every week (every 7 days) (0-6)
  // the "Date" functionality is the ACTUAL "Day of the month"
  // we are actually leaving out "seconds" from display, letting it run passively in background logic

  /* For Example.
  testing April has 30 days: '0430'  
   _        _   _    _    _   _    _   _  
  | | |_|   _| | |   _|  | | | |  | | | | 
  |_|   |   _| |_|  |_   |_| |_|  |_| |_|
  reads as : 
    (04)          (30)         (2)     (00)     (00)
    (Month-2bits) (Date-2b) ("Days"-1b) (Hrs-2b) (Min-2b)  : total of 9 bits.

  */ // we just want to add month/date to the already existing day/hrs/min
  

  assign TMen = (Timeset && Minadv) ? 1 : Szero; //sZero not working  // when timeset is 1 ; alarmset=0 ; regular clock=0
  // else when we reach 00:59:00 we want to increment seconds (00:59:59) before we actually go to (01:00:00) 
  assign THen = (Timeset && Hrsadv) ? 1 : Mzero && Szero;  // 1: Minadv and Hrsadv
  assign TDen = (Timeset && Dayadv) ? 1 : Hzero && Mzero && Szero;

  // date / month
  // minutes --60--> hours --24--> days --28/30/31--> months
  // month only advances when "Date" rollsover (with separate conditions 28/30/31)
  assign TMonthEn = (Timeset && Monthadv) ? 1 : DateZero && Hzero && Mzero && Szero;
  assign TDateEn = (Timeset && Dateadv) ? 1 : Hzero && Mzero && Szero;  // concern: when it hits dates 28/30/31
  // think. when does date advance?    when Hours/Minutes/Seconds are maxed out.
  // independent of "Day" of the week / same basis as "Day"
  
  // alarms
  // when alarmset=1 ; regular clock = 1; set AMen to Minadv or 
  assign AMen = (Alarmset && Minadv) ? 1 : 0;//Szero; // else when alarmset reaches 59sec; increment min by 1, and reset seconds
  assign AHen = (Alarmset && Hrsadv) ? 1 : 0;//Mzero && Szero; 


  // setting display
  assign Min = (Timeset==0 && Alarmset==1) ? AMin : TMin; 
  assign Hrs = (Timeset==0 && Alarmset==1) ? AHrs : THrs; // ^^^ Timeset / else Alarmset / else regular clock

  
  always_comb begin 
    days5 = 7'b0000101==TDays; //days5 == true when TDays=5.
    days6 = 7'b0000110==TDays;

    Days = TDays; // just like assignment of Min and Hrs -- regular clock

    // Date -- regular 
    Date = TDate;

    // Month -- regular
    Month = TMonth;
  end
  
  // we need the carrier of the date
  // assign maxDate = (TDate) ? (? 28 : 30) : 31; // maximum days of the particular month: 28/30/31

logic currMonth; // this is just TMonth -- what month it is

// to obtain the Date (max day of the month) (boundary of when we should cycle the counter)
// we need to provide the corresponding month // TMonth is the 1-12 month counter data.
ct_mod_D Date_ct( // we provide .TMo0
    .clk(Pulse), .rst(Reset), .en(TDateEn), .TMo0(TMonth), .ct_out(TDate), .z(DateZero) 
    ); // 28 days - Months 1 
    // 30 days - Months 3,5,8,10 
    // 31 days -- Months 2,4,6,7,9 (default case)

// mod 0 to 11, have to +1 before final display #
ct_mod_N #(.N(12)) Month_ct(
    .clk(Pulse), .rst(Reset), .en(TMonthEn), .ct_out(TMonth), .z(MonthZero) 
    ); // we should prov  ide the month enable // and recieve the month time
// month counter is also broken.


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
  /* seconds doesn't display, but testbench should take care of this part */
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

  lcd_int Ddisp(
    .bin_in (Days),
	.Segment1  (),
	.Segment0  (D0disp)
	);

  // display driver for Date
  lcd_int Datedisp(
    .bin_in (Date+1),
	.Segment1  (Date1disp),
	.Segment0  (Date0disp)
	);

  // display driver for Month
  lcd_int Monthdisp(
    .bin_in (Month+1),
	.Segment1  (Month1disp),
	.Segment0  (Month0disp)
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
