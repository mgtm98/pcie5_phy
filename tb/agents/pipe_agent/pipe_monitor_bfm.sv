interface pipe_monitor_bfm (
  input bit clk, 
  input bit reset, 

  input logic PCLK,
  //RxData,RxDataK,TxData and TxDataK sizes can be changed according to interface size
  input logic [31:0] RxData,   //for 32 bit interface
  input logic [3:0]  RxDataK,  //for 32 bit interface
  input logic        RxValid,
  input logic        PhyStatus,
  input logic        RxElecidle,
  input logic [2:0]  RxStatus, 
  input logic        RxstartBlock, 
  input logic [3:0]  RxsynchHeader,
  input logic [31:0] TxData,  //for 32 bit interface
  input logic [3:0]  TxDataK, //for 32 bit interface
  input logic        TxDataValid,
  input logic        TxDetectRx,
  input logic [3:0]  TxEelecIdle,
  input logic [1:0]  Width,
  input logic [3:0]  Rate, 
  input logic [3:0]  PCLKRate, 
  input logic        Reset,
  input logic        TxstartBlock,
  input logic [3:0]  TxsynchHeader,
  input logic [3:0]  Powerdown
);

initial
begin
  forever
  begin
    @($rose(rx_valid))
    begin
      `uvm_info("pipe_monitor_bfm", "dummy seq_item detected", UVM_MEDIUM)
      proxy.pipe_monitor_dummy();
    end
  end
end
  
endinterface
