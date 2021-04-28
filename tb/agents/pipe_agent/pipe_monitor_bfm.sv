interface pipe_monitor_bfm 
  #(
    param pipe_num_of_lanes,
    param pipe_max_width,
    localparam bus_data_width_param       = pipe_num_of_lanes  * pipe_max_width - 1,  
    localparam bus_data_kontrol_param     = (pipe_max_width / 8) * pipe_num_of_lanes - 1
  )(  
  input bit   Clk,
  input bit   Reset,
  input logic PhyReset,
   
  /*************************** RX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      RxData,    
  input logic [pipe_num_of_lanes-1:0]       RxDataValid,
  input logic [bus_data_kontrol_param:0]    RxDataK,
  input logic [pipe_num_of_lanes-1:0]       RxStartBlock,
  input logic [2*pipe_num_of_lanes-1:0]     RxSynchHeader,
  input logic [pipe_num_of_lanes-1:0]       RxValid,
  input logic [3*pipe_num_of_lanes-1:0]     RxStatus,
  input logic                               RxElecIdle,
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      TxData,    
  input logic [pipe_num_of_lanes-1:0]       TxDataValid,
  input logic [bus_data_kontrol_param:0]    TxDataK,
  input logic [pipe_num_of_lanes-1:0]       TxStartBlock,
  input logic [2*pipe_num_of_lanes-1:0]     TxSynchHeader,
  input logic [pipe_num_of_lanes-1:0]       TxElecIdle,
  input logic [pipe_num_of_lanes-1:0]       TxDetectRxLoopback,

  /*********************** Comands and Status Signals **********************************/
  input logic [3:0]                         PowerDown;
  input logic [3:0]                         Rate;
  input logic                               PhyStatus;
  input logic [1:0]                         Width;
  input logic                               PclkChangeAck;
  input logic                               PclkChangeOk;
  /*************************************************************************************/
  
  /******************************* Message Bus Interface *******************************/
  input logic [7:0]                         M2P_MessageBus;
  input logic [7:0]                         P2M_MessageBus;
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  input logic [18*pipe_num_of_lanes-1:0]   LocalTxPresetCoeffcients,
  input  logic [18*pipe_num_of_lanes-1:0]   TxDeemph,
  input logic [6*pipe_num_of_lanes-1:0]    LocalFS,
  input logic [6*pipe_num_of_lanes-1:0]    LocalLF,
  input  logic [pipe_num_of_lanes-1:0]      GetLocalPresetCoeffcients,
  input logic [pipe_num_of_lanes-1:0]      LocalTxCoeffcientsValid,
  input  logic [6*pipe_num_of_lanes-1:0]    FS,    // TODO: Review specs for these values
  input  logic [6*pipe_num_of_lanes-1:0]    LF,    // TODO: Review specs for these values
  input  logic [pipe_num_of_lanes-1:0]      RxEqEval,
  input  logic [4*pipe_num_of_lanes-1:0]    LocalPresetIndex,
  input  logic [pipe_num_of_lanes-1:0]      InvalidRequest,  // TODO: this signal needs to be checked
  input logic [6*pipe_num_of_lanes-1:0]    LinkEvaluationFeedbackDirectionChange
  /*************************************************************************************/
);

  `include "uvm_macros.svh"

  import uvm_pkg::*;
  import pipe_agent_pkg::*;

  pipe_monitor proxy;
  bit [15:0] lfsr[`NUM_OF_LANES];

  function reset_lfsr ();
    foreach(lfsr[i])
    begin
      lfsr[i] = 4'hFFFF;
    end
  endfunction

  forever begin
    proxy.detect_link_up;
  end

  /******************************* Receive TS*******************************/

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

/******************************* RESET# Scenario detection *******************************/
  int temp[2:0];
forever begin   

  wait(reset==1);
  @(posedge PCLK);
  //check on default values
  assert (TxDetectRx==0) else `uvm_error ("pipe_monitor_bfm", "TxDetectRx isn't setted by default value during reset");
  assert (TxElecIdle==1) else `uvm_error ("pipe_monitor_bfm", "TxElecIdle isn't setted by default value during reset");
  //assert (TxCompliance==0) else `uvm_error ("TxCompliance isn't setted by default value during reset");
  assert (PowerDown=='b01) else `uvm_error ("PowerDown isn't in P1 during reset");

  //check that pclk is operational
  temp=PclkRate;   //shared or per lane?
  @(posedge PCLK);
  assert (temp==PclkRate) else `uvm_error ("PCLK is not stable");

  wait(reset==0);
  @(posedge PCLK);

  foreach(PhyStatus[i]) begin 
    wait(PhyStatus[i]==0);
  end
  @(posedge PCLK);
  proxy.notify_reset_detected();
  `uvm_info ("pipe_monitor_bfm", "Monitor BFM Detected (Reset scenario)", UVM_LOW);
end

/******************************* Receiver detection Scenario *******************************/
forever begin  
  wait(TxDetectRx==1);
  @(posedge PCLK);
  assert (PowerDown=='b10) else `uvm_error ("PowerDown isn't in P2 during Detect");

  fork
    foreach(PhyStatus[i]) begin
      wait(PhyStatus[i]==1);
    end

    foreach(RxStatus[i]) begin 
      wait(RxStatus[i]=='b011);
    end    
  join
  @(posedge PCLK);

  // TODO: Modify
  fork
    foreach(PhyStatus[i]) begin
      wait(PhyStatus[i]==0);
    end

    foreach(RxStatus[i]) begin 
      wait(RxStatus[i]=='b000);  //??
    end    
  join
  @(posedge PCLK);

  // TODO: Change to zero??
  wait(TxDetectRx==1);
  @(posedge PCLK);
  proxy.notify_receiver_detected();
  `uvm_info ("Monitor BFM Detected (Receiver detection scenario)");
end

/******************************* Receive TSes *******************************/

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

  // task receive_data ();
  //   @(posedge pclk);
  //   TxValid = 1'b1;
  //   RxData [7:0] = 8'b0000_0000;
  //   RxDataK = 1'b0;    // at2kd
  // if data l gat == 0 masln ha2ol de idle data 
  // endtask

  function bit [7:0] descramble (bit [7:0] in_data, shortint unsigned lane_num);
    bit [15:0] lfsr_new;
    bit [7:0] descrambled_data;

    // LFSR value after 8 serial clocks
    for (i=0; i<8; i++)
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
  
//waiting on power down to be P0
initial 
begin
  forever
  begin
      for (int i = 0; i < NUM_OF_LANES; i++) begin
        @ (PowerDown[i] == 'b00);
      end
      
      for (int i = 0; i < NUM_OF_LANES; i++) begin
        @ (PhyStatus[i] == 1);
      end
      @(posedge CLK);
      for (int i = 0; i < NUM_OF_LANES; i++) begin
        @ (PhyStatus[i] == 0);
      end

      for (int i = 0; i < NUM_OF_LANES; i++) begin
        @ (TxElecIdle[i] == 0)	;
      end
      proxy.pipe_polling_state_start();
  end
end  

  // Receive Idle Data
  initial
  begin
    forever
    begin
      receive_idle_data();
      proxy.notify_idle_data_detected();
    end
  end
endinterface

