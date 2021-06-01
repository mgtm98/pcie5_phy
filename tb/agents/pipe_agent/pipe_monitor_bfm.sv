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

  import uvm_pkg::*;
  import pipe_agent_pkg::*;
  import common_pkg::*;

  gen_t current_gen;

  event build_connect_finished_e;
  event detected_exit_electricle_idle_e;
  event detected_power_down_change_e;

  pipe_monitor proxy;

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
  /******************************* Receive TS*******************************/

  task automatic receive_ts (output ts_s ts ,input int start_lane = 0,input int end_lane = pipe_num_of_lanes );
    if(Width==2'b01) // 16 bit pipe parallel interface
    begin
        wait(TxData[(start_lane*32+0)+:8]==8'b101_11100); //wait to see a COM charecter
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


  bit [15:0] lfsr_gen_1_2 [pipe_num_of_lanes];
  bit [22:0] lfsr_gen_3 [pipe_num_of_lanes];
  byte data_sent [$];
  byte data_received [$];
  bit k_data [$];

  function void reset_lfsr ();
    integer j,i;
    foreach(lfsr_gen_1_2[i]) begin
      lfsr_gen_1_2[i] = 16'hFFFF;
    end
    foreach(lfsr_gen_3[i]) begin
      j=i;
      if (i>7) begin
        j=j-8;
      end
      case (j)
        0 : lfsr_gen_3[i] = 'h1DBFBC;
        1 : lfsr_gen_3[i] = 'h0607BB;
        2 : lfsr_gen_3[i] = 'h1EC760;
        3 : lfsr_gen_3[i] = 'h18C0DB;
        4 : lfsr_gen_3[i] = 'h010F12;
        5 : lfsr_gen_3[i] = 'h19CFC9;
        6 : lfsr_gen_3[i] = 'h0277CE;
        7 : lfsr_gen_3[i] = 'h1BB807;
      endcase
    end
  endfunction

  function int get_width ();
    int lane_width;
    case (Width)
      2'b00: lane_width = 8;
      2'b01: lane_width = 16;
      2'b11: lane_width = 32;
    endcase
    return lane_width;
  endfunction

  function bit [7:0] descramble (bit [7:0] in_data, shortint unsigned lane_num);
  if (current_gen == GEN1 || current_gen == GEN2)
    return descramble_gen_1_2 (in_data,  lane_num);
  else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5) 
    return descramble_gen_3_4_5 (in_data, lane_num);
  endfunction

  function bit [7:0] descramble_gen_1_2 (bit [7:0] in_data, shortint unsigned lane_num);
    bit [15:0] lfsr_new;
    bit [7:0] descrambled_data;

    // LFSR value after 8 serial clocks
    for (int i = 0; i < 8; i++)
    begin
      lfsr_new[ 0] = lfsr_gen_1_2 [lane_num] [15];
      lfsr_new[ 1] = lfsr_gen_1_2 [lane_num] [ 0];
      lfsr_new[ 2] = lfsr_gen_1_2 [lane_num] [ 1];
      lfsr_new[ 3] = lfsr_gen_1_2 [lane_num] [ 2] ^ lfsr_gen_1_2 [lane_num] [15];
      lfsr_new[ 4] = lfsr_gen_1_2 [lane_num] [ 3] ^ lfsr_gen_1_2 [lane_num] [15];
      lfsr_new[ 5] = lfsr_gen_1_2 [lane_num] [ 4] ^ lfsr_gen_1_2 [lane_num] [15];
      lfsr_new[ 6] = lfsr_gen_1_2 [lane_num] [ 5];
      lfsr_new[ 7] = lfsr_gen_1_2 [lane_num] [ 6];
      lfsr_new[ 8] = lfsr_gen_1_2 [lane_num] [ 7];
      lfsr_new[ 9] = lfsr_gen_1_2 [lane_num] [ 8];
      lfsr_new[10] = lfsr_gen_1_2 [lane_num] [ 9];
      lfsr_new[11] = lfsr_gen_1_2 [lane_num] [10];
      lfsr_new[12] = lfsr_gen_1_2 [lane_num] [11];
      lfsr_new[13] = lfsr_gen_1_2 [lane_num] [12];
      lfsr_new[14] = lfsr_gen_1_2 [lane_num] [13];
      lfsr_new[15] = lfsr_gen_1_2 [lane_num] [14];
  
      // Generation of Decrambled Data
      descrambled_data [i] = lfsr_gen_1_2 [lane_num] [15] ^ in_data [i];
      
      lfsr_gen_1_2 [lane_num] = lfsr_new;
    end
    return descrambled_data;
  endfunction

  function bit [7:0] descramble_gen_3_4_5 (bit [7:0] data_in, shortint unsigned lane_num);
  endfunction

  initial begin
      int lane_width;
      int num_of_clks;
      int num_of_bytes_in_lane;
      dllp_t dllp;
      tlp_t tlp;
      bit [10:0] length;
      int i, j ,k;
      bit is_end_of_data_block;
      int num_of_idle_data;
    forever begin
      for (i = 0; i < pipe_num_of_lanes; i++) begin
        wait (RxStartBlock [i] == 1 && RxSyncHeader [i*2 +: 2] == 2'b10);
      end
      @(posedge PCLK);
      lane_width = get_width();
      num_of_clks = 128/lane_width;
      num_of_bytes_in_lane = lane_width/8;
      for (i = 0; i < num_of_clks; i++) begin
        for (j = 0; j < num_of_bytes_in_lane; j++) begin
          for (k = 0; k < pipe_num_of_lanes; k++) begin
            data_sent.push_back() = descramble (RxData [((k*pipe_max_width) + (j*8)) +: 8], k);
          end
        end
        @(posedge PCLK);
      end
      is_end_of_data_block = 0;
      if (RxStartBlock [0] == 0 || RxStartBlock [0] == 1 && RxSyncHeader [0*2 +: 2] == 2'b10) begin
        is_end_of_data_block = 1;
      end
        if (is_end_of_data_block == 1) begin      
          for (i = 0; i < pipe_num_of_lanes; i++) begin
            assert (RxStartBlock [i] == 0 || RxStartBlock [i] == 1 && RxSyncHeader [i*2 +: 2] == 2'b10)
          end
          while (data_sent.size() != 0) begin

            // Notify that dllp sent
            if (data_sent[0] == `SDP_gen_3_symbol_0 && data_sent[1] == `SDP_gen_3_symbol_1) begin
              data_sent.pop_front();
              data_sent.pop_front();
              for (j = 0; j < 6; j++) begin
                dllp[j] = data_sent.pop_front();
              end
              proxy.notify_dllp_sent(dllp);
            end

            // Notify that tlp sent
            if (data_sent [0] [3:0] == `STP_gen_3) begin
              length = {data_sent [1] [6:0], data_sent [0] [7:4]};
              data_sent.pop_front();
              data_sent.pop_front();
              data_sent.pop_front();
              data_sent.pop_front();
              tlp = new [length];
              foreach (tlp[j]) begin
                tlp[j] = data_sent.pop_front();
              end
              proxy.notify_tlp_sent(tlp);
            end

            // Notify that idle data sent
            num_of_idle_data = 0;
            if (data_sent [0] == 8'b0000_0000) begin
              foreach (data_sent[j]) begin
                if (data_sent [j] == 8'b0000_0000) begin
                  num_of_idle_data ++;
                end
                else begin
                  break;
                end
              end
              repeat (num_of_idle_data) begin
                data_sent.pop_front();
              end
              repeat ($floor(num_of_idle_data/pipe_num_of_lanes)) begin
                proxy.notify_idle_data_sent();
              end
            end
          end
        end
      end
    end
  end

  initial begin
    int lane_width;
    int num_of_clks;
    int num_of_bytes_in_lane;
    dllp_t dllp;
    tlp_t tlp;
    bit [10:0] length;
    int i, j ,k;
    bit is_end_of_data_block;
    int num_of_idle_data;
  forever begin
    for (i = 0; i < pipe_num_of_lanes; i++) begin
      wait (TxStartBlock [i] == 1 && TxSyncHeader [i*2 +: 2] == 2'b10);
    end
    @(posedge PCLK);
    lane_width = get_width();
    num_of_clks = 128/lane_width;
    num_of_bytes_in_lane = lane_width/8;
    for (i = 0; i < num_of_clks; i++) begin
      for (j = 0; j < num_of_bytes_in_lane; j++) begin
        for (k = 0; k < pipe_num_of_lanes; k++) begin
          data_received.push_back() = descramble (TxData [((k*pipe_max_width) + (j*8)) +: 8], k);
        end
      end
      @(posedge PCLK);
    end
    is_end_of_data_block = 0;
    if (TxStartBlock [0] == 0 || TxStartBlock [0] == 1 && TxSyncHeader [0*2 +: 2] == 2'b10) begin
      is_end_of_data_block = 1;
    end
      if (is_end_of_data_block == 1) begin      
        for (i = 0; i < pipe_num_of_lanes; i++) begin
          assert (TxStartBlock [i] == 0 || TxStartBlock [i] == 1 && TxSyncHeader [i*2 +: 2] == 2'b10)
        end
        while (data_received.size() != 0) begin

          // Notify that dllp sent
          if (data_received[0] == `SDP_gen_3_symbol_0 && data_received[1] == `SDP_gen_3_symbol_1) begin
            data_received.pop_front();
            data_received.pop_front();
            for (j = 0; j < 6; j++) begin
              dllp[j] = data_received.pop_front();
            end
            proxy.notify_dllp_received(dllp);
          end

          // Notify that tlp sent
          if (data_received [0] [3:0] == `STP_gen_3) begin
            length = {data_received [1] [6:0], data_received [0] [7:4]};
            data_received.pop_front();
            data_received.pop_front();
            data_received.pop_front();
            data_received.pop_front();
            tlp = new [length];
            foreach (tlp[j]) begin
              tlp[j] = data_received.pop_front();
            end
            proxy.notify_tlp_received(tlp);
          end

          // Notify that idle data sent
          num_of_idle_data = 0;
          if (data_received [0] == 8'b0000_0000) begin
            foreach (data_received[j]) begin
              if (data_received [j] == 8'b0000_0000) begin
                num_of_idle_data ++;
              end
              else begin
                break;
              end
            end
            repeat (num_of_idle_data) begin
              data_received.pop_front();
            end
            repeat ($floor(num_of_idle_data/pipe_num_of_lanes)) begin
              proxy.notify_idle_data_received();
            end
          end
        end
      end
    end
  end
endinterface
