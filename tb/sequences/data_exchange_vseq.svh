class data_exchange_vseq extends base_vseq;

  `uvm_object_utils(data_exchange_vseq);
  
  extern function new(string name = "data_exchange_vseq");
  extern task body();

endclass: data_exchange_vseq

function data_exchange_vseq::new(string name = "data_exchange_vseq");
  super.new(name);
endfunction: new

task data_exchange_vseq::body();
  //handels of sequnces
  lpif_data_transmit_seq lpif_data_transmit_seq_h = lpif_data_transmit_seq::type_id::create("lpif_data_transmit_seq_h");
  pipe_data_transmit_seq pipe_data_transmit_seq_h = pipe_data_transmit_seq::type_id::create("pipe_data_transmit_seq_h");

 `uvm_info (get_type_name (), $sformatf ("starting lpif_data_transmit_seq and pipe_data_transmit_seq in parallel"), UVM_MEDIUM)
  fork
    lpif_data_transmit_seq_h.start (lpif_sequencer_h, this);
    pipe_data_transmit_seq_h.start (pipe_sequencer_h, this); 
  join	
endtask