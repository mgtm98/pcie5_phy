interface pipe_monitor_bfm 
  #(
    parameter pipe_num_of_lanes,
    parameter pipe_max_width,
    localparam bus_data_width_param       = pipe_num_of_lanes  * pipe_max_width - 1,  
    localparam bus_data_kontrol_param     = (pipe_max_width / 8) * pipe_num_of_lanes - 1
  )(  
  // input bit   CLK,
  input bit   Reset,
  // input logic PhyReset,
   
  /*************************** RX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      RxData,    
  input logic [pipe_num_of_lanes-1:0]       RxDataValid,
  input logic [bus_data_kontrol_param:0]    RxDataK,
  input logic [pipe_num_of_lanes-1:0]       RxStartBlock,
  input logic [2*pipe_num_of_lanes-1:0]     RxSyncHeader,
  input logic [pipe_num_of_lanes-1:0]       RxValid,
  input logic [3*pipe_num_of_lanes-1:0]     RxStatus,
  input logic                               RxElecIdle,
  //input logic [pipe_num_of_lanes-1:0]       RxElecIdle,
  
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      TxData,    
  input logic [pipe_num_of_lanes-1:0]       TxDataValid,
  input logic [bus_data_kontrol_param:0]    TxDataK,
  input logic [pipe_num_of_lanes-1:0]       TxStartBlock,
  input logic [2*pipe_num_of_lanes-1:0]     TxSyncHeader,
  input logic [pipe_num_of_lanes-1:0]       TxElecIdle,
  input logic [pipe_num_of_lanes-1:0]       TxDetectRxLoopback,

  /*********************** Comands and Status Signals **********************************/
  input logic [3:0]                         PowerDown,
  input logic [3:0]                         Rate,
  input logic [pipe_num_of_lanes-1:0]       PhyStatus,
  input logic [1:0]                         Width,
  input logic                               PclkChangeAck,
  input logic                               PclkChangeOk,
  /*************************************************************************************/
  
  /******************************* Message Bus Interface *******************************/
  input logic [7:0]                         M2P_MessageBus,
  input logic [7:0]                         P2M_MessageBus,
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  input logic [18*pipe_num_of_lanes-1:0]    LocalTxPresetCoeffcients,
  input logic [18*pipe_num_of_lanes-1:0]    TxDeemph,
  input logic [6*pipe_num_of_lanes-1:0]     LocalFS,
  input logic [6*pipe_num_of_lanes-1:0]     LocalLF,
  input logic [pipe_num_of_lanes-1:0]       GetLocalPresetCoeffcients,
  input logic [pipe_num_of_lanes-1:0]       LocalTxCoeffcientsValid,
  input logic [6*pipe_num_of_lanes-1:0]     FS,    // TODO: Review specs for these values
  input logic [6*pipe_num_of_lanes-1:0]     LF,    // TODO: Review specs for these values
  input logic [pipe_num_of_lanes-1:0]       RxEqEval,
  input logic [4*pipe_num_of_lanes-1:0]     LocalPresetIndex,
  input logic [pipe_num_of_lanes-1:0]       InvalidRequest,  // TODO: this signal needs to be checked
  input logic [6*pipe_num_of_lanes-1:0]     LinkEvaluationFeedbackDirectionChange,
  /*************************************************************************************/

  input logic                               PCLK,     //TODO: This signal is removed 
  input logic [4:0]                         PclkRate     //TODO: This signal is removed 
);

  `include "uvm_macros.svh"
  `include "settings.svh"

  import uvm_pkg::*;
  import pipe_agent_pkg::*;
  import common_pkg::*;

  gen_t current_gen;
  scrambler_s monitor_scrambler;
  event build_connect_finished_e;
  event detected_exit_electricle_idle_e;
  event detected_power_down_change_e;

  pipe_monitor proxy;

  scrambler_s monitor_rx_scrambler;
  scrambler_s monitor_tx_scrambler;

  initial begin
    @(build_connect_finished_e);
    forever begin
      proxy.detect_link_up;
    end
  end
 
  //clock wait
