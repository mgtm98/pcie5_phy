interface pipe_driver_bfm
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
  output logic [bus_data_width_param:0]      RxData,    
  output logic [pipe_num_of_lanes-1:0]       RxDataValid,
  output logic [bus_data_kontrol_param:0]    RxDataK,
  output logic [pipe_num_of_lanes-1:0]       RxStartBlock,
  output logic [2*pipe_num_of_lanes-1:0]     RxSyncHeader,
  output logic [pipe_num_of_lanes-1:0]       RxValid,
  output logic [3*pipe_num_of_lanes-1:0]     RxStatus,
  output logic                               RxElecIdle,
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
  input  logic [3:0]                         PowerDown,
  input  logic [3:0]                         Rate,
  output logic [pipe_num_of_lanes-1:0]       PhyStatus,
  input  logic [1:0]                         Width,
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
  output logic [6*pipe_num_of_lanes-1:0]     LinkEvaluationFeedbackDirectionChange,
  /*************************************************************************************/

  input logic                                PCLK,     //TODO: This signal is removed 
  input logic [4:0]                          PclkRate     //TODO: This signal is removed 
);

`include "uvm_macros.svh"
`include "settings.svh"
import uvm_pkg::*;
import common_pkg::*;
import pipe_agent_pkg::*;

  
//------------------------------------------
// Data Members
//------------------------------------------
gen_t current_gen;
bit [15:0] lfsr [`NUM_OF_LANES];
bit [5:0]  lf_to_be_recvd;
bit [5:0]  fs_to_be_recvd;

function void reset_lfsr ();
  foreach(lfsr[i])
  begin
    lfsr[i] = 16'hFFFF;
  end
endfunction

//starting polling state
initial begin
  forever begin
    wait(PowerDown == 'b00);
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

    `uvm_info("pipe_driver_bfm", "Waiting for deassertion Txelecidle signal", UVM_LOW)
    for (int i = 0; i < `NUM_OF_LANES; i++) begin
      wait(TxElecIdle[i] == 0);
    end
  end
end
/******************************* RESET# (Phystatus de-assertion) *******************************/
initial begin
  forever begin 
    wait(Reset==0);
    @(posedge PCLK);
  
    foreach(PhyStatus[i]) begin
      PhyStatus[i]=0;
    end
  end
end
/******************************* Detect (Asserting needed signals) *******************************/
initial begin
  forever begin 
    wait(TxDetectRxLoopback==1);
    @(posedge PCLK);
  
    foreach(PhyStatus[i]) begin
      PhyStatus[i]=1;
    end
    // TODO: Check RxStatus[i]=='b011;
    // foreach(RxStatus[i]) begin 
    //   RxStatus[i]=='b011;
    // end 
  
    @(posedge PCLK);
  
    foreach(PhyStatus[i]) begin
      PhyStatus[i]=0;
    end
    // TODO: Check RxStatus[i]=='b000;
    // foreach(RxStatus[i]) begin 
    //   RxStatus[i]=='b000;  //??
    // end    
  end
end

//------------------------------------------
// Methods
//------------------------------------------
task send_ts(ts_s ts ,int start_lane = 0, int end_lane = pipe_num_of_lanes);
  logic [pipe_max_width:0] Data;
  logic [pipe_max_width/8 -1:0] Character;
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
    RxDataValid[i] <= 1;
    RxValid[i] <= 1;
  end

  if(current_gen <= GEN2)
  begin
    // Symbol 0
    RxData_Q = {RxData_Q,8'b1011110} ;
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
    temp[7:6] = 0'b00;
    if(ts.max_gen_supported == GEN1)
      temp[5:2] = 0;
    else if(ts.max_gen_supported == GEN2)
      temp[5:3] = 0;
    else if(ts.max_gen_supported == GEN3)
      temp[5:4] = 0;
    else if(ts.max_gen_supported == GEN4)
      temp[5] = 0;
    RxData_Q = {RxData_Q, temp};

    //Symbol 5
    RxData_Q = {RxData_Q, 0'h00};
    RxDataK_Q = {RxDataK_Q, 0};

    //Symbol 6~15
    if(ts.ts_type_t == TS1)
    begin
    RxData_Q = {RxData_Q, 8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A,8'h4A};
    RxDataK_Q = {RxDataK_Q,0,0,0,0,0,0,0,0,0,0};
    end
    else
    begin
      RxData_Q = {RxData_Q, 8'h4A,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45,8'h45};
      RxDataK_Q = {RxDataK_Q,0,0,0,0,0,0,0,0,0,0};
    end


    

    while(RxData_Q.size())
    begin
      @(posedge PCLK);
      
      for(int i = start_lane;i<end_lane;i++)
      begin

        // Stuffing the Data and characters depending on the number of Bytes sent per clock on each lane
        for(int j=0;j<pipe_max_width/8;j++)
        begin
          Data[(j+1)*8 -1 : j*8] = RxData_Q[0];
          Character[j] = RxDataK_Q[0];
          RxData_Q = RxData_Q[1:$];
          RxDataK_Q = RxDataK_Q[1:$];  
        end

        //duplicating the Data and Characters to each lane in the driver
        RxData[(i+1)* pipe_max_width -1 : i*pipe_max_width] <=Data ;
        RxDataK[(i+1)* pipe_max_width/8 -1 : i*pipe_max_width/8] <= Character;
        
      end

    end     
  end





  
  //prototype implementation
  // if(ts.ts_type == TS1)
  // begin

  //   //Symbol 0:
  //   @(posedge PCLK);
  //   if(ts.max_gen_supported <= GEN2)
  //   begin
  //     RxData <= 8'b1011110;
  //     RxDataK <= 1;
  //   end
  //   else 
  //     RxData <= 8'h1E;
  //   //Symbol 1
  //   @(posedge PCLK);

  //   if(ts.use_link_number)
  //   begin
  //     RxData <= ts.link_number;
  //     RxDataK <= 0;
  //   end
  //   else
  //   begin
  //     RxData <= 8'b11110111; //PAD character
  //     RxDataK <= 1;
  //   end

  //   //Symbol 2
  //   @(posedge PCLK);
  //   if(ts.use_lane_number)
  //   begin
  //     RxData <= ts.lane_number;
  //     RxDataK <= 0;
  //   end
  //   else
  //   begin
  //     RxData <= 8'b11110111; //PAD character
  //     RxDataK <= 1;
  //   end

  //   //Symbol 3
  //   @(posedge PCLK);
  //   if(ts.use_n_fts)
  //   begin
  //     RxData <= ts.n_fts;
  //     RxDataK <= 0;
  //   end
  //   else
  //   begin
  //   //missing part ?!!
  //   end

  //   //Symbol 4
  //   @(posedge PCLK);
  //   RxDataK <= 0;
  //   RxData <= 0'hff; 
  //   // bits 6,7 value needs to be discuessed
  //   RxData[0] <= 0;
  //   RxData[7:6] <= 0'b00;


  //   if(ts.max_gen_supported == GEN1)
  //     RxData[5:2] <= 0;
  //   else if(ts.max_gen_supported == GEN2)
  //     RxData[5:3] <= 0;
  //   else if(ts.max_gen_supported == GEN3)
  //     RxData[5:4] <= 0;
  //   else if(ts.max_gen_supported == GEN4)
  //     RxData[5] <= 0;


  //   //Symbol 5
  //   //needs to be discussed
  //   @(posedge PCLK);
  //   RxDataK <= 0;
  //   RxData <= 0; 

  //   //Symbol 6~15 in case of Gen 1 and 2
  //   if(ts.max_gen_supported == GEN1 || ts.max_gen_supported == GEN2)
  //   begin
  //     @(posedge PCLK);
  //     RxDataK <= 0;
  //     RxData <= 8'h4A; 
  //     repeat(8)@(posedge PCLK);
  //   end

  //   //Symbol 6~15 in case of Gen 3
  //   else 
  //   begin

  //     //Symbol 6
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 0; 

  //     //Symbol 7
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 0; 

  //     //Symbol 8
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 0; 

  //     //Symbol 9
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 0; 

  //     //Symbol 10~13
  //     @(posedge PCLK);
  //     RxData <= 8'h4A; 
  //     repeat(3)@(posedge PCLK);

  //     //Symbol 14~15
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 8'h4A; 
  //     repeat(1)@(posedge PCLK);
  //   end

  // end


  // if(ts.ts_type == TS2)
  // begin

  //   //Symbol 0:
  //   @(posedge PCLK);
  //   if(ts.max_gen_supported <= GEN2)
  //   begin
  //     RxData <= 8'b1011110;
  //     RxDataK <= 1;
  //   end
  //   else 
  //     RxData <= 8'h2D;
  //   //Symbol 1
  //   @(posedge PCLK);

  //   if(ts.use_link_number)
  //   begin
  //     RxData <= ts.link_number;
  //     RxDataK <= 0;
  //   end
  //   else
  //   begin
  //     RxData <= 8'b11110111; //PAD character
  //     RxDataK <= 1;
  //   end

  //   //Symbol 2
  //   @(posedge PCLK);
  //   if(ts.use_lane_number)
  //   begin
  //     RxData <= ts.lane_number;
  //     RxDataK <= 0;
  //   end
  //   else
  //   begin
  //     RxData <= 8'b11110111; //PAD character
  //     RxDataK <= 1;
  //   end

  //   //Symbol 3
  //   @(posedge PCLK);
  //   if(ts.use_n_fts)
  //   begin
  //     RxData <= ts.n_fts;
  //     RxDataK <= 0;
  //   end
  //   else
  //   begin
  //   //missing part ?!!
  //   end

  //   //Symbol 4
  //   @(posedge PCLK);
  //   RxDataK <= 0;
  //   RxData <= 0'hff; 
  //   // bits 0,6,7 value needs to be discuessed
  //   RxData[0] <= 0;
  //   RxData[7:6] <= 0'b00;


  //   if(ts.max_gen_supported == GEN1)
  //     RxData[5:2] <= 0;
  //   else if(ts.max_gen_supported == GEN2)
  //     RxData[5:3] <= 0;
  //   else if(ts.max_gen_supported == GEN3)
  //     RxData[5:4] <= 0;
  //   else if(ts.max_gen_supported == GEN4)
  //     RxData[5] <= 0;


  //   //Symbol 5
  //   //needs to be discussed
  //   @(posedge PCLK);
  //   RxDataK <= 0;
  //   RxData <= 0; 

  //   //Symbol 6~15 in case of Gen 1 and 2
  //   if(ts.max_gen_supported == GEN1 || ts.max_gen_supported == GEN2)
  //   begin
  //     @(posedge PCLK);
  //     RxDataK <= 0;
  //     RxData <= 8'h4A; 
        

  //     @(posedge PCLK);
  //     RxDataK <= 0;
  //     RxData <= 8'h45; 

  //     repeat(7)@(posedge PCLK);

  //   end

  //   //Symbol 6~15 in case of Gen 3
  //   else 
  //   begin

  //     //Symbol 6
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 0; 


  //     //Symbol 7
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 0; 

  //     //Symbol 8
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 0; 

  //     //Symbol 9
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 0; 

  //     //Symbol 10~13
  //     @(posedge PCLK);
  //     RxData <= 8'h4A; 
  //     repeat(3)@(posedge PCLK);

  //     //Symbol 14~15
  //     //needs to be discussed
  //     @(posedge PCLK);
  //     RxData <= 8'h4A; 
  //     repeat(1)@(posedge PCLK);
  //   end

  // end
endtask

task send_tses(ts_s ts [], int start_lane = 0, int end_lane = pipe_num_of_lanes);
  for(int i=0;i<ts.size();i++)
  begin
    send_ts(ts[i],start_lane,end_lane);
  end
endtask


initial begin
  forever begin
    @(PclkRate);
    @(posedge PCLK);
    PclkChangeOk <= 1;
  end
end

  task change_speed();
    // @(TxElecIdle && RxStandby);
    // wait random amount of time
    @(posedge PCLK);
    PhyStatus <= 1;
    @(posedge PCLK);
    PhyStatus <= 0;
    PclkChangeOk <= 0;
  endtask : change_speed

/******************************* Normal Data Operation *******************************/

bit [0:10] tlp_length_field;
byte tlp_gen3_symbol_0;
byte tlp_gen3_symbol_1;
byte data [$];
bit k_data [$];
bit [0:10] tlp_length_field;
byte tlp_gen3_symbol_0;
byte tlp_gen3_symbol_1;

function void send_tlp (tlp_t tlp);
  if (current_gen == GEN1 || current_gen == GEN2) begin
    data.push_back(`STP_gen_1_2);          K_data.push_back(K);

    for (int i = 0; i < tlp.size(); i++) begin
      data.push_back(tlp[i]);              K_data.push_back(D);
    end

    data.push_back(`END_gen_1_2);          K_data.push_back(K);

  end
  else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5)begin
    tlp_length_field  = tlp.size() + 2;
    tlp_gen3_symbol_0 = {`STP_gen_3 , tlp_length_field[0:3]};
    tlp_gen3_symbol_1 = {tlp_length_field[4:10] , 1'b0};

    data.push_back(tlp_gen3_symbol_0);    K_data.push_back(K); //nosaha K w nosaha D ???
    data.push_back(tlp_gen3_symbol_1);    K_data.push_back(D);
    //check if i need K_data queue in gen3 or not??
    //check on lenth constraint of TLP , is it different than earlier gens??? 
    for (int i = 0; i < tlp.size(); i++) begin
      data.push_back(tlp[i]);              K_data.push_back(D);
    end

  end
endfunction

function void send_dllp (dllp_t dllp);
  if (current_gen == GEN1 || current_gen == GEN2) begin
    data.push_back(`SDP_gen_1_2);          K_data.push_back(K);
    data.push_back(dllp[0]);               K_data.push_back(D);
    data.push_back(dllp[1]);               K_data.push_back(D);
    data.push_back(dllp[2]);               K_data.push_back(D);
    data.push_back(dllp[3]);               K_data.push_back(D);
    data.push_back(dllp[4]);               K_data.push_back(D);
    data.push_back(dllp[5]);               K_data.push_back(D);
    data.push_back(`END_gen_1_2);          K_data.push_back(K);
  end
  else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5) begin
    //check if i need K_data queue in gen3 or not??
    data.push_back(`SDP_gen_3_symbol_0);   
    data.push_back(`SDP_gen_3_symbol_1);   
    data.push_back(dllp[0]);              
    data.push_back(dllp[1]);               
    data.push_back(dllp[2]);               
    data.push_back(dllp[3]);          
    data.push_back(dllp[4]);           
    data.push_back(dllp[5]);            
  end
endfunction

function void send_idle_data ();
  for (int i = 0; i < pipe_num_of_lanes; i++) begin
    data.push_back(8'b00000000);           K_data.push_back(D); //control but scrambled
  end
endfunction


task send_data ();
  assert (PowerDown == 4'b0000) 
  else `uvm_fatal("pipe_driver_bfm", "Unexpected PowerDown value at Normal Data Operation")
  RxElecIdle = 1'b0;  
  for (int i = 0; i < pipe_num_of_lanes; i++) begin
    RxDataValid [i] = 1'b1;
    RxValid [i] = 1'b1;
	if (current_gen == GEN1 || current_gen == GEN2)
		send_data_gen_1_2 ();
	else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5)
	 	send_data_gen_3_4_5 ();
endtask

function int get_width ();
  int lane_width;
  case (Width)
    2'b00: lane_width = 8;
    2'b01: lane_width = 16;
    2'b11: lane_width = 32;
  endcase
  return lane_width;
endfunction

 task automatic send_data_gen_1_2 ();
  int lanenum;
  byte data_scrambled [$];
  int pipe_width = get_width();
  int bus_data_width = (pipe_num_of_lanes * pipe_width) - 1;
  for(int i = 0; i < data.size(); i++) begin
    lanenum = $floor(i*(8.0/pipe_width));
    lanenum = lanenum - pipe_num_of_lanes * ($floor(lanenum/pipe_num_of_lanes));
    if(k_data [i] == 0) begin
      data_scrambled[i] = scramble(data[i],lanenum);
    end
    else if (k_data [i] == 1) begin
      data_scrambled[i] = data[i];
    end
  end  
  for (int k = 0; k < data_scrambled.size() + k; k = k + (bus_data_width+1)/8) begin
    @ (posedge PCLK);    
    for (int j = k; j < pipe_num_of_lanes + k; j = j ++) begin
      for (int i = j - k; i < (bus_data_width+1)/8; i = i + pipe_num_of_lanes) begin
        RxData[(8*i) +: 8] = data_scrambled.pop_front();
        RxDataK[i] = k_data.pop_front();
      end
    end
  end
  if (!(lanenum == pipe_num_of_lanes)) begin
    for (int j = lanenum + 1; j < (bus_data_width+1)/8; j = j ++) begin
      RxData [(8*j) +: 8] = 8'h00;
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
          RxData [((l*pipe_max_width) + (k*8)) +: 8] = scramble(struct,data.pop_front(),l);
        end
      end
      @(posedge PCLK);
    end
  end
  for (int i = 0; i < pipe_num_of_lanes; i++) begin
    RxDataValid [i] = 1'b0;
    // RxValid [i] = 1'b0;
  end
endtask

  task eqialization_preset_applied(preset_index);
    @(LocalPresetIndex);
    assert(LocalPresetIndex == preset_index) else 
    `uvm_error(get_name(), "")
    wait(GetLocalPresetCoeffcients == 1);
    @(posedge PCLK);
    LocalTxCoefficientsValid  <= 1;
    LocalTxPresetCoefficients <= 0; // TODO: How to get these values from the table
    @(posedge PCLK);
    LocalTxCoefficientsValid  <= 0;
    @(TxDeemph);
    assert(TxDeemph == 0) else 
    `uvm_error(get_name(), "")
  endtask : eqialization_preset_applied

  function inform_lf_fs(bit [5:0] lf, bit[5:0] fs);
    lf_to_be_recvd = lf;
    fs_to_be_recvd = fs;
  endfunction : inform_lf_fs

  function set_local_lf_fs(bit [5:0] lf, bit[5:0] fs);
    LocalLF <= lf;
    LocalFS <= fs;
  endfunction : set_local_lf_fs

  initial begin
    @(LF) assert(LF == lf_to_be_recvd) else
    `uvm_error(get_name(), "")
  end

  initial begin
    @(FS) assert(FS == fs_to_be_recvd) else
    `uvm_error(get_name(), "")
  end


// task send_data (byte data, int start_lane = 0 ,int end_lane = NUM_OF_LANES);
//    fork
//     variable no. of process
//     scrambler (0000, )
//    join
//    hadeha l scrumbled data wl start lane wl end_lane // to do shabh tses
//    scrambling w n-send 3l signals
//     @(posedge PCLK);
//     RxValid = 1'b1;
//     RxData [7:0] = 8'b0000_0000;
//     RxDataK = 1'b0;    // at2kd
// endtask

// function bit [7:0] scramble (bit [7:0] in_data, shortint unsigned lane_num);
//   bit [15:0] lfsr_new;

//   // LFSR value after 8 serial clocks
//   for (i=0; i<8; i++)
//   begin
//     lfsr_new[ 0] = lfsr [lane_num] [15];
//     lfsr_new[ 1] = lfsr [lane_num] [ 0];
//     lfsr_new[ 2] = lfsr [lane_num] [ 1];
//     lfsr_new[ 3] = lfsr [lane_num] [ 2] ^ lfsr [lane_num] [15];
//     lfsr_new[ 4] = lfsr [lane_num] [ 3] ^ lfsr [lane_num] [15];
//     lfsr_new[ 5] = lfsr [lane_num] [ 4] ^ lfsr [lane_num] [15];
//     lfsr_new[ 6] = lfsr [lane_num] [ 5];
//     lfsr_new[ 7] = lfsr [lane_num] [ 6];
//     lfsr_new[ 8] = lfsr [lane_num] [ 7];
//     lfsr_new[ 9] = lfsr [lane_num] [ 8];
//     lfsr_new[10] = lfsr [lane_num] [ 9];
//     lfsr_new[11] = lfsr [lane_num] [10];
//     lfsr_new[12] = lfsr [lane_num] [11];
//     lfsr_new[13] = lfsr [lane_num] [12];
//     lfsr_new[14] = lfsr [lane_num] [13];
//     lfsr_new[15] = lfsr [lane_num] [14];       

//     // Generation of Scrambled Data
//     scrambled_data [i] = lfsr [lane_num] [15] ^ in_data [i];
    
//     lfsr [lane_num] = lfsr_new;
//   end
//   return scrambled_data;
// endfunction



endinterface

