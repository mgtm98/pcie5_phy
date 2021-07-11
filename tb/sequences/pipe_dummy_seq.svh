class pipe_dummy_seq extends pipe_base_seq;
  
  `uvm_object_utils(pipe_dummy_seq)

  extern function new(string name = "pipe_dummy_seq");
  extern virtual task body();
  
endclass: pipe_dummy_seq

function pipe_dummy_seq::new(string name = "pipe_dummy_seq");
  super.new(name);
endfunction

task pipe_dummy_seq::body();
  pipe_seq_item pipe_seq_item_h = pipe_seq_item::type_id::create("pipe_seq_item_h");
  start_item(pipe_seq_item_h);
  if(!pipe_seq_item_h.randomize() with {pipe_operation == SEND_TSES;}) begin
    `uvm_fatal(get_name(), "Can't randomize pipe_seq_item")
  end
  for (int i = 0; i < `NUM_OF_LANES; i++) begin
    pipe_seq_item_h.tses_sent[i].n_fts            = 0;
    pipe_seq_item_h.tses_sent[i].lane_number      = i;
    pipe_seq_item_h.tses_sent[i].link_number      = 8;
    pipe_seq_item_h.tses_sent[i].use_n_fts        = 0;
    pipe_seq_item_h.tses_sent[i].use_link_number  = 0;
    pipe_seq_item_h.tses_sent[i].use_lane_number  = 0;
    pipe_seq_item_h.tses_sent[i].max_gen_supported = GEN1;
    pipe_seq_item_h.tses_sent[i].ts_type          = TS1;
  end
  finish_item(pipe_seq_item_h);
endtask