`ifndef __PIPE_TYPES_SVH
`define __PIPE_TYPES_SVH



typedef enum
{
  TLP_TRANSFER, 
  DLLP_TRANSFER, 
  LINK_UP, 
  ENTER_RECOVERY, 
  ENTER_L0S, 
  EXIT_L0S, 
  SPEED_CHANGE, 
  RESET, 
  PCLK_RATE_CHANGE,
  WIDTH_CHANGE
} pipe_operation_t;

  // Pipe bus width between the MAC layer and PHY layer
  // width can either be 32bit - 16bit - 8bit
  // for more info check Pipe interface refence Page 18 
typedef enum 
{
  BUS_WIDTH_8  = 8,
  BUS_WIDTH_16 = 16,
  BUS_WIDTH_32 = 32,
  BUS_WIDTH_64 = 64
} pipe_width_t;



`endif


