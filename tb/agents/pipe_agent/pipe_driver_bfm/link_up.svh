task config_state;
  ts_config_t received_tses [NUM_OF_LANES];
  // -------------------- Config.Linkwidth.Start --------------------
  int unsigned num_of_ts1s_with_non_pad_link_number [NUM_OF_LANES];
  // Initialize the detected num of ts1s with non pad link number to zero
  foreach(num_of_ts1s_with_non_pad_link_number[i])
  begin
    num_of_ts1s_with_non_pad_link_number[i] = 0;
  end
  // Detect ts1s until 2 consecutive ts1s have a non-pad link number
  while(num_of_ts1s_with_non_pad_link_number < 2)
  begin
    receive_ts(received_tses);
    // Make sure the received tses are ts1s
    foreach(received_tses[i])
    begin
      // Make sure the tses received are ts1s
      assert (received_tses[i].ts_sype == TS1) 
      else   `uvm_error(get_name(), "Expected TS1s but detected TS2s")
      // Non PAD link number
      if(received_ts[i].use_link_number)
      begin
        num_of_ts1s_with_non_pad_link_number[i] += 1
      end
      // PAD link number
      else
      begin
        num_of_ts1s_with_non_pad_link_number[i] = 0;
      end
    end
    // Check if any lane detected 2 consecutive ts1s with non PAD link number
    int unsigned two_consecutive_ts1s_with_non_pad_link_number_detected = 0;
    foreach(num_of_ts1s_with_non_pad_link_number[i])
    begin
      if(num_of_ts1s_with_non_pad_link_number[i] == 2)
      begin
        two_consecutive_ts1s_with_non_pad_link_number_detected = 1;
        break;
      end
    end
    // Move to the next sub-state if any lane detected 2 consecutive ts1s with non PAD link number
    if(two_consecutive_ts1s_with_non_pad_link_number_detected)
    begin
      break;
    end
  end

  // -------------------- Config.Linkwidth.Accept --------------------
  // Use the link number of the ts1s on the first lane to be transmitted
  bit [7:0] used_link_num = ts_configs[0].link_number;
  foreach(ts_configs[i])
  begin
    ts_configs[i].link_number = used_link_num;
    ts_configs[i].use_link_number = 1;
  end
  // Send ts1s with this link number until some ts1s are received with non PAD lane number
  ts1_with_non_pad_lane_number_detected = 0
  fork
    begin
      while (!ts1_with_non_pad_lane_number_detected)
      begin
        send_ts(ts_configs);
      end
    end
    begin
      while (!ts1_with_non_pad_lane_number_detected)
      begin
        receive_ts(received_tses);
        // Check if any ts1 received has a non PAD lane number
        foreach(received_tses[i])
        begin
          // Make sure the tses received are ts1s
          assert (received_tses[i].ts_sype == TS1) 
          else   `uvm_error(get_name(), "Expected TS1s but detected TS2s")
          // Non PAD lane number
          if(received_tses[i].use_lane_num)
          begin
            ts1_with_non_pad_lane_number_detected = 1
          end
        end
      end
    end
  join
  // Get the lane numbers from the received ts1s
  foreach(received_tses[i])
  begin
    assert (received_tses[i].lane_number == i) 
    else   `uvm_error(get_name(), "the order of lane numbers are incorrect")
    ts_configs[i].lane_number = received_tses[i].lane_number;
  end

  // -------------------- Config.Lanenum.Wait --------------------
  int num_of_ts2_received [NUM_OF_LANES];
  // Initialize the num_of_ts2_received array with zeros
  foreach(num_of_ts2_received[i])
  begin
    num_of_ts2_received[i] = 0;
  end
  // Transmit TS1s until 2 consecutive TS2s are received
  int unsigned two_consecutive_ts2s_detected = 0;
  fork
    begin
      while (!two_consecutive_ts2s_detected)
      begin
        send_ts(ts_configs);
      end
    end

    begin
      while (!two_consecutive_ts2s_detected)
      begin
        receive_ts(received_tses);
        foreach(received_tses[i])
        begin
          if(received_tses[i].ts_sype == TS2)
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
        // Move to the next sub-state if any lane detected 2 consecutive ts2s
        if(two_consecutive_ts2s_detected)
        begin
          break;
        end
      end
    end
  join

  // -------------------- Config.Lanenum.Accept --------------------

  // -------------------- Config.Complete --------------------

  // -------------------- Config.Idle --------------------
endtask




task automatic receive_tses (output ts_s ts [] ,input int start_lane = 0,input int end_lane = NUM_OF_LANES );
    if(Width==2'b01) // 16 bit pipe parallel interface
    begin
        for (int i=start_lane;i<=end_lane;i++)
        begin
            wait(TxData[i][7:0]==8'b101_11100); //wait to see a COM charecter
        end
        for (int i=start_lane;i<=end_lane;i++)
        begin
            ts[i].link_number=TxData[i][15:8]; // link number
        end
        for(int sympol_count =2;sympol_count<16;sympol_count=sympol_count+2) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                2:begin 
                        for(int i=start_lane;i<=end_lane;i++) //lanes numbers
                        begin
                            ts[i].lane_number=TxData[i][7:0];
                        end
                        for (int i=start_lane;i<=end_lane;i++)
                        begin
                        ts[i].n_fts=TxData[i][15:8]; // number of fast training sequnces
                        end
                    end
    
                4:begin  //supported sppeds
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            if(TxData[i][5]==1'b1) ts[i].max_gen_suported=GEN5;
                            else if(TxData[i][4]==1'b1) ts[i].max_gen_suported=GEN4;
                            else if(TxData[i][3]==1'b1) ts[i].max_gen_suported=GEN3;
                            else if(TxData[i][2]==1'b1) ts[i].max_gen_suported=GEN2;
                            else ts[i].max_gen_suported=GEN1;	
                        end
                    end
    
                10:begin // ts1 or ts2 determine
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            if(TxData[i][7:0]==8'b010_01010) ts[i].ts_sype=TS1;
                            else if(TxData[i][7:0]==8'b010_00101) ts[i].ts_sype=TS2;
                        end
                    end
            endcase
        end
    end
    else if(Width==2'b10) // 32 pipe parallel interface  
    begin
        for (int i=start_lane;i<=end_lane;i++)
        begin
            wait(TxData[i][7:0]==8'b101_11100); //wait to see a COM charecter
        end
        for (int i=start_lane;i<=end_lane;i++)
        begin
            ts[i].link_number=TxData[i][15:8]; // link number
        end
        for(int i=start_lane;i<=end_lane;i++) // lane numbers
        begin 
            ts[i].lane_number=TxData[i][23:16];
        end
        for(int i=start_lane;i<=end_lane;i++)
        begin
            ts[i].n_fts=TxData[i][31:24]; // number of fast training sequnces
        end
        for(int sympol_count =4;sympol_count<16;sympol_count=sympol_count+4) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                4:begin  //supported sppeds
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            if(TxData[i][5]==1'b1) ts[i].max_gen_suported=GEN5;
                            else if(TxData[i][4]==1'b1) ts[i].max_gen_suported=GEN4;
                            else if(TxData[i][3]==1'b1) ts[i].max_gen_suported=GEN3;
                            else if(TxData[i][2]==1'b1) ts[i].max_gen_suported=GEN2;
                            else ts[i].max_gen_suported=GEN1;	
                        end
                    end
    
                 8:begin // ts1 or ts2 determine
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            if(TxData[i][23:16]==8'b010_01010) ts[i].ts_sype=TS1;
                            else if(TxData[i][23:16]==8'b010_00101) ts[i].ts_sype=TS2;
                        end
                    end
            endcase
        end
    end
    else //8 bit pipe paraleel interface 
    begin
        for (int i=start_lane;i<=end_lane;i++)
        begin
            wait(TxData[i][7:0]==8'b101_11100); //wait to see a COM charecter
        end
        for(int sympol_count =1;sympol_count<16;sympol_count++) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                1:begin //link number
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            ts[i].link_number=TxData[i][7:0]; 
                        end
                    end
                2:begin //lanes numbers
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            ts[i].lane_number=TxData[i][7:0];
                        end
                    end
                3:begin // number of fast training sequnces
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            ts[i].n_fts=TxData[i][7:0]; 
                        end
                    end
                4:begin  //supported sppeds
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            if(TxData[i][5]==1'b1) ts[i].max_gen_suported=GEN5;
                            else if(TxData[i][4]==1'b1) ts[i].max_gen_suported=GEN4;
                            else if(TxData[i][3]==1'b1) ts[i].max_gen_suported=GEN3;
                            else if(TxData[i][2]==1'b1) ts[i].max_gen_suported=GEN2;
                            else ts[i].max_gen_suported=GEN1;	
                        end
                    end
                10:begin // ts1 or ts2 determine
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            if(TxData[i][7:0]==8'b010_01010) ts[i].ts_sype=TS1;
                            else if(TxData[i][7:0]==8'b010_00101) ts[i].ts_sype=TS2;
                        end
                    end
            endcase
        end
    end    
endtask


task automatic receive_ts (output ts_s ts ,input int start_lane = 0,input int end_lane = NUM_OF_LANES );
    if(Width==2'b01) // 16 bit pipe parallel interface
    begin
        wait(TxData[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        ts.link_number=TxData[start_lane][15:8]; // link number
        for(int sympol_count =2;sympol_count<16;sympol_count=sympol_count+2) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                2:begin 
                        ts.lane_number=TxData[start_lane][7:0]; // lane number
                        ts.n_fts=TxData[start_lane][15:8]; // number of fast training sequnces
                  end
    
                4:begin // speeds supported
                        if(TxData[start_lane][5]==1'b1) ts.max_gen_suported=GEN5;
                        else if(TxData[start_lane][4]==1'b1) ts.max_gen_suported=GEN4;
                        else if(TxData[start_lane][3]==1'b1) ts.max_gen_suported=GEN3;
                        else if(TxData[start_lane][2]==1'b1) ts.max_gen_suported=GEN2;
                        else ts.max_gen_suported=GEN1;	
                    end
    
                10:begin // ts1 or ts2 determine
                        if(TxData[start_lane][7:0]==8'b010_01010) ts.ts_sype=TS1;
                        else if(TxData[start_lane][7:0]==8'b010_00101) ts.ts_sype=TS2;
                    end
            endcase
        end
    end
    else if(Width==2'b10) // 32 pipe parallel interface  
    begin
        wait(TxData[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        ts.link_number=TxData[start_lane][15:8]; //link number
        ts.lane_number=TxData[start_lane][7:0]; // lane number
        ts.n_fts=TxData[start_lane][31:24]; // number of fast training sequnces
        for(int sympol_count =4;sympol_count<16;sympol_count=sympol_count+4) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                4:begin // supported speeds
                        if(TxData[start_lane][5]==1'b1) ts.max_gen_suported=GEN5;
                        else if(TxData[start_lane][4]==1'b1) ts.max_gen_suported=GEN4;
                        else if(TxData[start_lane][3]==1'b1) ts.max_gen_suported=GEN3;
                        else if(TxData[start_lane][2]==1'b1) ts.max_gen_suported=GEN2;
                        else ts.max_gen_suported=GEN1;	
                    end
    
                 8:begin // ts1 or ts2 determine
                        if(TxData[start_lane][23:16]==8'b010_01010) ts.ts_sype=TS1;
                        else if(TxData[start_lane][23:16]==8'b010_00101) ts.ts_sype=TS2;
                    end
            endcase
        end
    end
    else //8 bit pipe paraleel interface 
    begin
        wait(TxData[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        for(int sympol_count =1;sympol_count<16;sympol_count++) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                1:ts.link_number=TxData[start_lane][7:0]; //link number
                2:ts.lane_number=TxData[start_lane][7:0]; // lane number
                3:ts.n_fts=TxData[start_lane][7:0]; // number of fast training sequnces
                4:begin  //supported sppeds
                        if(TxData[start_lane][5]==1'b1) ts.max_gen_suported=GEN5;
                        else if(TxData[start_lane][4]==1'b1) ts.max_gen_suported=GEN4;
                        else if(TxData[start_lane][3]==1'b1) ts.max_gen_suported=GEN3;
                        else if(TxData[start_lane][2]==1'b1) ts.max_gen_suported=GEN2;
                        else ts.max_gen_suported=GEN1;	
                    end
                10:begin // ts1 or ts2 determine
                        if(TxData[start_lane][7:0]==8'b010_01010) ts.ts_sype=TS1;
                        else if(TxData[start_lane][7:0]==8'b010_00101) ts.ts_sype=TS2;
                    end
            endcase
        end
    end    
endtask
