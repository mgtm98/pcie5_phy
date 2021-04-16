`ifndef __LPIF_TYPES_SVH
`define __LPIF_TYPES_SVH

typedef enum{
  LINK_UP, 
  RESET, 
  TLP_TRANSFER, 
  DLLP_TRANSFER, 
  ENTER_RETRAIN, 
  ENTER_L0S, 
  EXIT_L0S, 
  SPEED_MODE_CHANGE
} lpif_operation_t;

typedef enum{
  NOP,
  Active,
  Active_L0s,
  Deepest_Allowable_PM_State,  // [L1_Substates_only],
  L1_1,
  L1_2,
  L1_3,
  L1_4,
  L2,
  LinkReset,
  Reserved,
  Retrain,
  Disable
} lpif_states;

`endif
