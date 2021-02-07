class lpif_dummy_seq extends uvm_sequence #(lpif_seq_item);

    `uvm_object_utils(lpif_dummy_seq)
    
    //------------------------------------------
    // Data Members (Outputs rand, inputs non-rand)
    //------------------------------------------
    rand logic [7:0] data_d;
    
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
        req.data_d = data_d;
        finish_item(req);
      end
    
    endtask:body
    