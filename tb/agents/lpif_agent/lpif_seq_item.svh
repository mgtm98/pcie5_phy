//  Class: lpif_seq_item
//
class lpif_seq_item extends uvm_sequence_item;
  `uvm_object_utils(lpif_seq_item)

  //  Group: Variables
  rand lpif_operation_t lpif_operation;
  rand tlp_t tlp;
  rand dllp_t dllp;
  

  //  Group: Constraints
  constraint c1 {tlp.size()>20; tlp.size()<1000;}

  //  Group: Functions

  //  Constructor: new
  function new(string name = "lpif_seq_item");
    super.new(name);
  endfunction: new

  //  Function: do_copy
  extern function void do_copy(uvm_object rhs);
  //  Function: do_compare
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  //  Function: convert2string
  extern function string convert2string();
  //  Function: do_print
  extern function void do_print(uvm_printer printer);
  //  Function: do_record
  // extern function void do_record(uvm_recorder recorder);
  //  Function: do_pack
  // extern function void do_pack();
  //  Function: do_unpack
  // extern function void do_unpack();
  
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
