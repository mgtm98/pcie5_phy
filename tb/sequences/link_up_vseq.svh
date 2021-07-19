class link_up_vseq extends base_vseq;

  `uvm_object_utils(link_up_vseq);

  extern function new(string name = "link_up_vseq");
  extern task body();

endclass: link_up_vseq

function link_up_vseq::new(string name = "link_up_vseq");
  super.new(name);
endfunction: new

task link_up_vseq::body();
  //handels of sequnces
  lpif_link_up_seq lpif_link_up_seq_h = lpif_link_up_seq::type_id::create("lpif_link_up_seq_h");
  pipe_link_up_seq pipe_link_up_seq_h = pipe_link_up_seq::type_id::create("pipe_link_up_seq_h");

 `uvm_info (get_type_name(), $sformatf ("starting  link_up_vseq"), UVM_MEDIUM)
  fork
    lpif_link_up_seq_h.start (lpif_sequencer_h,this);
    pipe_link_up_seq_h.start (pipe_sequencer_h,this); 
  join	
  `uvm_info (get_type_name(), $sformatf ("finished  link_up_vseq"), UVM_MEDIUM)
endtask

