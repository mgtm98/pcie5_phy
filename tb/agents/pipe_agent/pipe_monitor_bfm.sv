interface pipe_monitor_bfm 
  #(
    parameter pipe_num_of_lanes,
    parameter pipe_max_width,
    localparam bus_data_width_param       = pipe_num_of_lanes  * pipe_max_width - 1,  
    localparam bus_data_kontrol_param     = (pipe_max_width / 8) * pipe_num_of_lanes - 1
  )(  
  input logic   PCLK,
  input logic   Reset,
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
  input logic [4*pipe_num_of_lanes - 1:0]   PowerDown,
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

  // input logic                               PCLK,     //TODO: This signal is removed 
  input logic [4:0]                         PclkRate     //TODO: This signal is removed 
);

  `include "uvm_macros.svh"
  `include "settings.svh"

  import uvm_pkg::*;
  import pipe_agent_pkg::*;
  import common_pkg::*;

  gen_t current_gen;
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
  ts_s tses_received_temp [];
  tses_received_temp = new[pipe_num_of_lanes];
  forever begin
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
      `uvm_info ("pipe_monitor_bfm", "Reset scenario started in PIPE", UVM_LOW)
      wait(Reset==0);
      `uvm_info ("pipe_monitor_bfm", "Received Reset = 0", UVM_LOW)
       @(posedge PCLK);
      reset_lfsr(monitor_tx_scrambler,current_gen);
      //check on default values
      
      foreach(TxDetectRxLoopback[i])
       assert (TxDetectRxLoopback[i]==0) else `uvm_error ("pipe_monitor_bfm", $sformatf("TxDetectRxLoopback is set by %x Reset",TxDetectRxLoopback[i]));
      foreach(TxElecIdle[i])
       assert (TxElecIdle[i]==1) else `uvm_error ("pipe_monitor_bfm", "TxElecIdle isn't set by default value during Reset");
      for (int i = 0; i < `NUM_OF_LANES; i++) begin     
       assert (PowerDown[(i*4) +:4] == 4'b0010) else `uvm_error ("pipe_monitor_bfm", "PowerDown isn't in P1 during Reset");
      end
       //check that PCLK is operational
      // temp=PclkRate;   //shared or per lane?
      // @(posedge PCLK);
      // assert (temp==PclkRate) else `uvm_error ("pipe_monitor_bfm", "PCLK is not stable");
      wait(Reset==1);
      // @(posedge PCLK);
      `uvm_info ("pipe_monitor_bfm", "Received Reset = 1", UVM_LOW)

      foreach(PhyStatus[i]) begin 
        wait(PhyStatus[i]==0);
      end
      `uvm_info ("pipe_monitor_bfm", "Received PhyStatus = 0", UVM_LOW)

      // @(posedge PCLK);
      proxy.notify_reset_detected();
     `uvm_info ("pipe_monitor_bfm", "Reset scenario detected", UVM_LOW)
    end
  end

  // initial begin
  //   forever begin
  //     `uvm_info("pipe_monitor_bfm", $sformatf("TxDetectRxLoopback = %b", TxDetectRxLoopback), UVM_LOW)
  //     @(posedge PCLK);
  //   end
  // end

/******************************* Receiver detection Scenario *******************************/
  initial begin
    forever begin  
      `uvm_info("pipe_driver_bfm", "Entered receiver detection", UVM_LOW)
      foreach(TxDetectRxLoopback[i]) begin
        wait(TxDetectRxLoopback[i] == 1);
      end
      `uvm_info ("pipe_monitor_bfm", "TxDetectRxLoopback = 1", UVM_LOW)
      @(posedge PCLK);
      for (int i = 0; i < `NUM_OF_LANES; i++) begin
        assert (PowerDown[(i*4) +:4] == 4'b0010) else `uvm_error ("pipe_monitor_bfm", "PowerDown isn't in P1 during Detect")
      end
      for (int i = 0; i < `NUM_OF_LANES; i++) begin
        wait(PhyStatus[i]==1);
        assert (RxStatus[(i*3) +:3]=='b011) else `uvm_error ("pipe_monitor_bfm", "RxStatus is not ='b011")
      end
      `uvm_info ("pipe_monitor_bfm", "Powerdown and rxstatus is tamam", UVM_LOW)

      @(posedge PCLK);
    
      for (int i = 0; i < `NUM_OF_LANES; i++) begin
        wait(PhyStatus[i]==0);
        assert (RxStatus[(i*3) +:3]=='b000) else `uvm_error ("pipe_monitor_bfm", "RxStatus is not ='b000")
      end
      `uvm_info ("pipe_monitor_bfm", "waiting for txdetectrx to be deasserted", UVM_LOW)
      foreach(TxDetectRxLoopback[i]) begin
        wait(TxDetectRxLoopback[i] == 0);
      end
      `uvm_info ("pipe_monitor_bfm", "txdetectrx is deasserted", UVM_LOW)
      @(posedge PCLK);
      proxy.notify_receiver_detected();
      `uvm_info ("pipe_monitor_bfm", "Receiver detected", UVM_MEDIUM)
    end
  end

/******************************* Receive TSes *******************************/

  task automatic receive_tses (output ts_s ts [] ,input int start_lane = 0,input int end_lane = pipe_num_of_lanes );
  ts = new[pipe_num_of_lanes];
    `uvm_info("pipe_monitor_bfm", "Entered receive_tses task", UVM_NONE)
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
        `uvm_info("pipe_monitor_bfm", "Waiting for COM character", UVM_NONE)
          for (int i = start_lane; i < end_lane;i++)
          begin
             // `uvm_info("pipe_monitor_bfm", $sformatf("Waiting for lane TxData %i", i), UVM_NONE)
              
              wait(TxData[(i*32+0)+:8]==8'b101_11100); //wait to see a COM charecter

              //`uvm_info("pipe_monitor_bfm", $sformatf("Recevied COM for lane TxData %i", i), UVM_NONE)
          end

          `uvm_info("pipe_monitor_bfm", "Received COM character", UVM_NONE)
          
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
  // initial begin
  //   forever begin
  //     for (int i = 0; i < pipe_num_of_lanes; i++) begin
  //       wait (TxElecIdle[i] == 0);
  //     end
  //     //`uvm_info("pipe_monitor_bfm", $sformatf("elecidle= %b detected in monitor bfm",TxElecIdle), UVM_LOW)
  //     //proxy.exit_electricle_idle();
  //     -> detected_exit_electricle_idle_e;
  //   end
  // end

  // //wait for powerdown change
  // initial begin
  //   forever begin
  //     for (int i = 0; i < pipe_num_of_lanes; i++) begin
  //       wait(PowerDown[(i*4) +:4] == 4'b0000);
  //     end
  //     `uvm_info("pipe_monitor_bfm", "Powerdown changed ", UVM_LOW)
  //     for (int i = 0; i < pipe_num_of_lanes; i++) begin
  //       wait(PhyStatus[i] == 1);
  //     end

  //     @(posedge PCLK);
  //     for (int i = 0; i < pipe_num_of_lanes; i++) begin
  //       wait(PhyStatus[i] == 0);
  //     end
  //     `uvm_info("pipe_monitor_bfm", "Phystatus asserted one clk cycle monitor bfm", UVM_LOW)
  //     -> detected_power_down_change_e;
  //     //proxy.power_down_change();
  //   end
  // end

  //waiting on power down to be P0
  initial begin
    forever begin
      for (int i = 0; i < pipe_num_of_lanes; i++) begin
        wait(PowerDown[(i*4) +:4] == 4'b0000);
      end
      `uvm_info("pipe_monitor_bfm", "Powerdown changed ", UVM_LOW)
      for (int i = 0; i < pipe_num_of_lanes; i++) begin
        wait(PhyStatus[i] == 1);
      end

      @(posedge PCLK);
      for (int i = 0; i < pipe_num_of_lanes; i++) begin
        wait(PhyStatus[i] == 0);
      end

      `uvm_info("pipe_monitor_bfm", "Powerdown= P0 detected ended in monitor bfm", UVM_LOW)
      for (int i = 0; i < pipe_num_of_lanes; i++) begin
        wait (TxElecIdle[i] == 0);
      end
      `uvm_info("pipe_monitor_bfm", "exit elecidle detected in monitor bfm", UVM_LOW)
      proxy.DUT_polling_state_start();
    end
  end  
  
  // initial begin
  //   forever begin
  //       wait(detected_power_down_change_e.triggered);
  //       `uvm_info("pipe_monitor_bfm", $sformatf("Powerdown= %b detected in monitor bfm",PowerDown), UVM_LOW)
  //       for (int i = 0; i < pipe_num_of_lanes; i++) begin
  //         assert (PowerDown[(i*4) +:4] == 4'b0000) 
  //         else begin
  //           `uvm_info("pipe_monitor_bfm", "Powerdown not p0 detected in monitor bfm", UVM_LOW)
  //           wait(detected_power_down_change_e.triggered);
  //           i = 0;
  //         end
  //       end
  //       `uvm_info("pipe_monitor_bfm", "Powerdown= P0 detected ended in monitor bfm", UVM_LOW)
  //       wait(detected_exit_electricle_idle_e.triggered);
  //       `uvm_info("pipe_monitor_bfm", "exit elecidle detected in monitor bfm", UVM_LOW)
  //       proxy.DUT_polling_state_start();
  //   end
  // end  
/******************************* Normal Data Operation *******************************/

  function int get_width ();
    int lane_width;
    case (Width)
      2'b00: lane_width = 8;
      2'b01: lane_width = 16;
      2'b11: lane_width = 32;
    endcase
    return lane_width;
  endfunction

  byte data [$];
  bit k_data [$];
  bit [0:10] tlp_length_field;
  byte tlp_gen3_symbol_0;
  byte tlp_gen3_symbol_1;
  bit [15:0] lfsr[pipe_num_of_lanes];
  bit [7:0] temp_value;
  bit [7:0] temp_data;

  int lanenum;
  int pipe_width = get_width();
  int bus_data_width = (pipe_num_of_lanes * pipe_width) ;
  tlp_t tlp_receieved;
  dllp_t dllp_receieved;
  dllp_t dllp_sent;
  tlp_t tlp_sent;
  bit [7:0] [bus_data_kontrol_param : 0] data_descrambled;
  byte tlp_q [$];
  byte dllp_q [$];
  int start_tlp;
  int start_dllp;
  bit dllp_done = 0;
  bit tlp_done = 0;
  int num_idle_data = 0;

  byte data_sent [$];
  byte data_received [$];

//check receiving data
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
          num_idle_data++;
          if (num_idle_data == bus_data_width/8) begin
            proxy.notify_idle_data_sent();
            num_idle_data = 0;
          end
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
         data_descrambled[j] = descramble(monitor_tx_scrambler,temp_value,lanenum, current_gen);
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
         data_descrambled[j] = descramble(monitor_tx_scrambler,temp_value,lanenum, current_gen);
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

 //check sending data
 initial begin
   forever begin 
     foreach(RxDataValid[i]) begin
       wait (RxDataValid[i] == 1) ; 	
     end	
     @ (posedge PCLK);
     for (int i = 0; i < (bus_data_kontrol_param + 1); i++) begin
       if ((RxDataK[i] == 1 && RxData[(8*i) +: 8] == `STP_gen_1_2) || tlp_done == 0) begin
         start_tlp = i;
         send_tlp_gen_1_2; 
       end
       else if ((RxDataK[i] == 1 && RxData[(8*i) +: 8] == `SDP_gen_1_2) || tlp_done == 0) begin
         start_dllp = i;
         send_dllp_gen_1_2; 
       end
        else if ((RxDataK[i] == 0 && RxData[(8*i) +: 8] == 8'b0000_0000)) begin
          num_idle_data++;
          if (num_idle_data == bus_data_width/8) begin
            proxy.notify_idle_data_sent();
            num_idle_data = 0;
          end
        end
     end
   end
 end
 
 task automatic send_dllp_gen_1_2;
  int end_dllp = (bus_data_width_param + 1)/8;
  for(int i = start_tlp; i < bus_data_kontrol_param + 1; i++) begin 
    int j = i - start_dllp;
    if(!(RxDataK[i] == 1 && RxData[(8*i) +: 8] == `END_gen_1_2)) begin
      lanenum = $floor(i/(pipe_max_width/8.0));
       if(RxDataK [i] == 0) begin
        temp_value = RxData[(8*i) +: 8];
        data_descrambled[j] = descramble(monitor_rx_scrambler, temp_value, lanenum, current_gen);
       end
       else if (RxDataK [i] == 1) begin
        data_descrambled[j] = (RxData[(8*i) +: 8]);
       end
    end
    else begin
      data_descrambled[j] = (RxData[(8*i) +: 8]);
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
       dllp_sent [i] = dllp_q.pop_front();
    end
    proxy.notify_dllp_sent(dllp_sent);
  end
 endtask
 
 task automatic send_tlp_gen_1_2;
  int end_tlp = (bus_data_width_param + 1)/8;
  for(int i = start_tlp; i < bus_data_kontrol_param + 1; i++) begin 
    int j = i - start_tlp;
    if(!(RxDataK[i] == 1 && RxData[(8*i) +: 8] == `END_gen_1_2)) begin
      lanenum = $floor(i/(pipe_max_width/8.0));
       if(RxDataK [i] == 0) begin
         temp_value = RxData[(8*i) +: 8];
         data_descrambled[j] = descramble(monitor_rx_scrambler, temp_value, lanenum, current_gen);
       end
       else if (RxDataK [i] == 1) begin
         data_descrambled[j] = (RxData[(8*i) +: 8]);
       end
    end
    else begin
      data_descrambled[j] = (RxData[(8*i) +: 8]);
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
      tlp_sent [i] = tlp_q.pop_front();
    end
    proxy.notify_tlp_sent(tlp_sent);
  end
 endtask  
 

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
            temp_data = RxData [((k*pipe_max_width) + (j*8)) +: 8];
            temp_data = descramble(monitor_rx_scrambler, temp_data, k, current_gen);
            data_sent.push_back(temp_data);
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
            else `uvm_fatal("pipe_monitor_bfm", "RxStartBlock & RxStartBlock values are not the same on all the lanes at Normal Data Operation")
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
          temp_data = TxData [((k*pipe_max_width) + (j*8)) +: 8];
          temp_data = descramble(monitor_tx_scrambler, temp_data, k, current_gen);
          data_received.push_back(temp_data);
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
          else `uvm_fatal("pipe_monitor_bfm", "RxStartBlock & RxStartBlock values are not the same on all the lanes at Normal Data Operation")
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
