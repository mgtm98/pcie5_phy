`ifndef __PIPE_TYPES_SVH
`define __PIPE_TYPES_SVH

typedef enum{
  TS1,
  TS2
} ts_type_t;

typedef enum{
  D=0,
  K=1
} D_K_character;

typedef enum{
  GEN1,
  GEN2,
  GEN3,
  GEN4,
  GEN5
} gen_t;

typedef struct {
  bit [7:0]             n_fts;
  bit                   use_n_fts;
  bit [7:0]             link_number;
  bit                   use_link_number;
  bit [7:0]             lane_number;
  bit                   use_lane_number;
  gen_t                 max_gen_supported;
  ts_type_t             ts_type;

  bit                   speed_change;                     // need to be added in the send/recv tasks
  bit                   auto_speed_change;                // need to be added in the send/recv tasks
  bit [2:0]             rx_preset_hint;                   // need to be added in the send/recv tasks
  bit [3:0]             tx_preset;                        // need to be added in the send/recv tasks
  bit [1:0]             ec;
  bit                   use_preset;
  bit [5:0]             lf_value;
  bit [5:0]             fs_value;
  bit [5:0]             pre_cursor;
  bit [5:0]             cursor;
  bit [5:0]             post_cursor;
  bit                   reject_coeficient;

  // fields for TS2 only
  bit                   equalization_command;         



} ts_s;

typedef enum {
  TLP_TRANSFER, 
  DLLP_TRANSFER, 
  LINK_UP, 
  ENTER_RECOVERY, 
  // ENTER_L0S, 
  // EXIT_L0S, 
  SPEED_CHANGE,         // speed change is used to direct the driver to change the speed using pipe signals
  RESET, 
  PCLK_RATE_CHANGE,
  WIDTH_CHANGE,
  SEND_TS,
  SEND_TSES,
  SEND_IDLE_DATA,
  SEND_DATA
  CHECK_EQ_PRESET_APPLIED,
  INFORM_LF_FS,
  SET_LOCAL_LF_FS
} pipe_operation_t;

typedef enum bit[4:0]{
  PCLK_62     = 0,
  PCLK_125    = 1,
  PCLK_250    = 2,
  PCLK_500    = 3,
  PCLK_1000   = 4,
  PCLK_2000   = 5,
  PCLK_4000   = 6
} pclk_rate_t;

typedef enum bit[1:0] {
  PIPE_WIDTH_8_BIT  = 0,
  PIPE_WIDTH_16_BIT = 1,
  PIPE_WIDTH_32_BIT = 2
} pipe_width_t;

typedef struct {
  pipe_operation_t pipe_operation;
  tlp_t tlp;
  dllp_t dllp;
  pipe_width_t pipe_width;
  pclk_rate_t pclk_rate;
} pipe_seq_item_s;

// Typedef of parameterized PIPE interfaces
typedef virtual pipe_if #(
  .pipe_num_of_lanes(`NUM_OF_LANES),
  .pipe_max_width(`PIPE_MAX_WIDTH)
) pipe_if_param;

typedef virtual pipe_driver_bfm #(
  .pipe_num_of_lanes(`NUM_OF_LANES),
  .pipe_max_width(`PIPE_MAX_WIDTH)
) pipe_driver_bfm_param;

typedef virtual pipe_monitor_bfm #(
  .pipe_num_of_lanes(`NUM_OF_LANES),
  .pipe_max_width(`PIPE_MAX_WIDTH)
) pipe_monitor_bfm_param;

`endif
