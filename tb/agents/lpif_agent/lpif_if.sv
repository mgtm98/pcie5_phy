interface lpif_if(input Clk,
                 input reset);

logic [7:0][7:0] Data;
logic [7:0] Valid;
logic Irdy;
logic ex_cg_ack;
logic [3:0] state_req;
logic stall_ack;
logic [8:0] tlp_start;
logic [8:0] tlp_end;
logic [8:0] dllp_start;
logic [8:0] dllp_end;
logic ex_cg_req;
logic block_dl_init;
logic protocol_valid;
logic [2:0] protocol;
logic link_up;
logic [3:0] state_sts;
logic trdy;
logic phyinrecenter;
logic rxframe_errmask;
logic [2:0] link_cfg;
logic stall_req;
logic phyinl1;

endinterface: lpif_if
