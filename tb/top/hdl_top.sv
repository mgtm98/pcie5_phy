module hdl_top;

  `include "settings.svh"
  `include "uvm_macros.svh"

  import uvm_pkg::*;
  import common_pkg::*;
  import utility_pkg::*;
  import lpif_agent_pkg::*;
  import pipe_agent_pkg::*;
  import pcie_env_pkg::*;
  import pcie_seq_pkg::*;

  // clk and reset
  //
  logic clk;
  // logic reset;

  //
  
  initial begin
    string argument_value;
    uvm_cmdline_processor cmdline_proc;
    cmdline_proc = uvm_cmdline_processor::get_inst();
    cmdline_proc.get_arg_value("+IS_ENV_UPSTREAM=", argument_value);
    IS_ENV_UPSTREAM = `IS_ENV_UPSTREAM;
  end

  // Instantiate the pin interfaces:
  //
  lpif_if #(
    .lpif_bus_width(`LPIF_BUS_WIDTH)
  ) LPIF(
    .lclk(clk)
  );   // LPIF interface

  pipe_if #(
    .pipe_num_of_lanes(`NUM_OF_LANES),
    .pipe_max_width(`PIPE_MAX_WIDTH)
  ) PIPE(
    .PCLK(clk)
    // reset
  );  // PIPE Interface
  
  //
  // Instantiate the BFM interfaces:
  //
  lpif_driver_bfm #(
    .lpif_bus_width(`LPIF_BUS_WIDTH)
  ) LPIF_drv_bfm(
    .reset                  (LPIF.reset),
    .lclk                   (LPIF.lclk),
    .pl_trdy                (LPIF.pl_trdy),
    .pl_data                (LPIF.pl_data),
    .pl_valid               (LPIF.pl_valid),
    .lp_irdy                (LPIF.lp_irdy),
    .lp_data                (LPIF.lp_data),
    .lp_valid               (LPIF.lp_valid),
    .pl_linkup              (LPIF.pl_linkup),
    .lp_state_req           (LPIF.lp_state_req),
    .pl_state_sts           (LPIF.pl_state_sts),
    .lp_force_detect        (LPIF.lp_force_detect),
    .pl_speed_mode          (LPIF.pl_speed_mode),

    .pl_tlp_start           (LPIF.pl_tlp_start),
    .pl_tlp_end             (LPIF.pl_tlp_end),
    .pl_dllp_start          (LPIF.pl_dllp_start),
    .pl_dllp_end            (LPIF.pl_dllp_end),
    .pl_tlpedb              (LPIF.pl_tlpedb),

    .lp_tlp_start           (LPIF.lp_tlp_start),
    .lp_tlp_end             (LPIF.lp_tlp_end),
    .lp_dllp_start          (LPIF.lp_dllp_start),
    .lp_dllp_end            (LPIF.lp_dllp_end),
    .lp_tlpedb              (LPIF.lp_tlpedb)

  //	.pl_exit_cg_req         (LPIF.pl_exit_cg_req),
  //	.lp_exit_cg_ack         (LPIF.lp_exit_cg_ack),
  );

  lpif_monitor_bfm #(
    .lpif_bus_width(`LPIF_BUS_WIDTH)
  ) LPIF_mon_bfm(
    .reset                  (LPIF.reset),
    .lclk                   (LPIF.lclk),
    .pl_trdy                (LPIF.pl_trdy),
    .pl_data                (LPIF.pl_data),
    .pl_valid               (LPIF.pl_valid),
    .lp_irdy                (LPIF.lp_irdy),
    .lp_data                (LPIF.lp_data),
    .lp_valid               (LPIF.lp_valid),
    .pl_linkup              (LPIF.pl_linkup),
    .lp_state_req           (LPIF.lp_state_req),
    .pl_state_sts           (LPIF.pl_state_sts),
    .lp_force_detect        (LPIF.lp_force_detect),
    .pl_speed_mode          (LPIF.pl_speed_mode),

    .pl_tlp_start           (LPIF.pl_tlp_start),
    .pl_tlp_end             (LPIF.pl_tlp_end),
    .pl_dllp_start          (LPIF.pl_dllp_start),
    .pl_dllp_end            (LPIF.pl_dllp_end),
    .pl_tlpedb              (LPIF.pl_tlpedb),
  
    .lp_tlp_start           (LPIF.lp_tlp_start),
    .lp_tlp_end             (LPIF.lp_tlp_end),
    .lp_dllp_start          (LPIF.lp_dllp_start),
    .lp_dllp_end            (LPIF.lp_dllp_end),
    .lp_tlpedb              (LPIF.lp_tlpedb)

  //	.pl_exit_cg_req         (LPIF.pl_exit_cg_req),
  //	.lp_exit_cg_ack         (LPIF.lp_exit_cg_ack),
  );

  pipe_driver_bfm #(
    .pipe_num_of_lanes(`NUM_OF_LANES),
    .pipe_max_width(`PIPE_MAX_WIDTH)
  ) PIPE_drv_bfm(
    .PCLK                  (PIPE.PCLK), 
    .RxData                (PIPE.RxData),
    .RxDataValid           (PIPE.RxDataValid),
    .RxDataK               (PIPE.RxDataK),
    .RxValid               (PIPE.RxValid),
    .PhyStatus             (PIPE.PhyStatus),
    .RxElecIdle            (PIPE.RxElecIdle),
    .RxStatus              (PIPE.RxStatus),
    .RxStartBlock          (PIPE.RxStartBlock),
    .RxSyncHeader          (PIPE.RxSyncHeader),
    .TxData                (PIPE.TxData),
    .TxDataK               (PIPE.TxDataK),
    .TxDataValid           (PIPE.TxDataValid),
    .TxDetectRxLoopback    (PIPE.TxDetectRxLoopback),
    .TxElecIdle            (PIPE.TxElecIdle),
    .Width                 (PIPE.Width),
    .Rate                  (PIPE.Rate),
    .PclkRate              (PIPE.PclkRate),
    .Reset                 (PIPE.Reset),                      
    .TxStartBlock          (PIPE.TxStartBlock),
    .TxSyncHeader          (PIPE.TxSyncHeader),
    .PowerDown             (PIPE.PowerDown),
    .PclkChangeAck (PIPE.PclkChangeAck),
    .PclkChangeOk (PIPE.PclkChangeOk),
    .M2P_MessageBus (PIPE.M2P_MessageBus),
    .P2M_MessageBus (PIPE.P2M_MessageBus),
    .LocalTxPresetCoeffcients (PIPE.LocalTxPresetCoeffcients),
    .TxDeemph (PIPE.TxDeemph),
    .LocalFS (PIPE.LocalFS),
    .LocalLF (PIPE.LocalLF),
    .GetLocalPresetCoeffcients (PIPE.GetLocalPresetCoeffcients),
    .LocalTxCoeffcientsValid (PIPE.LocalTxCoeffcientsValid),
    .FS (PIPE.FS),
    .LF (PIPE.LF),
    .RxEqEval (PIPE.RxEqEval),
    .LocalPresetIndex (PIPE.LocalPresetIndex),
    .InvalidRequest (PIPE.InvalidRequest),
    .LinkEvaluationFeedbackDirectionChange (PIPE.LinkEvaluationFeedbackDirectionChange)
  );

  pipe_monitor_bfm #(
    .pipe_num_of_lanes(`NUM_OF_LANES),
    .pipe_max_width(`PIPE_MAX_WIDTH)
  ) PIPE_mon_bfm(
    .PCLK                  (PIPE.PCLK), 
    .RxData                (PIPE.RxData),
    .RxDataValid           (PIPE.RxDataValid),
    .RxDataK               (PIPE.RxDataK),
    .RxValid               (PIPE.RxValid),
    .PhyStatus             (PIPE.PhyStatus),
    .RxElecIdle            (PIPE.RxElecIdle),
    .RxStatus              (PIPE.RxStatus),
    .RxStartBlock          (PIPE.RxStartBlock),
    .RxSyncHeader          (PIPE.RxSyncHeader),
    .TxData                (PIPE.TxData),
    .TxDataK               (PIPE.TxDataK),
    .TxDataValid           (PIPE.TxDataValid),
    .TxDetectRxLoopback    (PIPE.TxDetectRxLoopback),
    .TxElecIdle            (PIPE.TxElecIdle),
    .Width                 (PIPE.Width),
    .Rate                  (PIPE.Rate),
    .PclkRate              (PIPE.PclkRate),
    .Reset                 (PIPE.Reset),                      
    .TxStartBlock          (PIPE.TxStartBlock),
    .TxSyncHeader          (PIPE.TxSyncHeader),
    .PowerDown             (PIPE.PowerDown),
    .PclkChangeAck (PIPE.PclkChangeAck),
    .PclkChangeOk (PIPE.PclkChangeOk),
    .M2P_MessageBus (PIPE.M2P_MessageBus),
    .P2M_MessageBus (PIPE.P2M_MessageBus),
    .LocalTxPresetCoeffcients (PIPE.LocalTxPresetCoeffcients),
    .TxDeemph (PIPE.TxDeemph),
    .LocalFS (PIPE.LocalFS),
    .LocalLF (PIPE.LocalLF),
    .GetLocalPresetCoeffcients (PIPE.GetLocalPresetCoeffcients),
    .LocalTxCoeffcientsValid (PIPE.LocalTxCoeffcientsValid),
    .FS (PIPE.FS),
    .LF (PIPE.LF),
    .RxEqEval (PIPE.RxEqEval),
    .LocalPresetIndex (PIPE.LocalPresetIndex),
    .InvalidRequest (PIPE.InvalidRequest),
    .LinkEvaluationFeedbackDirectionChange (PIPE.LinkEvaluationFeedbackDirectionChange)
  );

    
  // DUT
  PCIe #(
    .MAXPIPEWIDTH (`PIPE_MAX_WIDTH),
    .DEVICETYPE (~`IS_ENV_UPSTREAM), //0 for downstream 1 for upstream
    .LANESNUMBER (`NUM_OF_LANES),
    .GEN1_PIPEWIDTH (8) ,	
    .GEN2_PIPEWIDTH (8) ,	
    .GEN3_PIPEWIDTH (8) ,								
    .GEN4_PIPEWIDTH (8) ,	
    .GEN5_PIPEWIDTH (8) ,	
    .MAX_GEN (1)
  ) DUT (
  . CLK (clk),
  . lpreset                               (LPIF.reset),
  . phy_reset                             (PIPE.Reset),
  . width                                 (PIPE.Width),
  . TxData                                (PIPE.TxData),
  . TxDataValid                           (PIPE.TxDataValid),
  . TxElecIdle                            (PIPE.TxElecIdle),
  . TxStartBlock                          (PIPE.TxStartBlock),
  . TxDataK                               (PIPE.TxDataK),
  . TxSyncHeader                          (PIPE.TxSyncHeader),
  . TxDetectRx_Loopback                   (PIPE.TxDetectRxLoopback),
  . RxData                                (PIPE.RxData),
  . RxDataValid                           (PIPE.RxDataValid),
  . RxDataK                               (PIPE.RxDataValid),
  . RxStartBlock                          (PIPE.RxStartBlock),
  . RxSyncHeader                          (PIPE.RxSyncHeader),
  . RxStatus                              (PIPE.RxStatus),
  . RxElectricalIdle                      (PIPE.RxElecIdle),
  . PowerDown                             (PIPE.PowerDown),
  . Rate                                  (PIPE.Rate),
  . PhyStatus                             (PIPE.PhyStatus),  
  . PCLKRate                              (PIPE.PclkRate),
  . PclkChangeAck                         (PIPE.PclkChangeAck),
  . PclkChangeOk                          (PIPE.PclkChangeOk),
  .	LocalTxPresetCoefficients             (PIPE.LocalTxPresetCoeffcients),
  .	TxDeemph                              (PIPE.TxDeemph),
  .	LocalFS                               (PIPE.LocalFS),
  .	LocalLF                               (PIPE.LocalLF),
  .	LocalPresetIndex                      (PIPE.LocalPresetIndex),
  .	GetLocalPresetCoeffcients             (PIPE.GetLocalPresetCoeffcients),
  .	LocalTxCoefficientsValid              (PIPE.LocalTxCoeffcientsValid),
  .	LF                                    (PIPE.LF),
  .	FS                                    (PIPE.FS),
  .	RxEqEval                              (PIPE.RxEqEval),
  .	InvalidRequest                        (PIPE.InvalidRequest),
  .	LinkEvaluationFeedbackDirectionChange (PIPE.LinkEvaluationFeedbackDirectionChange),
  
  . pl_trdy         (LPIF.pl_trdy),
  . lp_irdy         (LPIF.lp_irdy),
  . lp_data         (LPIF.lp_data),
  . lp_valid        (LPIF.lp_valid),
  . pl_data         (LPIF.pl_data),
  . pl_valid        (LPIF.pl_valid),
  . lp_state_req    (LPIF.lp_state_req),
  . pl_state_sts    (LPIF.pl_state_sts),
  . pl_speedmode    (LPIF.pl_speed_mode),
  . lp_force_detect (LPIF.lp_force_detect),
  . lp_dlpstart     (LPIF.lp_dllp_start) ,
  . lp_dlpend       (LPIF.lp_dllp_end),
  . lp_tlpstart     (LPIF.lp_tlp_start),
  . lp_tlpend       (LPIF.lp_tlp_end),
  . pl_dlpstart     (LPIF.pl_dllp_start),
  . pl_dlpend       (LPIF.pl_dllp_end),
  . pl_tlpstart     (LPIF.pl_tlp_start),
  . pl_tlpend       (LPIF.pl_tlp_end),
  . pl_tlpedb       (LPIF.pl_tlpedb),
  . linkUp          (LPIF.pl_linkup)
  );


  // UVM initial block:
  // Virtual interface wrapping & run_test()
  initial begin //tbx vif_binding_block
    import uvm_pkg::uvm_config_db;
    uvm_config_db #(lpif_driver_bfm_param) ::set(null, "uvm_test_top", "lpif_driver_bfm", LPIF_drv_bfm);
    uvm_config_db #(lpif_monitor_bfm_param)::set(null, "uvm_test_top", "lpif_monitor_bfm", LPIF_mon_bfm);
    uvm_config_db #(pipe_driver_bfm_param) ::set(null, "uvm_test_top", "pipe_driver_bfm", PIPE_drv_bfm);
    uvm_config_db #(pipe_monitor_bfm_param)::set(null, "uvm_test_top", "pipe_monitor_bfm", PIPE_mon_bfm);
  end

  //
  // Clock and reset initial block:
  //
  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end
  // initial begin 
  //   reset = 0;
  //   repeat(4) @(posedge clk);
  //   reset = 1;
  // end

  initial begin
    forever #50000 `uvm_info("hdl_top", $sformatf("Time: %t", $time), UVM_NONE)
  end

endmodule: hdl_top
