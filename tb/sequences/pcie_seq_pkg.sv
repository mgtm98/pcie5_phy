package pcie_seq_pkg;
  `include "uvm_macros.svh"

  import uvm_pkg::*;
  import lpif_agent_pkg::*;
  import pipe_agent_pkg::*;

  // LPIF seq
  class lpif_seq extends uvm_sequence #(lpif_seq_item);
    `uvm_object_utils(lpif_seq)
    
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
    extern function new(string name = "lpif_seq");
    extern task body;
    
    endclass:lpif_seq
    
  function lpif_seq::new(string name = "lpif_seq");
    super.new(name);
  endfunction
    
  task lpif_seq::body;
    lpif_seq_item req = lpif_seq_item::type_id::create("req");;
    start_item(req);
    if (!req.randomize())
    begin
      `uvm_error(get_name(), "Can't randomize sequence item")
    end
    finish_item(req);
  endtask: body
  
  // PIPE seq
  class pipe_seq extends uvm_sequence #(pipe_seq_item);

`uvm_object_utils(pipe_seq)

// Standard UVM Methods:
extern function new(string name = "pipe_seq");
extern task body;
endclass:pipe_seq

function pipe_seq::new(string name = "pipe_seq");
  super.new(name);
endfunction

task pipe_seq::body;
  pipe_seq_item pipe_seq_item_h ;
  start_item(pipe_seq_item_h);
  if (!pipe_seq_item_h.randomize())
  begin
    `uvm_error(get_name(), "Can't randomize sequence item")
  end
  finish_item(pipe_seq_item_h);
endtask:body

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
      lpif_seq lpif_seq_h = lpif_seq::type_id::create("lpif_seq_h");
      pipe_seq pipe_seq_h = pipe_seq::type_id::create("pipe_seq_h");
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