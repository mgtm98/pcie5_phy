package common_pkg;

// Note: bit is used instead of logic as the (dllp, tlp) packets were contain only 0/1 

// DLLP type (array of 6 bytes) TODO: Check dllp size from pcie spec and write it
typedef bit [7:0] dllp_t [0:5];

// DLLP type (queue of bytes) TODO: Check tlp size from pcie spec and write it
typedef bit [7:0] tlp_t [$];

typedef enum
{
  ACTIVE_state,
  L0s_state,
  RETRAIN_state,
  DISABLE_state,
  RESET_state
} state_t;

typedef enum
{
  GEN1, GEN2, GEN3, GEN4, GEN5
} speed_mode_t;

typedef enum
{
  PCLK_62     = 62,
  PCLK_125    = 125,
  PCLK_250    = 250,
  PCLK_500    = 500,
  PCLK_1000   = 1000,
  PCLK_2000   = 2000,
  PCLK_4000   = 4000
}pclk_rate_t;

endpackage: common_pkg
