`define SEND_RECV_TS() \
	task send_seq_item(ts_s tses [`NUM_OF_LANES]); \
	  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item"); \
	  pipe_seq_item_h.tses_sent = tses; \
	  start_item (pipe_seq_item_h); \
	    if (!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TSES;}) begin \
	      `uvm_error(get_name(), "") \
	    end \
	  finish_item (pipe_seq_item_h); \
	endtask \
	task get_tses_recived(output ts_s tses [`NUM_OF_LANES]); \
	  @(pipe_agent_config_h.detected_tses_e); \
	  tses = pipe_agent_config_h.tses_received; \
	endtask \

