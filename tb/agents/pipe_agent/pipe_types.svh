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

typedef struct{
  pipe_operation_t pipe_operation;
  tlp_t tlp;
  dllp_t dllp;
  pipe_width_t pipe_width;
  pclk_rate_t pclk_rate;
} pipe_seq_item_c;

typedef enum{
  PIPE_WIDTH_8_BIT,
  PIPE_WIDTH_16_BIT,
  PIPE_WIDTH_32_BIT,
}pipe_width_t;


`endif


