// traffic light controller solution stretch
// CSE140L 3-street, 20-state version, ew str/left decouple
// inserts all-red after each yellow
// uses enumerated variables for states and for red-yellow-green
// 5 after traffic, 10 max cycles for green when other traffic present
import light_package ::*;           // defines red, yellow, green

// same as Harris & Harris 4-state, but we have added two all-reds
module traffic_light_controller2(
	input clk, reset, e_str_sensor, w_str_sensor, e_left_sensor, 
		w_left_sensor, ns_sensor,             // traffic sensors, east-west str, east-west left, north-south 
	output colors e_str_light, w_str_light, e_left_light, w_left_light, ns_light);     // traffic lights, east-west str, east-west left, north-south

	logic s, sb, e, eb, w, wb, l, lb, n, nb;	 // shorthand for traffic combinations:

	// assigning sets of sensors to cardinal directions, left-turn only traffic,
	// and a matching variable to trace conflicting traffic.

	assign s  = e_str_sensor || w_str_sensor;					 	// assign straight s to E or W straight
	assign sb = e_left_sensor || w_left_sensor || ns_sensor;		// 3 directions which conflict with s
	/* fill in the remaining definitions -- given in lab3.docx instructions Part 2   */    

	assign e = e_left_sensor || e_str_sensor; 				// E_str or E_left -- still going east
	assign eb = w_left_sensor || w_str_sensor|| ns_sensor; 	// assign conflicts to eastward traffic

	assign w = w_left_sensor || w_str_sensor; 				// going west - western left or wester straight
	assign wb = ns_sensor || e_left_sensor || e_str_sensor; // assign conflicts to westward traffic

	assign n = ns_sensor;										// north/south - going north (or south).
	assign nb = e_left_sensor || w_left_sensor || e_str_sensor || w_str_sensor; // assign conflicts to northward traffic

	assign l = e_left_sensor || w_left_sensor; 			   // east_left or west_left -- is going left
	assign lb = ns_sensor || e_str_sensor || w_str_sensor; // conflicts: NS is the only conflict to both E & W left turns


	// 20 suggested states, 4 per direction   Y, Z = easy way to get 2-second yellows
	// HRRRR = red-red following ZRRRR; ZRRRR = second yellow following YRRRR; 
	// RRRRH = red-red following RRRRZ;
	/* EXAMPLE
	HRRRR ==> (ES/WS, ES/EL, WS/WL, EL/WL, NS)	*/
	
	typedef enum {GRRRR, YRRRR, ZRRRR, HRRRR, 	           // ES+WS
				RGRRR, RYRRR, RZRRR, RHRRR, 			   // EL+ES
				RRGRR, RRYRR, RRZRR, RRHRR,				   // WL+WS
				RRRGR, RRRYR, RRRZR, RRRHR, 			   // WL+EL
				RRRRG, RRRRY, RRRRZ, RRRRH} tlc_states;    // NS
	tlc_states    present_state, next_state;
	integer ctr5, next_ctr5,       //  5 sec timeout when my traffic goes away
			ctr10, next_ctr10;     // 10 sec limit when other traffic presents

	// sequential part of our state machine (register between C1 and C2 in Harris & Harris Moore machine diagram
	// combinational part will reset or increment the counters and figure out the next_state
	always_ff @(posedge clk)
	if(reset) begin
		present_state <= RRRRH;
		ctr5          <= 0;
		ctr10         <= 0;
	end  
	else begin
		present_state <= next_state;
		ctr5          <= next_ctr5;
		ctr10         <= next_ctr10;
	end  

	// combinational part of state machine ("C1" block in the Harris & Harris Moore machine diagram)
	// default needed because only 6 of 8 possible states are defined/used
	always_comb begin
	next_state = RRRRH;                            // default to reset state
	next_ctr5  = 0; 							   // default: reset counters
	next_ctr10 = 0;
	case(present_state)
	/* ************* Fill in the case statements ************** */
	// Each section defines subsequent state transition logic for the particular present state.

	// Section 1: GRRRR, YRRRR, ZRRRR, HRRRR

		GRRRR: begin                                // ES+WS green 
		if (ctr10 > 8)   					   		// timeout if others want a turn
			next_state = YRRRR;
		else if (ctr5 > 3) begin				    // timeout if my traffic goes away
			next_state = YRRRR;
		end 
		else 								   		// otherwise stay green
			next_state = GRRRR;
		if (!s || ctr5>0) begin		                // vacant countdown // if (no straight traffic || ctr5 below 0) : begin/inc counter
			next_ctr5  = ctr5+1;
		end
		if ((s && sb) || ctr10>0) begin				// if (straight traffic & conflicting traffic waiting) || ctr10>0 then increase counter
			next_ctr10 = ctr10+1;					// occupied countdown
		end
		end
		YRRRR: next_state = ZRRRR;					// first yellow state of EW_str to second
		ZRRRR: next_state = HRRRR;					// second yellow state of EW_str to all red state
	// fill in
	//
		HRRRR: begin                            ///**/ **fill in the blanks in the if ... else if ... chain
		if  (e == 1)							// Priority 1: east traffic, if present.	
			next_state = RGRRR;	                	// ES+EL green	 
		else if (w==1) begin 					// Priority 2: west traffic
			next_state = RRGRR;						// WS+WL green    
		end
		else if (l==1) begin 					// Priority 3: EW left-turn traffic
			next_state = RRRGR;						// WL+EL green
		end
		else if (n==1) begin 					// Priority 4: northern traffic
			next_state = RRRRG;						// NS green
		end
		else if (s==1) begin					// Priority 5: EW straight traffic
			next_state = GRRRR;						// EW_S green
		end
		else									// else: repeat current state
			next_state = HRRRR;	   				// all red state, w/ EW_str as previous yellow
		end

	// Section 2: RGRRR, RYRRR, RZRRR, RHRRR

		//(ES/WS, ES/EL, WS/WL, EL/WL, NS)
		RGRRR: begin 		                   // Present state: Green on ES+EL        
		if (ctr10 > 8)   					   // Next states: Yellow on ES+EL after some time on green
			next_state = RYRRR;					
		else if (ctr5 > 3) begin				 
			next_state = RYRRR;
		end 
		else 								   // if timer limit for green light not reached: stay green
			next_state = RGRRR;
		if (!e || ctr5>0) begin		           		// vacant countdown
			next_ctr5  = ctr5+1;
		end
		if ((e && eb) || ctr10>0) begin
			next_ctr10 = ctr10+1;			   		// occupied countdown
		end
		end
		RYRRR: next_state = RZRRR;				// yellow1 to yellow2 state of ES+EL
		RZRRR: next_state = RHRRR;				// yellow2 to all red state of ES+EL
		RHRRR: begin                                 
		if  (w == 1)	
			next_state = RRGRR;					// Priority coming off of all Reds with last yellow on ES+EL:                   
		else if (l==1) begin 							// w,l,n,s,e   
			next_state = RRRGR;							 
		end
		else if (n==1) begin 
			next_state = RRRRG;							 
		end
		else if (s==1) begin 
			next_state = GRRRR;							 
		end
		else if (e==1) begin 
			next_state = RGRRR;
		end
		else									// else return to current state RHRRR
			next_state = RHRRR;	   
		end


	// Section 3: RRGRR, RRYRR, RRZRR, RRHRR

		RRGRR: begin 		                    // WS + WL green
		if (ctr10 > 8)   					   			// timeout if others want a turn
			next_state = RRYRR;
		else if (ctr5 > 3) begin				   		// timeout if my traffic goes away
			next_state = RRYRR;
		end 
		else 								   	// otherwise stay green
			next_state = RRGRR;
		if (!w || ctr5>0) begin		                    // vacant countdown
			next_ctr5  = ctr5+1;
		end
		if ((w && wb) || ctr10>0) begin
			next_ctr10 = ctr10+1;					   // occupied countdown
		end
		end
		// ** fill in the guts to complete 5 sets of R Y Z H progressions **
		RRYRR: next_state = RRZRR;			
		RRZRR: next_state = RRHRR;
		RRHRR: begin                                 
		if  (l == 1)					// Priority coming off of all Reds with last yellow on WS+WL:
			next_state = RRRGR;	        	// l,n,s,e,w       
		else if (n==1) begin 
			next_state = RRRRG;							 
		end
		else if (s==1) begin 
			next_state = GRRRR;							 
		end
		else if (e==1) begin 
			next_state = RGRRR;							 
		end
		else if (w==1) begin 
			next_state = RRGRR; 
		end
		else							// otherwise, repeat current state RRHRR.
			next_state = RRHRR;	   
		end 
		

	// Section 4: RRRGR, RRRYR, RRRZR, RRRHR

		RRRGR: begin 		                   // WL + EL GREEN
		if (ctr10 > 8)   					   		// timeout if others want a turn
			next_state = RRRYR;
		else if (ctr5 > 3) begin			   		// timeout if my traffic goes away
			next_state = RRRYR;
		end 
		else 								   // otherwise stay green
			next_state = RRRGR;
		if (!l || ctr5>0) begin		           		// vacant countdown
			next_ctr5  = ctr5+1;
		end
		if ((l && lb) || ctr10>0) begin
			next_ctr10 = ctr10+1;			  		// occupied countdown
		end
		end
		RRRYR: next_state = RRRZR;
		RRRZR: next_state = RRRHR;
		RRRHR: begin                                  
		if  (n == 1)				// Priority coming off of all Reds with last yellow on WL+EL:
			next_state = RRRRG;	    	// n,s,e,w,l                    
		else if (s==1) begin 
			next_state = GRRRR;							 
		end
		else if (e==1) begin 
			next_state = RGRRR;							 
		end
		else if (w==1) begin 
			next_state = RRGRR;							 
		end
		else if (l==1) begin 
			next_state = RRRGR;
		end
		else
			next_state = RRRHR;	   
		end

	// Section 5: RRRRG, RRRRY, RRRRZ, RRRRH

		RRRRG: begin 		                    // NS GREEN
		if (ctr10 > 8)   					    	// timeout if others want a turn 
			next_state = RRRRY;
		else if (ctr5 > 3) begin					// timeout if my traffic goes away
			next_state = RRRRY;
		end 
		else 								   	// otherwise stay green
			next_state = RRRRG;
		if (!n || ctr5>0) begin		            	// vacant countdown
			next_ctr5  = ctr5+1;
		end
		if ((n && nb) || ctr10>0) begin
			next_ctr10 = ctr10+1;					// occupied countdown
		end
		end
		RRRRY: next_state = RRRRZ;				// yellow1 to yellow2 of NS 
		RRRRZ: next_state = RRRRH;				// yellow2 to all red state of NS
		RRRRH: begin                                
		if  (s == 1)				// Priority coming off of all Reds with last yellow on NS:
			next_state = GRRRR;	           // s,e,w,l,n
		else if (e==1) begin 
			next_state = RGRRR;							 
		end
		else if (w==1) begin 
			next_state = RRGRR;							 
		end
		else if (l==1) begin 
			next_state = RRRGR;							 
		end
		else if (n==1) begin 
			next_state = RRRRG;
		end
		else						// else repeat present state RRRRH
			next_state = RRRRH;	   
		end


	endcase
  end

