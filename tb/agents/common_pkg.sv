//  Package: common_pkg
//  All common types used by the agents are defined here

package common_pkg;

  // Pipe bus width between the MAC layer and PHY layer
  // width can either be 32bit - 16bit - 8bit
  // for more info check Pipe interface refence Page 18 
  typedef enum {
    BUS_WIDTH_8  = 8,
    BUS_WIDTH_16 = 16,
    BUS_WIDTH_32 = 32
  } pipe_data_width_t;

  typedef struct  {
    bit nothing
  } tlp_s;
   
endpackage: common_pkg


