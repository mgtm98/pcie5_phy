`include "settings.svh"

interface pipe_driver_bfm
  #(
    parameter pipe_num_of_lanes,
    parameter pipe_max_width,
    localparam bus_data_width_param       = pipe_num_of_lanes  * pipe_max_width - 1,  
    localparam bus_data_kontrol_param     = (pipe_max_width / 8) * pipe_num_of_lanes - 1
  )(  
  input bit   Clk,
  input bit   Reset,
  input logic PhyReset,
   
  /*************************** RX Specific Signals *************************************/
  output logic [bus_data_width_param:0]      RxData,    
  output logic [pipe_num_of_lanes-1:0]       RxDataValid,
  output logic [bus_data_kontrol_param:0]    RxDataK,
  output logic [pipe_num_of_lanes-1:0]       RxStartBlock,
  output logic [2*pipe_num_of_lanes-1:0]     RxSynchHeader,
  output logic [pipe_num_of_lanes-1:0]       RxValid,
  output logic [3*pipe_num_of_lanes-1:0]     RxStatus,
  output logic                               RxElecIdle,
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
  output logic [18*pipe_num_of_lanes-1:0]   LocalTxPresetCoeffcients,
  input  logic [18*pipe_num_of_lanes-1:0]   TxDeemph,
  output logic [6*pipe_num_of_lanes-1:0]    LocalFS,
  output logic [6*pipe_num_of_lanes-1:0]    LocalLF,
  input  logic [pipe_num_of_lanes-1:0]      GetLocalPresetCoeffcients,
  output logic [pipe_num_of_lanes-1:0]      LocalTxCoeffcientsValid,
  input  logic [6*pipe_num_of_lanes-1:0]    FS,    // TODO: Review specs for these values
  input  logic [6*pipe_num_of_lanes-1:0]    LF,    // TODO: Review specs for these values
  input  logic [pipe_num_of_lanes-1:0]      RxEqEval,
  input  logic [4*pipe_num_of_lanes-1:0]    LocalPresetIndex,
  input  logic [pipe_num_of_lanes-1:0]      InvalidRequest,  // TODO: this signal needs to be checked
  output logic [6*pipe_num_of_lanes-1:0]    LinkEvaluationFeedbackDirectionChange
  /*************************************************************************************/
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import pipe_agent_pkg::*;
  
bit   PCLK;     //TODO: This signal is removed 
logic [4:0]  PclkRate;     //TODO: This signal is removed 
  
//------------------------------------------
// Data Members
//------------------------------------------
gen_t current_gen;
bit [15:0] lfsr [`NUM_OF_LANES];

