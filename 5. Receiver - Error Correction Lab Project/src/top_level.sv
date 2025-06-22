// shell for Lab 4 CSE140L
// this will be top level of your DUT
// W is data path width (8 bits)
// byte count = number of "words" (bytes) in reg_file
//   or data_memory
module top_level #(parameter W=8,
                   byte_count = 256)(
  input        clk, 
               init,	           // req. from test bench
  output logic done);	           // ack. to test bench

// memory interface = 
//   write_en, raddr, waddr, data_in, data_out: 
  logic write_en;                  // store enable for dat_mem

// address pointers for reg_file/data_mem
  logic[$clog2(byte_count)-1:0] raddr, waddr;

// data path connections into/out of reg file/data mem
  logic[W-1:0] data_in;
  wire [W-1:0] data_out; 

/* instantiate data memory (reg file)
   Here we can override the two parameters, if we 
     so desire (leaving them as defaults here) */
  dat_mem #(.W(W),.byte_count(byte_count)) 
    dm1(.*);		               // reg_file or data memory

/* ********** insert your code here
   read from data mem, manipulate bits, write
   result back into data_mem  ************
*/
/*
LSBs      action
000			no op
001         read Least Significant Byte from data_memory
002			read Most Significant Byte from data memory
003         Lab 4: compute parity bits
004         Lab 4: rearrange bits for write-to-memory
005         write LSB to data memory
006         write MSB to data memory
007         no op
*/

/*
data_in = data_out
*/


