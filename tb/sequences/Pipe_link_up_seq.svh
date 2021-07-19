class pipe_link_up_seq extends pipe_base_seq;

  `uvm_object_utils(pipe_link_up_seq)

  ts_s ts_sent;
  ts_s tses_sent [];
  ts_s tses_received [];
  int idle_data_received [];

  rand gen_t           max_gen_supported;
  rand bit   [7:0]     link_number;
  rand bit   [7:0]     n_fts;
  rand int             random_start_polling;
  rand int             delay_clocks;

  constraint random_start_polling_c {random_start_polling inside {0,1,2};}
  constraint delay_clocks_c {delay_clocks inside {[10:15]};}
  // Methods
  extern local task detect_state;
  extern local task polling_state;
  extern local task polling_active_state;
  extern local task polling_configuration_state;
  extern local task receiving_8_ts1;
  extern local task sending_1024_ts1;
  extern local task config_state;
  extern local task config_linkwidth_start_state_upstream;
  extern local task config_linkwidth_accept_state_upstream;
  extern local task config_lanenum_wait_state_upstream;
  extern local task config_complete_state_upstream;
  extern local task config_linkwidth_start_state_downstream;
  extern local task config_linkwidth_accept_state_downstream;
  extern local task config_lanenum_wait_state_downstream;
  extern local task config_complete_state_downstream;
  extern local task config_idle_state;
  
  // Standard UVM Methods:
  extern function new(string name = "pipe_link_up_seq");
  extern task body;
  
endclass:pipe_link_up_seq

function pipe_link_up_seq::new(string name = "pipe_link_up_seq");
  super.new(name);
endfunction
  
task pipe_link_up_seq::body;
  `uvm_info("pipe_link_up_seq", "Started pipe_link_up_seq", UVM_MEDIUM)
  if(!this.randomize()) begin
    `uvm_fatal(get_name(), "Can't randomize the pipe_link_up_seq")
  end

  random_start_polling = 0;

  ts_sent.n_fts            = this.n_fts;
  ts_sent.lane_number      = 0;
  ts_sent.link_number      = this.link_number;
  ts_sent.use_n_fts        = 0;
  ts_sent.use_link_number  = 0;
  ts_sent.use_lane_number  = 0;
  ts_sent.max_gen_supported = this.max_gen_supported;
  ts_sent.ts_type          = TS1;

  tses_sent = new[`NUM_OF_LANES];
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

  if (random_start_polling == 2) begin
    fork
      detect_state;
      begin
        repeat(delay_clocks) @(pipe_agent_config_h.detected_posedge_clk_e);
        polling_state;
      end
    join
  end
  else begin
  detect_state;
  polling_state;
  end
  config_state;
  -> pipe_agent_config_h.link_up_finished_e;
  `uvm_info("pipe_link_up_seq", "Finished pipe_link_up_seq", UVM_MEDIUM)
endtask: body

task pipe_link_up_seq::detect_state;
  `uvm_info(get_name(), "waiting for receiver detection", UVM_MEDIUM)
  wait(pipe_agent_config_h.receiver_detected_e.triggered);
  `uvm_info(get_name(), "Receiver detected", UVM_MEDIUM)
endtask

task pipe_link_up_seq::polling_state;
  `uvm_info("pipe_link_up_seq", "polling state started", UVM_MEDIUM)
  polling_active_state;
  polling_configuration_state;
  `uvm_info("pipe_link_up_seq", "polling state finished", UVM_MEDIUM)
endtask

task pipe_link_up_seq::receiving_8_ts1; //Dut sending
  int rec_8_ts1 = 0;
  @(pipe_agent_config_h.DUT_start_polling_e);
  `uvm_info("pipe_link_up_seq", "print 1", UVM_MEDIUM)
  while (rec_8_ts1 < 8) begin
    @(pipe_agent_config_h.detected_tses_e);
      if(pipe_agent_config_h.tses_received[0].ts_type == TS1 && !(pipe_agent_config_h.tses_received[0].use_lane_number) &&  !(pipe_agent_config_h.tses_received[0].use_link_number)) begin
        rec_8_ts1++;
        `uvm_info("pipe_link_up_seq", "receiving ts1s", UVM_MEDIUM)
      end
      else
      `uvm_error(get_name(), "training sequences of polling active state received is not correct")
  end
endtask

