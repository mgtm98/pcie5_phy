interface lpif_monitor_bfm #(
  parameter lpif_bus_width,
  localparam bus_data_width_param = lpif_bus_width - 1,
  localparam bus_kontrol_param = (lpif_bus_width/8) - 1
)(
  input logic lclk,
  input logic reset,
  input logic                                pl_trdy,
  input logic [bus_data_width_param:0]       pl_data,
  input logic [bus_kontrol_param:0]          pl_valid,
  
  input logic                               lp_irdy,
  input logic [bus_data_width_param:0]      lp_data,
  input logic [bus_kontrol_param:0]         lp_valid,
    
  input logic                                pl_linkup,
  
  input logic [3:0]                         lp_state_req,
  input logic [3:0]                         pl_state_sts,
  input logic                               lp_force_detect,
  
  input logic [2:0]                          pl_speed_mode,
  
  input logic [bus_kontrol_param:0]          pl_tlp_start,
  input logic [bus_kontrol_param:0]          pl_tlp_end,
  input logic [bus_kontrol_param:0]          pl_dllp_start,
  input logic [bus_kontrol_param:0]          pl_dllp_end,
  input logic [bus_kontrol_param:0]          pl_tlpedb,
  
  input logic [bus_kontrol_param:0]         lp_tlp_start,
  input logic [bus_kontrol_param:0]         lp_tlp_end,
  input logic [bus_kontrol_param:0]         lp_dllp_start,
  input logic [bus_kontrol_param:0]         lp_dllp_end,
  input logic [bus_kontrol_param:0]         lp_tlpedb
);

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import common_pkg::*;
  import lpif_agent_pkg::*;

  lpif_monitor proxy;
  logic [3:0]  pl_state_sts_previous;

  /************************************** Detect Link Up **************************************/
  initial begin
    forever begin
      @(pl_state_sts)begin
        if(pl_state_sts_previous == LINK_RESET && pl_state_sts == ACTIVE) proxy.notify_link_up_received();
        pl_state_sts_previous = pl_state_sts;
      end
    end
  end

  /********************************** TX Normal Data Operation ***********************************/
  // Data Queue
  bit [7:0] tx_data_queue [$];

  // TX Monitor BFM States
  lpif_monitor_bfm_state_t tx_monitor_bfm_state;

  function void process_tx_data_queue;
    tlp_t tlp;
    dllp_t dllp;
    // Make sure the TX data queue is not empty
    assert (tx_data_queue.size() != 0) 
    else   `uvm_error("lpif_monitor_bfm", "The tx_data_queue is empty while it is expected to contain data")
    // Make sure the TX monitor BFM state is valid
    assert (tx_monitor_bfm_state != WAITING_FOR_START) 
    else   `uvm_error("lpif_monitor_bfm", "Unexpected TX Monitor BFM state while processing tx_data_queue")
    // Process a TLP stored in the data queue
    if(tx_monitor_bfm_state == RECEIVING_TLP) begin
      // Make sure the number of bytes in the data queue is in the valid range of number of bytes in a TLP
      assert (tx_data_queue.size() >= TLP_MIN_SIZE && tx_data_queue.size() <= TLP_MAX_SIZE) 
      else   `uvm_error("lpif_monitor_bfm", "The size of the TX data queue is not in the valid range of the number of bytes in a TLP")
      // Copy the data from the data queue to the tlp variable
      tlp = tx_data_queue;
      proxy.notify_tlp_sent(tlp);
    end
    // Process a DLLP stored in the data queue
    else if(tx_monitor_bfm_state == RECEIVING_DLLP) begin
      // Make sure the number of bytes in the data queue is equal to the expected number (6) for the DLLP
      assert (tx_data_queue.size() == 6) 
      else   `uvm_error("lpif_monitor_bfm", "The size of the TX data queue is not equal to 6 while expecting DLLP of size 6 bytes")
      // Copy the data from the data queue to the dllp variable
      foreach(dllp[i]) begin
        dllp[i] = tx_data_queue.pop_front();
      end
      proxy.notify_dllp_sent(dllp);
    end
    // Empty the data queue
    tx_data_queue = {};
    assert (tx_data_queue.size() == 0) 
    else   `uvm_error("lpif_monitor_bfm", "The tx_data_queue is not empty while it is expected to be empty after processing its data")
  endfunction

  // Detecting TX TLP & DLLP
  initial begin
    int i;
    tx_monitor_bfm_state = WAITING_FOR_START;
    forever begin
      if(lp_irdy === 1 && pl_trdy === 1) begin
        for(i = 0; i < bus_kontrol_param + 1; i++) begin
          if(tx_monitor_bfm_state == WAITING_FOR_START) begin
            if(lp_valid[i] === 1) begin
              // Assertions on some signals
              assert (lp_tlp_end[i] === 0) 
              else   `uvm_error("lpif_monitor_bfm", "The lp_tlp_end signal is asserted while no tlp is being received")
              assert (lp_dllp_end[i] === 0) 
              else   `uvm_error("lpif_monitor_bfm", "The lp_dllp_end signal is asserted while no dllp is being received")
              assert (!(lp_tlp_start[i] === 1 && lp_dllp_start[i] === 1))
              else   `uvm_error("lpif_monitor_bfm", "The lp_tlp_start and lp_dllp_start signals are asserted at the same time")
              assert (!(lp_tlp_start[i] === 0 && lp_dllp_start[i] === 0))
              else   `uvm_error("lpif_monitor_bfm", "The lp_tlp_start and lp_dllp_start signals are de-asserted at the same time while expecting one of them to be asserted")
              assert (i % 2 == 0) 
              else   `uvm_error("lpif_monitor_bfm", "The start of a TLP or a DLLP is on an invalid lane (odd-numbered lane)")
              // Check if this byte is the start of the TLP
              if(lp_tlp_start[i] === 1) begin
                tx_monitor_bfm_state = RECEIVING_TLP;
              end
              // Check if this byte is the start of the DLLP
              else if(lp_dllp_start[i] === 1) begin
                tx_monitor_bfm_state = RECEIVING_DLLP;
              end
              tx_data_queue.push_back(lp_data[i*8+:8]);
            end
          end
          else if(tx_monitor_bfm_state == RECEIVING_TLP) begin
            if(lp_valid[i] === 1) begin
              // Assertions on some signals
              assert (lp_tlp_start[i] === 0) 
              else   `uvm_error("lpif_monitor_bfm", "The lp_tlp_start is asserted while receiving a TLP")
              assert (lp_dllp_start[i] === 0) 
              else   `uvm_error("lpif_monitor_bfm", "The lp_dllp_start is asserted while receiving a TLP")
              assert (lp_dllp_end[i] === 0) 
              else   `uvm_error("lpif_monitor_bfm", "The lp_dllp_end is asserted while receiving a TLP")
              // Add this byte to the queue
              tx_data_queue.push_back(lp_data[i*8+:8]);
              // Check if this byte is the end of the TLP
              if(lp_tlp_end[i] === 1) begin
                process_tx_data_queue();
                tx_monitor_bfm_state = WAITING_FOR_START;
              end
            end
          end
          else if(tx_monitor_bfm_state == RECEIVING_DLLP) begin
            if(lp_valid[i] === 1) begin
              // Assertions on some signals
              assert (lp_tlp_start[i] === 0) 
              else   `uvm_error("lpif_monitor_bfm", "The lp_tlp_start is asserted while receiving a TLP")
              assert (lp_tlp_end[i] === 0) 
              else   `uvm_error("lpif_monitor_bfm", "The lp_tlp_end is asserted while receiving a TLP")
              assert (lp_dllp_start[i] === 0) 
              else   `uvm_error("lpif_monitor_bfm", "The lp_dllp_start is asserted while receiving a TLP")
              // Add this byte to the queue
              tx_data_queue.push_back(lp_data[i*8+:8]);
              // Check if this byte is the end of the TLP
              if(lp_dllp_end[i] === 1) begin
                process_tx_data_queue();
                tx_monitor_bfm_state = WAITING_FOR_START;
              end
            end
          end
          else begin
            `uvm_error("lpif_monitor_bfm", "tx_monitor_bfm_state is invalid")
          end
        end
        @(posedge lclk);
      end
      else begin
        @(posedge lclk);
      end
    end
  end

  /********************************** RX Normal Data Operation ***********************************/
  // Data Queue
  bit [7:0] rx_data_queue [$];

  // RX Monitor BFM State
  lpif_monitor_bfm_state_t rx_monitor_bfm_state;

  function void process_rx_data_queue;
    tlp_t tlp;
    dllp_t dllp;
    // Make sure the RX data queue is not empty
    assert (rx_data_queue.size() != 0) 
    else   `uvm_error("lpif_monitor_bfm", "The RX data queue is empty while it is expected to contain data")
    // Make sure the RX monitor BFM state is valid
    assert (rx_monitor_bfm_state != WAITING_FOR_START) 
    else   `uvm_error("lpif_monitor_bfm", "Unexpected RX Monitor BFM state while processing rx_data_queue")
    // Process a TLP stored in the data queue
    if(rx_monitor_bfm_state == RECEIVING_TLP) begin
      // Make sure the number of bytes in the data queue is in the valid range of number of bytes in a TLP
      assert (rx_data_queue.size() >= TLP_MIN_SIZE && rx_data_queue.size() <= TLP_MAX_SIZE) 
      else   `uvm_error("lpif_monitor_bfm", "The size of the RX data queue is not in the valid range of the number of bytes in a TLP")
      // Copy the data from the data queue to the tlp variable
      tlp = rx_data_queue;
      proxy.notify_tlp_received(tlp);
    end
    // Process a DLLP stored in the data queue
    else if(rx_monitor_bfm_state == RECEIVING_DLLP) begin
      // Make sure the number of bytes in the data queue is equal to the expected number (6) for the DLLP
      assert (rx_data_queue.size() == 6) 
      else   `uvm_error("lpif_monitor_bfm", "The size of the RX data queue is not equal to 6 while expecting DLLP of size 6 bytes")
      // Copy the data from the data queue to the dllp variable
      foreach(dllp[i]) begin
        dllp[i] = rx_data_queue.pop_front();
      end
      proxy.notify_dllp_received(dllp);
    end
    // Empty the data queue
    rx_data_queue = {};
    assert (rx_data_queue.size() == 0) 
    else   `uvm_error("lpif_monitor_bfm", "The rx_data_queue is not empty while it is expected to be empty after processing its data")
  endfunction

  // Detecting RX TLP & DLLP
  initial begin
    int i;
    rx_monitor_bfm_state = WAITING_FOR_START;
    forever begin
      for(i = 0; i < bus_kontrol_param + 1; i++) begin
        if(rx_monitor_bfm_state == WAITING_FOR_START) begin
          if(pl_valid[i] === 1) begin
            // Assertions on some signals
            assert (pl_tlp_end[i] === 0) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_tlp_end signal is asserted while no tlp is being received")
            assert (pl_dllp_end[i] === 0) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_dllp_end signal is asserted while no dllp is being received")
            assert (!(pl_tlp_start[i] === 1 && pl_dllp_start[i] === 1)) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_tlp_start and pl_dllp_start signals are asserted at the same time")
            assert (!(pl_tlp_start[i] === 0 && pl_dllp_start[i] === 0)) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_tlp_start and pl_dllp_start signals are de-asserted at the same time while expecting one of them to be asserted")
            assert (i % 2 == 0) 
            else   `uvm_error("lpif_monitor_bfm", "The start of a TLP or a DLLP is on an invalid lane (odd-numbered lane)")
            // Check if this byte is the start of the TLP
            if(pl_tlp_start[i] === 1) begin
              rx_monitor_bfm_state = RECEIVING_TLP;
            end
            // Check if this byte is the start of the DLLP
            else if(pl_dllp_start[i] === 1) begin
              rx_monitor_bfm_state = RECEIVING_DLLP;
            end
            // Add this byte to the queue
            rx_data_queue.push_back(pl_data[i*8+:8]);
          end
        end
        else if(rx_monitor_bfm_state == RECEIVING_TLP) begin
          if(pl_valid[i] === 1) begin
            // Assertions on some signals
            assert (pl_tlp_start[i] === 0) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_tlp_start is asserted while receiving a TLP")
            assert (pl_dllp_start[i] === 0) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_dllp_start is asserted while receiving a TLP")
            assert (pl_dllp_end[i] === 0) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_dllp_end is asserted while receiving a TLP")
            // Add this byte to the queue
            rx_data_queue.push_back(pl_data[i*8+:8]);
            // Check if this byte is the end of the TLP
            if(pl_tlp_end[i] === 1) begin
              process_rx_data_queue();
              rx_monitor_bfm_state = WAITING_FOR_START;
            end
          end
        end
        else if(rx_monitor_bfm_state == RECEIVING_DLLP) begin
          if(pl_valid[i]) begin
            // Assertions on some signals
            assert (pl_tlp_start[i] === 0) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_tlp_start is asserted while receiving a TLP")
            assert (pl_tlp_end[i] === 0) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_tlp_end is asserted while receiving a TLP")
            assert (pl_dllp_start[i] === 0) 
            else   `uvm_error("lpif_monitor_bfm", "The pl_dllp_start is asserted while receiving a TLP")
            // Add this byte to the queue
            rx_data_queue.push_back(pl_data[i*8+:8]);
            // Check if this byte is the end of the TLP
            if(pl_dllp_end[i] === 1) begin
              process_rx_data_queue();
              rx_monitor_bfm_state = WAITING_FOR_START;
            end
          end
        end
        else begin
          `uvm_error("lpif_monitor_bfm", "rx_monitor_bfm_state is invalid")
        end
      end
      @(posedge lclk);
    end
  end

endinterface