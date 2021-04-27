class lpif_agent extends uvm_component;

// UVM Factory Registration Macro
`uvm_component_utils(lpif_agent)


lpif_agent_config     lpif_agent_config_h;
lpif_monitor          lpif_monitor_h;
lpif_sequencer        lpif_sequencer_h;
lpif_driver           lpif_driver_h;
lpif_coverage_monitor lpif_coverage_monitor_h;

uvm_analysis_port #(lpif_seq_item) ap_sent;
uvm_analysis_port #(lpif_seq_item) ap_received;

// Standard UVM Methods:
extern function new(string name = "lpif_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass: lpif_agent


function lpif_agent::new(string name = "lpif_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void lpif_agent::build_phase(uvm_phase phase);
  
  if(!uvm_config_db#(lpif_agent_config)::get(this, "", "lpif_agent_config_h", lpif_agent_config_h)) begin
    `uvm_fatal(this.get_name(), "Cannot get LPIF Agent configuration from uvm_config_db");
  end

  `uvm_info (get_type_name (), "building lpif agent", UVM_MEDIUM)
  
  ap_sent = new("ap_sent",this);
  ap_received = new("ap_received",this);
  lpif_monitor_h = lpif_monitor::type_id::create("lpif_monitor_h", this);
  lpif_monitor_h.lpif_agent_config_h = lpif_agent_config_h;
  
  if(lpif_agent_config_h.active == UVM_ACTIVE) begin
    lpif_sequencer_h = lpif_sequencer::type_id::create("lpif_sequencer_h", this);
    lpif_driver_h = lpif_driver::type_id::create("lpif_driver_h", this);
    lpif_driver_h.lpif_agent_config_h = lpif_agent_config_h;
  end

  if(lpif_agent_config_h.has_coverage_monitor) begin
    lpif_coverage_monitor_h = lpif_coverage_monitor::type_id::create("lpif_coverage_monitor_h", this);
  end
endfunction: build_phase

function void lpif_agent::connect_phase(uvm_phase phase);
  // Only connect the driver and the sequencer if active
  if(lpif_agent_config_h.active == UVM_ACTIVE) begin
    lpif_driver_h.seq_item_port.connect(lpif_sequencer_h.seq_item_export);
  end
  if(lpif_agent_config_h.has_coverage_monitor) begin 
    lpif_monitor_h.ap_sent.connect(lpif_coverage_monitor_h.analysis_export_sent);
    lpif_monitor_h.ap_received.connect(lpif_coverage_monitor_h.analysis_export_received);
  end
  lpif_monitor_h.ap_sent.connect(ap_sent);
  lpif_monitor_h.ap_received.connect(ap_received);
endfunction: connect_phase
