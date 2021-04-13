class enter_recovery_vseq extends uvm_sequence #(uvm_sequence_item); //inherit from base_vseq class??

`uvm_object_utils(enter_recovery_vseq);
// handels of sequencers
lpif_sequencer lpif_sequencer_h;
pipe_sequencer pipe_sequencer_h;

function new(string name = "enter_recovery_vseq");
  super.new(name);
endfunction: new
    
task body();
  //handels of sequnces
  lpif_enter_recovery_seq lpif_enter_recovery_seq_h = lpif_enter_recovery_seq::type_id::create("lpif_enter_recovery_seq_h");
  pipe_enter_recovery_seq pipe_enter_recovery_seq_h = pipe_enter_recovery_seq::type_id::create("pipe_enter_recovery_seq_h");

 `uvm_info (get_type_name (), $sformatf ("starting lpif_enter_recovery_seq and pipe_enter_recovery_seq in parallel"), UVM_MEDIUM)
  fork
    lpif_enter_recovery_seq_h.start (lpif_sequencer_h,this);
    pipe_enter_recovery_seq_h.start (pipe_sequencer_h,this); 
  join	
endtask
endclass: enter_recovery_vseq