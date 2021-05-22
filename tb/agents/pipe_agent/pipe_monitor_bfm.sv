import common_pkg::*;

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
  
  //waiting on power down to be P0
  initial 
  begin
    forever
    begin
        for (int i = 0; i < pipe_num_of_lanes; i++) begin
          @ (PowerDown[i] == 'b00);
        end
        
        for (int i = 0; i < pipe_num_of_lanes; i++) begin
          @ (PhyStatus[i] == 1);
        end
        // TODO: CLK or PCLK
        @(posedge PCLK);
        for (int i = 0; i < pipe_num_of_lanes; i++) begin
          @ (PhyStatus[i] == 0);
        end

        for (int i = 0; i < pipe_num_of_lanes; i++) begin
          @ (TxElecIdle[i] == 0)	;
        end
        proxy.pipe_polling_state_start();
    end
  end  

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

  bit [15:0] lfsr[pipe_num_of_lanes];

  function void reset_lfsr;
    foreach(lfsr[i])
    begin
      lfsr[i] = 16'hFFFF;
    end
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
      lfsr_new[ 0] = lfsr [lane_num] [15];
      lfsr_new[ 1] = lfsr [lane_num] [ 0];
      lfsr_new[ 2] = lfsr [lane_num] [ 1];
      lfsr_new[ 3] = lfsr [lane_num] [ 2] ^ lfsr [lane_num] [15];
      lfsr_new[ 4] = lfsr [lane_num] [ 3] ^ lfsr [lane_num] [15];
      lfsr_new[ 5] = lfsr [lane_num] [ 4] ^ lfsr [lane_num] [15];
      lfsr_new[ 6] = lfsr [lane_num] [ 5];
      lfsr_new[ 7] = lfsr [lane_num] [ 6];
      lfsr_new[ 8] = lfsr [lane_num] [ 7];
      lfsr_new[ 9] = lfsr [lane_num] [ 8];
      lfsr_new[10] = lfsr [lane_num] [ 9];
      lfsr_new[11] = lfsr [lane_num] [10];
      lfsr_new[12] = lfsr [lane_num] [11];
      lfsr_new[13] = lfsr [lane_num] [12];
      lfsr_new[14] = lfsr [lane_num] [13];
      lfsr_new[15] = lfsr [lane_num] [14];       
  
      // Generation of Decrambled Data
      descrambled_data [i] = lfsr [lane_num] [15] ^ in_data [i];
      
      lfsr [lane_num] = lfsr_new;
    end
    return descrambled_data;
  endfunction

	function bit [7:0] descramble_gen_3_4_5 (bit [7:0] in_data, shortint unsigned lane_num);
	endfunction
endinterface

