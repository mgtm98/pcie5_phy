interface pipe_driver_bfm(
  input bit clk,
  // input bit reset,
  // TODO Change the size of RxData, RxDataK, TxData, TxDataK
  // Parametrization not mentioned in the document
   
  //Tx
  input logic [31:0] tx_data,  //for 32 bit interface
  input logic        tx_data_valid,
  input logic        tx_elec_idle,                   
  input logic [3:0]  tx_data_k, //for 32 bit interface
  input logic        tx_start_block,
  input logic [1:0]  tx_synch_header,  
  input logic        tx_detect_rx,
  
  //Rx
  output logic [31:0] rx_data,   //for 32 bit interface
  output logic        rx_data_valid,
  output logic        rx_elec_idle,
  output logic [3:0]  rx_data_k,  //for 32 bit interface
  output logic        rx_start_block, 
  output logic [1:0]  rx_synch_header,
  output logic        rx_valid,
  output logic [2:0]  rx_status, 
  input  logic        rx_stand_by,
  output logic        rx_stand_by_status,
  
  //Commands and Status signals
  input logic [3:0]  power_down,
  input logic [3:0]  rate, 
  input logic [3:0]  phy_mode,  //=0  means PCIe
  output logic       phy_status,
  input logic [1:0]  width,
  input logic [4:0]  pclk_rate,
  input logic        pclk_change_ack,
  output logic       pclk_change_ok,
  
  //clk and reset
  input logic        pclk,
  input logic        reset


);


`include "uvm_macros.svh"
import uvm_pkg::*;
import pipe_agent_pkg::*;

  
//------------------------------------------
// Data Members
//------------------------------------------
gen_t current_gen;


//------------------------------------------
// Methods
//------------------------------------------

  `include "link_up.svh"
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

  
  task detect_state;
  int temp[2:0];
  @(resetn==1);  //check on signals default value when reset?

  temp=pclk_rate;   //shared or per lane?
  @(posedge pclk);
    assert property (temp==pclk_rate) else `uvm_error ("PCLK is not stable");       
    @(resetn==0);

    foreach(phystatus[i]) begin 
      phystatus[i]=0;
    end
      
  @ (TxdetectRx==1)  //shared or per lane?
  //Transmitter starts in Electrical Idle //Gen 1 (2.5GT/s) //variables set to 0 

  /*
  for (int i = 0; i < NUM_OF_LANES; i++) begin  
      rx_elec_idle[i]=0;    //??
  end 

  fork      
    #12ms;    
    for (int i = 0; i < NUM_OF_LANES; i++) begin  
      fork
        @(Tx_elec_idle[i]==0);
      join_any
    end
  join_any 
  */

  foreach(Rx_status[i]) begin    // Rx_status='b011 on all lanes for one clk then ='b000
    Rx_status[i]='b011;  
  end

  foreach(phystatus[i]) begin  //asserting phystatus for one clk on all lanes
    phystatus[i]=1;
  end 
  @(posedge pclk);
  foreach(phystatus[i]) begin
    phystatus[i]=0;
  end

  foreach(Rx_status[i]) begin  
    Rx_status[i]='b000;       
  end

  @ (TxdetectRx==0);
  `uvm_info("Detect completed");

endtask : detect_state

task polling_state;

	ts_t config_h;
	//check array description
	`uvm_info("Waiting for powerdown change on lane");
	for (int i = 0; i < NUM_OF_LANES; i++) begin
		@ (powerdown[i] == 'b00);
 	end
	// assert all lanes at the same time
	for (int i = 0; i < NUM_OF_LANES ; i++) begin
		phy_status[i]=1;
	end

	@(posedge pclk);
	for (int i = 0; i < NUM_OF_LANES ; i++) begin
		phy_status[i]=0;
	end

	`uvm_info("Waiting for deassertion Txelecidle signal"); 
	for (int i = 0; i < NUM_OF_LANES; i++) begin
		@ (tx_elec_idle[i] == 0)	;
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
				@ (tx_elec_idle[i] == 0);	
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
    while(num_of_ts1s_with_non_pad_link_number < 2)
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
