`include "settings.svh"

interface pipe_driver_bfm
#(
  localparam bus_data_width_param       = `PCIE_LANE_NUMBER  * `PIPE_MAX_WIDTH - 1,  
  localparam bus_data_kontrol_param     = (`PIPE_MAX_WIDTH / 8) * `PCIE_LANE_NUMBER - 1
)(  
  input bit   Clk,
  input bit   Reset,
  input logic PhyReset,
   
  /*************************** RX Specific Signals *************************************/
  output logic [bus_data_width_param:0]      RxData,    
  output logic [`PCIE_LANE_NUMBER-1:0]       RxDataValid,
  output logic [bus_data_kontrol_param:0]    RxDataK,
  output logic [`PCIE_LANE_NUMBER-1:0]       RxStartBlock,
  output logic [2*`PCIE_LANE_NUMBER-1:0]     RxSynchHeader,
  output logic [`PCIE_LANE_NUMBER-1:0]       RxValid,
  output logic [3*`PCIE_LANE_NUMBER-1:0]     RxStatus,
  output logic                               RxElecIdle,
  /*************************************************************************************/
  
  /*************************** TX Specific Signals *************************************/
  input logic [bus_data_width_param:0]      TxData,    
  input logic [`PCIE_LANE_NUMBER-1:0]       TxDataValid,
  input logic [bus_data_kontrol_param:0]    TxDataK,
  input logic [`PCIE_LANE_NUMBER-1:0]       TxStartBlock,
  input logic [2*`PCIE_LANE_NUMBER-1:0]     TxSynchHeader,
  input logic [`PCIE_LANE_NUMBER-1:0]       TxElecIdle,
  input logic [`PCIE_LANE_NUMBER-1:0]       TxDetectRxLoopback,
  /*************************************************************************************/

  /*********************** Comands and Status Signals **********************************/
  input  logic [3:0]                         PowerDown,
  input  logic [3:0]                         Rate,
  output logic                               PhyStatus,
  input  logic [1:0]                         Width,
  input  logic                               PclkChangeAck,
  output logic                               PclkChangeOk,
  /*************************************************************************************/
  
  /******************************* Message Bus Interface *******************************/
  output logic [7:0]                         m2p_message_bus,
  input  logic [7:0]                         p2m_message_bus,
  /*************************************************************************************/

  /******************** MAC Interface(in/out) Equalization signals *********************/
  output logic [18*`PCIE_LANE_NUMBER-1:0]   LocalTxPresetCoeffcients,
  input  logic [18*`PCIE_LANE_NUMBER-1:0]   TxDeemph,
  output logic [6*`PCIE_LANE_NUMBER-1:0]    LocalFS,
  output logic [6*`PCIE_LANE_NUMBER-1:0]    LocalLF,
  input  logic [`PCIE_LANE_NUMBER-1:0]      GetLocalPresetCoeffcients,
  output logic [`PCIE_LANE_NUMBER-1:0]      LocalTxCoeffcientsValid,
  input  logic [6*`PCIE_LANE_NUMBER-1:0]    FS,    // TODO: Review specs for these values
  input  logic [6*`PCIE_LANE_NUMBER-1:0]    LF,    // TODO: Review specs for these values
  input  logic [`PCIE_LANE_NUMBER-1:0]      RxEqEval,
  input  logic [4*`PCIE_LANE_NUMBER-1:0]    LocalPresetIndex,
  input  logic [`PCIE_LANE_NUMBER-1:0]      InvalidRequest,  // TODO: this signal needs to be checked
  output logic [6*`PCIE_LANE_NUMBER-1:0]    LinkEvaluationFeedbackDirectionChange
  /*************************************************************************************/
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import pipe_agent_pkg::*;

logic [4:0]  PclkRate;     //TODO: This signal is removed 
  
//------------------------------------------
// Data Members
//------------------------------------------
gen_t current_gen;

initial 
begin
  forever
  begin
    @(pipe_agent_config_h.power_down_detected)
    begin
    for (int i = 0; i < NUM_OF_LANES ; i++) begin
      PhyStatus[i]=1;
    end
  
    @(posedge Pclk);
    for (int i = 0; i < NUM_OF_LANES ; i++) begin
      PhyStatus[i]=0;
    end
    end
  end
end

//------------------------------------------
// Methods
//------------------------------------------

  `include "link_up.svh"
task automatic receive_ts (output TS_config ts ,input int start_lane = 0,input int end_lane = NUM_OF_LANES );
    if(Width==2'b01) // 16 bit pipe parallel interface
    begin
        wait(TxData[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        ts.link_number=TxData[start_lane][15:8]; // link number
        for(int sympol_count =2;sympol_count<16;sympol_count=sympol_count+2) //looping on the 16 sympol of TS
        begin
            @(posedge Pclk);
            case(sympol_count)
                2:begin 
                    for(int i=start_lane;i<=end_lane;i++) //lanes numbers
                    begin
                        ts.lane_number[i]=TxData[i][7:0];
                    end
                    ts.n_fts=TxData[start_lane][15:8]; // number of fast training sequnces
                  end
    
                4:begin // speeds supported
                        if(TxData[start_lane][5]==1'b1) ts.max_suported=GEN5;
                        else if(TxData[start_lane][4]==1'b1) ts.max_suported=GEN4;
                        else if(TxData[start_lane][3]==1'b1) ts.max_suported=GEN3;
                        else if(TxData[start_lane][2]==1'b1) ts.max_suported=GEN2;
                        else ts.max_suported=GEN1;	
                    end
    
                10:begin // ts1 or ts2 determine
                        if(TxData[start_lane][7:0]==8'b010_01010) ts.ts_type=TS1;
                        else if(TxData[start_lane][7:0]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end
    else if(Width==2'b10) // 32 pipe parallel interface  
    begin
        wait(TxData[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        ts.link_number=TxData[start_lane][15:8]; //link number
        for(int i=start_lane;i<=end_lane;i++) // lane numbers
        begin 
            ts.lane_number[i]=TxData[i][23:16];
        end
        ts.n_fts=TxData[start_lane][31:24]; // number of fast training sequnces
        for(int sympol_count =4;sympol_count<16;sympol_count=sympol_count+4) //looping on the 16 sympol of TS
        begin
            @(posedge Pclk);
            case(sympol_count)
                4:begin // supported speeds
                        if(TxData[start_lane][5]==1'b1) ts.max_suported=GEN5;
                        else if(TxData[start_lane][4]==1'b1) ts.max_suported=GEN4;
                        else if(TxData[start_lane][3]==1'b1) ts.max_suported=GEN3;
                        else if(TxData[start_lane][2]==1'b1) ts.max_suported=GEN2;
                        else ts.max_suported=GEN1;	
                    end
    
                 8:begin // ts1 or ts2 determine
                        if(TxData[start_lane][23:16]==8'b010_01010) ts.ts_type=TS1;
                        else if(TxData[start_lane][23:16]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end
    else //8 bit pipe paraleel interface 
    begin
        wait(TxData[start_lane][7:0]==8'b101_11100); //wait to see a COM charecter
        for(int sympol_count =1;sympol_count<16;sympol_count++) //looping on the 16 sympol of TS
        begin
            @(posedge Pclk);
            case(sympol_count)
                1:ts.link_number=TxData[start_lane][7:0]; //link number
                2:begin //lanes numbers
                        for(int i=start_lane;i<=end_lane;i++)
                        begin
                            ts.lane_number[i]=TxData[i][7:0];
                        end
                    end
                3:ts.n_fts=TxData[start_lane][7:0]; // number of fast training sequnces
                4:begin  //supported sppeds
                        if(TxData[start_lane][5]==1'b1) ts.max_suported=GEN5;
                        else if(TxData[start_lane][4]==1'b1) ts.max_suported=GEN4;
                        else if(TxData[start_lane][3]==1'b1) ts.max_suported=GEN3;
                        else if(TxData[start_lane][2]==1'b1) ts.max_suported=GEN2;
                        else ts.max_suported=GEN1;	
                    end
                10:begin // ts1 or ts2 determine
                        if(TxData[start_lane][7:0]==8'b010_01010) ts.ts_type=TS1;
                        else if(TxData[start_lane][7:0]==8'b010_00101) ts.ts_type=TS2;
                    end
            endcase
        end
    end    
endtask

forever begin 
  wait(reset==0);
  @(posedge clk);

  foreach(PhyStatus) begin
    PhyStatus[i]=0;
  end
end

forever begin 
  wait(TxDetectRx==1);
  @(posedge Clk);

  foreach(PhyStatus[i]) begin
    PhyStatus[i]=1;
  end

  foreach(RxStatus[i]) begin 
    RxStatus[i]=='b011;
  end 

  @(posedge Clk);

  foreach(PhyStatus[i]) begin
    PhyStatus[i]=0;
  end

  foreach(RxStatus[i]) begin 
    RxStatus[i]=='b000;  //??
  end    
end

task polling_state;

	ts_t config_h;
	//check array description
	`uvm_info("Waiting for powerdown change on lane");
	for (int i = 0; i < NUM_OF_LANES; i++) begin
		@ (PowerDown[i] == 'b00);
 	end
	// assert all lanes at the same time
	for (int i = 0; i < NUM_OF_LANES ; i++) begin
		PhyStatus[i]=1;
	end

	@(posedge Pclk);
	for (int i = 0; i < NUM_OF_LANES ; i++) begin
		PhyStatus[i]=0;
	end

	`uvm_info("Waiting for deassertion Txelecidle signal"); 
	for (int i = 0; i < NUM_OF_LANES; i++) begin
		@ (TxElecIdle[i] == 0)	;
	end

	for (i = 0; i < 1024; i++) begin
		receive_ts(config_h);
	end
	
	int counter1_ts1_case1, counter2_ts1_case1, counter_ts2_case1;
	int counter1_ts1_case2, counter2_ts1_case2, counter2_ts2_case2;
	fork
	begin
		for (i = 0; i < 23; i++) begin
			send_ts(config_h); 

			//compliance we loopback supportedd?
			if (config_h.ts_type == TS1 & config_h.compliance == 0) begin
				counter1_ts1_case1 ++ ;
			end

			if (config_h.ts_type == TS2) begin
				counter_ts2_case1 ++ ;
			end

			if (config_h.ts_type == TS1 & config_h.loopback == 'b10) begin
				counter2_ts1_case1 ++ ;
			end

			if (counter1_ts1_case1 == 8 | counter2_ts1_case1 == 8 | counter_ts2_case1 == 8) begin
				break; 
			end
		end
	end

	begin
	#24ms; 
	fork
		begin
		for (i = 0; i < 23; i++) begin
			send_ts(config_h);

			if (config_h.ts_type == TS1 & config_h.compliance == 0) begin
				counter1_ts1_case2 ++ ;
			end

			if (config_h.ts_type == TS2) begin
				counter_ts2_case2 ++ ;
			end

			if (config_h.ts_type == TS1 & config_h.loopback == 'b10) begin
				counter2_ts1_case2 ++ ;
			end

			if (counter1_ts1_case2 == 8 | counter2_ts1_case2 == 8 | counter_ts2_case2 == 8) begin
				break; 
			end
		end
	    end
		begin
			for (int i = 0; i < NUM_OF_LANES; i++) begin //num of predetermined lanes?
				@ (TxElecIdle[i] == 0);	
			end
		end
	join_any
	end	
    join_any

    config_h.ts_type = TS2;
	fork
		for (int i = 0; i < 16; i++) begin  
			receive_ts(config_h);
		end

		for (int j = 0;  j< 8; j++) begin
			send_ts(config_h);
		end
	join

endtask : polling_state

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
    while(1)
    begin
      receive_ts(received_tses);
      // Make sure the received tses are ts1s
      foreach(received_tses[i])
      begin
        // Make sure the tses received are ts1s
        assert (received_tses[i].ts_type == TS1) 
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
      ts_configs[i].use_lane_number = 0;
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
            assert (received_tses[i].ts_type == TS1) 
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
      ts_configs[i].use_lane_number = 1;
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
            if(received_tses[i].ts_type == TS2)
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
endinterface

/*


Finish the verification plan

Finish the detailed scenario
  lpif normal data operation
  pipe link up upstream

seq
  Lpif_link_up_seq
  Lpif_data_transmit_seq
  Lpif_reset_seq
  Lpif_enter_recovery_seq
  Lpif_enter_l0s_seq X
  Lpif_exit_l0s_seq X

  pipe_link_up_seq
  pipe_data_transmit_seq
  pipe_enter_recovery_seq
  pipe_enter_l0s_seq X
  pipe_exit_l0s_seq X
  Pipe_speed_change_seq 

vseq
  base_vseq
  link_up_vseq
  data_exchange_vseq
  reset_vseq
  enter_recovery_vseq
  enter_l0s_vseq X
  exit_l0s_vseq X
  speed_change_vseq

seq_item
  lpif_seq_item
  pipe_seq_item

lpif
  lpif_driver
  lpif_monitor

pipe
  pipe_driver
  pipe_monitor

Parameterization
  lpif_if
  lpif_driver_bfm
  lpif_monitor_bfm

  pipe_if
  pipe_driver_bfm
  pipe_monitor_bfm

*/
