`include "settings.svh"

interface pipe_if
  #(
    parameter pipe_num_of_lanes,
    parameter pipe_max_width,
    localparam bus_data_width_param       = pipe_num_of_lanes  * pipe_max_width - 1,  
    localparam bus_data_kontrol_param     = (pipe_max_width / 8) * pipe_num_of_lanes - 1
  )(
    input bit   PCLK
    // input logic PhyReset
  );

  logic   Reset;

  /*************************** RX Specific Signals *************************************/
  logic [bus_data_width_param:0]      RxData;    
  logic [pipe_num_of_lanes-1:0]       RxDataValid;
  logic [bus_data_kontrol_param:0]    RxDataK;
  logic [pipe_num_of_lanes-1:0]       RxStartBlock;
  logic [2*pipe_num_of_lanes-1:0]     RxSyncHeader;
  logic [pipe_num_of_lanes-1:0]       RxValid;
  logic [3*pipe_num_of_lanes-1:0]     RxStatus;
  logic [pipe_num_of_lanes-1:0]       RxStandby;
  logic                               RxElecIdle;
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  logic [bus_data_width_param:0]      TxData;    
  logic [pipe_num_of_lanes-1:0]       TxDataValid;
  logic [bus_data_kontrol_param:0]    TxDataK;
  logic [pipe_num_of_lanes-1:0]       TxStartBlock;
  logic [2*pipe_num_of_lanes-1:0]     TxSyncHeader;
  logic [pipe_num_of_lanes-1:0]       TxElecIdle;
  logic [pipe_num_of_lanes-1:0]       TxDetectRxLoopback;

  /*********************** Comands and Status Signals **********************************/
  logic [4*pipe_num_of_lanes - 1:0]   PowerDown;
  logic [3:0]                         Rate;
  logic [pipe_num_of_lanes-1:0]       PhyStatus;
  logic [1:0]                         Width;
  logic [4:0]                         PCLKRate;
  logic                               PclkChangeAck;
  logic                               PclkChangeOk;
  /*************************************************************************************/

  /******************************* Message Bus Interface *******************************/
  logic [7:0]                         M2P_MessageBus;
  logic [7:0]                         P2M_MessageBus;
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  logic [18*pipe_num_of_lanes-1:0]   LocalTxPresetCoeffcients;
  logic [18*pipe_num_of_lanes-1:0]   TxDeemph;
  logic [6*pipe_num_of_lanes-1:0]    LocalFS;
  logic [6*pipe_num_of_lanes-1:0]    LocalLF;
  logic [pipe_num_of_lanes-1:0]      GetLocalPresetCoeffcients;
  logic [pipe_num_of_lanes-1:0]      LocalTxCoeffcientsValid;
  logic [6*pipe_num_of_lanes-1:0]    FS;    // TODO: Review specs for these values
  logic [6*pipe_num_of_lanes-1:0]    LF;    // TODO: Review specs for these values
  logic [pipe_num_of_lanes-1:0]      RxEqEval;
  logic [4*pipe_num_of_lanes-1:0]    LocalPresetIndex;
  logic [pipe_num_of_lanes-1:0]      InvalidRequest;
  logic [6*pipe_num_of_lanes-1:0]    LinkEvaluationFeedbackDirectionChange;
  /*************************************************************************************/

 
endinterface: pipe_if
