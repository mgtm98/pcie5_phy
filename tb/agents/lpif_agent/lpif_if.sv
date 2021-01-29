interface lpif_if(input PCLK,
                 input reset);

Logic [7:0][7:0] Data;
Logic [7:0] Valid;
Logic Irdy;
Logic ex_cg_ack;
Logic [3:0] state_req;
Logic stall_ack;
Logic [8:0] tlp_start;
Logic [8:0] tlp_end;
Logic [8:0] dllp_start;
Logic [8:0] dllp_end;
Logic ex_cg_req;
Logic block_dl_init;
Logic protocol_valid;
Logic [2:0] protocol;
Logic link_up;
Logic [3:0] state_sts;
Logic trdy;
Logic phyinrecenter;
Logic rxframe_errmask;
Logic [2:0] link_cfg;
Logic stall_req;
Logic phyinl1;

endinterface: lpif_if
