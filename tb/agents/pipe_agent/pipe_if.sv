//  Interface: pipe_if 

interface pipe_if #(pipe_data_width_t bus_width = BUS_WIDTH_32)(
  input bit clk,
  input bit reset
);
  integer bus_data_width_param = bus_width - 1;  
  integer bus_kontrol_param = (bus_width/8) - 1;

  logic [bus_data_width_param:0]  rx_data;        
  logic [bus_kontrol_param:0]     rx_data_k;
  logic                           rx_valid;
  logic                           phy_status;
  logic                           rx_elec_idle;
  logic [2:0]                     rx_status;
  logic                           rx_start_block;
  logic [3:0]                     rx_synch_header;
  logic [bus_data_width_param:0]  tx_data;
  logic [bus_kontrol_param:0]     tx_data_k;
  logic                           tx_data_valid;
  logic                           tx_detect_rx;
  logic [3:0]                     tx_elec_idle;
  logic [1:0]                     width;
  logic [3:0]                     rate;
  logic                           pclk;
  logic [4:0]                     pclk_rate ;
  logic                           _reset;
  logic                           tx_start_block;
  logic [3:0]                     tx_synch_header;
  logic [3:0]                     power_down;

endinterface: pipe_if

/*
  Notes:
    - why tx_data_valid and rx_valid (both with or without 'data')
    - we need notation for active low signals (reset# --> ...)
    - do we need to document each signal (breif description - spec page number)
    - this style in interface or the normal style
*/ 