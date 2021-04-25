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

typedef bit [3:0] enum {
	ACTIVE = 4'b0001,
	LINK_RESET = 4'b1001,
	RETRAIN = 4'b1011
} lpif_state_t;

`endif
