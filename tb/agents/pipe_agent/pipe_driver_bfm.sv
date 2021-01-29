interface pipe_driver_bfm(
  input bit clk,
  input bit reset,
  // TODO Change the size of RxData, RxDataK, TxData, TxDataK
  // Parametrization not mentioned in the document
  output logic [31:0] RxData,
  output logic [3:0] RxDataK,
  output logic RxValid,
  output logic PhyStatus,
  output logic RxElecidle,
  output logic [2:0] RxStatus,
  output logic RxstartBlock,
  output logic [3:0] RxsynchHeader,
  input logic [31:0] TxData,
  input logic [3:0] TxDataK,
  input logic TxDataValid,
  input logic TxDetectRx,
  input logic [3:0] TxEelecIdle,
  input logic [1:0] Width,
  input logic [3:0] Rate,
  input logic PCLK,
  input logic [4:0] PCLKRate,
  input logic Reset#,
  input logic TxStartBlock,
  input logic [3:0] TxSynchHeader,
  input logic [3:0] Powerdown
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
task link_up(device_config_s device_config);
  //to be implemented
endtask


task send_tlp(tlp_s tlp);
  //to be implemented
endtask


task send_dllp(dllp_s dllp);
  //to be implemented
endtask


task change_state(state_e state);
  //to be implemented
endtask

task change_speed(speed_mode_e speed);
  //to be implemented
endtask



endinterface