// program counter: bits[6:3] count passes through for loop/subroutine
// bits[2:0] count clock cycles within subroutine (I use 5 out of 8 possible, pad w/ 3 no ops)
  logic[ 6:0] count;  // pc - program counter
  logic[ 8:0] parity;
  logic[15:0] temp1, temp2, temp3, temp1cpy;
  logic       temp1_enh, temp1_enl, temp2_en;
  logic[3:0] errorIndexPos;               // int variable
  logic incomingDataParity; // two bit error - flag

  //assign parity[8] = ^temp1[10:4];
  //...

  

  always @(posedge clk) begin
    if(init) begin
      count <= 0;
      temp1 <= 'b0;
      temp2 <= 'b0;
    end
    else begin
      count                     <= count + 1;
      if(temp1_enh) temp1[15:8] <= data_out;
      if(temp1_enl) temp1[ 7:0] <= data_out;
      
      //if(temp2_en) begin
      // computed parities based on decrypted message 
      //  based on bits of decrypted msg and alrdy present parity bits of decrypted msg
      //if (temp2_en) begin
      parity[8] = ^temp1[15:9];                  // p8 - b5 to b11 - 15 to 9      // reduction parity (xor)
      parity[4] = (^temp1[15:12])^(^temp1[7:5]); // p4 - b2,3,4, 8,9,10,11 - 5,6,7, 12,13,14,15
      parity[2] = temp1[15]^temp1[14]^temp1[11]^temp1[10]^temp1[7]^temp1[6]^temp1[3]; //p2 - d1,3,4,6,7,10,11 - 3,6,7,10,11,14,15
      parity[1] = temp1[15]^temp1[13]^temp1[11]^temp1[9]^temp1[7]^temp1[5]^temp1[3]; //p1 - d1,2,4,5,7,9,11 - 3,5,7,9,11,13,15
      parity[0] = (^temp1[15:9])^(^temp1[7:5])^(temp1[3])^parity[8]^parity[4]^parity[2]^parity[1]; // all data bits
      
      // temp1 structure: {p0,p1,p2,b1,p4,b2,b3,b4,p8,b5,b6,b7,b8,b9,b10,b11}
      // parity structure: {p0,p1,p2,p4,p8} // 3,5,6,7,9,10,etc 
      // final parity calculation
      // parity = {XOR of all 16 bits, 
      /* XOR [b1,b2,b4,b5,b7,b9,b11], 
         XOR [b1,b3,b4,b6,b7,b10,b11]}
         XOR [b2,b3,b4,b8,b9,b1,b11]
         XOR [b5,b6,b7,b8,b9,b10,b11]
      which is
      {[15:0], [3,5,7,9,11,13,15], [3,6,7,10,11,14,15], [5,6,7,12,13,14,15], [9,10,11,12,13,14,15]}

      */ 

      // temp3 only holds data bits of temp1 - rearranged
      temp3[0] = temp1[3];  // b1
      temp3[3:1] = temp1[7:5]; // b2 to b4
      temp3[10:4] = temp1[15:9]; // b5 to b11

      // cloning temp1 // avoiding overwrite
      temp1cpy = temp1;
      //temp1cpy[15:8] = temp1[15:8];
      //temp1cpy[7:0] = temp1[7:0];
      //temp1cpy[15:0] = temp1[15:0];
      
      // (computed) global parity of encrypted message // not given p0
      incomingDataParity = ^temp1[15:0]; // (^temp1[15:8])^(^temp1[7:0]);
      
      // assigning flag bits
      // locate error 
      // error in data -- location represented by flags (parity comparison)
      errorIndexPos[0] = parity[1] ^ temp1[1];  // p1 ^ s1 // is s1 the parity? or the bit? b, 3,5,7,12
      errorIndexPos[1] = parity[2] ^ temp1[2];  // p2 ^ s2
      errorIndexPos[2] = parity[4] ^ temp1[4];  // p4 ^ s4
      errorIndexPos[3] = parity[8] ^ temp1[8];  // p8 ^ s8  // where s8 is from recovery // this is reversed: we have s8 as encrypted (input) and p8 as recovery (decrypted) 

      // defining in count cycle
      if (count==4) begin
        // one bit flipped - Detected Errors: 1
        // incomingdataparity = XOR of 16 bits = 100000...0 : XOR=1; XOR=0; XOR=1
        if (incomingDataParity) begin // (incomingDataParity==1) begin // if incomingData=0; 0 or 2 error
          // flip located (error'd) data bit
          temp1cpy[errorIndexPos] = temp1cpy[errorIndexPos] ^ (1'b1 << errorIndexPos);  // ^ 1'b1// somehow flipping 8th bit when we should be flipping 2nd
          
          // update temp3 with temp1cpy
          temp3[0] = temp1cpy[3];  // b1
          temp3[3:1] = temp1cpy[7:5]; // b2 to b4
          temp3[10:4] = temp1cpy[15:9]; // b5 to b11

          // update temp2 with temp3 databits
          temp2[10:0] = temp3[10:0]; // data bits

          // indicate single bit error to flag bits
          temp2[15:11] = 'b01000; // flag bits change to: (01)000 
          //temp2[15:11] = temp3[15:11];
                                    
        end // how about the case of parity // how about we use like TB -- checking bits in errorIndexPos
        else if (~(parity[1]|parity[2]|parity[4]|parity[8])) begin 
          temp2[10:0] = temp3[10:0];  // just propagate msg out -- no changes // needs to be explicitly stated
          temp2[15:11] = 'b00000; // flag bits change to: (00)000
          //temp2[15:11] = temp3[15:11];
        end
        else begin // 2 bit errors+
          temp2[10:0] = temp3[10:0]; // don't change msg. Give up. // needs to be explicitly stated 
          
          temp2[15:11] = 'b10000; // flag bits change to: (10)000
          //temp2[15:11] = temp3[15:11];
          // if 2nd error occurs
        end
      end
      //end
    end  
  end  
  

  always_comb begin
// defaults  
    temp1_enl        = 'b0;
    temp1_enh        = 'b0;
    temp2_en         = 'b0;
    raddr            = 'b0;
    waddr            = 'b0;
    write_en         = 'b0;
    data_in          = temp2[7:0];  
    //temp2 = 'b0; 
    case(count[2:0])
      1: begin                  // step 1: load from data_mem into lower byte of temp1
//           raddr     = function of count[6:3]
          // raddr = 2*count[6:3]; //  from tb - 2*i // addr have 8 bitss

          raddr = 2*count[6:3] + 64;
          temp1_enl = 'b1;
        
         end  
      2: begin                  // step 2: load from data_mem into upper byte of temp1
//           raddr      = function of count[6:3]
           // raddr = 2*count[6:3] + 1; // 2*i + 1 is what gives the counter proper function // + 1 for modifying hamming?
           
           
           raddr = 2*count[6:3] + 65;
           temp1_enh = 'b1;

         end
      3: begin
         temp2_en    = 'b1;     // step 3: copy from temp1 and parity bits into temp2
          
        end 
      // 4: // defined in sequential clk cycle
      5: begin                  // step 4: store from one bytte of temp2 into data_mem 
          write_en = 'b1;
//           waddr    = function of count[6:3]
//           data_in  = bits from temp2
          // waddr = 2*count[6:3] + 30; // {DUT.dm1.core[31+2*i],DUT.dm1.core[30+2*i]};
          //data_in = temp2[7:0];

          waddr = 2*count[6:3] + 94;
          data_in = temp2[7:0];

         end
      6: begin
          write_en = 'b1;      // step 5: store from other byte of temp2 into data_mem
//           waddr    = function of count[6:3]
//           data_in  = bits from temp2
          // waddr = 2*count[6:3] + 31; // addr [6:0] because we're starting from 1.
          //data_in = temp2[15:8];
          // spit out another recovered message?

          waddr = 2*count[6:3] + 95;
          data_in = temp2[15:8];

         end
    endcase
  end

// automatically stop at count 127; 120 might be even better (why?)
  assign done = &count;

endmodule
