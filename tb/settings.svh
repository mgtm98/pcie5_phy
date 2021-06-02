`ifndef __SETTINGS_SVH
`define __SETTINGS_SVH

  /********************** Verbosity Level Settings *************************************/
  `define COMPONENT_STRUCTURE_VERBOSITY UVM_MEDIUM
  `define UVM_REPORT_DISABLE_FILE_LINE  1
  /*************************************************************************************/
  
  /**************************** PIPE Agent Settings ************************************/
  `define PIPE_MAX_WIDTH                32
  `define NUM_OF_LANES                  16
  /*************************************************************************************/

  /**************************** LPIF Agent Settings ************************************/
  `define LPIF_BUS_WIDTH                512
  /************************************************************************************/

  /****************************** Packet settings ************************************/
  `define STP_gen_1_2                8'b1111_1011
  `define SDP_gen_1_2                8'b0101_1100
  `define END_gen_1_2                8'b1111_1101
  `define EDB_gen_1_2                8'b1111_0111
  `define COM                        8'b1011_1100

  `define STP_gen_3                  4'b1111

  `define SDP_gen_3_symbol_0         8'b0000_1111
  `define SDP_gen_3_symbol_1         8'b0011_0101

  `define END_gen_3_symbol_0         8'b1111_1000
  `define END_gen_3_symbol_1         8'b0000_0001
  `define END_gen_3_symbol_2         8'b0000_1001
  `define END_gen_3_symbol_3         8'b0000_0000

  `define EDB_gen_3                  8'b0000_0011  //EDB has 4 symbols with the same value

  /************************************************************************************/
  // "Set Bit" - Sets bit number "bit" of "var" to the value "val". Bit "bit" of "var" must start cleared.
  `define SB(var,bit_no,val) var |= (val & 1) << bit_no
  // "Get Bit" - Returns the value of bit number "bit" of "var".
  `define GB(var,bit_no) ((var >> bit_no) & 1)

`endif