//check variable option compliance or loopback in ts1?
task pipe_link_up_seq::sending_1024_ts1;
  int send_1024_ts1; 
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
  if (random_start_polling == 1) begin
    repeat(delay_clocks) begin
      @(pipe_agent_config_h.detected_posedge_clk_e);
      `uvm_info("Pipe_link_up_seq", "posedge clk came", UVM_LOW)
    end
  end
  for (send_1024_ts1 = 0; send_1024_ts1 < 1024; send_1024_ts1++) begin
  `uvm_info("Pipe_link_up_seq", "sending 1024 ts1", UVM_LOW)
  start_item (pipe_seq_item_h);
    if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TS; ts_sent.ts_type == TS1;})
    begin
      `uvm_error(get_name(), "Can't randomize sequence item and send TS1s")
    end
  finish_item (pipe_seq_item_h);
  end
endtask

task pipe_link_up_seq::polling_active_state;
  `uvm_info("Pipe_link_up_seq", $sformatf("delay_clocks = %d",delay_clocks), UVM_LOW)
  `uvm_info("Pipe_link_up_seq", $sformatf("random_start_polling = %d",random_start_polling), UVM_LOW)
  fork
    begin
      sending_1024_ts1;
      `uvm_info("Pipe_link_up_seq", "1024 ts1 sent", UVM_LOW)
    end
    begin
      receiving_8_ts1;
    end
  join
endtask

task pipe_link_up_seq::polling_configuration_state;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
  wait(pipe_agent_config_h.detected_tses_e.triggered)
  `uvm_info("pipe_link_up_seq", $sformatf("print tsemad: %p",pipe_agent_config_h.tses_received), UVM_MEDIUM)
  while (pipe_agent_config_h.tses_received[0].ts_type == TS1) begin
    start_item (pipe_seq_item_h);
        if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TS; ts_sent.ts_type == TS2;})
        begin
          `uvm_error(get_name(), "Can't randomize sequence item and send TS2s")
        end
    finish_item (pipe_seq_item_h);
    wait(pipe_agent_config_h.detected_tses_e.triggered);
  end
  fork
    begin
      int rec_8_ts2 = 0;
      while(rec_8_ts2 < 8) begin
      wait(pipe_agent_config_h.detected_tses_e.triggered)
      `uvm_info("pipe_link_up_seq", $sformatf("print ts2 received"), UVM_MEDIUM)
      if(pipe_agent_config_h.tses_received[0].ts_type == TS2 && !(pipe_agent_config_h.tses_received[0].use_lane_number) &&  !(pipe_agent_config_h.tses_received[0].use_link_number)) begin
        rec_8_ts2++;
      end
      else       
      `uvm_error(get_name(), "training sequences of polling config state received is not correct")
      end
    end
  
    begin
      for (int i = 0; i < 16; i++) begin
      start_item (pipe_seq_item_h);
      pipe_seq_item_h.pipe_operation = SEND_TS;
      pipe_seq_item_h.ts_sent.ts_type = TS2;
      // if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TS; ts_sent.ts_type == TS2;})
      // begin
      //   `uvm_error(get_name(), "Can't randomize sequence item and send TS2s")
      // end
      finish_item (pipe_seq_item_h);
      end
    end
  join
endtask

