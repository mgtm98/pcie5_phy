class dummy_vseq extends base_vseq;

  `uvm_object_utils(dummy_vseq);

  extern function new(string name = "dummy_vseq");
  extern task body();

endclass: dummy_vseq

function dummy_vseq::new(string name = "dummy_vseq");
  super.new(name);
endfunction: new

task dummy_vseq::body();
  //handels of sequnces
  lpif_dummy_seq lpif_dummy_seq_h = lpif_dummy_seq::type_id::create("lpif_dummy_seq_h");
  pipe_dummy_seq pipe_dummy_seq_h = pipe_dummy_seq::type_id::create("pipe_dummy_seq_h");
  `uvm_info(get_name(), "dummy_vseq started", UVM_NONE)

  // lpif_dummy_seq_h.start (lpif_sequencer_h,this);

  pipe_dummy_seq_h.start (pipe_sequencer_h,this);

  // fork
  //   lpif_dummy_seq_h.start (lpif_sequencer_h,this);
  //   pipe_dummy_seq_h.start (pipe_sequencer_h,this); 
  // join	
endtask

