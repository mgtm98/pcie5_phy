interface pipe_monitor_bfm 
#(
  localparam bus_data_width_param       = `PCIE_LANE_NUMBER  * `PIPE_MAX_WIDTH - 1,  
  localparam bus_data_kontrol_param     = (`PIPE_MAX_WIDTH / 8) * `PCIE_LANE_NUMBER - 1
)(  
  input bit   clk,
  input bit   reset,
  input logic phy_reset,
   
  /*************************** RX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      rx_data,    
  input logic [`PCIE_LANE_NUMBER-1:0]       rx_data_valid,
  input logic [bus_data_kontrol_param:0]    rx_data_k,
  input logic [`PCIE_LANE_NUMBER-1:0]       rx_start_block,
  input logic [2*`PCIE_LANE_NUMBER-1:0]     rx_synch_header,
  input logic [`PCIE_LANE_NUMBER-1:0]       rx_valid,
  input logic [3*`PCIE_LANE_NUMBER-1:0]     rx_status,
  input logic                               rx_elec_idle,
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      tx_data,    
  input logic [`PCIE_LANE_NUMBER-1:0]       tx_data_valid,
  input logic [bus_data_kontrol_param:0]    tx_data_k,
  input logic [`PCIE_LANE_NUMBER-1:0]       tx_start_block,
  input logic [2*`PCIE_LANE_NUMBER-1:0]     tx_synch_header,
  input logic [`PCIE_LANE_NUMBER-1:0]       tx_elec_idle,
  input logic [`PCIE_LANE_NUMBER-1:0]       tx_detect_rx__loopback,
  /*************************************************************************************/

  /*********************** Comands and Status Signals **********************************/
  input logic [3:0]                         power_down,
  input logic [3:0]                         rate,
  input logic                               phy_status,
  input logic [1:0]                         width,
  input logic                               pclk_change_ack,
  input logic                               pclk_change_ok,
  /*************************************************************************************/
  
  /******************************* Message Bus Interface *******************************/
  input logic [7:0]                         m2p_message_bus,
  input logic [7:0]                         p2m_message_bus,
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  input logic [18*`PCIE_LANE_NUMBER-1:0]   local_tx_preset_coeffcients,
  input logic [18*`PCIE_LANE_NUMBER-1:0]   tx_deemph,
  input logic [6*`PCIE_LANE_NUMBER-1:0]    local_fs,
  input logic [6*`PCIE_LANE_NUMBER-1:0]    local_lf,
  input logic [`PCIE_LANE_NUMBER-1:0]      get_local_preset_coeffcients,
  input logic [`PCIE_LANE_NUMBER-1:0]      local_tx_coeffcients_valid,
  input logic [6*`PCIE_LANE_NUMBER-1:0]    fs,    // TODO: Review specs for these values
  input logic [6*`PCIE_LANE_NUMBER-1:0]    lf,    // TODO: Review specs for these values
  input logic [`PCIE_LANE_NUMBER-1:0]      rx_eq_eval,
  input logic [4*`PCIE_LANE_NUMBER-1:0]    local_preset_index,
  input logic [`PCIE_LANE_NUMBER-1:0]      invalid_request,  // TODO: this signal needs to be checked
  input logic [6*`PCIE_LANE_NUMBER-1:0]    link_evaluation_feedback_direction_change
  /*************************************************************************************/
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
/*
initial begin //Detect linkup 
  detect_state();
  polling_state();
  config_state();

  proxy.notify_link_up_received(); //leha parameter?
end
*/

//RESET DETECTION
  int temp[2:0];
forever begin   //initial or forever?

  wait(reset==1);
  @(posedge pclk);
  //check on default values
  assert property (TxDetectRx==0) else `uvm_error ("TxDetectRx isn't setted by default value during reset");
  assert property (TxElecIdle==1) else `uvm_error ("TxElecIdle isn't setted by default value during reset");
  //assert property (TxCompliance==0) else `uvm_error ("TxCompliance isn't setted by default value during reset");
  assert property (PowerDown=='b10) else `uvm_error ("PowerDown isn't in P1 during reset");

  //check that pclk is operational
  temp=pclk_rate;   //shared or per lane?
  @(posedge pclk);
  assert property (temp==pclk_rate) else `uvm_error ("PCLK is not stable");

  wait(reset==0);
  @(posedge pclk);

  foreach(PhyStatus[i]) begin 
    wait(PhyStatus[i]==0);
  end
  @(posedge pclk);
  proxy.notify_reset_detected();
  `uvm_info ("Monitor BFM Detected (Reset scenario)");
end

//RECEIVER DETECTION
forever begin   //initial or forever?
  wait(TxDetectRx==1);
  @(posedge clk);


  fork
    foreach(PhyStatus[i]) begin
      wait(PhyStatus[i]==1);
    end

    foreach(RxStatus[i]) begin 
      wait(RxStatus[i]=='b011);
    end    
  join
  @(posedge clk);

  fork
    foreach(PhyStatus[i]) begin
      wait(PhyStatus[i]==0);
    end

    foreach(RxStatus[i]) begin 
      wait(RxStatus[i]=='b000);  //??
    end    
  join
  @(posedge clk);

  wait(TxDetectRx==1);
  @(posedge clk);
  proxy.notify_receiver_detected();
  `uvm_info ("Monitor BFM Detected (Receiver detection scenario)");

end
  
endinterface
