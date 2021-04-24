class pipe_link_up_seq extends uvm_sequence #(pipe_seq_item);
  `uvm_object_utils(pipe_link_up_seq)

  // Data Members
  pipe_agent_config pipe_agent_config_h;

  // Methods
  extern local task detect_state;
  extern local task detect_quiet_state;
  extern local task detect_active_state;
  extern local task polling_state;
  extern local task polling_active_state;
  extern local task polling_configuration_state;
  extern local task config_state;
  extern local task config_linkwidth_start_state_upstream;
  extern local task config_linkwidth_accept_state_upstream;
  extern local task config_lanenum_wait_state_upstream;
  extern local task config_lanenum_accept_state_upstream;
  extern local task config_complete_state_upstream;
  extern local task config_idle_state_upstream;
  extern local task config_linkwidth_start_state_downstream;
  extern local task config_linkwidth_accept_state_downstream;
  extern local task config_lanenum_wait_state_downstream;
  extern local task config_lanenum_accept_state_downstream;
  extern local task config_complete_state_downstream;
  extern local task config_idle_state_downstream;
  
  // Standard UVM Methods:
  extern function new(string name = "pipe_link_up_seq");
  extern task body;
  
endclass:pipe_link_up_seq

function pipe_link_up_seq::new(string name = "pipe_link_up_seq");
  super.new(name);
endfunction
  
task pipe_link_up_seq::body;
  detect_state;
  polling_state;
  config_state;
endtask: body

task pipe_link_up_seq::detect_state;

endtask

task pipe_link_up_seq::detect_quiet_state;

endtask

task pipe_link_up_seq::detect_active_state;

endtask

task pipe_link_up_seq::polling_state;
  `uvm_info("pipe_link_up_seq", "polling state started", UVM_MEDIUM);
  wait(pipe_agent_config_h.power_down_detected.triggered);
endtask

task pipe_link_up_seq::polling_active_state;
  //check on electrical idle
    pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");;
    start_item (pipe_seq_item_h);
    for (i = 0; i < 1024; i++) begin
    if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TS; & ts_sent.ts_type == TS1})
    begin
      `uvm_error(get_name(), "Can't randomize sequence item and send TS1s")
    end
    end
    finish_item (pipe_seq_item_h);
    
    int counter1_ts1_case1, counter2_ts1_case1, counter_ts2_case1;
    int counter1_ts1_case2, counter2_ts1_case2, counter2_ts2_case2;
    fork
    begin
      for (i = 0; i < 23; i++) begin
        send_ts(config_h); 
  
        //compliance we loopback supportedd?
        if (config_h.ts_type == TS1 & config_h.compliance == 0) begin
          counter1_ts1_case1 ++ ;
        end
  
        if (config_h.ts_type == TS2) begin
          counter_ts2_case1 ++ ;
        end
  
        if (config_h.ts_type == TS1 & config_h.loopback == 'b10) begin
          counter2_ts1_case1 ++ ;
        end
  
        if (counter1_ts1_case1 == 8 | counter2_ts1_case1 == 8 | counter_ts2_case1 == 8) begin
          break; 
        end
      end
    end
endtask

task pipe_link_up_seq::polling_configuration_state;

endtask

task pipe_link_up_seq::config_state;

endtask

task pipe_link_up_seq::config_linkwidth_start_state_upstream;

endtask

task pipe_link_up_seq::config_linkwidth_accept_state_upstream;

endtask

task pipe_link_up_seq::config_lanenum_wait_state_upstream;

endtask

task pipe_link_up_seq::config_lanenum_accept_state_upstream;

endtask

task pipe_link_up_seq::config_complete_state_upstream;

endtask

task pipe_link_up_seq::config_idle_state_upstream;

endtask

task pipe_link_up_seq::config_linkwidth_start_state_downstream;

endtask

task pipe_link_up_seq::config_linkwidth_accept_state_downstream;

endtask

task pipe_link_up_seq::config_lanenum_wait_state_downstream;

endtask

task pipe_link_up_seq::config_lanenum_accept_state_downstream;

endtask

task pipe_link_up_seq::config_complete_state_downstream;

endtask

task pipe_link_up_seq::config_idle_state_downstream;

endtask
