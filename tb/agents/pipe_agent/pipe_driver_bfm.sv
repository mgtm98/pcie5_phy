interface pipe_driver_bfm(
  input bit clk,
  // input bit reset,
  // TODO Change the size of RxData, RxDataK, TxData, TxDataK
  // Parametrization not mentioned in the document
  output logic [31:0] rx_data,   //for 32 bit interface
  output logic [3:0]  rx_data_k,  //for 32 bit interface
  output logic        rx_valid,
  output logic        phy_status,
  output logic        rx_elec_idle,
  output logic [2:0]  rx_status, 
  output logic        rx_start_block, 
  output logic [3:0]  rx_synch_header,
  input logic [31:0]  tx_data,  //for 32 bit interface
  input logic [3:0]  tx_data_k, //for 32 bit interface
  input logic        tx_data_valid,
  input logic        tx_detect_rx,
  input logic [3:0]  tx_elec_idle,
  input logic [1:0]  width,
  input logic [3:0]  rate, 
  input logic [3:0]  pclk_rate, 
  input logic        pclk,
  input logic        reset,
  input logic        tx_start_block,
  input logic [3:0]  tx_synch_header,
  input logic [3:0]  power_down
);


`include "uvm_macros.svh"
import uvm_pkg::*;
import pipe_agent_pkg::*;

  
//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------




endinterface