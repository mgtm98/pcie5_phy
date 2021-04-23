`ifndef __PIPE_TYPES_SVH
`define __PIPE_TYPES_SVH

typedef enum{
  TLP_TRANSFER, 
  DLLP_TRANSFER, 
  LINK_UP, 
  ENTER_RECOVERY, 
  // ENTER_L0S, 
  // EXIT_L0S, 
  SPEED_CHANGE, 
  RESET, 
  PCLK_RATE_CHANGE,
  WIDTH_CHANGE,
  SEND_TS,
  SEND_TSES
} pipe_operation_t;

typedef enum{
  PCLK_62     = 62,
  PCLK_125    = 125,
  PCLK_250    = 250,
  PCLK_500    = 500,
  PCLK_1000   = 1000,
  PCLK_2000   = 2000,
  PCLK_4000   = 4000
} pclk_rate_t;


`endif


