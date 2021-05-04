module hdl_top;

  `include "settings.svh"

  import lpif_agent_pkg::*;
  import pipe_agent_pkg::*;

  // clk and reset
  //
  logic clk;
  logic reset;

  //
  // Instantiate the pin interfaces:
  //
  lpif_if #(
    .lpif_bus_width(`LPIF_BUS_WIDTH)
  ) LPIF(clk);   // LPIF interface

  pipe_if #(
  .pipe_num_of_lanes(`NUM_OF_LANES),
  .pipe_max_width(`PIPE_MAX_WIDTH)
) PIPE(clk);  // PIPE Interface

  //
  // Instantiate the BFM interfaces:
  //
lpif_driver_bfm #(
  .lpif_bus_width(`LPIF_BUS_WIDTH)
) LPIF_drv_bfm(
    .lclk                   (LPIF.lclk),
    .pl_trdy                (LPIF.pl_trdy),
    .pl_data                (LPIF.pl_data),
    .pl_valid               (LPIF.pl_valid),
    .lp_irdy                (LPIF.lp_irdy),
    .lp_data                (LPIF.lp_data),
    .lp_valid               (LPIF.lp_valid),
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
    .lclk                   (LPIF.lclk),
    .pl_trdy                (LPIF.pl_trdy),
    .pl_data                (LPIF.pl_data),
    .pl_valid               (LPIF.pl_valid),
    .lp_irdy                (LPIF.lp_irdy),
    .lp_data                (LPIF.lp_data),
    .lp_valid               (LPIF.lp_valid),
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
    .CLK                   (PIPE.CLK), 
    .RxData                (PIPE.RxData),
    .RxDataK               (PIPE.RxDataK),
    .RxValid               (PIPE.RxValid),
    .PhyStatus             (PIPE.PhyStatus),
    .RxElecldle            (PIPE.RxElecldle),
    .RxStatus              (PIPE.RxStatus),
    .RxStartBlock          (PIPE.RxStartBlock),
    .RxSyncHeader          (PIPE.RxSyncHeader),
    .TxData                (PIPE.TxData),
    .TxDataK               (PIPE.TxDataK),
    .TxDataValid           (PIPE.TxDataValid),
    .TxDetectRx            (PIPE.TxDetectRx),
    .TxElecIdle            (PIPE.TxElecIdle),
    .Width                 (PIPE.Width),
    .Rate                  (PIPE.Rate),
    .PCLK                  (PIPE.PCLK),
    .PclkRate              (PIPE.PclkRate),
    .Reset                 (PIPE.Reset),                      
    .TxStartBlock          (PIPE.TxStartBlock),
    .TxSyncHeader          (PIPE.TxSyncHeader),
    .PowerDown             (PIPE.PowerDown)
  );

  pipe_monitor_bfm #(
    .pipe_num_of_lanes(`NUM_OF_LANES),
    .pipe_max_width(`PIPE_MAX_WIDTH)
  ) PIPE_mon_bfm(
    .CLK                   (PIPE.CLK), 
    .RxData                (PIPE.RxData),
    .RxDataK               (PIPE.RxDataK),
    .RxValid               (PIPE.RxValid),
    .PhyStatus             (PIPE.PhyStatus),
    .RxElecldle            (PIPE.RxElecldle),
    .RxStatus              (PIPE.RxStatus),
    .RxStartBlock          (PIPE.RxStartBlock),
    .RxSyncHeader          (PIPE.RxSyncHeader),
    .TxData                (PIPE.TxData),
    .TxDataK               (PIPE.TxDataK),
    .TxDataValid           (PIPE.TxDataValid),
    .TxDetectRx            (PIPE.TxDetectRx),
    .TxElecIdle            (PIPE.TxElecIdle),
    .Width                 (PIPE.Width),
    .Rate                  (PIPE.Rate),
    .PCLK                  (PIPE.PCLK),
    .PclkRate              (PIPE.PclkRate),
    .Reset                 (PIPE.Reset),                      
    .TxStartBlock          (PIPE.TxStartBlock),
    .TxSyncHeader          (PIPE.TxSyncHeader),
    .PowerDown             (PIPE.PowerDown)
  );

    
  // DUT
  // pcie_top DUT(
  //     // PCIE Interface:
  // );


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
    forever #10ns clk = ~clk;
  end
  // initial begin 
  //   reset = 0;
  //   repeat(4) @(posedge clk);
  //   reset = 1;
  // end

endmodule: hdl_top
