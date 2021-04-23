`include "settings.svh"

interface pipe_if(
    input bit   clk,
    input bit   reset,
    input logic phy_reset
  );

  localparam bus_data_width_param       = `PCIE_LANE_NUMBER  * `PIPE_MAX_WIDTH - 1;  
  localparam bus_data_kontrol_param     = (`PIPE_MAX_WIDTH / 8) * `PCIE_LANE_NUMBER - 1;

  /*************************** RX Specific Signals *************************************/
  logic [bus_data_width_param:0]      rx_data;    
  logic [`PCIE_LANE_NUMBER-1:0]       rx_data_valid;
  logic [bus_data_kontrol_param:0]    rx_data_k;
  logic [`PCIE_LANE_NUMBER-1:0]       rx_start_block;
  logic [2*`PCIE_LANE_NUMBER-1:0]     rx_synch_header;
  logic [`PCIE_LANE_NUMBER-1:0]       rx_valid;
  logic [3*`PCIE_LANE_NUMBER-1:0]     rx_status;
  logic                               rx_elec_idle;
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  logic [bus_data_width_param:0]      tx_data;    
  logic [`PCIE_LANE_NUMBER-1:0]       tx_data_valid;
  logic [bus_data_kontrol_param:0]    tx_data_k;
  logic [`PCIE_LANE_NUMBER-1:0]       tx_start_block;
  logic [2*`PCIE_LANE_NUMBER-1:0]     tx_synch_header;
  logic [`PCIE_LANE_NUMBER-1:0]       tx_elec_idle;
  logic [`PCIE_LANE_NUMBER-1:0]       tx_detect_rx__loopback;
  /*************************************************************************************/

  /*********************** Comands and Status Signals **********************************/
  logic [3:0]                         power_down;
  logic [3:0]                         rate;
  logic                               phy_status;
  logic [1:0]                         width;
  logic                               pclk_change_ack;
  logic                               pclk_change_ok;
  /*************************************************************************************/

  /******************************* Message Bus Interface *******************************/
  logic [7:0]                         m2p_message_bus;
  logic [7:0]                         p2m_message_bus;
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  logic [18*`PCIE_LANE_NUMBER-1:0]   local_tx_preset_coeffcients;
  logic [18*`PCIE_LANE_NUMBER-1:0]   tx_deemph;
  logic [6*`PCIE_LANE_NUMBER-1:0]    local_fs;
  logic [6*`PCIE_LANE_NUMBER-1:0]    local_lf;
  logic [`PCIE_LANE_NUMBER-1:0]      get_local_preset_coeffcients;
  logic [`PCIE_LANE_NUMBER-1:0]      local_tx_coeffcients_valid;
  logic [6*`PCIE_LANE_NUMBER-1:0]    fs;    // TODO: Review specs for these values
  logic [6*`PCIE_LANE_NUMBER-1:0]    lf;    // TODO: Review specs for these values
  logic [`PCIE_LANE_NUMBER-1:0]      rx_eq_eval;
  logic [4*`PCIE_LANE_NUMBER-1:0]    local_preset_index;
  logic [`PCIE_LANE_NUMBER-1:0]      invalid_request;
  logic [6*`PCIE_LANE_NUMBER-1:0]    link_evaluation_feedback_direction_change;
  /*************************************************************************************/
endinterface: pipe_if
