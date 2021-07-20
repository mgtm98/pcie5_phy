class speed_change_dsp_vseq extends base_vseq;

    `uvm_object_utils(speed_change_dsp_vseq);
  
    extern function new(string name = "speed_change_dsp_vseq");
    extern task body();
  
  endclass: speed_change_dsp_vseq
  
  function speed_change_dsp_vseq::new(string name = "speed_change_dsp_vseq");
    super.new(name);
  endfunction: new
  
  task speed_change_dsp_vseq::body();
    //handels of sequnces

    pipe_speed_change_without_eq_dsp_seq pipe_speed_change_without_eq_dsp_seq_h = pipe_speed_change_without_eq_dsp_seq::type_id::create("pipe_speed_change_without_eq_dsp_seq_h");
    
  
   `uvm_info (get_type_name(), $sformatf ("start speed change without EQ seq"), UVM_MEDIUM)
    pipe_speed_change_without_eq_dsp_seq_h.start (pipe_sequencer_h,this); 

  endtask