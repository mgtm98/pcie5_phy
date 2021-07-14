class pipe_speed_change_with_equalization_seq extends pipe_base_seq;

	`uvm_object_utils(pipe_speed_change_with_equalization_seq)

  int max_supported_gen_by_dsp=`MAX_GEN_FAR_PARTENER;
  int max_supported_gen_by_usp=`MAX_GEN_DUT;
  int negotaited_rate;
  logic [7:0] control_reg [`NUM_OF_LANES];
  rand bit [5:0] local_lf;
  rand bit [5:0] local_fs;
  rand bit [5:0] pre_cursor;
  rand bit [5:0] cursor;
  rand bit [5:0] post_cursor;
  rand bit enter_phase_2_3;



  // Standard UVM Methods:
  extern function new(string name = "pipe_speed_change_with_equalization_seq");
  extern function automatic int calc_gen(input logic[1:0] width, input logic[2:0] PCLKRate );
  extern task body;

  extern task send_seq_item(ts_s tses [`NUM_OF_LANES]);
  extern task get_tses_recived(output ts_s tses [`NUM_OF_LANES] );

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
	        $cast(tses_send[i].max_gen_supported , this.max_supported_gen_by_dsp);
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
        $cast(tses_send[i].max_gen_supported , this.max_supported_gen_by_dsp);
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


  // receive and send EIOS before enter rec.speed
  flag = 0;
  fork
    //send EIOS until receive EIOS
    while(!flag) begin
      pipe_seq_item_h.pipe_operation=SEND_EIOS;
      start_item (pipe_seq_item_h);
      finish_item (pipe_seq_item_h);
    end
    // Wait to receive EIOS
    begin
      @(pipe_agent_config_h.detected_eios_e);
      flag=1;
    end
  join

  @(pipe_agent_config_h.detected_TxElecIdle_and_RxStandby_asserted_e);

  if(max_supported_gen_by_dsp>max_supported_gen_by_usp)
    negotaited_rate=max_supported_gen_by_usp;
  else
    negotaited_rate=max_supported_gen_by_dsp;

  $cast(pipe_seq_item_h.gen , negotaited_rate);
  pipe_seq_item_h.pipe_operation=SET_GEN;
  start_item (pipe_seq_item_h);
  finish_item (pipe_seq_item_h);

  // receive and send EIEOS after changing speed to exit electic idle(gen?)
  flag = 0;
  fork
    //send EIEOS until receive EIEOS
    while(!flag) begin
      pipe_seq_item_h.pipe_operation=SEND_EIEOS;
      start_item (pipe_seq_item_h);
      finish_item (pipe_seq_item_h);
    end
    // Wait to receive EIEOS
    begin
      if(negotaited_rate<=2)begin
        @(pipe_agent_config_h.detected_eieos_e);
        flag=1;
      end
      else begin
        @(pipe_agent_config_h.detected_eieos_gen3_e);
        flag=1;
      end
    end
  join

//assert width
  case (negotaited_rate)
    1:begin assert(pipe_agent_config_h.new_width==`GEN1_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end
    2:begin assert(pipe_agent_config_h.new_width==`GEN2_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end
    3:begin assert(pipe_agent_config_h.new_width==`GEN3_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end
    4:begin assert(pipe_agent_config_h.new_width==`GEN4_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end
    5:begin assert(pipe_agent_config_h.new_width==`GEN5_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end 
    default: `uvm_error(get_name(), "width not right")
  endcase
  //assert Rate
  assert(pipe_agent_config_h.new_Rate==negotaited_rate)else`uvm_error(get_name(), "Rate signal not right");
  //assert PCLKRate
 assert(negotaited_rate==calc_gen(pipe_agent_config_h.new_width,pipe_agent_config_h.new_PCLKRate))else`uvm_error(get_name(), "PCLKRate signal not right"); 



  


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
		if (!pipe_seq_item_h.randomize() with {pipe_operation == INFORM_LF_FS; lf_to_be_informed	== 0;	 fs_to_be_informed == 0; }) begin
			`uvm_error(get_name(), "");
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
	  	// recv TS1s with ec = 2
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
        $cast(tses_send[i].max_gen_supported , this.max_supported_gen_by_dsp);
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
        $cast(tses_send[i].max_gen_supported , this.max_supported_gen_by_dsp);
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












task pipe_speed_change_with_equalization_seq::send_seq_item(ts_s tses [`NUM_OF_LANES]);
	pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
	pipe_seq_item_h.tses_sent = tses;
	start_item (pipe_seq_item_h);
	  if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TSES;}) begin
		`uvm_error(get_name(), "")
	  end
	finish_item (pipe_seq_item_h);
  endtask : send_seq_item
  
  task pipe_speed_change_with_equalization_seq::get_tses_recived(output ts_s tses [`NUM_OF_LANES]);
	@(pipe_agent_config_h.detected_tses_e);
	tses = pipe_agent_config_h.tses_received;
  endtask
  
  function automatic int pipe_speed_change_with_equalization_seq::calc_gen(input logic[1:0] width, input logic[2:0] PCLKRate );
	  
  
	real PCLKRate_value;
  real width_value;
  real freq;
  int gen;
	case(PCLKRate)
		3'b000:PCLKRate_value=0.0625;
		3'b001:PCLKRate_value=0.125;
		3'b010:PCLKRate_value=0.25;
		3'b011:PCLKRate_value=0.5;
		3'b100:PCLKRate_value=1;
	endcase
  

	case(width)
		2'b00:width_value=8;
		2'b01:width_value=16;
		2'b10:width_value=32;
	endcase

	freq=PCLKRate_value*width_value;

	case(freq)
		2:gen=1;
		4:gen=2;
		8:gen=3;
		16:gen=4;
		32:gen=5;
		default:gen=0;
	endcase
	return gen;
  endfunction
  // speed_change_bit            



