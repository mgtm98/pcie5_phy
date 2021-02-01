class pipe_agent extends uvm_agent;

  `uvm_component_utils(pipe_agent);
  
  pipe_driver                       pipe_driver_h;
  pipe_monitor                      pipe_monitor_h;
  pipe_sequencer                    pipe_sequencer_h;
  pipe_coverage_monitor             pipe_coverage_monitor_h;
  pipe_agent_config                 pipe_agent_config_h;
  uvm_analysis_port#(pipe_seq_item) ap;

  function pipe_agent::new(string name = "pipe_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: pipe_agent


function void pipe_agent::build_phase(uvm_phase phase);
  // Get configuration object from UVM database
  if(!uvm_config_db#(pipe_agent_config)::get(this, "", "pipe_config_db", pipe_agent_config_h)) begin
    `uvm_fatal(this.get_name(), "Can't get PIPE Agent configuration object");
  end
  
  // creating standard objects in every agent (Monitor, Analysis Port)
  pipe_monitor_h = pipe_monitor::type_id::create("pipe_monitor", this);
  ap = new("pipe_analysis_port", this);

  // check if the agent is configured to have coverage monitor
  if(pipe_agent_config_h.has_coverage_monitor) begin
    pipe_coverage_monitor_h = pipe_coverage_monitor::type_id::create("pipe_coverage_monitor", this);
  end

  // check if the agent is configured to be active (have a driver)
  if(pipe_agent_config_h.active == UVM_ACTIVE) begin
    pipe_driver_h = pipe_driver::type_id::create("pipe_driver", this);
    pipe_sequencer_h = pipe_sequencer::type_id::create("pipe_sequencer", this);
  end
endfunction: build_phase

function void pipe_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  // pass monitor virtual interface (monitor_bfm) to the monitor
  pipe_monitor_h.pipe_monitor_bfm_h = pipe_agent_config_h.pipe_monitor_bfm_h;

  // connecting monitor analysis port by the agent analysis port
  pipe_monitor_h.ap.connect(this.ap);

  // check ig agent is active
  if(pipe_agent_config_h.active == UVM_ACTIVE) begin
    // pass driver virtual interface (driver_bfm) to the driver
    pipe_driver_h.pipe_driver_bfm_h = pipe_agent_config_h.pipe_driver_bfm;
    // connecting driver sequence item port with the driver sequence item export
    pipe_driver_h.seq_item_port.connect(pipe_sequencer_h.seq_item_export);
  end
endfunction: connect_phase  
