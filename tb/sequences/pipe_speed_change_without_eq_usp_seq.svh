class pipe_speed_change_without_eq_usp_seq extends pipe_base_seq;

    `uvm_object_utils(pipe_speed_change_without_eq_usp_seq)
  
    int max_supported_gen_by_usp=`MAX_GEN_FAR_PARTENER;
    int max_supported_gen_by_dsp=`MAX_GEN_DUT;
    int negotaited_rate;
  
    // Standard UVM Methods:
    extern function new(string name = "pipe_speed_change_without_eq_usp_seq");
    extern function automatic int calc_gen(input logic[1:0] width, input logic[4:0] PCLKRate );
    extern task body;
  
    extern task send_seq_item(ts_s tses [`NUM_OF_LANES]);
    extern task get_tses_recived(output ts_s tses [`NUM_OF_LANES] );
    
  endclass:pipe_speed_change_without_eq_usp_seq
  
  function pipe_speed_change_without_eq_usp_seq::new(string name = "pipe_speed_change_without_eq_usp_seq");
    super.new(name);
  endfunction
  
  task automatic pipe_speed_change_without_eq_usp_seq::body();
    ts_s tses_send [`NUM_OF_LANES];
    ts_s tses_recv [`NUM_OF_LANES];
    bit flag;
    int ts2_recived_count;
    int ts2_sent_count; 
  
    // setting generation in driver bfm to GEN1
  
    pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
    pipe_seq_item_h.gen = GEN1;
    pipe_seq_item_h.pipe_operation=SET_GEN;
    start_item (pipe_seq_item_h);
    finish_item (pipe_seq_item_h);
    

  //*************************************step 1&2 (gen 1): send  TS1 with speed_change bit asserted untill receive TS1 with speed_change bit asserted*************//
    `uvm_info(get_name(), "print 1", UVM_MEDIUM)
    flag=0;
    fork
      // send TS1 with speed_change bit
      while (1) begin
        tses_send  = super.tses;
        foreach(tses_send[i]) begin
          tses_send[i].speed_change = 1'b1;
          $cast(tses_send[i].max_gen_supported , this.max_supported_gen_by_usp);
          tses_send[i].ts_type = TS1;
          tses_send[i].link_number=1;
          tses_send[i].lane_number=15-i;
          tses_send[i].use_link_number=1;
          tses_send[i].use_lane_number=1;
        end
        this.send_seq_item(tses_send);
        if(flag) break;
      end
      // wait until TS1 that  have the Speed Change bit set  is recived from DSP
      begin
        while(1) begin
          this.get_tses_recived(tses_recv);
          if(tses_recv[0].ts_type == TS1) break;
        end
        foreach(tses_recv[i]) begin
          assert((tses_recv[i].ts_type == TS1) && (tses_recv[i].speed_change==1)) else 
            `uvm_fatal("pipe_speed_change_without_eq_usp_seq", "received tses not as expecting step 2&3");
        end
        flag = 1;
      end
    join
    `uvm_info(get_name(), "print 2", UVM_MEDIUM)
    //*******************************************************************************************************************//
   
  // ***************************************step 3&4(gen 1): send and receive TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived****************************/
    ts2_recived_count=1;
    ts2_sent_count=0; 
    fork
      begin
        // send TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
        while(1) begin//(ts2_sent_count < 8) || (ts2_recived_count < 8)
          tses_send  = super.tses;
          foreach(tses_send[i]) begin
            tses_send[i].speed_change = 1'b1;
            $cast(tses_send[i].max_gen_supported , this.max_supported_gen_by_usp);
            tses_send[i].auto_speed_change = 1'b1;
            tses_send[i].ts_type = TS2;
            tses_send[i].link_number=1;
            tses_send[i].lane_number=15-i;
            tses_send[i].use_link_number=1;
            tses_send[i].use_lane_number=1;
          end
          this.send_seq_item(tses_send);
          ts2_sent_count++;
        end
      end
      // receive TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
      begin
        while((ts2_sent_count < 8) || (ts2_recived_count < 8)) begin
          this.get_tses_recived(tses_recv);
          foreach(tses_recv[i]) begin
            if((tses_recv[i].speed_change==1) &&(tses_recv[i].ts_type == TS2))
              begin ts2_recived_count++; end
          end
          $display(ts2_recived_count,tses_recv[0].ts_type);
          
        end
      end
    join
    `uvm_info(get_name(), "print 3", UVM_MEDIUM)
  //*******************************************************************************************************************//
  /***************************************************step 5 (gen1 --> gen 2,3,4,5):snding and reciving EIOS and EIEOS and asserting PCLKRate, Rate, width *****************************************************/ 
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
    `uvm_info(get_name(), "print a", UVM_MEDIUM)
    // wait for TxElecIdle and RxStandby to be asserted
    @(pipe_agent_config_h.detected_TxElecIdle_and_RxStandby_asserted_e);
    `uvm_info(get_name(), "print b", UVM_MEDIUM)
  
    // figuring out what is the negotiated gen
    if(max_supported_gen_by_dsp>max_supported_gen_by_usp)
      negotaited_rate=max_supported_gen_by_usp;
    else
      negotaited_rate=max_supported_gen_by_dsp;
  
    // setting generation in driver bfm to the negotaited GEN
    $cast(pipe_seq_item_h.gen , negotaited_rate);
    pipe_seq_item_h.pipe_operation=SET_GEN;
    start_item (pipe_seq_item_h);
    finish_item (pipe_seq_item_h);
  
    // receive and send EIEOS after changing speed to exit electic idle 
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
    `uvm_info(get_name(), "print c", UVM_MEDIUM)
  
  //assert width
    case (negotaited_rate)
      1:begin assert(pipe_agent_config_h.new_width==`GEN1_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end
      2:begin assert(pipe_agent_config_h.new_width==`GEN2_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end
      3:begin assert(pipe_agent_config_h.new_width==`GEN3_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end
      4:begin assert(pipe_agent_config_h.new_width==`GEN4_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end
      5:begin assert(pipe_agent_config_h.new_width==`GEN5_PIPEWIDTH)else `uvm_error(get_name(), "width not right");end 
      default: `uvm_error(get_name(), "negotaited_rate not right")
    endcase
    //assert Rate
    assert(pipe_agent_config_h.new_Rate==negotaited_rate)else`uvm_error(get_name(), "Rate signal not right");
    //assert PCLKRate
   assert(negotaited_rate==calc_gen(pipe_agent_config_h.new_width,pipe_agent_config_h.new_PCLKRate))else`uvm_error(get_name(), "PCLKRate signal not right"); 
   `uvm_info(get_name(), "print 4", UVM_MEDIUM)
  /*************************************************************************************************************************************************************************/
 

    /****************************************step 6&7&8 (gen 2,3,4,5):send TS1 with speed_change bit=0 until TS1 that  have the Speed Change bit=0  is recived from DSP************************************************/
    // start sending TS1 and wait for TS1
    flag = 0;
    fork
      while (1) begin
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
            if(tses_recv[0].ts_type == TS1) break;
        end
        foreach(tses_recv[i]) begin
          assert((tses_recv[i].speed_change==0) && (tses_recv[i].ts_type == TS1)) else 
            `uvm_fatal("pipe_speed_change_without_eq_usp_seq", "received tses not as expecting step 7&8");
        end
        flag = 1;
      end
    join
    `uvm_info(get_name(), "print 5", UVM_MEDIUM)
  /*************************************************************************************************************************************************************************/
  // ***************************************step 9(gen 2,3,4,5): send and receive TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived****************************/
    ts2_sent_count = 0;
    ts2_recived_count = 0;
  
    fork
      // send TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
      begin
        tses_send  = super.tses;
        foreach(tses_send[i]) begin
          tses_send[i].speed_change = 1'b0;
          $cast(tses_send[i].max_gen_supported , this.max_supported_gen_by_dsp);
          tses_send[i].ts_type = TS2;
        end
        while((ts2_sent_count < 8) && (ts2_recived_count < 8)) begin
          this.send_seq_item(tses_send);
          ts2_sent_count++;
        end
      end
      // receive TS2 until 8 or more TS2 are sent and 8 or more TS2 are recived
      begin
        while((ts2_sent_count < 8) && (ts2_recived_count < 8)) begin
          this.get_tses_recived(tses_recv);
          foreach(tses_recv[i]) begin
            assert((tses_recv[i].speed_change==0) && tses_recv[i].ts_type == TS2) else 
              `uvm_fatal("pipe_speed_change_without_eq_usp_seq", "received tses not as expecting step 9");
          end
          ts2_recived_count++;
        end
      end
    join
    `uvm_info(get_name(), "print 6", UVM_MEDIUM)
  /*************************************************************************************************************************************************************************/  
  /*****************************************************step 10&11 (gen 2,3,4,5):sending idle data******************************************************************************/
    flag=0;
    fork
      begin
        int i;
        while(1) begin
          pipe_seq_item_h.pipe_operation=IDLE_DATA_TRANSFER;
          start_item (pipe_seq_item_h);
          finish_item (pipe_seq_item_h);
          pipe_seq_item_h.pipe_operation=pipe_agent_pkg::SEND_DATA;
          start_item (pipe_seq_item_h);
          finish_item (pipe_seq_item_h);
          if(flag) break;
        end
        for ( i = 0;i<16 ;i=i+1 ) begin
          pipe_seq_item_h.pipe_operation=IDLE_DATA_TRANSFER;
          start_item (pipe_seq_item_h);
          finish_item (pipe_seq_item_h);
          pipe_seq_item_h.pipe_operation=pipe_agent_pkg::SEND_DATA;
          start_item (pipe_seq_item_h);
          finish_item (pipe_seq_item_h);
        end
      end
      begin
        int i;
        @(pipe_agent_config_h.idle_data_detected_e);
        flag=1;
        for (i =0 ;i<7;i=i+1) begin
          @(pipe_agent_config_h.idle_data_detected_e);
        end
      end
    join
    `uvm_info(get_name(), "print 7", UVM_MEDIUM)
  /*************************************************************************************************************************************************************************/
  endtask : body
  
  task pipe_speed_change_without_eq_usp_seq::send_seq_item(ts_s tses [`NUM_OF_LANES]);
    pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item");
    pipe_seq_item_h.tses_sent = tses;
    pipe_seq_item_h.pipe_operation = SEND_TSES;
    start_item (pipe_seq_item_h);
    finish_item (pipe_seq_item_h);
  endtask : send_seq_item
  
  task pipe_speed_change_without_eq_usp_seq::get_tses_recived(output ts_s tses [`NUM_OF_LANES]);
    @(pipe_agent_config_h.detected_tses_e);
    tses = pipe_agent_config_h.tses_received;
  endtask
  
  function automatic int pipe_speed_change_without_eq_usp_seq::calc_gen(input logic[1:0] width, input logic[4:0] PCLKRate );
      
  
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