initial begin
  forever begin
    @(posedge PCLK)
    proxy.detect_posedge_clk;
  end
end
//-----------------------------------------------------------
// reciveing TS
//-----------------------------------------------------------
initial begin
  forever begin
    ts_s tses_received_temp [`NUM_OF_LANES];
    receive_tses(tses_received_temp);
    proxy.notify_tses_received(tses_received_temp);
  end
end

initial begin 
  forever begin
    for (int i = 0; i < `NUM_OF_LANES ; i++) begin
      wait(RxData[(i*8)+:8]==8'b1011_1100);
      //@(posedge PCLK);
    end              
    reset_lfsr(monitor_rx_scrambler,current_gen);
  end
end

  /******************************* Receive TS*******************************/

  task automatic receive_ts (output ts_s ts ,input int start_lane = 0,input int end_lane = pipe_num_of_lanes );
    if(Width==2'b01) // 16 bit pipe parallel interface
    begin
        wait(TxData[(start_lane*32+0)+:8]==8'b101_11100); //wait to see a COM charecter

        reset_lfsr(monitor_tx_scrambler,current_gen);

        ts.link_number=TxData[(start_lane*32+8)+:8]; // link number
        for(int sympol_count =2;sympol_count<16;sympol_count=sympol_count+2) //looping on the 16 sympol of TS
        begin
            @(posedge PCLK);
            case(sympol_count)
                2:begin 
                        ts.lane_number=TxData[(start_lane*32+0)+:8]; // lane number
                        ts.n_fts=TxData[(start_lane*32+8)+:8]; // number of fast training sequnces
                  end
    
                4:begin // speeds supported
                        if(TxData[start_lane*32+5]==1'b1) ts.max_gen_supported=GEN5;
                        else if(TxData[start_lane*32+4]==1'b1) ts.max_gen_supported=GEN4;
                        else if(TxData[start_lane*32+3]==1'b1) ts.max_gen_supported=GEN3;
                        else if(TxData[start_lane*32+2]==1'b1) ts.max_gen_supported=GEN2;
                        else ts.max_gen_supported=GEN1;	
                    end
    
                10:begin // ts1 or ts2 determine
                        if(TxData[(start_lane*32+0)+:8]==8'b010_01010) ts.ts_type=TS1;
                        else if(TxData[(start_lane*32+0)+:8]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end
    else if(Width==2'b10) // 32 pipe parallel interface  
    begin
        wait(TxData[(start_lane*32+0)+:8]==8'b101_11100); //wait to see a COM charecter

        reset_lfsr(monitor_tx_scrambler,current_gen);

        ts.link_number=TxData[(start_lane*32+8)+:8]; //link number
        ts.lane_number=TxData[(start_lane*32+0)+:8]; // lane number
        ts.n_fts=TxData[(start_lane*32+24)+:8]; // number of fast training sequnces
        for(int sympol_count =4;sympol_count<16;sympol_count=sympol_count+4) //looping on the 16 sympol of TS
        begin
            @(posedge PCLK);
            case(sympol_count)
                4:begin // supported speeds
                        if(TxData[start_lane*32+5]==1'b1) ts.max_gen_supported=GEN5;
                        else if(TxData[start_lane*32+4]==1'b1) ts.max_gen_supported=GEN4;
                        else if(TxData[start_lane*32+3]==1'b1) ts.max_gen_supported=GEN3;
                        else if(TxData[start_lane*32+2]==1'b1) ts.max_gen_supported=GEN2;
                        else ts.max_gen_supported=GEN1;	
                    end
    
                 8:begin // ts1 or ts2 determine
                        if(TxData[(start_lane*32+16)+:8]==8'b010_01010) ts.ts_type=TS1;
                        else if(TxData[(start_lane*32+16)+:8]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end
    else //8 bit pipe paraleel interface 
    begin
        wait(TxData[(start_lane*32+0)+:8]==8'b101_11100); //wait to see a COM charecter

        reset_lfsr(monitor_tx_scrambler,current_gen);

        for(int sympol_count =1;sympol_count<16;sympol_count++) //looping on the 16 sympol of TS
        begin
            @(posedge PCLK);
            case(sympol_count)
                1:ts.link_number=TxData[(start_lane*32+0)+:8]; //link number
                2:ts.lane_number=TxData[(start_lane*32+0)+:8]; // lane number
                3:ts.n_fts=TxData[(start_lane*32+0)+:8]; // number of fast training sequnces
                4:begin  //supported sppeds
                        if(TxData[start_lane*32+5]==1'b1) ts.max_gen_supported=GEN5;
                        else if(TxData[start_lane*32+4]==1'b1) ts.max_gen_supported=GEN4;
                        else if(TxData[start_lane*32+3]==1'b1) ts.max_gen_supported=GEN3;
                        else if(TxData[start_lane*32+2]==1'b1) ts.max_gen_supported=GEN2;
                        else ts.max_gen_supported=GEN1;	
                    end
                10:begin // ts1 or ts2 determine
                        if(TxData[(start_lane*32+0)+:8]==8'b010_01010) ts.ts_type=TS1;
                        else if(TxData[(start_lane*32+0)+:8]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end    
  endtask

/******************************* RESET# Scenario detection *******************************/
  logic [4:0] temp;
  initial begin
    forever begin   
      wait(Reset==1);
      @(posedge PCLK);
      reset_lfsr(monitor_tx_scrambler,current_gen);
      //check on default values
      assert (TxDetectRxLoopback==0) else `uvm_error ("pipe_monitor_bfm", "TxDetectRxLoopback isn't setted by default value during Reset");
      assert (TxElecIdle==1) else `uvm_error ("pipe_monitor_bfm", "TxElecIdle isn't setted by default value during Reset");
      //assert (TxCompliance==0) else `uvm_error ("TxCompliance isn't setted by default value during Reset");
      assert (PowerDown=='b01) else `uvm_error ("pipe_monitor_bfm", "PowerDown isn't in P1 during Reset");
    
      //check that PCLK is operational
      temp=PclkRate;   //shared or per lane?
      @(posedge PCLK);
      assert (temp==PclkRate) else `uvm_error ("pipe_monitor_bfm", "PCLK is not stable");
    
      wait(Reset==0);
      @(posedge PCLK);
      
      foreach(PhyStatus[i]) begin 
        wait(PhyStatus[i]==0);
      end

      @(posedge PCLK);
      proxy.notify_reset_detected();
     `uvm_info ("pipe_monitor_bfm", "Reset scenario detected", UVM_LOW);
    end
  end

/******************************* Receiver detection Scenario *******************************/
  initial begin
    forever begin  
      wait(TxDetectRxLoopback==1);
      @(posedge PCLK);
      assert (PowerDown=='b01) else `uvm_error ("pipe_monitor_bfm", "PowerDown isn't in P1 during Detect")
    
      foreach(PhyStatus[i]) begin
        wait(PhyStatus[i]==1);
        assert (RxStatus[i]=='b011) else `uvm_error ("pipe_monitor_bfm", "RxStatus is not ='b011")
      end
    
      @(posedge PCLK);
    
      foreach(PhyStatus[i]) begin
        wait(PhyStatus[i]==0);
        assert (RxStatus[i]=='b000) else `uvm_error ("pipe_monitor_bfm", "RxStatus is not ='b000")
      end
    
      wait(TxDetectRxLoopback==0);
      @(posedge PCLK);
      proxy.notify_receiver_detected();
      `uvm_info ("pipe_monitor_bfm", "Receiver detected", UVM_MEDIUM)
    end
  end

/******************************* Receive TSes *******************************/

  task automatic receive_tses (output ts_s ts [] ,input int start_lane = 0,input int end_lane = pipe_num_of_lanes );
      if(Width==2'b01) // 16 bit pipe parallel interface
      begin
          for (int i=start_lane;i<=end_lane;i++)
          begin
              wait(TxData[(i*32+0)+:8]==8'b101_11100); //wait to see a COM charecter
          end

          reset_lfsr(monitor_tx_scrambler,current_gen);

          for (int i=start_lane;i<=end_lane;i++)
          begin
              ts[i].link_number=TxData[(i*32+8)+:8]; // link number
          end
          for(int sympol_count =2;sympol_count<16;sympol_count=sympol_count+2) //looping on the 16 sympol of TS
          begin
              @(posedge PCLK);
              case(sympol_count)
                  2:begin 
                          for(int i=start_lane;i<=end_lane;i++) //lanes numbers
                          begin
                              ts[i].lane_number=TxData[(i*32+0)+:8];
                          end
                          for (int i=start_lane;i<=end_lane;i++)
                          begin
                          ts[i].n_fts=TxData[(i*32+8)+:8]; // number of fast training sequnces
                          end
                      end
      
                  4:begin  //supported sppeds
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              if(TxData[i*32+5]==1'b1) ts[i].max_gen_supported=GEN5;
                              else if(TxData[i*32+4]==1'b1) ts[i].max_gen_supported=GEN4;
                              else if(TxData[i*32+3]==1'b1) ts[i].max_gen_supported=GEN3;
                              else if(TxData[i*32+2]==1'b1) ts[i].max_gen_supported=GEN2;
                              else ts[i].max_gen_supported=GEN1;	
                          end
                      end
      
                  10:begin // ts1 or ts2 determine
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              if(TxData[(i*32+0)+:8]==8'b010_01010) ts[i].ts_type=TS1;
                              else if(TxData[(i*32+0)+:8]==8'b010_00101) ts[i].ts_type=TS2;
                          end
                      end
              endcase
          end
      end
      else if(Width==2'b10) // 32 pipe parallel interface  
      begin
          for (int i=start_lane;i<=end_lane;i++)
          begin
              wait(TxData[(i*32+0)+:8]==8'b101_11100); //wait to see a COM charecter
          end

          reset_lfsr(monitor_tx_scrambler,current_gen);

          for (int i=start_lane;i<=end_lane;i++)
          begin
              ts[i].link_number=TxData[(i*32+8)+:8]; // link number
          end
          for(int i=start_lane;i<=end_lane;i++) // lane numbers
          begin 
              ts[i].lane_number=TxData[(i*32+16)+:8];
          end
          for(int i=start_lane;i<=end_lane;i++)
          begin
              ts[i].n_fts=TxData[(i*32+24)+:8]; // number of fast training sequnces
          end
          for(int sympol_count =4;sympol_count<16;sympol_count=sympol_count+4) //looping on the 16 sympol of TS
          begin
              @(posedge PCLK);
              case(sympol_count)
                  4:begin  //supported sppeds
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              if(TxData[i*32+5]==1'b1) ts[i].max_gen_supported=GEN5;
                              else if(TxData[i*32+4]==1'b1) ts[i].max_gen_supported=GEN4;
                              else if(TxData[i*32+3]==1'b1) ts[i].max_gen_supported=GEN3;
                              else if(TxData[i*32+2]==1'b1) ts[i].max_gen_supported=GEN2;
                              else ts[i].max_gen_supported=GEN1;	
                          end
                      end
      
                  8:begin // ts1 or ts2 determine
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              if(TxData[(i*32+16)+:8]==8'b010_01010) ts[i].ts_type=TS1;
                              else if(TxData[(i*32+16)+:8]==8'b010_00101) ts[i].ts_type=TS2;
                          end
                      end
              endcase
          end
      end
      else //8 bit pipe paraleel interface 
      begin
          for (int i=start_lane;i<=end_lane;i++)
          begin
              wait(TxData[(i*32+0)+:8]==8'b101_11100); //wait to see a COM charecter
          end
          
          reset_lfsr(monitor_tx_scrambler,current_gen);

          for(int sympol_count =1;sympol_count<16;sympol_count++) //looping on the 16 sympol of TS
          begin
              @(posedge PCLK);
              case(sympol_count)
                  1:begin //link number
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              ts[i].link_number=TxData[(i*32+0)+:8]; 
                          end
                      end
                  2:begin //lanes numbers
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              ts[i].lane_number=TxData[(i*32+0)+:8];
                          end
                      end
                  3:begin // number of fast training sequnces
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              ts[i].n_fts=TxData[(i*32+0)+:8]; 
                          end
                      end
                  4:begin  //supported sppeds
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              if(TxData[i*32+5]==1'b1) ts[i].max_gen_supported=GEN5;
                              else if(TxData[i*32+4]==1'b1) ts[i].max_gen_supported=GEN4;
                              else if(TxData[i*32+3]==1'b1) ts[i].max_gen_supported=GEN3;
                              else if(TxData[i*32+2]==1'b1) ts[i].max_gen_supported=GEN2;
                              else ts[i].max_gen_supported=GEN1;	
                          end
                      end
                  10:begin // ts1 or ts2 determine
                          for(int i=start_lane;i<=end_lane;i++)
                          begin
                              if(TxData[(i*32+0)+:8]==8'b010_01010) ts[i].ts_type=TS1;
                              else if(TxData[(i*32+0)+:8]==8'b010_00101) ts[i].ts_type=TS2;
                          end
                      end
              endcase
          end
      end    
  endtask
  

  //wait for exit electricle idle
  initial begin
    forever begin
      for (int i = 0; i < pipe_num_of_lanes; i++) begin
        @ (TxElecIdle[i] == 0);
      end
      proxy.exit_electricle_idle();
    end
  end

  //wait for powerdown change
  initial begin
    forever begin
      for (int i = 0; i < pipe_num_of_lanes; i++) begin
        @ (PowerDown[i]);
      end
      
      for (int i = 0; i < pipe_num_of_lanes; i++) begin
        @ (PhyStatus[i] == 1);
      end

      @(posedge PCLK);
      for (int i = 0; i < pipe_num_of_lanes; i++) begin
        @ (PhyStatus[i] == 0);
      end
      proxy.power_down_change();
    end
  end

  //waiting on power down to be P0
  initial begin
    forever begin
        wait(detected_power_down_change_e.triggered);
        for (int i = 0; i < pipe_num_of_lanes; i++) begin
          assert (PowerDown[i] == 2'b00) 
          else begin
            wait(detected_power_down_change_e.triggered);
            i = 0;
          end
        end
        wait(detected_exit_electricle_idle_e.triggered);
        proxy.DUT_polling_state_start();
    end
  end  
  
/******************************* Normal Data Operation *******************************/
  byte data [$];
  bit k_data [$];
  bit [0:10] tlp_length_field;
  byte tlp_gen3_symbol_0;
  byte tlp_gen3_symbol_1;
  bit [15:0] lfsr[pipe_num_of_lanes];
  bit [7:0] temp_value;

  //gen 1 and 2

  int lanenum;
  int pipe_width = get_width();
  int bus_data_width = (pipe_num_of_lanes * pipe_width) ;
  tlp_t tlp_receieved;
  dllp_t dllp_receieved;
  bit [7:0] [bus_data_kontrol_param : 0] data_descrambled;
  byte tlp_q [$];
  byte dllp_q [$];
  int start_tlp;
  int start_dllp;
  bit dllp_done = 0;
  bit tlp_done = 0;
 initial begin
   forever begin 
     foreach(TxDataValid[i]) begin
       wait (TxDataValid[i] == 1) ; 	
     end	
     @ (posedge PCLK);
     for (int i = 0; i < (bus_data_kontrol_param + 1); i++) begin
       if ((TxDataK[i] == 1 && TxData[(8*i) +: 8] == `STP_gen_1_2) || tlp_done == 0) begin
         start_tlp = i;
         receive_tlp_gen_1_2; 
       end
       else if ((TxDataK[i] == 1 && TxData[(8*i) +: 8] == `SDP_gen_1_2) || tlp_done == 0) begin
         start_dllp = i;
         receive_dllp_gen_1_2; 
       end
        else if ((TxDataK[i] == 0 && TxData[(8*i) +: 8] == 8'b0000_0000)) begin
        end
     end
   end
 end
 
 task automatic receive_dllp_gen_1_2;
  int end_dllp = (bus_data_width_param + 1)/8;
  for(int i = start_tlp; i < bus_data_kontrol_param + 1; i++) begin 
    int j = i - start_dllp;
    if(!(TxDataK[i] == 1 && TxData[(8*i) +: 8] == `END_gen_1_2)) begin
      lanenum = $floor(i/(pipe_max_width/8.0));
       if(TxDataK [i] == 0) begin
        temp_value=TxData[(8*i) +: 8];
         data_descrambled[j] = descramble(monitor_scrambler,temp_value,lanenum, current_gen);
       end
       else if (TxDataK [i] == 1) begin
         data_descrambled[j] = (TxData[(8*i) +: 8]);
       end
    end
    else begin
      data_descrambled[j] = (TxData[(8*i) +: 8]);
      dllp_done = 1;
      end_dllp = j;
      break;
    end
  end  
  for (int j = 0; j < (bus_data_width)/(pipe_num_of_lanes*8); j = j ++) begin
     for (int i = j ; i < (bus_data_width_param + 1)/8 ; i = i + (bus_data_width_param + 1)/(pipe_num_of_lanes*8)) begin
       if (i > end_dllp) begin
       break;
       end
         dllp_q.push_back(data_descrambled[(i)]); 
     end
  end
  if (dllp_done) begin
    for (int i = 0; i < dllp_q.size(); i++) begin
       dllp_receieved [i] = dllp_q.pop_front();
    end
    proxy.notify_dllp_received(dllp_receieved);
  end
 endtask
 
 task automatic receive_tlp_gen_1_2;
  int end_tlp = (bus_data_width_param + 1)/8;
  for(int i = start_tlp; i < bus_data_kontrol_param + 1; i++) begin 
    int j = i - start_tlp;
    if(!(TxDataK[i] == 1 && TxData[(8*i) +: 8] == `END_gen_1_2)) begin
      lanenum = $floor(i/(pipe_max_width/8.0));
       if(TxDataK [i] == 0) begin
          temp_value=TxData[(8*i) +: 8];
         data_descrambled[j] = descramble(monitor_scrambler,temp_value,lanenum, current_gen);
       end
       else if (TxDataK [i] == 1) begin
         data_descrambled[j] = (TxData[(8*i) +: 8]);
       end
    end
    else begin
      data_descrambled[j] = (TxData[(8*i) +: 8]);
      tlp_done = 1;
      end_tlp = j;
      break;
    end
  end  
  for (int j = 0; j < (bus_data_width)/(pipe_num_of_lanes*8); j = j ++) begin
     for (int i = j ; i < (bus_data_width_param + 1)/8 ; i = i + (bus_data_width_param + 1)/(pipe_num_of_lanes*8)) begin
       if (i > end_tlp) begin
       break;
       end
         tlp_q.push_back(data_descrambled[(i)]); 
     end
  end
  if (tlp_done) begin
    for (int i = 0; i < tlp_q.size(); i++) begin
       tlp_receieved [i] = tlp_q.pop_front();
    end
    proxy.notify_tlp_received(tlp_receieved);
  end
 endtask  
 
  


endinterface
