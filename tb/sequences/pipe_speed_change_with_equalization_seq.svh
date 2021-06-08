class pipe_speed_change_with_equalization_seq extends pipe_base_seq;

	`uvm_object_utils(pipe_speed_change_with_equalization_seq)

  rand gen_t max_supported_gen_by_dsp;
  gen_t max_supported_by_usp;
  logic [7:0] control_reg [`NUM_OF_LANES];
  rand bit [5:0] local_lf;
  rand bit [5:0] local_fs;
  rand bit [5:0] pre_cursor;
  rand bit [5:0] cursor;
  rand bit [5:0] post_cursor;
  rand bit enter_phase_2_3;

	// Standard UVM Methods:
	extern function new(string name = "pipe_speed_change_with_equalization_seq");
	extern task body;

  `SEND_RECV_TS
endclass:pipe_speed_change_with_equalization_seq

function pipe_speed_change_with_equalization_seq::new(string name = "pipe_speed_change_with_equalization_seq");
  super.new(name);
endfunction

task automatic pipe_speed_change_with_equalization_seq::body();
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
  ts_s tses_send [`NUM_OF_LANES];
  ts_s tses_recv [`NUM_OF_LANES];
  ts_s tses_recv_prev [`NUM_OF_LANES];
  bit flag = 0;
  int ts_recived_count = 0;
  int ts_sent_count = 0;
  bit [5:0] lf_of_USP;
  bit [5:0] fs_of_USP;

  // inform the BFM what values of LF, FS that will be used
  start_item (pipe_seq_item_h);
    if (!pipe_seq_item_h.randomize() with {
    																					pipe_operation == SET_LOCAL_LF_FS;
    																					lf_to_be_informed	== this.local_lf;
    																					fs_to_be_informed == this.local_fs;
																					}) begin
      `uvm_error(get_name(), "")
    end
  finish_item (pipe_seq_item_h);

  // inform BFM with the cursor params that might be sent
  start_item (pipe_seq_item_h);
    if (!pipe_seq_item_h.randomize() with {
    																					pipe_operation == SET_CURSOR_PARAMS;
    																					cursor	== this.cursor;
    																					pre_cursor == this.pre_cursor;
    																					post_cursor == this.post_cursor;
																					}) begin
      `uvm_error(get_name(), "")
    end
  finish_item (pipe_seq_item_h);
  
  // send TS1s until 8 TS1s are recived
  fork
  	// send TS1s
  	begin
  		while (1) begin
	  		tses_send = super.tses;
	  		foreach(tses_send[i]) begin
	        tses_send[i].speed_change = 1'b1;
	        tses_send[i].max_gen_supported = this.max_supported_gen_by_dsp;
	        tses_send[i].ts_type = TS1;
	      end
	      this.send_seq_item(tses_send);
	      if(flag) break;
	    end
  	end
  	// recicve 8 TS1s
  	begin
  		while(1) begin
        this.get_tses_recived(tses_recv);
        assert(tses_recv[0].ts_type == TS1 && tses_recv[0].speed_change) else 
        	`uvm_fatal("pipe_speed_change_without_equalization_seq", "");
        ts_recived_count += 1;
        if(ts_recived_count >= 8) begin
        	flag = 1;
        	break;
        end
      end
  	end
  join

  flag = 0;
  ts_recived_count = 0;

  // send TS2s until 8 TS2s are recived from the other device
  fork
  	// send TS2s
  	begin
  		tses_send = super.tses;
  		foreach(tses_send[i]) begin
        tses_send[i].speed_change = 1'b1;
        tses_send[i].max_gen_supported = this.max_supported_gen_by_dsp;
        tses_send[i].ts_type = TS2;
        tses_send[i].rx_preset_hint = 0; 	// TODO: values from control register
        tses_send[i].tx_preset = 0;				// TODO: values from control register
        tses_send[i].equalization_command = 1;
      end
  		while(1) begin
	      this.send_seq_item(tses_send);
	      if(flag) break;
	    end
  	end
  	// recv TS2
  	begin
  		while(1) begin
        this.get_tses_recived(tses_recv);
        assert(tses_recv[0].ts_type == TS2) else 
        	`uvm_fatal("pipe_speed_change_without_equalization_seq", "");
        ts_recived_count += 1;
        if(ts_recived_count >= 8) begin
        	flag = 1;
        	break;
        end
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

  // TODO must send EIOS

  // 
  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
  start_item (pipe_seq_item_h);
    if (!pipe_seq_item_h.randomize() with {pipe_operation == CHECK_EQ_PRESET_APPLIED;}) begin
      `uvm_error(get_name(), "")
    end
  finish_item (pipe_seq_item_h);

	flag = 0;
  ts_recived_count = 0;

  fork
  	begin
  		// recv TS1s until a TS1 with ec = 1, then the previous TSs should be with ec = 0
	    while(1) begin
		    tses_recv_prev = tses_recv;
		    this.get_tses_recived(tses_recv);
		    if(tses_recv[0].ts_type == TS1 &&	tses_recv[0].ec == 1 ) break;
	 		end
	 		ts_recived_count = 1;
	 		// assert that the previous TSs was with ex = 0
	 		assert(	tses_recv_prev[0].ts_type == TS1 &&
	 						tses_recv_prev[0].rx_preset_hint == 0 &&		// TODO: values from control register
	 						tses_recv_prev[0].tx_preset == 0 						// TODO: values from control register
 			) else `uvm_error(get_name(), "")
	 		// recv TS1s with ec = 1, until two TS1s are recived back to back
	 		while(1) begin
		    this.get_tses_recived(tses_recv);
		    if(tses_recv[0].ts_type == TS1 &&	tses_recv[0].ec == 1) ts_recived_count += 1;
		    else ts_recived_count = 0;
		    if (ts_recived_count >= 2) break;
	  	end
	  	flag = 0;
	  	lf_of_USP = tses_recv[0].lf_value;
	  	fs_of_USP = tses_recv[0].lf_value;
	  	assert(lf_of_USP == this.local_lf && fs_of_USP == this.local_fs) else
	  	`uvm_error(get_name(), "")
  	end

  	// send TS1s with ec = 1
  	begin

  		// inform the BFM what values of LF, FS that will be used
  		pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
		  start_item (pipe_seq_item_h);
		    if (!pipe_seq_item_h.randomize() with {
		    																					pipe_operation == INFORM_LF_FS;
		    																					lf_to_be_informed	== 0;	// TODO: dummy numbers
		    																					fs_to_be_informed == 0; // TODO: dummy numbers
    																					}) begin
		      `uvm_error(get_name(), "")
		    end
		  finish_item (pipe_seq_item_h);

		  // send TS1s with LF, FS that was informed to the BFM
  		while(1) begin
	  		tses_send = super.tses;
	  		foreach(tses_send[i]) begin
	        tses_send[i].ts_type = TS1;
	        tses_send[i].ec = 1; 													// TODO: values from control register
	        tses_send[i].lf_value = 0;										// TODO: dummy numbers
	        tses_send[i].fs_value = 0;										// TODO: dummy numbers
	        tses_send[i].post_cursor = 0;									// TODO: dummy numbers NOTE: bt3ty ana al mara dy
	        tses_send[i].tx_preset = 0;										// TODO: dummy numbers NOTE: bt3ty ana al mara dy
	      end
	      this.send_seq_item(tses_send);
	      if(flag) break;
	    end
  	end

  join

  flag = 0;
  ts_recived_count = 0;

  if(!this.enter_phase_2_3) begin
  	

  	fork
	  	// send TS1s with ec = 2 to indicate that phase2/3 are needed
	  	begin
	  		while(1) begin
		  		tses_send = super.tses;
		  		foreach(tses_send[i]) begin
		        tses_send[i].ts_type = TS1;
		        tses_send[i].ec = 2; 
		      end
		      this.send_seq_item(tses_send);
		      if(flag) break;
		    end
	  	end
	  	// recv TS1s with ec = 0
	  	begin
	  		while(1) begin
	        this.get_tses_recived(tses_recv);
	        assert(tses_recv[0].ts_type == TS1) else 
	        	`uvm_fatal("pipe_speed_change_without_equalization_seq", "");
	        if (tses_recv[0].ec == 2) ts_recived_count += 1;
	        if(ts_recived_count) begin
	        	flag = 1;
	        	break;
	        end
	      end
	  	end
	  join

	  // the recived TS1 will contain values to be applied in the DSP

	  flag = 0;
  	ts_recived_count = 0;

	  fork
	  	// send TS1s with ec = 2 to indicate that phase2/3 are needed
	  	begin
	  		// send untill USP is satisfied and echo back with ec=3
	  		while(1) begin
	  			tses_send = tses_recv;
		  		foreach(tses_send[i]) begin
		        tses_send[i].rcv = 0; 
		      end
		      this.send_seq_item(tses_send);
		      if(flag) break;
		    end
	  	end
	  	// recv 2 TS1s with ec = 3 back to back
	  	begin
	  		while(1) begin
	        this.get_tses_recived(tses_recv);
	        assert(tses_recv[0].ts_type == TS1) else 
	        	`uvm_fatal("pipe_speed_change_without_equalization_seq", "");
	        if (tses_recv[0].ec == 3) ts_recived_count += 1;
	        else ts_recived_count = 0;
	        if(ts_recived_count == 2) begin
	        	flag = 1;
	        	break;
	        end
	      end
	  	end
	  join

	  pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
	  start_item (pipe_seq_item_h);
	    if (!pipe_seq_item_h.randomize() with {pipe_operation == ASSERT_EVAL_FEEDBACK_CHANGED;}) begin
	      `uvm_error(get_name(), "")
	    end
	  finish_item (pipe_seq_item_h);

	  // phase 3 started here

	  fork
	  	// send TS1s with ec = 3
	  	begin
	  		while(1) begin
		  		tses_send = super.tses;
		  		foreach(tses_send[i]) begin
		        tses_send[i].ts_type = TS1;
		        tses_send[i].use_preset = 0;
		        tses_send[i].cursor = this.cursor;
		        tses_send[i].pre_cursor = this.pre_cursor;
		        tses_send[i].post_cursor = this.post_cursor;
		        tses_send[i].ec = 3; 
		      end
		      this.send_seq_item(tses_send);
		      if(flag) break;
		    end
	  	end
	  	// recv TS1s with ec = 0
	  	begin
	  		while(1) begin
	        this.get_tses_recived(tses_recv);
	        // if()
	        assert(	tses_recv[0].ts_type == TS1 && 
	        				tses_recv[0].cursor == this.cursor && 
	        				tses_recv[0].pre_cursor == this.pre_cursor && 
	        				tses_recv[0].post_cursor == this.post_cursor && 
	        				tses_recv[0].ec == 3 ) else 
	        	`uvm_fatal("pipe_speed_change_without_equalization_seq", "");
	        ts_recived_count += 1;
	        if(ts_recived_count == 2) begin
	        	flag = 1;
	        	break;
	        end
	      end
	  	end
	  join
  end

	// if phase 2/3 not needed
	fork
		// send TS1s with ec = 0 to indicate that equalization is ended
		begin
			while(1) begin
	  		tses_send = super.tses;
	  		foreach(tses_send[i]) begin
	        tses_send[i].ts_type = TS1;
	        tses_send[i].ec = 0; 
	      end
	      this.send_seq_item(tses_send);
	      if(flag) break;
	    end
		end
		// recv TS1s with ec = 0
		begin
			while(1) begin
	      this.get_tses_recived(tses_recv);
	      assert(tses_recv[0].ts_type == TS1) else 
	      	`uvm_fatal("pipe_speed_change_without_equalization_seq", "");
	      if (tses_recv[0].ec == 0) ts_recived_count += 1;
	      else ts_recived_count = 0;
	      if(ts_recived_count == 2) begin
	      	flag = 1;
	      	break;
	      end
	    end
	  end
  join

    // start sending TS1 and wait for TS2
  flag = 0;
  fork

    while(1) begin
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

  ts_sent_count = 0;
  ts_recived_count = 0;
  fork
    // send TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
    while(ts_sent_count > 8 && ts_recived_count > 8) begin
      tses_send  = super.tses;
      foreach(tses_send[i]) begin
        tses_send[i].speed_change = 1'b0;
        tses_send[i].max_gen_supported = this.max_supported_gen_by_dsp;
        tses_send[i].ts_type = TS2;
      end
      this.send_seq_item(tses_send);
      ts_sent_count++;
    end
    // receive TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
    begin
      while(ts_sent_count > 8 && ts_recived_count > 8) begin
        this.get_tses_recived(tses_recv);
        foreach(tses_recv[i]) begin
          assert(!tses_recv[i].speed_change && tses_recv[i].ts_type == TS2) else 
            `uvm_fatal("pipe_speed_change_without_equalization_seq", "");
        end
        ts_recived_count++;
      end
    end
  join
  
endtask:body
