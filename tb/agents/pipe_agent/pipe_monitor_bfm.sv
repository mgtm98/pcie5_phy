interface pipe_monitor_bfm (
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

initial begin //Detect linkup 
  detect_state();
  polling_state();
  config_state();

  proxy.notify_link_up_received(); //leha parameter?
end

task detect_state;
  int temp[2:0];
  @(resetn==1);

  temp=pclk_rate;   //shared or per lane??
  @(posedge pclk);
    assert property (temp==pclk_rate) else `uvm_error ("PCLK is not stable");

  @(resetn==0);

  foreach(phystatus[i]) begin  
      @(phystatus[i]=0);
    end

  @ (TxdetectRx==1);  //shared or per lane?
  //Transmitter starts in Electrical Idle //Gen 1 (2.5GT/s) //variables set to 0 

  /*
  fork        //12 ms timeout or any lane exits electricalidle
    #12ms;    
    for (int i = 0; i < NUM_OF_LANES; i++) begin 
      fork
        //automatic int j = i;
        @(rx_elec_idle[i]==0);   
      join_any
    end
  join_any

  foreach(Rx_status[i]) begin //wait on Rx_status='b011 for 1 clk then ='b000 
      @(Rx_status[i]='b011);
    end
  */

  foreach(phystatus[i]) begin  //wait on phystatus assertion for 1 clk
      @(phystatus[i]=1);
    end
  @(posedge pclk);
  foreach(phystatus[i]) begin  
      @(phystatus[i]=0);
    end
  
  foreach(Rx_status[i]) begin 
      @(Rx_status[i]='b000);
    end

  @ (TxdetectRx==0);
  `uvm_info("Receiver Detected");

endtask : detect_state
  
endinterface
