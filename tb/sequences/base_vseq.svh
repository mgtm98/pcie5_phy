class base_vseq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(base_vseq);

  lpif_sequencer lpif_sequencer_h;
  pipe_sequencer pipe_sequencer_h;
  
  extern function new(string name = "base_vseq");

endclass: base_vseq

function base_vseq::new(string name = "base_vseq");
  super.new(name);
endfunction: new