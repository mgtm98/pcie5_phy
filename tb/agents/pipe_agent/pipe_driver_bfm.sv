interface pipe_driver_bfm
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
  output logic [bus_data_width_param:0]      RxData,    
  output logic [pipe_num_of_lanes-1:0]       RxDataValid,
  output logic [bus_data_kontrol_param:0]    RxDataK,
  output logic [pipe_num_of_lanes-1:0]       RxStartBlock,
  output logic [2*pipe_num_of_lanes-1:0]     RxSyncHeader,
  output logic [pipe_num_of_lanes-1:0]       RxValid,
  output logic [3*pipe_num_of_lanes-1:0]     RxStatus,
  output logic                               RxElecIdle,
  //output logic [pipe_num_of_lanes-1:0]     RxElecIdle,
  
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  input  logic [bus_data_width_param:0]      TxData,    
  input  logic [pipe_num_of_lanes-1:0]       TxDataValid,
  input  logic [bus_data_kontrol_param:0]    TxDataK,
  input  logic [pipe_num_of_lanes-1:0]       TxStartBlock,
  input  logic [2*pipe_num_of_lanes-1:0]     TxSyncHeader,
  input  logic [pipe_num_of_lanes-1:0]       TxElecIdle,
  input  logic [pipe_num_of_lanes-1:0]       TxDetectRxLoopback,

  /*********************** Comands and Status Signals **********************************/
  input  logic [4*pipe_num_of_lanes - 1:0]   PowerDown,
  input  logic [3:0]                         Rate,
  output logic [pipe_num_of_lanes-1:0]       PhyStatus,
  input  logic [1:0]                         Width,
  input  logic [4:0]                         PCLKRate,
  input  logic                               PclkChangeAck,
  output logic                               PclkChangeOk,
  /*************************************************************************************/
  
  /******************************* Message Bus Interface *******************************/
  output logic [7:0]                         M2P_MessageBus,
  input  logic [7:0]                         P2M_MessageBus,
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  output logic [18*pipe_num_of_lanes-1:0]    LocalTxPresetCoeffcients,
  input  logic [18*pipe_num_of_lanes-1:0]    TxDeemph,
  output logic [6*pipe_num_of_lanes-1:0]     LocalFS,
  output logic [6*pipe_num_of_lanes-1:0]     LocalLF,
  input  logic [pipe_num_of_lanes-1:0]       GetLocalPresetCoeffcients,
  output logic [pipe_num_of_lanes-1:0]       LocalTxCoeffcientsValid,
  input  logic [6*pipe_num_of_lanes-1:0]     FS,    // TODO: Review specs for these values
  input  logic [6*pipe_num_of_lanes-1:0]     LF,    // TODO: Review specs for these values
  input  logic [pipe_num_of_lanes-1:0]       RxEqEval,
  input  logic [4*pipe_num_of_lanes-1:0]     LocalPresetIndex,
  input  logic [pipe_num_of_lanes-1:0]       InvalidRequest,  // TODO: this signal needs to be checked
  output logic [6*pipe_num_of_lanes-1:0]     LinkEvaluationFeedbackDirectionChange
  /*************************************************************************************/

);

`include "uvm_macros.svh"
`include "settings.svh"
import uvm_pkg::*;
import common_pkg::*;
import pipe_agent_pkg::*;


  
//------------------------------------------
// Data Members
//------------------------------------------
gen_t current_gen = GEN1;
scrambler_s driver_scrambler;
//bit [15:0] lfsr [`NUM_OF_LANES];
bit [5:0]  lf_usp;
bit [5:0]  fs_usp;
bit [5:0]  lf_dsp;
bit [5:0]  fs_dsp;
bit [5:0]  cursor;
bit [5:0]  pre_cursor;
bit [5:0]  post_cursor;
bit [2:0]  my_rx_preset_hint;
bit [3:0]  my_tx_preset;
bit [17:0] my_local_txPreset_coefficients;
bit        eval_feedback_was_asserted = 0;
bit flag_tx_preset_applied;
assign LocalFS={pipe_num_of_lanes{fs_usp}};
assign LocalLF={pipe_num_of_lanes{lf_usp}};

