class pipe_speed_change_without_equalization_seq extends pipe_base_seq;

  `uvm_object_utils(pipe_link_up_seq)

  rand gen_t max_supported_gen_by_dsp;
  gen_t max_supported_by_usp;

  // Standard UVM Methods:
  extern function new(string name = "pipe_speed_change_without_equalization_seq");
  extern task body;

  extern task send_seq_item(ts_s tses [`NUM_OF_LANES]);
  extern task get_tses_recived(output ts_s tses [`NUM_OF_LANES] );
  
endclass:pipe_speed_change_without_equalization_seq

function pipe_speed_change_without_equalization_seq::new(string name = "pipe_speed_change_without_equalization_seq");
  super.new(name);
endfunction

task automatic pipe_speed_change_without_equalization_seq::body();
  ts_s tses_send [`NUM_OF_LANES];
  ts_s tses_recv [`NUM_OF_LANES];
  bit flag;
  int ts2_recived_count = 1;
  int ts2_sent_count = 0;
  pipe_seq_item pipe_seq_item_h;
  
  // receive TS1 with speed_change bit asserted
  this.get_tses_recived(tses_recv);
  foreach(tses_recv[i]) begin
    assert(tses_recv[i].speed_change && tses_recv[i].ts_type == TS1) else 
      `uvm_fatal("pipe_speed_change_without_equalization_seq", "");
  end
  
  // save the USP max gen supported
  this.max_supported_by_usp = tses_recv[0].max_gen_supported;

  // send TS1 until TS2 is recived from USP
  fork
    // send TS1
    while (1) begin
      tses_send  = super.tses;
      foreach(tses_send[i]) begin
        tses_send[i].speed_change = 1'b1;
        tses_send[i].max_gen_supported = this.max_supported_gen_by_dsp;
        tses_send[i].ts_type = TS1;
      end
      this.send_seq_item(tses_send);
      if(flag) break;
    end
    // wait until TS2 is sent and then TS2 count is 1
    begin
      while(1) begin
        this.get_tses_recived(tses_recv);
        if(tses_recv[0].ts_type == TS2) break;
      end
      foreach(tses_recv[i]) begin
        assert(tses_recv[i].speed_change && tses_recv[i].ts_type == TS2 && tses_recv[i].auto_speed_change) else 
          `uvm_fatal("pipe_speed_change_without_equalization_seq", "");
      end
      flag = 1;
    end
  join
  
  // send and receive TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
  fork
    // send TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
    while(ts2_sent_count > 8 && ts2_recived_count > 8) begin
      tses_send  = super.tses;
      foreach(tses_send[i]) begin
        tses_send[i].speed_change = 1'b1;
        tses_send[i].max_gen_supported = this.max_supported_gen_by_dsp;
        tses_send[i].ts_type = TS2;
      end
      this.send_seq_item(tses_send);
      ts2_sent_count++;
    end
    // receive TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
    begin
      while(ts2_sent_count > 8 && ts2_recived_count > 8) begin
        this.get_tses_recived(tses_recv);
        foreach(tses_recv[i]) begin
          assert(tses_recv[i].speed_change && tses_recv[i].ts_type == TS2 && tses_recv[i].auto_speed_change) else 
            `uvm_fatal("pipe_speed_change_without_equalization_seq", "");
        end
        ts2_recived_count++;
      end
    end
  join
  // bfm will respond to the dut signals
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
  start_item (pipe_seq_item_h);
    if (!pipe_seq_item_h.randomize() with {pipe_operation == SPEED_CHANGE;}) begin
      `uvm_error(get_name(), "")
    end
  finish_item (pipe_seq_item_h);
  // wait for TS1s
  this.get_tses_recived(tses_recv);
  foreach(tses_recv[i]) begin
    assert(!tses_recv[i].speed_change && tses_recv[i].ts_type == TS1) else 
      `uvm_fatal("pipe_speed_change_without_equalization_seq", "");
  end
  // start sending TS1 and wait for TS2
  flag = 0;
  fork

    while (1) begin
      tses_send  = super.tses;
      foreach(tses_send[i]) begin
        tses_send[i].speed_change = 1'b0;
        tses_send[i].max_gen_supported = this.max_supported_gen_by_dsp;
        tses_send[i].ts_type = TS1;
      end
      this.send_seq_item(tses_send);
      if(flag) break;
    end

    begin
      while(1) begin
          this.get_tses_recived(tses_recv);
          if(tses_recv[0].ts_type == TS2) break;
      end
      foreach(tses_recv[i]) begin
        assert(!tses_recv[i].speed_change && tses_recv[i].ts_type == TS2) else 
          `uvm_fatal("pipe_speed_change_without_equalization_seq", "");
      end
      flag = 1;
    end
  join

  ts2_sent_count = 0;
  ts2_recived_count = 0;
  fork
    // send TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
    while(ts2_sent_count > 8 && ts2_recived_count > 8) begin
      tses_send  = super.tses;
      foreach(tses_send[i]) begin
        tses_send[i].speed_change = 1'b0;
        tses_send[i].max_gen_supported = this.max_supported_gen_by_dsp;
        tses_send[i].ts_type = TS2;
      end
      this.send_seq_item(tses_send);
      ts2_sent_count++;
    end
    // receive TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
    begin
      while(ts2_sent_count > 8 && ts2_recived_count > 8) begin
        this.get_tses_recived(tses_recv);
        foreach(tses_recv[i]) begin
          assert(!tses_recv[i].speed_change && tses_recv[i].ts_type == TS2) else 
            `uvm_fatal("pipe_speed_change_without_equalization_seq", "");
        end
        ts2_recived_count++;
      end
    end
  join
  
endtask : body

task pipe_speed_change_without_equalization_seq::send_seq_item(ts_s tses [`NUM_OF_LANES]);
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
  pipe_seq_item_h.tses_sent = tses;
  start_item (pipe_seq_item_h);
    if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TSES;}) begin
      `uvm_error(get_name(), "")
    end
  finish_item (pipe_seq_item_h);
endtask : send_seq_item

task pipe_speed_change_without_equalization_seq::get_tses_recived(output ts_s tses [`NUM_OF_LANES]);
  @(pipe_agent_config_h.detected_tses_e);
  tses = pipe_agent_config_h.tses_received;
endtask

// speed_change_bit