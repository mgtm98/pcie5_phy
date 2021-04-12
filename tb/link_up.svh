task link_up(link_up_config link_up_config_h);

	ts_t.use_n_fts=false;
	ts_t.use_link_number=false;
	ts_t.use_lane_number=false;
	ts_t.ts_type=TS1;
	ts_t.max_gen_suported=link_up_config_h.max_gen_suported; //??

	detect_state();  
	polling_state();      
	configuration_state();
	
endtask : link_up