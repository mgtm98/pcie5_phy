interface pipe_driver_bfm(
  input bit clk,
  // input bit reset,
  // TODO Change the size of RxData, RxDataK, TxData, TxDataK
  // Parametrization not mentioned in the document
   
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

  
//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

  task config_state;
    ts_config_t received_tses [NUM_OF_LANES];
    // -------------------- Config.Linkwidth.Start --------------------
    int unsigned num_of_ts1s_with_non_pad_link_number [NUM_OF_LANES];
    // Initialize the detected num of ts1s with non pad link number to zero
    foreach(num_of_ts1s_with_non_pad_link_number[i])
    begin
      num_of_ts1s_with_non_pad_link_number[i] = 0;
    end
    // Detect ts1s until 2 consecutive ts1s have a non-pad link number
    while(num_of_ts1s_with_non_pad_link_number < 2)
    begin
      receive_ts(received_tses);
      // Make sure the received tses are ts1s
      foreach(received_tses[i])
      begin
        // Make sure the tses received are ts1s
        assert (received_tses[i].ts_type == TS1) 
        else   `uvm_error(get_name(), "Expected TS1s but detected TS2s")
        // Non PAD link number
        if(received_ts[i].use_link_number)
        begin
          num_of_ts1s_with_non_pad_link_number[i] += 1
        end
        // PAD link number
        else
        begin
          num_of_ts1s_with_non_pad_link_number[i] = 0;
        end
      end
      // Check if any lane detected 2 consecutive ts1s with non PAD link number
      int unsigned two_consecutive_ts1s_with_non_pad_link_number_detected = 0;
      foreach(num_of_ts1s_with_non_pad_link_number[i])
      begin
        if(num_of_ts1s_with_non_pad_link_number[i] == 2)
        begin
          two_consecutive_ts1s_with_non_pad_link_number_detected = 1;
          break;
        end
      end
      // Move to the next sub-state if any lane detected 2 consecutive ts1s with non PAD link number
      if(two_consecutive_ts1s_with_non_pad_link_number_detected)
      begin
        break;
      end
    end

    // -------------------- Config.Linkwidth.Accept --------------------
    // Use the link number of the ts1s on the first lane to be transmitted
    bit [7:0] used_link_num = ts_configs[0].link_number;
    foreach(ts_configs[i])
    begin
      ts_configs[i].link_number = used_link_num;
      ts_configs[i].use_link_number = 1;
    end
    // Send ts1s with this link number until some ts1s are received with non PAD lane number
    ts1_with_non_pad_lane_number_detected = 0
    fork
      begin
        while (!ts1_with_non_pad_lane_number_detected)
        begin
          send_ts(ts_configs);
        end
      end
      begin
        while (!ts1_with_non_pad_lane_number_detected)
        begin
          receive_ts(received_tses);
          // Check if any ts1 received has a non PAD lane number
          foreach(received_tses[i])
          begin
            // Make sure the tses received are ts1s
            assert (received_tses[i].ts_type == TS1) 
            else   `uvm_error(get_name(), "Expected TS1s but detected TS2s")
            // Non PAD lane number
            if(received_tses[i].use_lane_num)
            begin
              ts1_with_non_pad_lane_number_detected = 1
            end
          end
        end
      end
    join
    // Get the lane numbers from the received ts1s
    foreach(received_tses[i])
    begin
      assert (received_tses[i].lane_number == i) 
      else   `uvm_error(get_name(), "the order of lane numbers are incorrect")
      ts_configs[i].lane_number = received_tses[i].lane_number;
    end

    // -------------------- Config.Lanenum.Wait --------------------
    int num_of_ts2_received [NUM_OF_LANES];
    // Initialize the num_of_ts2_received array with zeros
    foreach(num_of_ts2_received[i])
    begin
      num_of_ts2_received[i] = 0;
    end
    // Transmit TS1s until 2 consecutive TS2s are received
    int unsigned two_consecutive_ts2s_detected = 0;
    fork
      begin
        while (!two_consecutive_ts2s_detected)
        begin
          send_ts(ts_configs);
        end
      end

      begin
        while (!two_consecutive_ts2s_detected)
        begin
          receive_ts(received_tses);
          foreach(received_tses[i])
          begin
            if(received_tses[i].ts_type == TS2)
            begin
              num_of_ts2_received[i] += 1;
            end
            else
            begin
              num_of_ts2_received[i] = 0;
            end
          end
          // Check if any lane detected 2 consecutive ts2s
          foreach(num_of_ts2_received[i])
          begin
            if(num_of_ts2_received[i] == 2)
            begin
              two_consecutive_ts2s_detected = 1;
            end
          end
          // Move to the next sub-state if any lane detected 2 consecutive ts2s
          if(two_consecutive_ts2s_detected)
          begin
            break;
          end
        end
      end
    join

    // -------------------- Config.Lanenum.Accept --------------------

    // -------------------- Config.Complete --------------------

    // -------------------- Config.Idle --------------------
  endtask
endinterface
