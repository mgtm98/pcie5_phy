class lpif_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(lpif_agent)

//------------------------------------------
// Data Members
//------------------------------------------
lpif_agent_config lpif_agent_config_h;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(lpif_seq_item) ap;
lpif_monitor   lpif_monitor_h;
lpif_sequencer lpif_sequencer_h;
lpif_driver    lpif_driver_h;
lpif_coverage_monitor lpif_coverage_monitor_h;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "lpif_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass: lpif_agent


function lpif_agent::new(string name = "lpif_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void lpif_agent::build_phase(uvm_phase phase);
  `get_config(lpif_agent_config, lpif_agent_config_h , "lpif_agent_config")
  // Monitor is always present
  lpif_monitor_h = lpif_monitor::type_id::create("lpif_monitor_h", this);
  lpif_monitor_h.lpif_agent_config_h = lpif_agent_config_h;

  if(lpif_agent_config_h.active == UVM_ACTIVE) 
  begin
  lpif_driver_h.lpif_agent_config_h = lpif_agent_config_h;
  lpif_sequencer_h = lpif_sequencer::type_id::create("lpif_sequencer_h", this);
  lpif_driver_h = lpif_driver::type_id::create("lpif_driver_h", this);
  end

  if(lpif_agent_config_h.has_functional_coverage) 
  begin
    lpif_coverage_monitor_h = lpif_coverage_monitor::type_id::create("lpif_coverage_monitor_h", this);
  end
endfunction: build_phase

function void lpif_agent::connect_phase(uvm_phase phase);
  ap = lpif_monitor_h.ap;
  // Only connect the driver and the sequencer if active
  if(lpif_agent_config_h.active == UVM_ACTIVE) 
  begin
    lpif_driver_h.seq_item_port.connect(lpif_sequencer_h.seq_item_export);
  end
  if(lpif_agent_config_h.has_functional_coverage) 
  begin
    lpif_monitor_h.ap.connect(lpif_coverage_monitor_h.analysis_export);
  end

endfunction: connect_phase
