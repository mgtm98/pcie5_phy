class reset_vseq extends uvm_sequence #(uvm_sequence_item); //inherit from base_vseq class??

`uvm_object_utils(reset_vseq);
// handels of sequencers
lpif_sequencer lpif_sequencer_h;
pipe_sequencer pipe_sequencer_h;

function new(string name = "reset_vseq");
  super.new(name);
endfunction: new
    
task body();
  //handels of sequnces
  lpif_reset_seq lpif_reset_seq_h = lpif_reset_seq::type_id::create("lpif_reset_seq_h");
  pipe_reset_seq pipe_reset_seq_h = pipe_reset_seq::type_id::create("pipe_reset_seq_h");

 `uvm_info (get_type_name (), $sformatf ("starting lpif_reset_seq and pipe_reset_seq in parallel"), UVM_MEDIUM)
  fork
    lpif_reset_seq_h.start (lpif_sequencer_h,this);
    pipe_reset_seq_h.start (pipe_sequencer_h,this); 
  join	
endtask
endclass: reset_vseq