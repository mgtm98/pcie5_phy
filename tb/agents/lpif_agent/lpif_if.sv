interface lpif_if(input PCLK,
                 input reset);

Logic [NBYTES-1:0][7:0] Data;
Logic [PL_NVLD-1:0] Valid;
Logic Irdy;
Logic ex_cg_ack;
Logic [3:0] state_req;
Logic stall_ack;
Logic [w-1] tlp_start;
Logic [w-1] tlp_end;
Logic [w-1] dllp_start;
Logic [w-1] dllp_end;
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
