class enter_recovery_vseq extends base_vseq;

  `uvm_object_utils(enter_recovery_vseq);

  extern function new(string name = "enter_recovery_vseq");
  extern task body();

endclass: enter_recovery_vseq

function enter_recovery_vseq::new(string name = "enter_recovery_vseq");
  super.new(name);
endfunction: new

task enter_recovery_vseq::body();
  //handels of sequnces
  lpif_enter_recovery_seq lpif_enter_recovery_seq_h = lpif_enter_recovery_seq::type_id::create("lpif_enter_recovery_seq_h");
  pipe_enter_recovery_seq pipe_enter_recovery_seq_h = pipe_enter_recovery_seq::type_id::create("pipe_enter_recovery_seq_h");

 `uvm_info (get_type_name (), $sformatf ("starting lpif_enter_recovery_seq and pipe_enter_recovery_seq in parallel"), UVM_MEDIUM)
  fork
    lpif_enter_recovery_seq_h.start (lpif_sequencer_h,this);
    pipe_enter_recovery_seq_h.start (pipe_sequencer_h,this); 
  join	
endtask

