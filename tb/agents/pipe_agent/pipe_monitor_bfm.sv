interface pipe_monitor_bfm (
  input bit clk, 
  // input bit reset, 

  input logic PCLK,
  //RxData,RxDataK,TxData and TxDataK sizes can be changed according to interface size
  input logic [31:0] rx_data,   //for 32 bit interface
  input logic [3:0]  rx_data_K,  //for 32 bit interface
  input logic        rx_valid,
  input logic        phy_status,
  input logic        rx_elec_idle,
  input logic [2:0]  rx_status, 
  input logic        rx_start_block, 
  input logic [3:0]  rx_synch_header,
  input logic [31:0] tx_data,  //for 32 bit interface
  input logic [3:0]  tx_data_K, //for 32 bit interface
  input logic        tx_data_valid,
  input logic        tx_detect_rx,
  input logic [3:0]  tx_elec_idle,
  input logic [1:0]  width,
  input logic [3:0]  rate, 
  input logic [3:0]  pclk_rate, 
  input logic        reset,
  input logic        tx_start_block,
  input logic [3:0]  tx_synch_header,
  input logic [3:0]  power_down
);

  `include "uvm_macros.svh"

  import uvm_pkg::*;
  import pipe_agent_pkg::*;

  pipe_monitor proxy;

  initial
  begin
    forever
    begin
      @(rx_valid)
      begin
        `uvm_info("pipe_monitor_bfm", "dummy seq_item detected", UVM_MEDIUM)
        proxy.pipe_monitor_dummy();
      end
    end
  end
  
endinterface
