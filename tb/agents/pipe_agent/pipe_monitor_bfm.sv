interface pipe_monitor_bfm 
  #(
    param pipe_num_of_lanes,
    param pipe_max_width,
    localparam bus_data_width_param       = pipe_num_of_lanes  * pipe_max_width - 1,  
    localparam bus_data_kontrol_param     = (pipe_max_width / 8) * pipe_num_of_lanes - 1
  )(  
  input bit   clk,
  input bit   reset,
  input logic phy_reset,
   
  /*************************** RX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      rx_data,    
  input logic [pipe_num_of_lanes-1:0]       rx_data_valid,
  input logic [bus_data_kontrol_param:0]    rx_data_k,
  input logic [pipe_num_of_lanes-1:0]       rx_start_block,
  input logic [2*pipe_num_of_lanes-1:0]     rx_synch_header,
  input logic [pipe_num_of_lanes-1:0]       rx_valid,
  input logic [3*pipe_num_of_lanes-1:0]     rx_status,
  input logic                               rx_elec_idle,
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      tx_data,    
  input logic [pipe_num_of_lanes-1:0]       tx_data_valid,
  input logic [bus_data_kontrol_param:0]    tx_data_k,
  input logic [pipe_num_of_lanes-1:0]       tx_start_block,
  input logic [2*pipe_num_of_lanes-1:0]     tx_synch_header,
  input logic [pipe_num_of_lanes-1:0]       tx_elec_idle,
  input logic [pipe_num_of_lanes-1:0]       tx_detect_rx__loopback,
  /*************************************************************************************/

  /*********************** Comands and Status Signals **********************************/
  input logic [3:0]                         power_down,
  input logic [3:0]                         rate,
  input logic                               phy_status,
  input logic [1:0]                         width,
  input logic                               pclk_change_ack,
  input logic                               pclk_change_ok,
  /*************************************************************************************/
  
  /******************************* Message Bus Interface *******************************/
  input logic [7:0]                         m2p_message_bus,
  input logic [7:0]                         p2m_message_bus,
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  input logic [18*pipe_num_of_lanes-1:0]   local_tx_preset_coeffcients,
  input logic [18*pipe_num_of_lanes-1:0]   tx_deemph,
  input logic [6*pipe_num_of_lanes-1:0]    local_fs,
  input logic [6*pipe_num_of_lanes-1:0]    local_lf,
  input logic [pipe_num_of_lanes-1:0]      get_local_preset_coeffcients,
  input logic [pipe_num_of_lanes-1:0]      local_tx_coeffcients_valid,
  input logic [6*pipe_num_of_lanes-1:0]    fs,    // TODO: Review specs for these values
  input logic [6*pipe_num_of_lanes-1:0]    lf,    // TODO: Review specs for these values
  input logic [pipe_num_of_lanes-1:0]      rx_eq_eval,
  input logic [4*pipe_num_of_lanes-1:0]    local_preset_index,
  input logic [pipe_num_of_lanes-1:0]      invalid_request,  // TODO: this signal needs to be checked
  input logic [6*pipe_num_of_lanes-1:0]    link_evaluation_feedback_direction_change
  /*************************************************************************************/
);

  `include "uvm_macros.svh"

  import uvm_pkg::*;
  import pipe_agent_pkg::*;

  pipe_monitor proxy;

  forever begin
    proxy.detect_link_up;
  end

  task automatic receive_ts (output TS_config ts ,input int start_lane = 0,input int end_lane = NUM_OF_LANES );
    if(width==2'b01) // 16 bit pipe parallel interface
    begin
        wait(tx_data[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        ts.link_number=tx_data[start_lane][15:8]; // link number
        for(int sympol_count =2;sympol_count<16;sympol_count=sympol_count+2) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                2:begin 
                    for(int i=start_lane;i<=end_lane;i++) //lanes numbers
                    begin
                        ts.lane_number[i]=tx_data[i][7:0];
                    end
                    ts.n_fts=tx_data[start_lane][15:8]; // number of fast training sequnces
                  end
    
                4:begin // speeds supported
                        if(tx_data[start_lane][5]==1'b1) ts.max_suported=GEN5;
                        else if(tx_data[start_lane][4]==1'b1) ts.max_suported=GEN4;
                        else if(tx_data[start_lane][3]==1'b1) ts.max_suported=GEN3;
                        else if(tx_data[start_lane][2]==1'b1) ts.max_suported=GEN2;
                        else ts.max_suported=GEN1;	
                    end
    
                10:begin // ts1 or ts2 determine
                        if(tx_data[start_lane][7:0]==8'b010_01010) ts.ts_type=TS1;
                        else if(tx_data[start_lane][7:0]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end
    else if(width==2'b10) // 32 pipe parallel interface  
    begin
        wait(tx_data[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        ts.link_number=tx_data[start_lane][15:8]; //link number
        for(int i=start_lane;i<=end_lane;i++) // lane numbers
        begin 
            ts.lane_number[i]=tx_data[i][23:16];
        end
        ts.n_fts=tx_data[start_lane][31:24]; // number of fast training sequnces
        for(int sympol_count =4;sympol_count<16;sympol_count=sympol_count+4) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                4:begin // supported speeds
                        if(tx_data[start_lane][5]==1'b1) ts.max_suported=GEN5;
                        else if(tx_data[start_lane][4]==1'b1) ts.max_suported=GEN4;
                        else if(tx_data[start_lane][3]==1'b1) ts.max_suported=GEN3;
                        else if(tx_data[start_lane][2]==1'b1) ts.max_suported=GEN2;
                        else ts.max_suported=GEN1;	
                    end
    
                 8:begin // ts1 or ts2 determine
                        if(tx_data[start_lane][23:16]==8'b010_01010) ts.ts_type=TS1;
                        else if(tx_data[start_lane][23:16]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end
    else //8 bit pipe paraleel interface 
    begin
        wait(tx_data[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        for(int sympol_count =1;sympol_count<16;sympol_count++) //looping on the 16 sympol of TS
        begin
            @(posedge pclk);
            case(sympol_count)
                1:ts.link_number=tx_data[start_lane][7:0]; //link number
                2:begin //lanes numbers
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            ts.lane_number[i]=tx_data[i][7:0];
                        end
                    end
                3:ts.n_fts=tx_data[start_lane][7:0]; // number of fast training sequnces
                4:begin  //supported sppeds
                        if(tx_data[start_lane][5]==1'b1) ts.max_suported=GEN5;
                        else if(tx_data[start_lane][4]==1'b1) ts.max_suported=GEN4;
                        else if(tx_data[start_lane][3]==1'b1) ts.max_suported=GEN3;
                        else if(tx_data[start_lane][2]==1'b1) ts.max_suported=GEN2;
                        else ts.max_suported=GEN1;	
                    end
                10:begin // ts1 or ts2 determine
                        if(tx_data[start_lane][7:0]==8'b010_01010) ts.ts_type=TS1;
                        else if(tx_data[start_lane][7:0]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end    
endtask

//RESET DETECTION
  int temp[2:0];
forever begin   //initial or forever?

  wait(reset==1);
  @(posedge pclk);
  //check on default values
  assert (TxDetectRx==0) else `uvm_error ("pipe_monitor_bfm", "TxDetectRx isn't setted by default value during reset");
  assert (TxElecIdle==1) else `uvm_error ("pipe_monitor_bfm", "TxElecIdle isn't setted by default value during reset");
  //assert (TxCompliance==0) else `uvm_error ("TxCompliance isn't setted by default value during reset");
  assert (PowerDown=='b10) else `uvm_error ("PowerDown isn't in P1 during reset");

  //check that pclk is operational
  temp=pclk_rate;   //shared or per lane?
  @(posedge pclk);
  assert (temp==pclk_rate) else `uvm_error ("PCLK is not stable");

  wait(reset==0);
  @(posedge pclk);

  foreach(PhyStatus[i]) begin 
    wait(PhyStatus[i]==0);
  end
  @(posedge pclk);
  proxy.notify_reset_detected();
  `uvm_info ("pipe_monitor_bfm", "Monitor BFM Detected (Reset scenario)", UVM_LOW);
end

//RECEIVER DETECTION
forever begin   //initial or forever?
  wait(TxDetectRx==1);
  @(posedge clk);

  fork
    foreach(PhyStatus[i]) begin
      wait(PhyStatus[i]==1);
    end

    foreach(RxStatus[i]) begin 
      wait(RxStatus[i]=='b011);
    end    
  join
  @(posedge clk);

  fork
    foreach(PhyStatus[i]) begin
      wait(PhyStatus[i]==0);
    end

    foreach(RxStatus[i]) begin 
      wait(RxStatus[i]=='b000);  //??
    end    
  join
  @(posedge clk);

  wait(TxDetectRx==1);
  @(posedge clk);
  proxy.notify_receiver_detected();
  `uvm_info ("Monitor BFM Detected (Receiver detection scenario)");
end

<<<<<<< HEAD
task automatic receive_tses (output ts_s ts [] ,input int start_lane = 0,input int end_lane = NUM_OF_LANES );
  if(width==2'b01) // 16 bit pipe parallel interface
  begin
      for (int i=start_lane;i<=end_lane;i++)
      begin
          wait(tx_data[i][7:0]==8'b101_11100); //wait to see a COM charecter
      end
      for (int i=start_lane;i<=end_lane;i++)
      begin
          ts[i].link_number=tx_data[i][15:8]; // link number
      end
      for(int sympol_count =2;sympol_count<16;sympol_count=sympol_count+2) //looping on the 16 sympol of TS
      begin
          @(posedge pclk);
          case(sympol_count)
              2:begin 
                      for(int i=start_lane;i<=end_lane;i++) //lanes numbers
                      begin
                          ts[i].lane_number=tx_data[i][7:0];
                      end
                      for (int i=start_lane;i<=end_lane;i++)
                      begin
                      ts[i].n_fts=tx_data[i][15:8]; // number of fast training sequnces
                      end
                  end
  
              4:begin  //supported sppeds
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          if(tx_data[i][5]==1'b1) ts[i].max_gen_suported=GEN5;
                          else if(tx_data[i][4]==1'b1) ts[i].max_gen_suported=GEN4;
                          else if(tx_data[i][3]==1'b1) ts[i].max_gen_suported=GEN3;
                          else if(tx_data[i][2]==1'b1) ts[i].max_gen_suported=GEN2;
                          else ts[i].max_gen_suported=GEN1;	
                      end
                  end
  
              10:begin // ts1 or ts2 determine
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          if(tx_data[i][7:0]==8'b010_01010) ts[i].ts_sype=TS1;
                          else if(tx_data[i][7:0]==8'b010_00101) ts[i].ts_sype=TS2;
                      end
                  end
          endcase
      end
  end
  else if(width==2'b10) // 32 pipe parallel interface  
  begin
      for (int i=start_lane;i<=end_lane;i++)
      begin
          wait(tx_data[i][7:0]==8'b101_11100); //wait to see a COM charecter
      end
      for (int i=start_lane;i<=end_lane;i++)
      begin
          ts[i].link_number=tx_data[i][15:8]; // link number
      end
      for(int i=start_lane;i<=end_lane;i++) // lane numbers
      begin 
          ts[i].lane_number=tx_data[i][23:16];
      end
      for(int i=start_lane;i<=end_lane;i++)
      begin
          ts[i].n_fts=tx_data[i][31:24]; // number of fast training sequnces
      end
      for(int sympol_count =4;sympol_count<16;sympol_count=sympol_count+4) //looping on the 16 sympol of TS
      begin
          @(posedge pclk);
          case(sympol_count)
              4:begin  //supported sppeds
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          if(tx_data[i][5]==1'b1) ts[i].max_gen_suported=GEN5;
                          else if(tx_data[i][4]==1'b1) ts[i].max_gen_suported=GEN4;
                          else if(tx_data[i][3]==1'b1) ts[i].max_gen_suported=GEN3;
                          else if(tx_data[i][2]==1'b1) ts[i].max_gen_suported=GEN2;
                          else ts[i].max_gen_suported=GEN1;	
                      end
                  end
  
               8:begin // ts1 or ts2 determine
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          if(tx_data[i][23:16]==8'b010_01010) ts[i].ts_sype=TS1;
                          else if(tx_data[i][23:16]==8'b010_00101) ts[i].ts_sype=TS2;
                      end
                  end
          endcase
      end
  end
  else //8 bit pipe paraleel interface 
  begin
      for (int i=start_lane;i<=end_lane;i++)
      begin
          wait(tx_data[i][7:0]==8'b101_11100); //wait to see a COM charecter
      end
      for(int sympol_count =1;sympol_count<16;sympol_count++) //looping on the 16 sympol of TS
      begin
          @(posedge pclk);
          case(sympol_count)
              1:begin //link number
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          ts[i].link_number=tx_data[i][7:0]; 
                      end
                  end
              2:begin //lanes numbers
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          ts[i].lane_number=tx_data[i][7:0];
                      end
                  end
              3:begin // number of fast training sequnces
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          ts[i].n_fts=tx_data[i][7:0]; 
                      end
                  end
              4:begin  //supported sppeds
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          if(tx_data[i][5]==1'b1) ts[i].max_gen_suported=GEN5;
                          else if(tx_data[i][4]==1'b1) ts[i].max_gen_suported=GEN4;
                          else if(tx_data[i][3]==1'b1) ts[i].max_gen_suported=GEN3;
                          else if(tx_data[i][2]==1'b1) ts[i].max_gen_suported=GEN2;
                          else ts[i].max_gen_suported=GEN1;	
                      end
                  end
              10:begin // ts1 or ts2 determine
                      for(int i=start_lane;i<=end_lane;i++)
                      begin
                          if(tx_data[i][7:0]==8'b010_01010) ts[i].ts_sype=TS1;
                          else if(tx_data[i][7:0]==8'b010_00101) ts[i].ts_sype=TS2;
                      end
                  end
          endcase
      end
  end    
endtask


task automatic receive_ts (output ts_s ts ,input int start_lane = 0,input int end_lane = NUM_OF_LANES );
  if(width==2'b01) // 16 bit pipe parallel interface
  begin
      wait(tx_data[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
      ts.link_number=tx_data[start_lane][15:8]; // link number
      for(int sympol_count =2;sympol_count<16;sympol_count=sympol_count+2) //looping on the 16 sympol of TS
      begin
          @(posedge pclk);
          case(sympol_count)
              2:begin 
                      ts.lane_number=tx_data[start_lane][7:0]; // lane number
                      ts.n_fts=tx_data[start_lane][15:8]; // number of fast training sequnces
                end
  
              4:begin // speeds supported
                      if(tx_data[start_lane][5]==1'b1) ts.max_gen_suported=GEN5;
                      else if(tx_data[start_lane][4]==1'b1) ts.max_gen_suported=GEN4;
                      else if(tx_data[start_lane][3]==1'b1) ts.max_gen_suported=GEN3;
                      else if(tx_data[start_lane][2]==1'b1) ts.max_gen_suported=GEN2;
                      else ts.max_gen_suported=GEN1;	
                  end
  
              10:begin // ts1 or ts2 determine
                      if(tx_data[start_lane][7:0]==8'b010_01010) ts.ts_sype=TS1;
                      else if(tx_data[start_lane][7:0]==8'b010_00101) ts.ts_sype=TS2;
                  end
          endcase
      end
  end
  else if(width==2'b10) // 32 pipe parallel interface  
  begin
      wait(tx_data[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
      ts.link_number=tx_data[start_lane][15:8]; //link number
      ts.lane_number=tx_data[start_lane][7:0]; // lane number
      ts.n_fts=tx_data[start_lane][31:24]; // number of fast training sequnces
      for(int sympol_count =4;sympol_count<16;sympol_count=sympol_count+4) //looping on the 16 sympol of TS
      begin
          @(posedge pclk);
          case(sympol_count)
              4:begin // supported speeds
                      if(tx_data[start_lane][5]==1'b1) ts.max_gen_suported=GEN5;
                      else if(tx_data[start_lane][4]==1'b1) ts.max_gen_suported=GEN4;
                      else if(tx_data[start_lane][3]==1'b1) ts.max_gen_suported=GEN3;
                      else if(tx_data[start_lane][2]==1'b1) ts.max_gen_suported=GEN2;
                      else ts.max_gen_suported=GEN1;	
                  end
  
               8:begin // ts1 or ts2 determine
                      if(tx_data[start_lane][23:16]==8'b010_01010) ts.ts_sype=TS1;
                      else if(tx_data[start_lane][23:16]==8'b010_00101) ts.ts_sype=TS2;
                  end
          endcase
      end
  end
  else //8 bit pipe paraleel interface 
  begin
      wait(tx_data[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
      for(int sympol_count =1;sympol_count<16;sympol_count++) //looping on the 16 sympol of TS
      begin
          @(posedge pclk);
          case(sympol_count)
              1:ts.link_number=tx_data[start_lane][7:0]; //link number
              2:ts.lane_number=tx_data[start_lane][7:0]; // lane number
              3:ts.n_fts=tx_data[start_lane][7:0]; // number of fast training sequnces
              4:begin  //supported sppeds
                      if(tx_data[start_lane][5]==1'b1) ts.max_gen_suported=GEN5;
                      else if(tx_data[start_lane][4]==1'b1) ts.max_gen_suported=GEN4;
                      else if(tx_data[start_lane][3]==1'b1) ts.max_gen_suported=GEN3;
                      else if(tx_data[start_lane][2]==1'b1) ts.max_gen_suported=GEN2;
                      else ts.max_gen_suported=GEN1;	
                  end
              10:begin // ts1 or ts2 determine
                      if(tx_data[start_lane][7:0]==8'b010_01010) ts.ts_sype=TS1;
                      else if(tx_data[start_lane][7:0]==8'b010_00101) ts.ts_sype=TS2;
                  end
          endcase
      end
  end    
endtask
  
=======
//waiting on power down to be P0
initial 
begin
  forever
  begin
      for (int i = 0; i < NUM_OF_LANES; i++) begin
        @ (powerdown[i] == 'b00);
      end
      proxy.pipe_polling_state_start();
  end
end  
>>>>>>> b7141c807e4ec15dee81af9e8ddfa0d120e939f3
endinterface
