class data_exchange_vseq extends uvm_sequence #(uvm_sequence_item); //inherit from base_vseq class??

  `uvm_object_utils(data_exchange_vseq);
  // handels of sequencers
  lpif_sequencer lpif_sequencer_h;
  pipe_sequencer pipe_sequencer_h;
  
  function new(string name = "data_exchange_vseq");
    super.new(name);
  endfunction: new
      
  task body();
    //handels of sequnces
    lpif_data_exchange_seq data_exchange_seq_h = lpif_data_exchange_seq::type_id::create("lpif_data_exchange_seq_h");
    pipe_data_exchange_seq pipe_data_exchange_seq_h = pipe_data_exchange_seq::type_id::create("pipe_data_exchange_seq_h");
  
   `uvm_info (get_type_name (), $sformatf ("starting lpif_data_exchange_seq and pipe_data_exchange_seq in parallel"), UVM_MEDIUM)
    fork
      lpif_data_exchange_seq_h.start (lpif_sequencer_h,this);
      pipe_data_exchange_seq_h.start (pipe_sequencer_h,this); 
    join	
  endtask
  endclass: data_exchange_vseq