task pipe_link_up_seq::config_state;
  `uvm_info("pipe_link_up_seq", $sformatf("env type: %b",IS_ENV_UPSTREAM), UVM_MEDIUM)
  if (IS_ENV_UPSTREAM) begin
  config_linkwidth_start_state_upstream;
  config_linkwidth_accept_state_upstream;
  config_lanenum_wait_state_upstream;
  config_complete_state_upstream;
  config_idle_state;
  end
  else begin
  config_linkwidth_start_state_downstream;
  config_linkwidth_accept_state_downstream;
  config_lanenum_wait_state_downstream;
  config_complete_state_downstream;
  config_idle_state;
  end
endtask

task pipe_link_up_seq::config_linkwidth_start_state_upstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int unsigned num_of_ts1s_with_non_pad_link_number [`NUM_OF_LANES];
  bit two_consecutive_ts1s_with_non_pad_link_number_detected;
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  pipe_seq_item_h.tses_sent = tses_sent;
  // Initialize the num_of_ts2_received array with zeros
  `uvm_info("pipe_link_up_seq", "Entered config_linkwidth_start_state_upstream", UVM_MEDIUM)
  foreach(num_of_ts1s_with_non_pad_link_number[i])
  begin
    num_of_ts1s_with_non_pad_link_number[i] = 0;
  end
  // Transmit TS1s until 2 consecutive TS2s are receivedIUM)
  two_consecutive_ts1s_with_non_pad_link_number_detected = 0;
  fork
    begin
      while (!two_consecutive_ts1s_with_non_pad_link_number_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
        `uvm_info("pipe_link_up_seq", "TS1 with PAD Link and Lane numbers sent", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "TS1 with Non-PAD Link number received", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "2 Consecutive TS1s with Non-PAD Link number are Detected", UVM_MEDIUM)
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_linkwidth_accept_state_upstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  bit [7:0] used_link_num;
  bit ts1_with_non_pad_lane_number_detected;
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  `uvm_info("pipe_link_up_seq", "Entered config_linkwidth_accept_state_upstream", UVM_MEDIUM)
  // Use the link number of the ts1s on the first lane to be transmitted
  used_link_num = tses_received[0].link_number;
  foreach(tses_sent[i])
  begin
    tses_sent[i].link_number = used_link_num;
    tses_sent[i].use_link_number = 1;
    tses_sent[i].use_lane_number = 0;
  end
  pipe_seq_item_h.tses_sent = tses_sent;
  // Send ts1s with this link number until some ts1s are received with non PAD lane number
  ts1_with_non_pad_lane_number_detected = 0;
  fork
    begin
      while (!ts1_with_non_pad_lane_number_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
        `uvm_info("pipe_link_up_seq", "TS1 with received Link number sent", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "TS1 with Non-PAD Lane number received", UVM_MEDIUM)
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
  int num_of_ts2_received [`NUM_OF_LANES];
  bit two_consecutive_ts2s_detected;
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  pipe_seq_item_h.tses_sent = tses_sent;
  `uvm_info("pipe_link_up_seq", "Entered config_lanenum_wait_state_upstream", UVM_MEDIUM)
  // Initialize the num_of_ts2_received array with zeros
  foreach(num_of_ts2_received[i])
  begin
    num_of_ts2_received[i] = 0;
  end
  // Transmit TS1s until 2 consecutive TS2s are received
  `uvm_info("pipe_link_up_seq", "config_lanenum_wait_state_upstream1", UVM_MEDIUM)

  two_consecutive_ts2s_detected = 0;
  fork
    begin
      while (!two_consecutive_ts2s_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
        `uvm_info("pipe_link_up_seq", "TS1 with Non-PAD Link and Lane numbers sent", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "TS2 with the same Link number and Lane number received", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "2 Consecutive TS2s with the same Link number and Lane number are Detected", UVM_MEDIUM)
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_complete_state_upstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int num_of_ts2_received [`NUM_OF_LANES];
  bit eight_consecutive_ts2s_detected;
  int i;
  `uvm_info("pipe_link_up_seq", "Entered config_complete_state_upstream", UVM_MEDIUM)
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
  eight_consecutive_ts2s_detected = 0;
  fork
    begin
      @(pipe_agent_config_h.detected_tses_e);

      for (i = 0; i < 16; i++)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
        `uvm_info("pipe_link_up_seq", "TS2 with the correct Link and Lane numbers sent", UVM_MEDIUM)
      end
      `uvm_info("pipe_link_up_seq", "16 TS2s with the correct Link and Lane numbers are Sent", UVM_MEDIUM)

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
            `uvm_info("pipe_link_up_seq", "TS2 with the correct Link and Lane numbers received", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "8 Consecutive TS2s with the correct Link and Lane numbers are Detected", UVM_MEDIUM)
          end
        end
      end
    end
  join
endtask


task pipe_link_up_seq::config_linkwidth_start_state_downstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int unsigned num_of_detected_ts1s_with_same_link_number [`NUM_OF_LANES];
  bit two_ts1s_with_same_link_number_detected;
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  `uvm_info("pipe_link_up_seq", "Entered config_linkwidth_start_state_downstream", UVM_MEDIUM)
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
  two_ts1s_with_same_link_number_detected = 0;
  fork
    begin
      while (!two_ts1s_with_same_link_number_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
        `uvm_info("pipe_link_up_seq", "TS1 with the generated Link number sent", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "TS1 with the same Link number received", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "2 Consecutive TS1s with Link no. that matches transmitted Link number are Detected", UVM_MEDIUM)
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_linkwidth_accept_state_downstream;
  `uvm_info("pipe_link_up_seq", "Entered config_linkwidth_accept_state_downstream", UVM_MEDIUM)
  // Update the lane numbers to start with zero and increase sequentially
  foreach(tses_sent[i])
  begin
    tses_sent[i].lane_number = `NUM_OF_LANES - i - 1;
    tses_sent[i].use_lane_number = 1;
  end
endtask

task pipe_link_up_seq::config_lanenum_wait_state_downstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int unsigned num_of_detected_ts1s_with_same_lane_numbers;
  bit two_ts1s_with_same_lane_numbers_detected;
  bit all_lane_numbers_are_correct;
  `uvm_info("pipe_link_up_seq", "Entered config_lanenum_wait_state_downstream", UVM_MEDIUM)
  pipe_seq_item_h.pipe_operation = SEND_TSES;
  pipe_seq_item_h.tses_sent = tses_sent;
  // Send ts1s with the generated lane numbers until two ts1s are received with the same link numbers
  num_of_detected_ts1s_with_same_lane_numbers = 0;
  two_ts1s_with_same_lane_numbers_detected = 0;
  fork
    begin
      while (!two_ts1s_with_same_lane_numbers_detected)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
        `uvm_info("pipe_link_up_seq", "TS1 with the generated Lane numbers sent", UVM_MEDIUM)
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
          `uvm_info("pipe_link_up_seq", "TS1 with same Lane numbers Detected", UVM_MEDIUM)
        end
        else
        begin
          num_of_detected_ts1s_with_same_lane_numbers = 0;
        end

        // Check if all lane detected 2 cosecutive ts1s with the same lane numbers
        if(num_of_detected_ts1s_with_same_lane_numbers == 2)
        begin
          two_ts1s_with_same_lane_numbers_detected = 1;
          `uvm_info("pipe_link_up_seq", "2 TS1s with the same Link number and Lane number are Detected", UVM_MEDIUM)
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_complete_state_downstream;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int num_of_ts2_received [`NUM_OF_LANES];
  bit eight_consecutive_ts2s_detected;
  int i;
  `uvm_info("pipe_link_up_seq", "Entered config_complete_state_downstream", UVM_MEDIUM)
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
  eight_consecutive_ts2s_detected = 0;
  fork
    begin
      @(pipe_agent_config_h.detected_tses_e);

      for (i = 0; i < 16; i++)
      begin
        start_item(pipe_seq_item_h);
        finish_item(pipe_seq_item_h);
        `uvm_info("pipe_link_up_seq", "TS2 with the correct Link and Lane numbers sent", UVM_MEDIUM)
      end
      `uvm_info("pipe_link_up_seq", "16 TS2s with the correct Link and Lane numbers are Sent", UVM_MEDIUM)

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
            `uvm_info("pipe_link_up_seq", "TS2 with the correct Link and Lane numbers received", UVM_MEDIUM)
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
            `uvm_info("pipe_link_up_seq", "8 Consecutive TS2s with the correct Link and Lane numbers are Detected", UVM_MEDIUM)
          end
        end
      end
    end
  join
endtask

task pipe_link_up_seq::config_idle_state;
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  int num_of_idle_data_received;
  bit eight_consecutive_idle_data_detected;
  bit one_idle_data_received;
  int i;
  `uvm_info("pipe_link_up_seq", "Entered config_idle_state", UVM_MEDIUM)
  pipe_seq_item_h.pipe_operation = IDLE_DATA_TRANSFER;

  // Initialize the num_of_idle_data_received array with zeros
  num_of_idle_data_received = 0;

  // Transmit 16 idle data until 8 consecutive idle data are received
  eight_consecutive_idle_data_detected = 0;
  fork
    begin
      @(pipe_agent_config_h.idle_data_detected_e);
      one_idle_data_received = 1;
      `uvm_info("pipe_link_up_seq", "one_idle_data_received = 1", UVM_MEDIUM)
    end

    begin 
      while (!one_idle_data_received)
      begin
        start_item(pipe_seq_item_h);
        pipe_seq_item_h.pipe_operation = IDLE_DATA_TRANSFER;
        finish_item(pipe_seq_item_h);
        start_item(pipe_seq_item_h);
        pipe_seq_item_h.pipe_operation = pipe_agent_pkg::SEND_DATA;
        finish_item(pipe_seq_item_h);
      end
    end

    begin
      wait (one_idle_data_received);
        for (i = 0; i < 16; i++)
        begin
          start_item(pipe_seq_item_h);
          pipe_seq_item_h.pipe_operation = IDLE_DATA_TRANSFER;
          finish_item(pipe_seq_item_h);
          `uvm_info("pipe_link_up_seq", "idle data sent", UVM_MEDIUM)
        end
        start_item(pipe_seq_item_h);
        pipe_seq_item_h.pipe_operation = pipe_agent_pkg::SEND_DATA;
        finish_item(pipe_seq_item_h);
        `uvm_info("pipe_link_up_seq", "16 Idle Data are Sent", UVM_MEDIUM)
    end
 
    begin
      while (!eight_consecutive_idle_data_detected)
      begin
        @(pipe_agent_config_h.idle_data_detected_e);
        
        num_of_idle_data_received += 1;
        `uvm_info("pipe_link_up_seq", "idle data received", UVM_MEDIUM)

        // Check if 8 consecutive idle data detected
        if(num_of_idle_data_received == 8) 
        begin
          eight_consecutive_idle_data_detected = 1;
          `uvm_info("pipe_link_up_seq", "8 Consecutive Idle Data are Detected", UVM_MEDIUM)
        end
      end
    end
  join
endtask
