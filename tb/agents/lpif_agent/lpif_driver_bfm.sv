`include "settings.svh"

interface lpif_driver_bfm #(
  parameter lpif_bus_width,
  localparam bus_data_width_param = lpif_bus_width - 1,
  localparam bus_kontrol_param = (lpif_bus_width/8) - 1
)(
    input logic                                lclk,
    output logic                               reset,

    input logic                                pl_trdy,
    input logic [bus_data_width_param:0]       pl_data,
    input logic [bus_kontrol_param:0]          pl_valid,
    
    output logic                               lp_irdy,
    output logic [bus_data_width_param:0]      lp_data,
    output logic [bus_kontrol_param:0]         lp_valid,
    
    input logic                                pl_linkup,

    output logic [3:0]                         lp_state_req,
    input logic [3:0]                          pl_state_sts,
    output logic                               lp_force_detect,
    
    input logic [2:0]                          pl_speed_mode,
    
    input logic [bus_kontrol_param:0]          pl_tlp_start,
    input logic [bus_kontrol_param:0]          pl_tlp_end,
    input logic [bus_kontrol_param:0]          pl_dllp_start,
    input logic [bus_kontrol_param:0]          pl_dllp_end,
    input logic [bus_kontrol_param:0]          pl_tlpedb,
    
    output logic [bus_kontrol_param:0]         lp_tlp_start,
    output logic [bus_kontrol_param:0]         lp_tlp_end,
    output logic [bus_kontrol_param:0]         lp_dllp_start,
    output logic [bus_kontrol_param:0]         lp_dllp_end,
    output logic [bus_kontrol_param:0]         lp_tlpedb
  );

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import common_pkg::*;
  import lpif_agent_pkg::*;

  task reset_scenario ();
    `uvm_info("lpif_driver_bfm", "reset scenario started", UVM_LOW)
    @(posedge lclk);
    reset <= 0;
    @(posedge lclk);
    reset <= 1;
    @(posedge lclk);
    lp_state_req <= LINK_RESET;
    `uvm_info("lpif_driver_bfm", "waiting link_reset sts", UVM_LOW)
    //wait(pl_state_sts == LINK_RESET);
  	//@(posedge lclk);
    `uvm_info("lpif_driver_bfm", "reset scenario finished", UVM_LOW)
  endtask

  task link_up ();
    wait(pl_linkup == 1);
  	@(posedge lclk);
    lp_state_req <= ACTIVE;
    wait(pl_state_sts == ACTIVE);
  	@(posedge lclk);
  endtask

/********************************** Normal Data Operation ***********************************/
  bit [7:0] data_queue [$];
  bit tlp_start_queue [$];
  bit tlp_end_queue [$];
  bit dllp_start_queue [$];
  bit dllp_end_queue [$];

  function void send_tlp(tlp_t tlp);
    // Add the bytes of the TLP to the data queue and add the suitable values for the other signals
    foreach(tlp[i]) begin
      data_queue.push_back(tlp[i]);
      tlp_start_queue.push_back(0);
      tlp_end_queue.push_back(0);
      dllp_start_queue.push_back(0);
      dllp_end_queue.push_back(0);
    end
    // Fix the first value of the tlp_start queue
    tlp_start_queue.pop_front();
    tlp_start_queue.push_front(1);
    // Fix the last value of the tlp_end queue
    tlp_end_queue.pop_back();
    tlp_end_queue.push_back(1);
  endfunction

  function void send_dllp(dllp_t dllp);
    // Add the bytes of the DLLP to the data queue and add the suitable values for the other signals
    foreach(dllp[i]) begin
      data_queue.push_back(dllp[i]);
      tlp_start_queue.push_back(0);
      tlp_end_queue.push_back(0);
      dllp_start_queue.push_back(0);
      dllp_end_queue.push_back(0);
    end
    // Fix the first value of the dllp_start queue
    dllp_start_queue.pop_front();
    dllp_start_queue.push_front(1);
    // Fix the last value of the dllp_end queue
    dllp_end_queue.pop_back();
    dllp_end_queue.push_back(1);
  endfunction

  task send_data();
    longint unsigned i;
    longint unsigned j;
    longint unsigned num_of_loops;
    lp_irdy <= 1;
    // Calculate the number of times the upper layer will need to put the data on the full bus
    num_of_loops = data_queue.size() / (lpif_bus_width / 8);
    // Loop over the number of times the upper layer will need to put the data on the full bus
    for(i = 0; i < num_of_loops; i++) begin
      // Loop over the full bus
      for(j = 0; j < lpif_bus_width / 8; j++) begin
        // Put the values in the queues on the signals
        lp_data[(j*8)+:8] <= data_queue.pop_front();
        lp_tlp_start[j] <= tlp_start_queue.pop_front();
        lp_tlp_end[j] <= tlp_end_queue.pop_front();
        lp_dllp_start[j] <= dllp_start_queue.pop_front();
        lp_dllp_end[j] <= dllp_end_queue.pop_front();
        lp_valid[j] <= 1;
      end
      wait(pl_trdy == 1);
      @(posedge lclk);
    end
    // Notify that some of the values on the data bus will be invalid
    for(i = 0; i < lpif_bus_width / 8; i++) begin
      lp_valid[i] <= 0;
    end
    if(data_queue.size() != 0) begin
      // Loop over the only needed number of lanes
      num_of_loops = data_queue.size();
      for(i = 0; i < num_of_loops; i++) begin
        lp_data[(i*8)+:8] <= data_queue.pop_front();
        lp_tlp_start[i] <= tlp_start_queue.pop_front();
        lp_tlp_end[i] <= tlp_end_queue.pop_front();
        lp_dllp_start[i] <= dllp_start_queue.pop_front();
        lp_dllp_end[i] <= dllp_end_queue.pop_front();
        lp_valid[i] <= 1;
      end
      wait(pl_trdy == 1);
      @(posedge lclk);
    end
    // Notify that all the incoming values are invalid
    for(i = 0; i < lpif_bus_width / 8; i++) begin
      lp_valid[i] <= 0;
    end
    lp_irdy <= 0;
  endtask

  // task change_speed(speed_mode_t speed);
  //   //to be implemented
  // endtask

  task retrain();
    //to be implemented
  endtask
  
endinterface