// combination output driver  ("C2" block in the Harris & Harris Moore machine diagram)
	always_comb begin
	  e_str_light  = red;                // cover all red plus undefined cases
	  w_str_light  = red;				 // no need to list them below this block
	  e_left_light = red;
	  w_left_light = red;
	  ns_light     = red;
	  case(present_state)      // Moore machine
		GRRRR:   begin e_str_light = green;
					   w_str_light = green;
		end
		YRRRR,ZRRRR: begin e_str_light = yellow; w_str_light = yellow; end
		RGRRR: 		 begin e_str_light = green; e_left_light = green; end
		RYRRR,RZRRR: begin e_str_light = yellow; e_left_light = yellow; end
		RRGRR:		 begin w_str_light = green; w_left_light = green; end
		RRYRR,RRZRR: begin w_str_light = yellow; w_left_light = yellow; end
		RRRGR:		 begin e_left_light = green; w_left_light = green; end
		RRRYR,RRRZR: begin e_left_light = yellow; w_left_light = yellow; end
		RRRRG: 			begin ns_light = green; end
		RRRRY,RRRRZ: 	begin ns_light = yellow; end
      endcase
      // ** fill in the guts for all 5 directions -- just the greens and yellows **
	  // Here, just like part1 C2. We have to define which state transitions have which type of lights.
	end


endmodule