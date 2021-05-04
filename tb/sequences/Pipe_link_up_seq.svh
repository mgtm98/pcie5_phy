class pipe_link_up_seq extends pipe_base_seq;

  `uvm_object_utils(pipe_link_up_seq)

  ts_s ts_sent;
  ts_s tses_sent [`NUM_OF_LANES];
  ts_s tses_received [`NUM_OF_LANES];
  int idle_data_received [`NUM_OF_LANES];

  rand gen_t           max_gen_supported;
  rand bit   [7:0]     link_number;
  rand bit   [7:0]     n_fts;

  // Methods
  extern local task detect_state;
  extern local task polling_state;
  extern local task polling_active_state;
  extern local task polling_configuration_state;
  extern local task config_state;
  extern local task config_linkwidth_start_state_upstream;
  extern local task config_linkwidth_accept_state_upstream;
  extern local task config_lanenum_wait_state_upstream;
  extern local task config_complete_state_upstream;
  extern local task config_idle_state_upstream;
  extern local task config_linkwidth_start_state_downstream;
  extern local task config_linkwidth_accept_state_downstream;
  extern local task config_lanenum_wait_state_downstream;
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
  super.body;
  if(!this.randomize()) begin
    `uvm_fatal(get_name(), "This object can't be randomized")
  end

  ts_sent.n_fts            = this.n_fts;
  ts_sent.lane_number      = 0;
  ts_sent.link_number      = this.link_number;
  ts_sent.use_n_fts        = 0;
  ts_sent.use_link_number  = 0;
  ts_sent.use_lane_number  = 0;
  ts_sent.max_gen_supported = this.max_gen_supported;
  ts_sent.ts_type          = TS1;

  for (int i = 0; i < `NUM_OF_LANES; i++) begin
    tses_sent[i].n_fts            = this.n_fts;
    tses_sent[i].lane_number      = i;
    tses_sent[i].link_number      = this.link_number;
    tses_sent[i].use_n_fts        = 0;
    tses_sent[i].use_link_number  = 0;
    tses_sent[i].use_lane_number  = 0;
    tses_sent[i].max_gen_supported = this.max_gen_supported;
    tses_sent[i].ts_type          = TS1;
  end

  detect_state;
  polling_state;
  config_state;
  -> pipe_agent_config_h.link_up_finished_e;
endtask: body

task pipe_link_up_seq::detect_state;
  wait(pipe_agent_config_h.receiver_detected_e.triggered);
  `uvm_info("pipe_link_up_seq", "Receiver detected", UVM_MEDIUM);
endtask

task pipe_link_up_seq::polling_state;
  `uvm_info("pipe_link_up_seq", "polling state started", UVM_MEDIUM);
  wait(pipe_agent_config_h.start_polling.triggered);
  polling_active_state;
  polling_configuration_state;
endtask

task pipe_link_up_seq::polling_active_state;
    pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
    int counter1_ts1_case1, counter2_ts1_case1, counter_ts2_case1;
    int counter1_ts1_case2, counter2_ts1_case2, counter_ts2_case2;
    start_item (pipe_seq_item_h);
    for (int i = 0; i < 1024; i++) begin
    if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TS; ts_sent.ts_type == TS1;})
    begin
      `uvm_error(get_name(), "Can't randomize sequence item and send TS1s")
    end
    end
    finish_item (pipe_seq_item_h);
    
    fork
    begin
      for (int i = 0; i < 23; i++) begin
        wait(pipe_agent_config_h.detected_tses.triggered)
        begin
        //compliance we loopback supportedd in ts configs? ts_rec contain config of tses
        if (pipe_agent_config_h.ts_rec.ts_type == TS1 & pipe_agent_config_h.ts_rec.compliance == 0) begin
          counter1_ts1_case1 ++ ;
        end
  
        if (pipe_agent_config_h.ts_rec.ts_type == TS2) begin
          counter_ts2_case1 ++ ;
        end
  
        if (pipe_agent_config_h.ts_rec.ts_type == TS1 & pipe_agent_config_h.ts_rec.loopback == 'b10) begin
          counter2_ts1_case1 ++ ;
        end
  
        if (counter1_ts1_case1 == 8 | counter2_ts1_case1 == 8 | counter_ts2_case1 == 8) begin
          break; 
        end
        end
      end
    end
    begin
      #24ms; 
      for (int i = 0; i < 23; i++) begin
        wait(pipe_agent_config_h.detected_tses.triggered);
        // TODO: Check this
        // if (ts_rec.ts_type == TS1 & ts_rec.compliance == 0) begin
        //   counter1_ts1_case2 ++ ;
        // end
    
        // TODO: Check this
        // if (ts_rec.ts_type == TS2) begin
        //   counter_ts2_case2 ++ ;
        // end
    
        // TODO: Check this
        // if (ts_rec.ts_type == TS1 & ts_rec.loopback == 'b10) begin
        //   counter2_ts1_case2 ++ ;
        // end
    
        if (counter1_ts1_case2 == 8 | counter2_ts1_case2 == 8 | counter_ts2_case2 == 8) begin
          break; 
        end
      end
    end
    join_any
endtask

task pipe_link_up_seq::polling_configuration_state;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
  int j = 0;
  fork
    begin
      while(j<8) begin
        wait(pipe_agent_config_h.detected_tses.triggered)
        if(pipe_agent_config_h.ts_rec.ts_type == TS2) begin
          j++;
        end
      end
    end

    begin
    start_item (pipe_seq_item_h);
    for (int i = 0; i < 16; i++) begin
      if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TS; ts_sent.ts_type == TS2;})
      begin
        `uvm_error(get_name(), "Can't randomize sequence item and send TS1s")
      end
      end
    finish_item (pipe_seq_item_h);
    end
  join
