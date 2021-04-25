`include "settings.svh"

interface pipe_if(
    input bit   clk,
    input bit   reset,
    input logic phy_reset
  );

  localparam bus_data_width_param       = `PCIE_LANE_NUMBER  * `PIPE_MAX_WIDTH - 1;  
  localparam bus_data_kontrol_param     = (`PIPE_MAX_WIDTH / 8) * `PCIE_LANE_NUMBER - 1;

  /*************************** RX Specific Signals *************************************/
  logic [bus_data_width_param:0]      RxData;    
  logic [`PCIE_LANE_NUMBER-1:0]       RxDataValid;
  logic [bus_data_kontrol_param:0]    RxDataK;
  logic [`PCIE_LANE_NUMBER-1:0]       RxStartBlock;
  logic [2*`PCIE_LANE_NUMBER-1:0]     RxSynchHeader;
  logic [`PCIE_LANE_NUMBER-1:0]       RxValid;
  logic [3*`PCIE_LANE_NUMBER-1:0]     RxStatus;
  logic                               RxElecIdle;
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  logic [bus_data_width_param:0]      TxData;    
  logic [`PCIE_LANE_NUMBER-1:0]       TxDataValid;
  logic [bus_data_kontrol_param:0]    TxDataK;
  logic [`PCIE_LANE_NUMBER-1:0]       TxStartBlock;
  logic [2*`PCIE_LANE_NUMBER-1:0]     TxSynchHeader;
  logic [`PCIE_LANE_NUMBER-1:0]       TxElecIdle;
  logic [`PCIE_LANE_NUMBER-1:0]       TxDetectRxLoopback;
  /*************************************************************************************/

  /*********************** Comands and Status Signals **********************************/
  logic [3:0]                         PowerDown;
  logic [3:0]                         Rate;
  logic                               PhyStatus;
  logic [1:0]                         Width;
  logic                               PclkChangeAck;
  logic                               pclkChangeOk;
  /*************************************************************************************/

  /******************************* Message Bus Interface *******************************/
  logic [7:0]                         M2P_MessageBus;
  logic [7:0]                         P2M_MessageBus;
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  logic [18*`PCIE_LANE_NUMBER-1:0]   LocalTxPresetCoeffcients;
  logic [18*`PCIE_LANE_NUMBER-1:0]   TxDeemph;
  logic [6*`PCIE_LANE_NUMBER-1:0]    LocalFS;
  logic [6*`PCIE_LANE_NUMBER-1:0]    LocalLF;
  logic [`PCIE_LANE_NUMBER-1:0]      GetLocalPresetCoeffcients;
  logic [`PCIE_LANE_NUMBER-1:0]      LocalTxCoeffcientsValid;
  logic [6*`PCIE_LANE_NUMBER-1:0]    FS;    // TODO: Review specs for these values
  logic [6*`PCIE_LANE_NUMBER-1:0]    LF;    // TODO: Review specs for these values
  logic [`PCIE_LANE_NUMBER-1:0]      RxEqEval;
  logic [4*`PCIE_LANE_NUMBER-1:0]    LocalPresetIndex;
  logic [`PCIE_LANE_NUMBER-1:0]      InvalidRequest;
  logic [6*`PCIE_LANE_NUMBER-1:0]    LinkEvaluationFeedbackDirectionChange;
  /*************************************************************************************/
endinterface: pipe_if
