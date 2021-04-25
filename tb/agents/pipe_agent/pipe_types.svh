`ifndef __PIPE_TYPES_SVH
`define __PIPE_TYPES_SVH

typedef enum{
  TS1,
  TS2
} ts_type_t;

typedef enum{
  GEN1,
  GEN2,
  GEN3,
  GEN4,
  GEN5
} gen_t;

typedef struct {
  bit [7:0]             n_fts,
  bit                   use_n_fts,
  bit [7:0]             link_number,
  bit                   use_link_number,
  bit [7:0]             lane_number,
  bit                   use_lane_number,
  gen_t                 max_gen_suported,
  ts_type_t             ts_type
} ts_s;

typedef enum {
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

typedef bit [4:0] enum{
  PCLK_62     = 0,
  PCLK_125    = 1,
  PCLK_250    = 2,
  PCLK_500    = 3,
  PCLK_1000   = 4,
  PCLK_2000   = 5,
  PCLK_4000   = 6
} pclk_rate_t;

typedef bit [1:0] enum {
  PIPE_WIDTH_8_BIT  = 0,
  PIPE_WIDTH_16_BIT = 1,
  PIPE_WIDTH_32_BIT = 2,
} pipe_width_t;

typedef struct {
  pipe_operation_t pipe_operation;
  tlp_t tlp;
  dllp_t dllp;
  pipe_width_t pipe_width;
  pclk_rate_t pclk_rate;
} pipe_seq_item_s;

`endif