endtask

task pipe_link_up_seq::config_state;
  // Upstream
  config_linkwidth_start_state_upstream;
  config_linkwidth_accept_state_upstream;
  config_lanenum_wait_state_upstream;
  config_complete_state_upstream;
  config_idle_state_upstream;
  // Downstream
  // config_linkwidth_start_state_downstream;
  // config_linkwidth_accept_state_downstream;
  // config_lanenum_wait_state_downstream;
  // config_complete_state_downstream;
  // config_idle_state_downstream;
endtask

task pipe_link_up_seq::config_linkwidth_start_state_upstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int unsigned num_of_ts1s_with_non_pad_link_number [`NUM_OF_LANES];
  bit two_consecutive_ts1s_with_non_pad_link_number_detected = 0;
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  pipe_seq_item_h.tses_sent = tses_sent;
  // Initialize the num_of_ts2_received array with zeros
  foreach(num_of_ts1s_with_non_pad_link_number[i])
  begin
    num_of_ts1s_with_non_pad_link_number[i] = 0;
  end
  // Transmit TS1s until 2 consecutive TS2s are received
  fork
    begin
      while (!two_consecutive_ts1s_with_non_pad_link_number_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end

    begin
      while (!two_consecutive_ts1s_with_non_pad_link_number_detected)
      begin
        @(pipe_agent_config_h.detected_tses_e);
        tses_received = pipe_agent_config_h.tses_received;
        foreach(tses_received[i])
        begin
          if(tses_received[i].ts_type == TS1 && tses_received[i].use_link_number)
          begin
            num_of_ts1s_with_non_pad_link_number[i] += 1;
          end
          else
          begin
            num_of_ts1s_with_non_pad_link_number[i] = 0;
          end
        end
        // Check if any lane detected 2 consecutive ts2s
        foreach(num_of_ts1s_with_non_pad_link_number[i])
        begin
          if(num_of_ts1s_with_non_pad_link_number[i] == 2)
          begin
            two_consecutive_ts1s_with_non_pad_link_number_detected = 1;
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_linkwidth_accept_state_upstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  bit [7:0] used_link_num = tses_received[0].link_number;
  int unsigned ts1_with_non_pad_lane_number_detected = 0;
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  // Use the link number of the ts1s on the first lane to be transmitted
  foreach(tses_sent[i])
  begin
    tses_sent[i].link_number = used_link_num;
    tses_sent[i].use_link_number = 1;
    tses_sent[i].use_lane_number = 0;
  end
  pipe_seq_item_h.tses_sent = tses_sent;
  // Send ts1s with this link number until some ts1s are received with non PAD lane number
  fork
    begin
      while (!ts1_with_non_pad_lane_number_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end
    begin
      while (!ts1_with_non_pad_lane_number_detected)
      begin
        @(pipe_agent_config_h.detected_tses_e);
        tses_received = pipe_agent_config_h.tses_received;
        // Check if any ts1 received has a non PAD lane number
        foreach(tses_received[i])
        begin
          // Make sure the tses received are ts1s
          assert (tses_received[i].ts_type == TS1) 
          else   `uvm_error(get_name(), "Expected TS1s but detected TS2s")
          // Non PAD lane number
          if(tses_received[i].use_lane_number)
          begin
            ts1_with_non_pad_lane_number_detected = 1;
          end
        end
      end
    end
  join
  // Get the lane numbers from the received ts1s
  foreach(tses_received[i])
  begin
    assert (tses_received[i].lane_number == i) 
    else   `uvm_error(get_name(), "the order of lane numbers are incorrect")
    tses_sent[i].lane_number = tses_received[i].lane_number;
    tses_sent[i].use_lane_number = 1;
  end
endtask

task pipe_link_up_seq::config_lanenum_wait_state_upstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  bit two_consecutive_ts2s_detected = 0;
  int num_of_ts2_received [`NUM_OF_LANES];
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  pipe_seq_item_h.tses_sent = tses_sent;
  // Initialize the num_of_ts2_received array with zeros
  foreach(num_of_ts2_received[i])
  begin
    num_of_ts2_received[i] = 0;
  end
  // Transmit TS1s until 2 consecutive TS2s are received
  fork
    begin
      while (!two_consecutive_ts2s_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end

    begin
      while (!two_consecutive_ts2s_detected)
      begin
        @(pipe_agent_config_h.detected_tses_e);
        tses_received = pipe_agent_config_h.tses_received;
        foreach(tses_received[i])
        begin
          if(tses_received[i].ts_type == TS2)
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
      end
    end
  join
endtask

task pipe_link_up_seq::config_complete_state_upstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  bit eight_consecutive_ts2s_detected = 0;
  int num_of_ts2_received [`NUM_OF_LANES];  
  pipe_seq_item_h.pipe_operation = SEND_TSES;

  // Initialize the num_of_ts2_received array with zeros
  foreach(num_of_ts2_received[i])
  begin
    num_of_ts2_received[i] = 0;
  end

  foreach (tses_sent[i]) begin
    tses_sent[i].ts_type = TS2;
  end
  
  pipe_seq_item_h.tses_sent = tses_sent;

  // Transmit 16 TS2s until 8 consecutive TS2s are received
  fork
    begin
      @(pipe_agent_config_h.detected_tses_e);

      for (int i = 0; i < 16; i++)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end

      while (!eight_consecutive_ts2s_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end

    begin
      while (!eight_consecutive_ts2s_detected)
      begin
        @(pipe_agent_config_h.detected_tses_e);
        tses_received = pipe_agent_config_h.tses_received;
        
        foreach(tses_received[i])
        begin
          if(tses_received[i].ts_type == TS2)
          begin
            num_of_ts2_received[i] += 1;
          end
          else
          begin
            num_of_ts2_received[i] = 0;
          end
        end

        // Check if any lane detected 8 consecutive ts2s
        foreach(num_of_ts2_received[i])
        begin
          if(num_of_ts2_received[i] == 8)
          begin
            eight_consecutive_ts2s_detected = 1;
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_idle_state_upstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int num_of_idle_data_received [`NUM_OF_LANES];
  bit eight_consecutive_idle_data_detected = 0;
  pipe_seq_item_h.pipe_operation = SEND_IDLE_DATA;

  // Initialize the num_of_idle_data_received array with zeros
  foreach(num_of_idle_data_received[i])
  begin
    num_of_idle_data_received[i] = 0;
  end

  // Transmit 16 idle data until 8 consecutive idle data are received
  fork
    begin
      @(pipe_agent_config_h.idle_data_detected_e);

      for (int i = 0; i < 16; i++)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end

    begin
      while (!eight_consecutive_idle_data_detected)
      begin
        @(pipe_agent_config_h.idle_data_detected_e);
        
        foreach(idle_data_received[i])
        begin
          begin
            num_of_idle_data_received[i] += 1;
          end
        end

        // Check if any lane detected 8 consecutive idle data
        foreach(num_of_idle_data_received[i])
        begin
          if(num_of_idle_data_received[i] == 8)
          begin
            eight_consecutive_idle_data_detected = 1;
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_linkwidth_start_state_downstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int unsigned num_of_detected_ts1s_with_same_link_number [`NUM_OF_LANES];  
  bit two_ts1s_with_same_link_number_detected = 0;
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  foreach(tses_sent[i])
  begin
    tses_sent[i].link_number = link_number;
    tses_sent[i].use_link_number = 1;
  end
  pipe_seq_item_h.tses_sent = tses_sent;
  // Initialize the num_of_detected_ts1s_with_same_link_number array with zeros
  foreach(num_of_detected_ts1s_with_same_link_number[i])
  begin
    num_of_detected_ts1s_with_same_link_number[i] = 0;
  end
  // Send ts1s with the generated link number until two ts1s are received with the same link number
  fork
    begin
      while (!two_ts1s_with_same_link_number_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end
    begin
      while (!two_ts1s_with_same_link_number_detected)
      begin
        @(pipe_agent_config_h.detected_tses_e);
        tses_received = pipe_agent_config_h.tses_received;
        
        foreach(tses_received[i])
        begin
          if(tses_received[i].link_number == link_number && tses_received[i].use_link_number)
          begin
            num_of_detected_ts1s_with_same_link_number[i] += 1;
          end
          else
          begin
            num_of_detected_ts1s_with_same_link_number[i] = 0;
          end
        end

        // Check if any lane detected 2 cosecutive ts1s with the same link number
        foreach(num_of_detected_ts1s_with_same_link_number[i])
        begin
          if(num_of_detected_ts1s_with_same_link_number[i] == 2)
          begin
            two_ts1s_with_same_link_number_detected = 1;
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_linkwidth_accept_state_downstream;
  // Update the lane numbers to start with zero and increase sequentially
  foreach(tses_sent[i])
  begin
    tses_sent[i].lane_number = i;
    tses_sent[i].use_lane_number = 1;
  end
endtask

task pipe_link_up_seq::config_lanenum_wait_state_downstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int unsigned num_of_detected_ts1s_with_same_lane_numbers = 0;
  bit two_ts1s_with_same_lane_numbers_detected = 0;
  bit all_lane_numbers_are_correct = 1;
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  pipe_seq_item_h.tses_sent = tses_sent;
  // Send ts1s with the generated lane numbers until two ts1s are received with the same link numbers
  fork
    begin
      while (!two_ts1s_with_same_lane_numbers_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end
    begin
      while (!two_ts1s_with_same_lane_numbers_detected)
      begin
        @(pipe_agent_config_h.detected_tses_e);
        tses_received = pipe_agent_config_h.tses_received;
        
        all_lane_numbers_are_correct = 1;
        foreach(tses_received[i])
        begin
          if(tses_received[i].lane_number != tses_sent[i].lane_number || !tses_received[i].use_lane_number)
          begin
            all_lane_numbers_are_correct = 0;
          end
        end
        if (all_lane_numbers_are_correct)
        begin
          num_of_detected_ts1s_with_same_lane_numbers += 1;
        end
        else
        begin
          num_of_detected_ts1s_with_same_lane_numbers = 0;
        end

        // Check if all lane detected 2 cosecutive ts1s with the same lane numbers
        if(num_of_detected_ts1s_with_same_lane_numbers == 2)
        begin
          two_ts1s_with_same_lane_numbers_detected = 1;
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_complete_state_downstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int num_of_ts2_received [`NUM_OF_LANES];
  bit eight_consecutive_ts2s_detected = 0;
  pipe_seq_item_h.pipe_operation = SEND_TSES;

  // Initialize the num_of_ts2_received array with zeros
  foreach(num_of_ts2_received[i])
  begin
    num_of_ts2_received[i] = 0;
  end

  foreach (tses_sent[i]) begin
    tses_sent[i].ts_type = TS2;
  end
  
  pipe_seq_item_h.tses_sent = tses_sent;

  // Transmit 16 TS2s until 8 consecutive TS2s are received
  fork
    begin
      @(pipe_agent_config_h.detected_tses_e);

      for (int i = 0; i < 16; i++)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end

      while (!eight_consecutive_ts2s_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end

    begin
      while (!eight_consecutive_ts2s_detected)
      begin
        @(pipe_agent_config_h.detected_tses_e);
        tses_received = pipe_agent_config_h.tses_received;
        
        foreach(tses_received[i])
        begin
          if(tses_received[i].ts_type == TS2)
          begin
            num_of_ts2_received[i] += 1;
          end
          else
          begin
            num_of_ts2_received[i] = 0;
          end
        end

        // Check if any lane detected 8 consecutive ts2s
        foreach(num_of_ts2_received[i])
        begin
          if(num_of_ts2_received[i] == 8)
          begin
            eight_consecutive_ts2s_detected = 1;
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_idle_state_downstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int num_of_idle_data_received [`NUM_OF_LANES];
  bit eight_consecutive_idle_data_detected = 0;
  pipe_seq_item_h.pipe_operation = SEND_IDLE_DATA;

  // Initialize the num_of_idle_data_received array with zeros
  foreach(num_of_idle_data_received[i])
  begin
    num_of_idle_data_received[i] = 0;
  end

  // Transmit 16 idle data until 8 consecutive idle data are received
  fork
    begin
      @(pipe_agent_config_h.idle_data_detected_e);

      for (int i = 0; i < 16; i++)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
      end
    end

    begin
      while (!eight_consecutive_idle_data_detected)
      begin
        @(pipe_agent_config_h.idle_data_detected_e);
        
        foreach(idle_data_received[i])
        begin
          begin
            num_of_idle_data_received[i] += 1;
          end
        end

        // Check if any lane detected 8 consecutive idle data
        foreach(num_of_idle_data_received[i])
        begin
          if(num_of_idle_data_received[i] == 8)
          begin
            eight_consecutive_idle_data_detected = 1;
          end
        end
      end
    end
  join
endtask
