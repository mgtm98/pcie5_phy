class pipe_link_up_seq extends uvm_sequence #(pipe_seq_item);
    `uvm_object_utils(pipe_link_up_seq)

    // Methods
    
    // Standard UVM Methods:
    extern function new(string name = "pipe_link_up_seq");
    extern task body;    
endclass:pipe_link_up_seq

  function pipe_link_up_seq::new(string name = "pipe_link_up_seq");
    super.new(name);
  endfunction
    
  task pipe_link_up_seq::body;
    pipe_seq_item req = pipe_seq_item::type_id::create("req");;
    start_item(req);
    if (!req.randomize() with {lpif_operation == LINK_UP;})
    begin
      `uvm_error(get_name(), "Can't randomize sequence item")
    end
    finish_item(req);
  endtask: body