function reset_lfsr ();
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
task send_ts(ts_s ts, int start_lane = 0, int end_lane = `NUM_OF_LANES);

  for(int i = start_lane; i < end_lane; i++) begin
    RxDataValid[i] <= 1;
    RxValid[i] <= 1;
  end
  if(ts.ts_type == TS1)
  begin

    //Symbol 0:
    @(posedge PCLK);
    if(ts.max_gen_supported <= GEN2)
    begin
      RxData <= 8'b1011110;
      RxDataK <= 1;
    end
    else 
      RxData <= 8'h1E;
    //Symbol 1
    @(posedge PCLK);

    if(ts.use_link_number)
    begin
      RxData <= ts.link_number;
      RxDataK <= 0;
    end
    else
    begin
      RxData <= 8'b11110111; //PAD character
      RxDataK <= 1;
    end

    //Symbol 2
    @(posedge PCLK);
    if(ts.use_lane_number)
    begin
      RxData <= ts.lane_number;
      RxDataK <= 0;
    end
    else
    begin
      RxData <= 8'b11110111; //PAD character
      RxDataK <= 1;
    end

    //Symbol 3
    @(posedge PCLK);
    if(ts.use_n_fts)
    begin
      RxData <= ts.n_fts;
      RxDataK <= 0;
    end
    else
    begin
    //missing part ?!!
    end

    //Symbol 4
    @(posedge PCLK);
    RxDataK <= 0;
    RxData <= 0'hff; 
    // bits 0,6,7 value needs to be discuessed
    RxData[0] <= 0;
    RxData[7:6] <= 0'b00;


    if(ts.max_gen_supported == GEN1)
      RxData[5:2] <= 0;
    else if(ts.max_gen_supported == GEN2)
      RxData[5:3] <= 0;
    else if(ts.max_gen_supported == GEN3)
      RxData[5:4] <= 0;
    else if(ts.max_gen_supported == GEN4)
      RxData[5] <= 0;


    //Symbol 5
    //needs to be discussed
    @(posedge PCLK);
    RxDataK <= 0;
    RxData <= 0; 

    //Symbol 6~15 in case of Gen 1 and 2
    if(ts.max_gen_supported == GEN1 || ts.max_gen_supported == GEN2)
    begin
      @(posedge PCLK);
      RxDataK <= 0;
      RxData <= 8'h4A; 
      repeat(8)@(posedge PCLK);
    end

    //Symbol 6~15 in case of Gen 3
    else 
    begin

      //Symbol 6
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 0; 

      //Symbol 7
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 0; 

      //Symbol 8
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 0; 

      //Symbol 9
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 0; 

      //Symbol 10~13
      @(posedge PCLK);
      RxData <= 8'h4A; 
      repeat(3)@(posedge PCLK);

      //Symbol 14~15
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 8'h4A; 
      repeat(1)@(posedge PCLK);
    end

  end


  if(ts.ts_type == TS2)
  begin

    //Symbol 0:
    @(posedge PCLK);
    if(ts.max_gen_supported <= GEN2)
    begin
      RxData <= 8'b1011110;
      RxDataK <= 1;
    end
    else 
      RxData <= 8'h2D;
    //Symbol 1
    @(posedge PCLK);

    if(ts.use_link_number)
    begin
      RxData <= ts.link_number;
      RxDataK <= 0;
    end
    else
    begin
      RxData <= 8'b11110111; //PAD character
      RxDataK <= 1;
    end

    //Symbol 2
    @(posedge PCLK);
    if(ts.use_lane_number)
    begin
      RxData <= ts.lane_number;
      RxDataK <= 0;
    end
    else
    begin
      RxData <= 8'b11110111; //PAD character
      RxDataK <= 1;
    end

    //Symbol 3
    @(posedge PCLK);
    if(ts.use_n_fts)
    begin
      RxData <= ts.n_fts;
      RxDataK <= 0;
    end
    else
    begin
    //missing part ?!!
    end

    //Symbol 4
    @(posedge PCLK);
    RxDataK <= 0;
    RxData <= 0'hff; 
    // bits 0,6,7 value needs to be discuessed
    RxData[0] <= 0;
    RxData[7:6] <= 0'b00;


    if(ts.max_gen_supported == GEN1)
      RxData[5:2] <= 0;
    else if(ts.max_gen_supported == GEN2)
      RxData[5:3] <= 0;
    else if(ts.max_gen_supported == GEN3)
      RxData[5:4] <= 0;
    else if(ts.max_gen_supported == GEN4)
      RxData[5] <= 0;


    //Symbol 5
    //needs to be discussed
    @(posedge PCLK);
    RxDataK <= 0;
    RxData <= 0; 

    //Symbol 6~15 in case of Gen 1 and 2
    if(ts.max_gen_supported == GEN1 || ts.max_gen_supported == GEN2)
    begin
      @(posedge PCLK);
      RxDataK <= 0;
      RxData <= 8'h4A; 

      @(posedge PCLK);
      RxDataK <= 0;
      RxData <= 8'h45; 

      repeat(7)@(posedge PCLK);

    end

    //Symbol 6~15 in case of Gen 3
    else 
    begin

      //Symbol 6
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 0; 


      //Symbol 7
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 0; 

      //Symbol 8
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 0; 

      //Symbol 9
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 0; 

      //Symbol 10~13
      @(posedge PCLK);
      RxData <= 8'h4A; 
      repeat(3)@(posedge PCLK);

      //Symbol 14~15
      //needs to be discussed
      @(posedge PCLK);
      RxData <= 8'h4A; 
      repeat(1)@(posedge PCLK);
    end

  end
endtask

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