/******************************* RESET# (Phystatus de-assertion) *******************************/
initial begin
  forever begin 
    //`uvm_info("pipe_driver_bfm", "pipe reset scenario started", UVM_LOW)
    wait(Reset==0);
    // @(posedge PCLK);
    RxDataK                               = 0;
    RxData                                = 0;
    RxStatus                              = 0;
    RxDataValid                           = 0;
    RxStartBlock                          = 0;
    RxSyncHeader                          = 0;
    RxElecIdle                            = 0;
    PclkChangeOk                          = 0;
    LocalTxPresetCoeffcients              = 0;
    lf_usp                               = 0;
    fs_usp                               = 0;
    LocalTxCoeffcientsValid               = 0;
    LinkEvaluationFeedbackDirectionChange = 0;
    current_gen                           = GEN1;
  
    PhyStatus = {pipe_num_of_lanes{1'b1}};

    @(posedge PCLK);

    wait(Reset==1);
    @(posedge PCLK);

    foreach(PhyStatus[i]) begin
      PhyStatus[i] = 0;
    end
    @(posedge PCLK);

    reset_lfsr(driver_scrambler,current_gen);
  end
end
/******************************* Detect (Asserting needed signals) *******************************/
initial begin
  forever begin 
    //`uvm_info("pipe_driver_bfm", "Waiting txdetectrx to be 1", UVM_LOW)
    foreach(TxDetectRxLoopback[i]) begin
      wait(TxDetectRxLoopback[i] == 1);
    end
    //`uvm_info("pipe_driver_bfm", "Received txdetectrx to be 1", UVM_LOW)
    
    @(posedge PCLK);
  
    foreach(PhyStatus[i]) begin
      PhyStatus[i]=1;
    end
    for (int i = 0; i < `NUM_OF_LANES; i++) begin 
      RxStatus[(i*3) +:3] = 3'b011;
    end 
  
    @(posedge PCLK);
  
    foreach(PhyStatus[i]) begin
      PhyStatus[i]=0;
    end
    for (int i = 0; i < `NUM_OF_LANES; i++) begin      
      RxStatus[(i*3) +:3] = 3'b000; 
    end    
    @(posedge PCLK);
  end
end

//starting polling state
initial begin
  logic [4*pipe_num_of_lanes - 1:0] previous_PowerDown;
  forever begin
    for (int i = 0; i < `NUM_OF_LANES; i++) begin
      wait(PowerDown[(i*4) +:4] == 4'b0000 && PowerDown !== previous_PowerDown);
    end
    previous_PowerDown = PowerDown;
    //`uvm_info("pipe_driver_bfm", "Powerdown= P0 detected", UVM_LOW)
    @(posedge PCLK);
    for (int i = 0; i < `NUM_OF_LANES ; i++) begin
      PhyStatus[i] = 1;
    end
    // PhyStatus = 1;
  
    @(posedge PCLK);
    for (int i = 0; i < `NUM_OF_LANES ; i++) begin
      PhyStatus[i] = 0;
    end
    // PhyStatus = 0;

    //`uvm_info("pipe_driver_bfm", "Waiting for deassertion Txelecidle signal", UVM_LOW)
    for (int i = 0; i < `NUM_OF_LANES; i++) begin
      wait(TxElecIdle[i] == 0);
    end
    //`uvm_info("pipe_driver_bfm", "deassertion of Txelecidle signal", UVM_LOW)
  end
end
//------------------------------------------
// Methods
//------------------------------------------

function automatic void ts_symbols_maker(ts_s ts,ref byte RxData_Q[$] , ref bit RxDataK_Q[$]);
  byte temp;
  if(current_gen <= GEN2)
  begin
    // Symbol 0
    RxData_Q = {RxData_Q,8'b10111100} ;
    RxDataK_Q = {RxDataK_Q,1};    
    
    //Symbol 1
    if(ts.use_link_number)
    begin
      RxData_Q = {RxData_Q, ts.link_number};
      RxDataK_Q = {RxDataK_Q, 0};
    end
    else
    begin
      RxData_Q = {RxData_Q, 8'b11110111}; //PAD character
      RxDataK_Q = {RxDataK_Q, 1};
    end

    //Symbol 2
    if(ts.use_lane_number)
    begin
      RxData_Q = {RxData_Q, ts.lane_number};
      RxDataK_Q = {RxDataK_Q, 0};
    end
    else
    begin
      RxData_Q = {RxData_Q, 8'b11110111}; //PAD character
      RxDataK_Q = {RxDataK_Q, 1};
    end

    //Symbol 3
    if(ts.use_n_fts)
    begin
      RxData_Q = {RxData_Q, ts.n_fts};
      RxDataK_Q = {RxDataK_Q, 0};
    end
    else
    begin
      RxData_Q = {RxData_Q, 8'h00};
      RxDataK_Q = {RxDataK_Q, 0};
    end

    //Symbol 4
    RxDataK_Q = {RxDataK_Q, 0};
    
    temp = 0'hFF;
    temp[0] = 0;
    if(ts.max_gen_supported == GEN1)
      temp[5:2] = 0;
    else if(ts.max_gen_supported == GEN2)
      temp[5:3] = 0;
    else if(ts.max_gen_supported == GEN3)
      temp[5:4] = 0;
    else if(ts.max_gen_supported == GEN4)
      temp[5] = 0;
    
    temp[6] = ts.auto_speed_change;
    temp[7] = ts.speed_change;

    RxData_Q = {RxData_Q, temp};

    //Symbol 5
    RxData_Q = {RxData_Q, 0'h00};
    RxDataK_Q = {RxDataK_Q, 0};

    //Symbol 6
    if(ts.equalization_command)
    begin
        temp = 8'hFF;
        temp[2:0] = ts.rx_preset_hint;
        temp[6:3] = ts.tx_preset;
        if(ts.ts_type == TS2)
          temp[7] = ts.equalization_command;  
    end
    else begin
      if(ts.ts_type == TS1)
        temp = 8'h4A;
      else
      temp = 8'h45;
    end

    RxData_Q = {RxData_Q,temp};
    RxDataK_Q = {RxDataK_Q,0};
    

    //Symbol 7~15
    if(ts.ts_type == TS1)
    begin
      RxData_Q = {RxData_Q,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A};
      RxDataK_Q = {RxDataK_Q,0,0,0,0,0,0,0,0,0};
    end
    else
    begin
      RxData_Q = {RxData_Q,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45};
      RxDataK_Q = {RxDataK_Q,0,0,0,0,0,0,0,0,0};
    end    
  end

  else
  begin
    // Symbol 0
    if(ts.ts_type ==TS1)
      RxData_Q = {RxData_Q,8'h1E};
    else
      RxData_Q = {RxData_Q,8'h2D};
    
    //Symbol 1
    if(ts.use_link_number)
      RxData_Q = {RxData_Q, ts.link_number};
    else
      RxData_Q = {RxData_Q, 8'b11110111}; //PAD character
    

    //Symbol 2
    if(ts.use_lane_number)
      RxData_Q = {RxData_Q, ts.lane_number};
    else
      RxData_Q = {RxData_Q, 8'b11110111}; //PAD character

    //Symbol 3
    if(ts.use_n_fts)
      RxData_Q = {RxData_Q, ts.n_fts};
    else
      RxData_Q = {RxData_Q, 8'h00};

    //Symbol 4
    temp = 0'hFF;
    temp[0] = 0;
    if(ts.max_gen_supported == GEN1)
      temp[5:2] = 0;
    else if(ts.max_gen_supported == GEN2)
      temp[5:3] = 0;
    else if(ts.max_gen_supported == GEN3)
      temp[5:4] = 0;
    else if(ts.max_gen_supported == GEN4)
      temp[5] = 0;
    
    temp[6] = ts.auto_speed_change;
    temp[7] = ts.speed_change;
    RxData_Q = {RxData_Q, temp};

    //Symbol 5
    RxData_Q = {RxData_Q, 0'h00};


    //Symbol 6
    temp = 8'h00;
    if(1) //need flag
    begin
      if(ts.ts_type == TS1)
      begin
        if(1) //need flag
          temp[1:0] = ts.ec;

        if(1) //need flag
          temp[6:3] = ts.tx_preset;

        temp[7] = ts.use_preset;  
      end
      else if(ts.ts_type == TS2)
      begin
        //not supported yet
      end
    end
    else
      temp = 8'h4A;

    RxData_Q = {RxData_Q,temp};

    //Symbol 7
    temp = 8'h00;
    if(ts.ts_type == TS1)
    begin
      if(ts.ec == 2'b01) 
        temp[5:0] = ts.fs_value;
      else
        temp[5:0] = ts.pre_cursor;
    end
    else
      temp = 8'h45;

    RxData_Q = {RxData_Q,temp};


    //Symbol 8
    temp = 8'h00;
    if(ts.ts_type == TS1)
    begin
      if(ts.ec == 2'b01)
        temp[5:0] = ts.lf_value;
      else
        temp[5:0] = ts.cursor;
    end
    else
      temp = 8'h45;

    RxData_Q = {RxData_Q,temp};

    //Symbol 9
    temp = 8'h00;
    if(ts.ts_type == TS1)
    begin
        temp[5:0] = ts.post_cursor;
        if(0) //need flag
          temp[6] = ts.rcv;

        temp[7] = ^{temp[6:0],RxData_Q[6],RxData_Q[7],RxData_Q[8]};
    end
    else
      temp = 8'h45;

    RxData_Q = {RxData_Q,temp};

    //Symbol 10~15
    if(ts.ts_type == TS1)
      RxData_Q = {RxData_Q,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A};
    else
      RxData_Q = {RxData_Q,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45};
  end


endfunction: ts_symbols_maker 


task automatic send_ts(ts_s ts ,int start_lane = 0, int end_lane = pipe_num_of_lanes);
  int width = get_width();
  bit [pipe_max_width-1:0] Data;
  bit [pipe_max_width/8 -1:0] Character;
  byte temp;
  byte RxData_Q[$]; //the actual symbols will be here (each symbol is a byte)
  // bit RxDataValid_Q[$];
  bit RxDataK_Q[$];
  //bit RxStartBlock_Q[$];
  //bit [1:0] RxSyncHeader_Q[$];
  // bit RxValid_Q[$];
  //bit [2:0] RxStatus_Q[$];
  //bit RxElecIdle_Q[$];

  for(int i = start_lane; i < end_lane; i++) begin
    RxDataValid[i] = 1;
    RxValid[i] = 1;
  end

  reset_lfsr(driver_scrambler, current_gen);

  ts_symbols_maker(ts,RxData_Q,RxDataK_Q);


  if(current_gen <=GEN2)
  begin
    while(RxData_Q.size())
    begin
      
        // Stuffing the Data and characters depending on the number of Bytes sent per clock on each lane
      for(int j=0;j<width/8;j++)
      begin
        Data[j*8 +:8] = RxData_Q.pop_front();
        Character[j] = RxDataK_Q.pop_front();
          //RxData_Q = RxData_Q[1:$];
          //RxDataK_Q = RxDataK_Q[1:$];  
      end
      for(int i = start_lane;i<end_lane;i++)
      begin
        //duplicating the Data and Characters to each lane in the driver
        RxData[i* pipe_max_width +: pipe_max_width] =Data ;
        RxDataK[i* pipe_max_width/8 +:pipe_max_width/8] = Character;
        
      end
      @(posedge PCLK);
    end 
  end

  if(current_gen > GEN2)
  begin
    
    while(RxData_Q.size())
    begin      
      for(int i = start_lane;i<end_lane;i++)
      begin

        // Stuffing the Data and characters depending on the number of Bytes sent per clock on each lane
        for(int j=0;j<width/8;j++)
        begin
          Data[j*8 +:8] = RxData_Q[0];
          RxData_Q = RxData_Q[1:$];
        end

        //duplicating the Data and Characters to each lane in the driver
        RxData[i* pipe_max_width +:pipe_max_width] =Data ;
      end
    @(posedge PCLK);  
    end     
  end
  for(int i = start_lane; i < end_lane; i++) begin
    RxDataValid[i] = 0;
    RxValid[i] = 0;
  end
endtask


task automatic send_tses(ts_s ts [], int start_lane = 0, int end_lane = pipe_num_of_lanes);
  int width = get_width();

  byte RxData_Q [][$];
  bit RxDataK_Q [][$];
  bit [pipe_max_width-1:0] Data []; // Data [i]-> dynamic array(size=ts.size()) [j]-> fixed array(size=pipe_max_width)
  bit [pipe_max_width/8 -1:0] Character [];



  RxData_Q = new[ts.size()];
  RxDataK_Q = new[ts.size()];
  Data = new[ts.size()];
  Character = new[ts.size()];
  foreach(ts[i])
  begin
    ts_symbols_maker(ts[i],RxData_Q[i],RxDataK_Q[i]);
    
  end

  reset_lfsr(driver_scrambler, current_gen);
  //`uvm_info("pipe_driver_bfm", $sformatf("%d", width), UVM_NONE)

  if(current_gen <=GEN2)
  begin
    while(RxData_Q[0].size())
    begin
      for(int i = start_lane; i < end_lane; i++) begin
        RxDataValid[i] = 1;
        RxValid[i] = 1;
      end
      
      for(int i = start_lane;i<end_lane;i++)
      begin
        // Stuffing the Data and characters depending on the number of Bytes sent per clock on each lane
        for(int j=0;j<width/8;j++)
        begin
          Data[i][j*8 +:8] = RxData_Q[i].pop_front();
          Character[i][j] = RxDataK_Q[i].pop_front();
          ////`uvm_info("pipe_driver_bfm", $sformatf("%p", RxData_Q[i]), UVM_NONE)
        end

        //duplicating the Data and Characters to each lane in the driver
        RxData[i*pipe_max_width+:pipe_max_width] =Data[i] ;
        RxDataK[i *pipe_max_width/8 +:pipe_max_width/8] = Character[i];
      end
      @(posedge PCLK);
    end 
  end
  for(int i = start_lane; i < end_lane; i++) begin
    RxDataValid[i] = 0;
    RxValid[i] = 0;
  end
endtask

task automatic send_eios();
  int width = get_width();
  bit [pipe_max_width-1:0] Data; 
  bit [pipe_max_width/8 -1:0] Character;
  bit [7:0] RxData_Q[$];
  bit RxDataK_Q[$];
  bit [7:0] com = 8'b10111100;
  bit [7:0] idl = 8'b01111100;
  bit [7:0] eios_gen3_ident = 8'h66;

  if(current_gen <=GEN2)
  begin
    RxData_Q = {com,idl,idl,idl};
    RxDataK_Q = {1,1,1,1};  
    while(RxData_Q.size())
    begin
      @(posedge PCLK);

      // Stuffing the Data and characters depending on the number of Bytes sent per clock on each lane
      for(int j=0;j<width/8;j++)
      begin
        Data[j*8 +:8] = RxData_Q.pop_front();
        Character[j] = RxDataK_Q.pop_front();
      end
      
      //duplicating the Data and Characters to each lane in the driver
      for(int i = 0;i<pipe_num_of_lanes;i++)
      begin
        RxData[i*pipe_max_width+:pipe_max_width] <= Data;
        RxDataK[i *pipe_max_width/8 +:pipe_max_width/8] <= Character;  
      end
    end 
    @(posedge PCLK);
    for(int i = 0; i < pipe_num_of_lanes; i++) begin
      RxDataValid[i] <= 1;
      RxValid[i] <= 1;
    end
    RxElecIdle <= 1;  
  end

  else //gen3 and higher:
  begin
    for(int z =0;z<16*8/width;z++)
    begin
      @(posedge PCLK);
      //stuff data depending on lane width
      for(int j=0;j<width/8;j++)
      begin
        Data[j*8 +:8] = eios_gen3_ident;
      end

      //driving signals of each lane
      for(int i = 0;i<pipe_num_of_lanes;i++)
      begin //Synchheader and startblock driving for first clock cycle
        
        if(z==0)
        begin
          RxStartBlock[i] <= 1'b1;
          RxSyncHeader[i*2 +:2] <= 2'b01;
        end
        else
        begin
          RxStartBlock[i] <= 1'b0;
        end
        //driving data on lanes
        RxData[i*pipe_max_width+:pipe_max_width] <= Data;
      end
    end
    @(posedge PCLK)
    RxElecIdle <= 1'b1;
  end
endtask

task automatic send_eieos();
  int width = get_width();

  bit [pipe_max_width-1:0] Data; 
  bit [pipe_max_width/8 -1:0] Character;
  bit [7:0] RxData_Q[$];
  bit RxDataK_Q[$];

  bit [7:0] com = 8'b10111100;
  bit [7:0] eie = 8'b11111100;
  bit [7:0] ts1_ident = 8'b01001010;
  RxData_Q = {com,eie,eie,eie,eie,eie,eie,eie,eie,eie,eie,eie,eie,eie,eie,ts1_ident};
  RxDataK_Q = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0};

  if(current_gen <=GEN2)
  begin
    while(RxData_Q.size())
    begin
      @(posedge PCLK);

      // for(int i = start_lane; i < end_lane; i++) begin
      //   RxDataValid[i] <= 1;
      //   RxValid[i] <= 1;
      // end
      
      
      // Stuffing the Data and characters depending on the number of Bytes sent per clock on each lane
      for(int j=0;j<width/8;j++)
      begin
        Data[j*8 +:8] = RxData_Q.pop_front();
        Character[j] = RxDataK_Q.pop_front();
      end
      
      //duplicating the Data and Characters to each lane in the driver
      for(int i = 0;i<pipe_num_of_lanes;i++)
      begin
        RxData[i*pipe_max_width+:pipe_max_width] <= Data;
        RxDataK[i *pipe_max_width/8 +:pipe_max_width/8] <= Character;  
      end
    end 
    @(posedge PCLK);
    RxElecIdle <= 0;  
  end
  else
  begin

  end
  // for(int i = start_lane; i < end_lane; i++) begin
  //   RxDataValid[i] <= 0;
  //   RxValid[i] <= 0;
  // end
endtask


/******************************* Normal Data Operation *******************************/

bit [0:10] tlp_length_field;
byte tlp_gen3_symbol_0;
byte tlp_gen3_symbol_1;
bit [7:0] data [$];
bit k_data [$];

function int get_width ();
	int lane_width;
	case (Width)
		2'b00: lane_width = 8;
		2'b01: lane_width = 16;
		2'b11: lane_width = 32;
	endcase
	return lane_width;
endfunction

bit [7:0] temp;
bit [7:0] temp_data;

function void send_tlp (tlp_t tlp);
  //`uvm_info("pipe_driver_bfm",$sformatf("sending tlp, size= %d",tlp.size()),UVM_MEDIUM)
  if (current_gen == GEN1 || current_gen == GEN2) begin
    data.push_back(`STP_gen_1_2);          k_data.push_back(K);

    for (int i = 0; i < tlp.size(); i++) begin
      data.push_back(tlp[i]);              k_data.push_back(D);
    end

    data.push_back(`END_gen_1_2);          k_data.push_back(K);

  end
  else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5)begin
    tlp_length_field  = tlp.size() + 2;
    tlp_gen3_symbol_0 = {`STP_gen_3 , tlp_length_field[0:3]};
    tlp_gen3_symbol_1 = {tlp_length_field[4:10] , 1'b0};

    data.push_back(tlp_gen3_symbol_0);    k_data.push_back(K); //nosaha K w nosaha D ???
    data.push_back(tlp_gen3_symbol_1);    k_data.push_back(D);
    //check if i need k_data queue in gen3 or not??
    //check on lenth constraint of TLP , is it different than earlier gens??? 
    for (int i = 0; i < tlp.size(); i++) begin
      data.push_back(tlp[i]);              k_data.push_back(D);
    end

  end
endfunction

function void send_dllp (dllp_t dllp);
  //`uvm_info("pipe_driver_bfm","sending dllp",UVM_MEDIUM)
  if (current_gen == GEN1 || current_gen == GEN2) begin
    data.push_back(`SDP_gen_1_2);          k_data.push_back(K);
    data.push_back(dllp[0]);               k_data.push_back(D);
    data.push_back(dllp[1]);               k_data.push_back(D);
    data.push_back(dllp[2]);               k_data.push_back(D);
    data.push_back(dllp[3]);               k_data.push_back(D);
    data.push_back(dllp[4]);               k_data.push_back(D);
    data.push_back(dllp[5]);               k_data.push_back(D);
    data.push_back(`END_gen_1_2);          k_data.push_back(K);
  end
  else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5) begin
    //check if i need k_data queue in gen3 or not??
    data.push_back(`SDP_gen_3_symbol_0);   
    data.push_back(`SDP_gen_3_symbol_1);   
    data.push_back(dllp[0]);              
    data.push_back(dllp[1]);               
    data.push_back(dllp[2]);               
    data.push_back(dllp[3]);          
    data.push_back(dllp[4]);           
    data.push_back(dllp[5]);            
  end
  //`uvm_info("pipe_driver_bfm",$sformatf("queue_data = %p",data),UVM_MEDIUM)
  //`uvm_info("pipe_driver_bfm",$sformatf("k_queue_data = %p",k_data),UVM_MEDIUM)
endfunction

function void send_idle_data ();
  for (int i = 0; i < pipe_num_of_lanes; i++) begin
    data.push_back(8'b00000000);           k_data.push_back(D); //control but scrambled
  end
  //`uvm_info("pipe_driver_bfm",$sformatf("queue_data = %p",data),UVM_MEDIUM)
endfunction

task send_data ();
  //`uvm_info("pipe_driver_bfm","entered send data",UVM_MEDIUM)
  //`uvm_info("pipe_driver_bfm",$sformatf("current_gen = %s",current_gen.name()),UVM_MEDIUM)
  wait (PowerDown == 4'b0000) ;
  //else `uvm_error("pipe_driver_bfm", "Unexpected PowerDown value at Normal Data Operation")
  RxElecIdle = 0;  
  for (int i = 0; i < pipe_num_of_lanes; i++) begin
    RxDataValid [i] = 1;
  end
	if (current_gen == GEN1 || current_gen == GEN2)
		send_data_gen_1_2 ();
	else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5) 
	 	send_data_gen_3_4_5 ();
  for (int i = 0; i < pipe_num_of_lanes; i++) begin
    RxDataValid [i] = 0;
  end
endtask

 task automatic send_data_gen_1_2 ();
  int lanenum;
  byte unsigned data_scrambled [$];
  int pipe_width = get_width();
  int bus_data_width = (pipe_num_of_lanes * pipe_width);
  for(int i = 0; i < data.size() + i; i++) begin
    lanenum = i;
    lanenum = lanenum - pipe_num_of_lanes * ($floor(lanenum/pipe_num_of_lanes));
    if(k_data [i] == D) begin
      temp = data.pop_front();;
      data_scrambled[i] = scramble(driver_scrambler, temp, lanenum, current_gen);
    end
    else if (k_data [i] == K) begin
      data_scrambled[i] = data.pop_front();;
    end
  end  
  //`uvm_info("pipe_driver_bfm",$sformatf("data_scrambled = %p",data_scrambled),UVM_MEDIUM)
  //`uvm_info("pipe_driver_bfm",$sformatf("k_queue_data = %p",k_data),UVM_MEDIUM)
  for (int k = 0; k < data_scrambled.size() + k ; k = k + (bus_data_width)/8) begin 
    for (int j = 0; j < (bus_data_width)/(pipe_num_of_lanes*8); j++) begin
      for (int i = j ; i < (bus_data_width_param + 1)/8 ; i = i + (bus_data_width_param + 1)/(pipe_num_of_lanes*8)) begin 
        RxData[(8*i) +: 8] = data_scrambled.pop_front();
        RxDataK[i] = k_data.pop_front();
        //`uvm_info("pipe_driver_bfm",$sformatf("rxdata = %h",RxData),UVM_MEDIUM)
      end
    end
    @ (posedge PCLK);
  end
  ////`uvm_info("pipe_driver_bfm",$sformatf("rxdata2 = %h",RxData),UVM_MEDIUM)
  if (!(lanenum == pipe_num_of_lanes)) begin
    for (int j = lanenum + 1; j < (bus_data_width)/8; j ++) begin
      RxData [(8*j) +: 8] = 8'b11110111;
      RxDataK[j] = 1'b1;
    end
  end
endtask

task automatic send_data_gen_3_4_5 ();
  int unsigned data_block_size = (128*pipe_num_of_lanes)/8;
  int num_of_idle_data = data_block_size - (data.size() % data_block_size);
  int num_of_data_blocks = data.size()/data_block_size;   
  int lane_width = get_width();
  int num_of_clks = 128/lane_width;
  int num_of_bytes_in_lane = lane_width/8;
  if (data.size() % data_block_size != 0) begin
    for (int i = 0; i < num_of_idle_data; i++) begin
      data.push_back(8'b00000000);
      k_data.push_back(0);
    end
  end
  for (int i = 0; i < num_of_data_blocks; i++) begin 
    for (int j = 0; j < num_of_clks; j++) begin 
      for (int k = 0; k < num_of_bytes_in_lane; k++) begin
        for (int l = 0; l < pipe_num_of_lanes; l++) begin
          if (j == 0) begin
            RxStartBlock [l] = 1'b1;
            RxSyncHeader [l*2 +: 2] = 2'b10;
          end
          else begin
            RxStartBlock [l] = 1'b0;
          end
          temp_data = data.pop_front();
          RxData [((l*pipe_max_width) + (k*8)) +: 8] = scramble(driver_scrambler, temp_data, l, current_gen);
        end
      end
      @(posedge PCLK);
    end
  end
endtask


/******************************* Equalization *******************************/
  initial begin
    flag_tx_preset_applied=0;
    forever begin
      wait((LocalPresetIndex==my_tx_preset)&&(GetLocalPresetCoeffcients == 1));
      @(posedge PCLK);
      LocalTxCoeffcientsValid  <= 1;
      LocalTxPresetCoeffcients <=my_local_txPreset_coefficients;

      @(posedge PCLK);
      LocalTxCoeffcientsValid  <= 0;
      wait(TxDeemph == my_local_txPreset_coefficients);
      flag_tx_preset_applied=1;
    end
  end

  task eqialization_preset_applied();
    //`uvm_info("pipe_monitor_bfm", "waiting for flag_tx_preset_applied ", UVM_NONE)
    wait(flag_tx_preset_applied==1);
  endtask : eqialization_preset_applied


  function void set_eq_param( bit [5:0]  lf_usp_i,
                              bit [5:0]  fs_usp_i,
                              bit [5:0]  lf_dsp_i,
                              bit [5:0]  fs_dsp_i,
                              bit [5:0]  cursor_i,
                              bit [5:0]  pre_cursor_i,
                              bit [5:0]  post_cursor_i,
                              bit [3:0]  my_tx_preset_i,
                              bit [2:0]  my_rx_preset_hint_i,
                              bit [17:0] my_local_txPreset_coefficients_i);

    lf_usp<=lf_usp_i;
    fs_usp<=fs_usp_i;
    lf_dsp<=lf_dsp_i;
    fs_dsp<=fs_dsp_i;
    cursor<=cursor_i;
    pre_cursor<=pre_cursor_i;
    post_cursor<=post_cursor_i;
    my_tx_preset<=my_tx_preset_i;
    my_rx_preset_hint<=my_rx_preset_hint_i;
    my_local_txPreset_coefficients<=my_local_txPreset_coefficients_i;

  endfunction : set_eq_param



  initial begin
    forever begin
      wait(RxEqEval == 1);
      assert((FS=={pipe_num_of_lanes{fs_dsp}})&&(LF=={pipe_num_of_lanes{lf_dsp}}))else `uvm_error("pipe_driver_bfm", "FS and LF not assigned");
      @(posedge PCLK);
      LinkEvaluationFeedbackDirectionChange <= 6'b000000;
      eval_feedback_was_asserted <= 1;
    end
  end

  

endinterface
