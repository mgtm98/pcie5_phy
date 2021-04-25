class lpif_seq_item extends uvm_sequence_item;
  `uvm_object_utils(lpif_seq_item)

  //  Group: Variables
  rand lpif_operation_t lpif_operation;
  rand tlp_t tlp;
  rand dllp_t dllp;

  const longint unsigned TLP_MIN_SIZE = 20;
  const longint unsigned TLP_MAX_SIZE  20;

  //  Group: Constraints
  constraint c1 {
    tlp.size() > TLP_MIN_SIZE;
    tlp.size() < TLP_MAX_SIZE;
  };

  extern         function void new(string name);
  extern virtual function void do_copy(uvm_object rhs);
  extern virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern virtual function string convert2string();
  extern virtual function void do_print(uvm_printer printer);
  extern         function lpif_seq_item_s to_struct();
  extern         function void from_struct(lpif_seq_item_s lpif_seq_item_s_h);
     
endclass: lpif_seq_item

  function void lpif_seq_item::new(string name = "lpif_seq_item");
    super.new(name);
  endfunction: new

function void lpif_seq_item::do_copy(uvm_object rhs);
  lpif_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end

  super.do_copy(rhs);
  // Copy over data members:
  lpif_operation = rhs_.lpif_operation;
  tlp = rhs_.tlp;
  dllp = rhs_.dllp;

endfunction:do_copy

function bit lpif_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  lpif_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end

  if (tlp.size() != rhs_.tlp.size()) begin
    return 0;
  end

  for (int i = 0; i < tlp.size(); i++) begin
    if (tlp[i] != rhs_.tlp[i] ) begin
      return 0;
    end
  end

  for (int i = 0; i < $size(dllp); i++) begin
    if (dllp[i] != rhs_.dllp[i] ) begin
      return 0;
    end
  end

  return super.do_compare(rhs, comparer) && lpif_operation == rhs_.lpif_operation ; //??
endfunction:do_compare

function string lpif_seq_item::convert2string();
  return $sformatf("LPIF Sequence Item: \n\toperation:%s, \n\ttlp size:%0d \n\tdllp size:%0d\n",
                this.lpif_operation.name(),
                this.tlp.size(),
                this.dllp.size());
endfunction:convert2string

function void lpif_seq_item::do_print(uvm_printer printer);
  // printer.m_string = convert2string();
  `uvm_info(get_name(), convert2string(), UVM_NONE)
endfunction:do_print

function lpif_seq_item_s lpif_seq_item::to_struct ();
  lpif_seq_item_s lpif_seq_item_struct;
  lpif_seq_item_struct.tlp = tlp;
  lpif_seq_item_struct.dllp = dllp;
  lpif_seq_item_struct.lpif_operation = lpif_operation;
  return lpif_seq_item_struct;
endfunction : to_struct 

function void lpif_seq_item::from_struct (lpif_seq_item_s lpif_seq_item_s_h);
  tlp = lpif_seq_item_struct.tlp;
  dllp = lpif_seq_item_struct.dllp;
  lpif_operation = lpif_seq_item_struct.lpif_operation;
endfunction : from_struct 
