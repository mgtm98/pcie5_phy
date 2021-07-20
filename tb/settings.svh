`ifndef __SETTINGS_SVH
`define __SETTINGS_SVH

  /********************** Verbosity Level Settings *************************************/
  `ifndef COMPONENT_STRUCTURE_VERBOSITY
    `define COMPONENT_STRUCTURE_VERBOSITY UVM_MEDIUM
  `endif

  `ifndef UVM_REPORT_DISABLE_FILE_LINE
    `define UVM_REPORT_DISABLE_FILE_LINE  1
  `endif
  /*************************************************************************************/
  
  /********************************MAX_GEN_SUPPORTED*************************************/
`ifndef MAX_GEN_FAR_PARTENER
  `define MAX_GEN_FAR_PARTENER 1
`endif
`ifndef MAX_GEN_DUT
  `define MAX_GEN_DUT 1
`endif
/*********************************PIPE_widths*******************************************/
`ifndef GEN1_PIPEWIDTH
  `define GEN1_PIPEWIDTH 8
`endif
`ifndef GEN2_PIPEWIDTH
  `define GEN2_PIPEWIDTH 8
`endif
`ifndef GEN3_PIPEWIDTH
  `define GEN3_PIPEWIDTH 8
`endif
`ifndef GEN4_PIPEWIDTH
  `define GEN4_PIPEWIDTH 8
`endif
`ifndef GEN5_PIPEWIDTH
  `define GEN5_PIPEWIDTH 8
`endif



  /*************************************************************************************/
  /**************************** PIPE Agent Settings ************************************/
  `ifndef PIPE_MAX_WIDTH
    `define PIPE_MAX_WIDTH                32
  `endif

  `ifndef NUM_OF_LANES
    `define NUM_OF_LANES                  16
  `endif
  /*************************************************************************************/

  /**************************** LPIF Agent Settings ************************************/
  `ifndef LPIF_BUS_WIDTH
    `define LPIF_BUS_WIDTH                512
  `endif
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