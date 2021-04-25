`include "settings.svh"

interface pipe_if
  #(
    param pipe_num_of_lanes,
    param pipe_max_width,
    localparam bus_data_width_param       = pipe_num_of_lanes  * pipe_max_width - 1,  
    localparam bus_data_kontrol_param     = (pipe_max_width / 8) * pipe_num_of_lanes - 1
  )(
    input bit   clk,
    input bit   reset,
    input logic phy_reset
  );

  /*************************** RX Specific Signals *************************************/
  logic [bus_data_width_param:0]      rx_data;    
  logic [pipe_num_of_lanes-1:0]       rx_data_valid;
  logic [bus_data_kontrol_param:0]    rx_data_k;
  logic [pipe_num_of_lanes-1:0]       rx_start_block;
  logic [2*pipe_num_of_lanes-1:0]     rx_synch_header;
  logic [pipe_num_of_lanes-1:0]       rx_valid;
  logic [3*pipe_num_of_lanes-1:0]     rx_status;
  logic                               rx_elec_idle;
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  logic [bus_data_width_param:0]      tx_data;    
  logic [pipe_num_of_lanes-1:0]       tx_data_valid;
  logic [bus_data_kontrol_param:0]    tx_data_k;
  logic [pipe_num_of_lanes-1:0]       tx_start_block;
  logic [2*pipe_num_of_lanes-1:0]     tx_synch_header;
  logic [pipe_num_of_lanes-1:0]       tx_elec_idle;
  logic [pipe_num_of_lanes-1:0]       tx_detect_rx__loopback;
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
  logic [18*pipe_num_of_lanes-1:0]   local_tx_preset_coeffcients;
  logic [18*pipe_num_of_lanes-1:0]   tx_deemph;
  logic [6*pipe_num_of_lanes-1:0]    local_fs;
  logic [6*pipe_num_of_lanes-1:0]    local_lf;
  logic [pipe_num_of_lanes-1:0]      get_local_preset_coeffcients;
  logic [pipe_num_of_lanes-1:0]      local_tx_coeffcients_valid;
  logic [6*pipe_num_of_lanes-1:0]    fs;    // TODO: Review specs for these values
  logic [6*pipe_num_of_lanes-1:0]    lf;    // TODO: Review specs for these values
  logic [pipe_num_of_lanes-1:0]      rx_eq_eval;
  logic [4*pipe_num_of_lanes-1:0]    local_preset_index;
  logic [pipe_num_of_lanes-1:0]      invalid_request;
  logic [6*pipe_num_of_lanes-1:0]    link_evaluation_feedback_direction_change;
  /*************************************************************************************/
endinterface: pipe_if
