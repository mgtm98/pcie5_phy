class reset_vseq extends base_vseq; //inherit from base_vseq class??

  `uvm_object_utils(reset_vseq);

  extern function new(string name = "reset_vseq");
  extern task body();

endclass: reset_vseq

function reset_vseq::new(string name = "reset_vseq");
  super.new(name);
endfunction: new
    
task reset_vseq::body();
  //handels of sequnces
  lpif_reset_seq lpif_reset_seq_h = lpif_reset_seq::type_id::create("lpif_reset_seq_h");
  pipe_reset_seq pipe_reset_seq_h = pipe_reset_seq::type_id::create("pipe_reset_seq_h");

 `uvm_info (get_type_name (), $sformatf ("starting lpif_reset_seq and pipe_reset_seq in parallel"), UVM_MEDIUM)
  fork
    lpif_reset_seq_h.start(lpif_sequencer_h,this);
    pipe_reset_seq_h.start(pipe_sequencer_h,this); 
  join	
endtask