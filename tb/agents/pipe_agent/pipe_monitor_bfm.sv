interface pipe_monitor_bfm 
#(
  localparam bus_data_width_param       = `PCIE_LANE_NUMBER  * `PIPE_MAX_WIDTH - 1,  
  localparam bus_data_kontrol_param     = (`PIPE_MAX_WIDTH / 8) * `PCIE_LANE_NUMBER - 1
)(  
  input bit   Clk,
  input bit   Reset,
  input logic PhyReset,
   
  /*************************** RX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      RxData,    
  input logic [`PCIE_LANE_NUMBER-1:0]       RxDataValid,
  input logic [bus_data_kontrol_param:0]    RxDataK,
  input logic [`PCIE_LANE_NUMBER-1:0]       RxStartBlock,
  input logic [2*`PCIE_LANE_NUMBER-1:0]     RxSynchHeader,
  input logic [`PCIE_LANE_NUMBER-1:0]       RxValid,
  input logic [3*`PCIE_LANE_NUMBER-1:0]     RxStatus,
  input logic                               RxElecIdle,
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      TxData,    
  input logic [`PCIE_LANE_NUMBER-1:0]       TxDataValid,
  input logic [bus_data_kontrol_param:0]    TxDataK,
  input logic [`PCIE_LANE_NUMBER-1:0]       TxStartBlock,
  input logic [2*`PCIE_LANE_NUMBER-1:0]     TxSynchHeader,
  input logic [`PCIE_LANE_NUMBER-1:0]       TxElecIdle,
  input logic [`PCIE_LANE_NUMBER-1:0]       TxDetectRxLoopback,
  /*************************************************************************************/

  /*********************** Comands and Status Signals **********************************/
  input logic [3:0]                         PowerDown;
  input logic [3:0]                         Rate;
  input logic                               PhyStatus;
  input logic [1:0]                         Width;
  input logic                               PclkChangeAck;
  input logic                               PclkChangeOk;
  /*************************************************************************************/
  
  /******************************* Message Bus Interface *******************************/
  input logic [7:0]                         M2P_MessageBus;
  input logic [7:0]                         P2M_MessageBus;
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  input logic [18*`PCIE_LANE_NUMBER-1:0]   LocalTxPresetCoeffcients;
  input logic [18*`PCIE_LANE_NUMBER-1:0]   TxDeemph;
  input logic [6*`PCIE_LANE_NUMBER-1:0]    LocalFS;
  input logic [6*`PCIE_LANE_NUMBER-1:0]    LocalLF;
  input logic [`PCIE_LANE_NUMBER-1:0]      GetLocalPresetCoeffcients;
  input logic [`PCIE_LANE_NUMBER-1:0]      LocalTxCoeffcientsValid;
  input logic [6*`PCIE_LANE_NUMBER-1:0]    FS;    // TODO: Review specs for these values
  input logic [6*`PCIE_LANE_NUMBER-1:0]    LF;    // TODO: Review specs for these values
  input logic [`PCIE_LANE_NUMBER-1:0]      RxEqEval;
  input logic [4*`PCIE_LANE_NUMBER-1:0]    LocalPresetIndex;
  input logic [`PCIE_LANE_NUMBER-1:0]      InvalidRequest;  // TODO: this signal needs to be checked
  input logic [6*`PCIE_LANE_NUMBER-1:0]    LinkEvaluationFeedbackDirectionChange;
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
      @(RxValid)
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
  @(posedge PCLK);
  //check on default values
  assert property (TxDetectRx==0) else `uvm_error ("TxDetectRx isn't setted by default value during reset");
  assert property (TxElecIdle==1) else `uvm_error ("TxElecIdle isn't setted by default value during reset");
  //assert property (TxCompliance==0) else `uvm_error ("TxCompliance isn't setted by default value during reset");
  assert property (PowerDown=='b10) else `uvm_error ("PowerDown isn't in P1 during reset");

  //check that pclk is operational
  temp=PclkRate;   //shared or per lane?
  @(posedge PCLK);
  assert property (temp==PclkRate) else `uvm_error ("PCLK is not stable");

  wait(reset==0);
  @(posedge PCLK);

  foreach(PhyStatus[i]) begin 
    wait(PhyStatus[i]==0);
  end
  @(posedge PCLK);
  proxy.notify_reset_detected();
  `uvm_info ("Monitor BFM Detected (Reset scenario)");
end

//RECEIVER DETECTION
forever begin   //initial or forever?
  wait(TxDetectRx==1);
  @(posedge CLK);


  fork
    foreach(PhyStatus[i]) begin
      wait(PhyStatus[i]==1);
    end

    foreach(RxStatus[i]) begin 
      wait(RxStatus[i]=='b011);
    end    
  join
  @(posedge CLK);

  fork
    foreach(PhyStatus[i]) begin
      wait(PhyStatus[i]==0);
    end

    foreach(RxStatus[i]) begin 
      wait(RxStatus[i]=='b000);  //??
    end    
  join
  @(posedge CLK);

  wait(TxDetectRx==1);
  @(posedge CLK);
  proxy.notify_receiver_detected();
  `uvm_info ("Monitor BFM Detected (Receiver detection scenario)");
end

//waiting on power down to be P0
initial 
begin
  forever
  begin
      for (int i = 0; i < NUM_OF_LANES; i++) begin
        @ (PowerDown[i] == 'b00);
      end
      proxy.pipe_polling_state_start();
  end
end  
endinterface
