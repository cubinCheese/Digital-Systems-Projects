// maps 2'b00, 01, 10 to red, yellow, green, respectively
// allows 2'b11, but it will not get a name associated with it 
package light_package;
// width declaration is optional w/ typedef enum
// used here to avoid 32-bit defaults w/ top 30 bits tied to 0
// first in list automatically maps to 2'b00
// next = 2'b01, etc.
// can also specifcy, e.g. to skip over a particular value
  // declaration of enumerated variables - quartus assigns binary values
  typedef enum logic[1:0] {red,yellow,green} colors; // we see ryg, devices see bin values

endpackage