class lpif_seq_item extends uvm_sequence_item;
  `uvm_object_utils(lpif_seq_item)

  //  Group: Variables
  rand lpif_operation_t lpif_operation;
  rand tlp_t tlp;
  rand dllp_t dllp;
  

  //  Group: Constraints
  constraint c1 {tlp.size()>20; tlp.size()<1000;}

  function new(string name = "lpif_seq_item");
    super.new(name);
  endfunction: new

  extern virtual function void do_copy(uvm_object rhs);
  extern virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern virtual function string convert2string();
  extern virtual function void do_print(uvm_printer printer);
  extern         function Lpif_seq_item_s to_struct();
  extern static  function void from_struct(Lpif_seq_item_s Lpif_seq_item_s_h);
    
  endfunction : 
  
endclass: lpif_seq_item


/*----------------------------------------------------------------------------*/
/*  Constraints                                                               */
/*----------------------------------------------------------------------------*/

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
  return super.do_compare(rhs, comparer) &&
        lpif_operation == rhs_.lpif_operation &&
        tlp == rhs_.tlp &&
        dllp == rhs_.dllp ;
endfunction:do_compare

function string lpif_seq_item::convert2string();
  string s;

  $sformat(s, "%s\n", super.convert2string());
  // $sformat(s, "%s\n lpif_operation\t%0h\n tlp\t%0h\n dllp\t%0b\n delay\t%0d\n", s, lpif_operation, tlp, dllp);
  return s;

endfunction:convert2string

function void lpif_seq_item::do_print(uvm_printer printer);
  printer.m_string = convert2string();
endfunction:do_print

//???????
function Lpif_seq_item_s lpif_seq_item::to_struct (); 
  Lpif_seq_item_s_h.tlp_data = tlp_data;
  Lpif_seq_item_s_h.dllp_data = dllp_data;
  Lpif_seq_item_s_h.operation = operation;
endfunction : to_struct 

//leh static ??????????????????????
function void lpif_seq_item::from_struct (Lpif_seq_item_s Lpif_seq_item_s_h);
  tlp_data = Lpif_seq_item_s_h.tlp_data;
  dllp_data = Lpif_seq_item_s_h.dllp_data;
  operation = Lpif_seq_item_s_h.operation;
endfunction : from_struct 
