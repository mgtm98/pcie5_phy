package common_pkg;

  // DLLP type (array of 6 bytes) TODO: Check dllp size from pcie spec and write it
  typedef bit [7:0] dllp_t [0:5];

  // DLLP type (queue of bytes) TODO: Check tlp size from pcie spec and write it
  typedef bit [7:0] tlp_t [$];

  typedef enum{
    ACTIVE_state,
    L0s_state,
    RETRAIN_state,
    DISABLE_state,
    RESET_state
  } state_t;

  typedef enum{
    GEN1, GEN2, GEN3, GEN4, GEN5
  } speed_mode_t;

endpackage: common_pkg
