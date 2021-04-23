interface pipe_monitor_bfm (
//Tx
  input logic [31:0] tx_data,  //for 32 bit interface
  input logic        tx_data_valid,
  input logic        TxElecIdle,
  input logic [3:0]  tx_data_k, //for 32 bit interface
  input logic        tx_start_block,
  input logic [1:0]  tx_synch_header,  
  input logic        TxDetectRx,
  
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
  input logic [3:0]  PowerDown,
  input logic [3:0]  rate, 
  input logic [3:0]  phy_mode,  //=0  means PCIe
  output logic       PhyStatus,
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
