interface pipe_driver_bfm(
  input bit clk,
  // input bit reset,
  // TODO Change the size of RxData, RxDataK, TxData, TxDataK
  // Parametrization not mentioned in the document
   
  //Tx
  input logic [31:0] tx_data,  //for 32 bit interface
  input logic        tx_data_valid,
  input logic        tx_elec_idle,
  input logic [3:0]  tx_data_k, //for 32 bit interface
  input logic        tx_start_block,
  input logic [1:0]  tx_synch_header,  
  input logic        tx_detect_rx,
  
  //Rx
  output logic [31:0] rx_data,   //for 32 bit interface
  output logic        rx_data_valid,
  output logic        rx_elec_idle,
  output logic [3:0]  rx_data_k,  //for 32 bit interface
  output logic        rx_start_block, 
  output logic [1:0]  rx_synch_header,
  output logic        rx_valid,
  output logic [2:0]  rx_status, 
  input  logic        rx_stand_by,
  output logic        rx_stand_by_status,
  
  //Commands and Status signals
  input logic [3:0]  power_down,
  input logic [3:0]  rate, 
  input logic [3:0]  phy_mode,  //=0  means PCIe
  output logic       phy_status,
  input logic [1:0]  width,
  input logic [4:0]  pclk_rate,
  input logic        pclk_change_ack,
  output logic       pclk_change_ok,
  
  //clk and reset
  input logic        pclk,
  input logic        reset


);


`include "uvm_macros.svh"
import uvm_pkg::*;
import pipe_agent_pkg::*;

  
//------------------------------------------
// Data Members
//------------------------------------------
gen_t current_gen;


//------------------------------------------
// Methods
//------------------------------------------

  `include "link_up.svh"
endinterface

/*


Finish the verification plan

Finish the detailed scenario
  lpif normal data operation
  pipe link up upstream

seq
  Lpif_link_up_seq
  Lpif_data_transmit_seq
  Lpif_reset_seq
  Lpif_enter_recovery_seq
  Lpif_enter_l0s_seq X
  Lpif_exit_l0s_seq X

  pipe_link_up_seq
  pipe_data_transmit_seq
  pipe_enter_recovery_seq
  pipe_enter_l0s_seq X
  pipe_exit_l0s_seq X
  Pipe_speed_change_seq 

vseq
  base_vseq
  link_up_vseq
  data_exchange_vseq
  reset_vseq
  enter_recovery_vseq
  enter_l0s_vseq X
  exit_l0s_vseq X
  speed_change_vseq

seq_item
  lpif_seq_item
  pipe_seq_item

lpif
  lpif_driver
  lpif_monitor

pipe
  pipe_driver
  pipe_monitor

Parameterization
  lpif_if
  lpif_driver_bfm
  lpif_monitor_bfm

  pipe_if
  pipe_driver_bfm
  pipe_monitor_bfm