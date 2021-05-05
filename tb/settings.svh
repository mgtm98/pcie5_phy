`ifndef __SETTINGS_SVH
`define __SETTINGS_SVH

  /********************** Verbosity Level Settings *************************************/
  `define COMPONENT_STRUCTURE_VERBOSITY UVM_MEDIUM
  `define UVM_REPORT_DISABLE_FILE_LINE  1
  /*************************************************************************************/
  
  /**************************** PIPE Agent Settings ************************************/
  `define PIPE_MAX_WIDTH                32
  `define NUM_OF_LANES                  2
  /*************************************************************************************/

  /**************************** LPIF Agent Settings ************************************/
  `define LPIF_BUS_WIDTH                512
  /************************************************************************************/

`endif