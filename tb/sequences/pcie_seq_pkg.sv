package pcie_seq_pkg;
  import lpif_agent_pkg::*;
  import pipe_agent_pkg::*;

  // LPIF seq
  class lpif_dummy_seq extends uvm_sequence #(lpif_seq_item);

    `uvm_object_utils(lpif_dummy_seq)
    
    //------------------------------------------
    // Data Members (Outputs rand, inputs non-rand)
    //------------------------------------------

    //------------------------------------------
    // Constraints
    //------------------------------------------
    
    
    
    //------------------------------------------
    // Methods
    //------------------------------------------
    
    // Standard UVM Methods:
    extern function new(string name = "lpif_dummy_seq");
    extern task body;
    
    endclass:lpif_dummy_seq
    
    function lpif_dummy_seq::new(string name = "lpif_dummy_seq");
      super.new(name);
    endfunction
    
    task lpif_dummy_seq::body;
      lpif_seq_item req = lpif_seq_item::type_id::create("req");;
    
      begin
        start_item(req);
        req.randomise();
        finish_item(req);
      end
    
    endtask: body
    
  // PIPE seq

  // Virtual seq
  class pcie_vseq extends uvm_sequence #(uvm_sequence_item);
    // UVM Factory Registration Macro
    `uvm_object_utils(pcie_vseq);
    // handels of sequencers
    lpif_sequencer lpif_sequencer_h;
    pipe_sequencer pipe_sequencer_h;
    
    //constructor
    function new(string name = "pcie_vseq");
      super.new(name);
    endfunction: new
        
    task body();
      //handels of sequnces
      lpif_seq lpif_seq_h = lpif_seq::type_id::create ("lpif_seq_h");
      pipe_seq pipe_seq_h = pipe_seq::type_id::create ("pipe_seq_h");
      `uvm_info (get_type_name (), $sformatf ("starting lpif_seq from pcie_vseq"), UVM_MEDIUM)
      lpif_seq_h.start (lpif_sequencer_h,this);
      `uvm_info (get_type_name (), $sformatf ("starting pipe_seq from pcie_vseq"), UVM_MEDIUM)
      pipe_seq_h.start (pipe_sequencer_h,this); 
      // `uvm_info (get_type_name (), $sformatf ("starting both lpif_seq and pipe_seq from pcie_vseq in parallel"), UVM_MEDIUM)
      // fork
      //     // run lpif and pipe sequnces in parallel
      //     lpif_seq_h.start (lpif_sequencer_h,this);
      //     pipe_seq_h.start (pipe_sequencer_h,this); 
      // join	
    endtask
  endclass: pcie_vseq
endpackage
