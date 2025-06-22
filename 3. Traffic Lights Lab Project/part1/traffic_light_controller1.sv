// traffic light controller
// CSE140L 3-street, 12-state version
// inserts all-red after each yellow
// uses enumerated variables for states and for red-yellow-green
// 5 after traffic, 10 max cycles for green after conflict
// starter (shell) -- you need to complete the always_comb logic
import light_package ::*;           // defines red, yellow, green

// same as Harris & Harris 4-state, but we have added two all-reds
module traffic_light_controller1(
  input         clk, reset, 
                ew_str_sensor, ew_left_sensor, ns_sensor,  // traffic sensors, east-west straight, east-west left, north-south 
  output colors ew_str_light, ew_left_light, ns_light);    // traffic lights, east-west straight, east-west left, north-south

// HRR = red-red following YRR; RRH = red-red following RRY;
// ZRR = 2nd cycle yellow, follows YRR, etc. 
  typedef enum {GRR, YRR, ZRR, HRR, RGR, RYR, RZR, RHR, RRG, RRY, RRZ, RRH} tlc_states;  // EW green, EW LEFT red, NS red
  tlc_states    present_state, next_state;
  integer ctr5, next_ctr5,       //  5 sec timeout when my traffic goes away
          ctr10, next_ctr10;     // 10 sec limit when other traffic presents

// sequential part of our state machine (register between C1 and C2 in Harris & Harris Moore machine diagram
// combinational part will reset or increment the counters and figure out the next_state
  always_ff @(posedge clk)
    if(reset) begin
	  present_state <= RRH;
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
    next_state = RRH;            // default to reset state
    next_ctr5  = 0; 	         // default to clearing counters
    next_ctr10 = 0;
    case(present_state)
  /* ************* Fill in the case statements ************** */
    // Three sections. 
    // Each denoting one of the pairs of directions: EW_straight, EW_left, NS

    // Section 1: GRR, YRR, ZRR, HRR

      GRR: begin  // for 5 clock cycles after traffic is no longer detected
        // when is next_state GRR? YRR?
        // what does ctr5 do? ctr10?
        
        if (ctr10 > 8)   					   // timeout if others want a turn
          next_state = YRR;
        else if (ctr5 > 3)	begin			   // timeout if my traffic goes away
          next_state = YRR;
        end
        else 							   // otherwise stay green
          next_state = GRR;
        if (!(ew_str_sensor) || ctr5>0) begin     // vacant countdown
          next_ctr5  = ctr5+1;
        end
        if (ew_str_sensor && (ew_left_sensor || ns_sensor) || ctr10>0) begin //EW straight is green, so we can't have EW left nor NS
          next_ctr10 = ctr10+1;					   // occupied countdown
        end
          
      end 
      // etc. 

      YRR: begin // first yellow state on ew_straight // turns yellow for two clock cycles, then red.
        // for two clock cycles of yellow we use additional states instead of counter
        next_state = ZRR;

      end
      ZRR: begin // second yellow state on ew_str
        next_state = HRR; 

      end  
      HRR: begin   // all red state, last yellow was on ew_str // defining priority of which direction gets green
        if (ew_left_sensor==1)                // priority - ew_left        
          next_state = RGR; 
        else if (ns_sensor==1) begin          // priority 2 - NS
          next_state = RRG;
        end
        else if (ew_str_sensor==1) begin      // priority 3 - ew_straight
          next_state = GRR;
        end 
        else                                  // else repeat to own state HRR
          next_state = HRR;
      end


      // Section 2: RGR, RYR, RZR, RHR, 

      RGR: begin                         // green on EW-left light

        if (ctr10 > 8)   					       // timeout if others want a turn
          next_state = RYR;
        else if (ctr5 > 3) begin			   // timeout if my traffic goes away
          next_state = RYR;
        end
        else 							               // otherwise stay green
          next_state = RGR;
        if (!(ew_left_sensor) || ctr5>0) begin     // vacant countdown // ctr5>0 means to continue count
          next_ctr5  = ctr5+1;
        end
        // if ew_left has traffic, and traffic detected on ns or ew_str: begin countdown to change traffic lights 
        if (ew_left_sensor && (ns_sensor || ew_str_sensor) || ctr10>0) begin
          next_ctr10 = ctr10+1;					           // occupied countdown
        end
      end

      RYR: begin // yellow on ew_left
        next_state = RZR;

      end
      RZR: begin // 2nd yellow on ew_left
        next_state = RHR;

      end 
      RHR: begin // All red, last yellow on ew_left. // define priorities for next green light
        if (ns_sensor==1)                     // priority - NS
          next_state = RRG;                 
        else if (ew_str_sensor==1) begin      // priority 2 - ew_straight
          next_state = GRR;
        end
        else if (ew_left_sensor==1) begin     // priority 3 - ew_left
          next_state = RGR;
        end 
        else                                  // else repeat own state RHR
          next_state = RHR;
      end


      // Section 3: RRG, RRY, RRZ, RRH

      RRG: begin  // this is now Green on NS sensor

        if (ctr10 > 8)   					   // timeout if others want a turn
          next_state = RRY;
        else if (ctr5 > 3)	begin			   // timeout if my traffic goes away
          next_state = RRY;
        end
        else 							   // otherwise stay green
          next_state = RRG;
        if (!(ns_sensor) || ctr5>0) begin     // vacant countdown
          next_ctr5  = ctr5+1;
        end
        if (ns_sensor && (ew_str_sensor || ew_left_sensor) || ctr10>0) begin
          next_ctr10 = ctr10+1;					   // occupied countdown
        end
      end


      RRY: begin              // yellow NS state
        next_state = RRZ;
      end
      RRZ: begin              // 2nd yellow NS state
        next_state = RRH;
      end
      RRH: begin              // all red state, last yellow on NS
        if (ew_str_sensor==1)             // priority - ew_straight
          next_state = GRR;
        else if(ew_left_sensor==1) begin  // priority 2 - ew_left
          next_state = RGR;
        end
        else if (ns_sensor==1) begin      // priority 3 - NS
          next_state = RRG; 
        end 
        else                              // else - repeat own state RRH
          next_state = RRH; 
      end
    endcase
  end

// below - we define the output (pretty light colors R/G/Y) for each particular state.
// combination output driver  ("C2" block in the Harris & Harris Moore machine diagram)
  always_comb begin
    ew_str_light  = red;                // cover all red plus undefined cases
	  ew_left_light = red;
	  ns_light      = red;
    case(present_state)      // Moore machine
      GRR:     ew_str_light  = green;
	  YRR,ZRR: ew_str_light  = yellow;  // my dual yellow states -- brute force way to make yellow last 2 cycles
	  RGR:     ew_left_light = green;
	  RYR,RZR: ew_left_light = yellow;
	  RRG:     ns_light      = green;
	  RRY,RRZ: ns_light      = yellow;
    endcase
  end

endmodule