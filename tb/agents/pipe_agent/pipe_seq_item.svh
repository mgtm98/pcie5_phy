/******************************** Class Header ********************************************/
class pipe_seq_item extends uvm_sequence_item;

  // UVM Factory Registration Macro
  `uvm_object_utils(pipe_seq_item)

  const longint unsigned TLP_MIN_SIZE = 20;
  const longint unsigned TLP_MAX_SIZE  20;

  // sequence item data variables
  rand pipe_operation_t pipe_operation; 
  rand tlp_t tlp;
  rand dllp_t dllp;
  rand pipe_width_t pipe_width;
  rand pclk_rate_t pclk_rate;
  rand ts_s ts_sent;
  rand ts_s tses_sent [`NUM_OF_LANES];
  
  constraint c1 {
    tlp.size() > TLP_MIN_SIZE;
    tlp.size() < TLP_MAX_SIZE;
  };

  extern function new(string name = "pipe_seq_item");
  extern function void do_copy(uvm_object rhs);
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function string convert2string();
  extern function void do_print(uvm_printer printer);
  extern function pipe_seq_item_c to_struct();
  extern function void from_struct(pipe_seq_item_c src);

endclass:pipe_seq_item
/*******************************************************************************************/

/********************************* Class Implementation ************************************/
function pipe_seq_item::new(string name = "pipe_seq_item");
  super.new(name);
endfunction

function void pipe_seq_item::do_copy(uvm_object rhs);
  pipe_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object to `pipe_seq_item` failed")
  end

  super.do_copy(rhs);
  this.pipe_operation = rhs_.pipe_operation;
  this.tlp            = rhs_.tlp;
  this.dllp           = rhs_.dllp;
  this.pipe_width     = rhs_.pipe_width;
  this.pclk_rate      = rhs_.pclk_rate;
  this.ts_sent        = rhs_.ts_sent;
  this.tses_sent      = rhs_.tses_sent;
endfunction:do_copy

function bit pipe_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  pipe_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_compare", "cast of rhs object failed")
    return 0;
  end

  if(tlp.size() != rhs_.tlp.size()) return 0;

  foreach(tlp[i]) begin
    if(tlp[i] != rhs_.tlp[i]) return 0
  end

  foreach(dllp[i]) begin
    if(dllp[i] != rhs_.dllp[i]) return 0
  end

  foreach(tses_sent[i]) begin
    if(tses_sent[i] != rhs_.tses_sent[i]) return 0
  end
  
  return ((super.do_compare(rhs, comparer)) && 
          (this.pipe_width == rhs_.pipe_width) &&
          (this.pclk_rate == rhs_.pclk_rate) &&
          (this.ts_sent == rhs_.ts_sent))
endfunction:do_compare

function string pipe_seq_item::convert2string();
  return $sformatf("PIPE Sequence Item: \n\toperation:%s, width:%s, rate:%s, \n\ttlp size:%0d
                 \n\tdllp size:%0d\n",
                this.pipe_operation.name(),
                this.pipe_width.name(),
                this.pclk_rate.name(),
                this.tlp.size(),
                this.dllp.size());
endfunction: convert2string

function void pipe_seq_item::do_print(uvm_printer printer);
  // printer.m_string = this.convert2string();
  `uvm_info(get_name(), convert2string(), UVM_NONE)
endfunction: do_print

function pipe_seq_item_s pipe_seq_item::to_struct();
  pipe_seq_item_s s_h;
  s_h.pipe_operation  = this.pipe_operation;
  s_h.tlp             = this.tlp;
  s_h.dllp            = this.dllp;
  s_h.pipe_width      = this.pipe_width;
  s_h.pclk_rate       = this.pclk_rate;
  return s_h;
endfunction: to_struct

function void pipe_seq_item::from_struct(pipe_seq_item_c src);
  this.pipe_operation = src.pipe_operation;
  this.tlp            = src.tlp;
  this.dllp           = src.dllp;
  this.pipe_width     = src.pipe_width;
  this.pclk_rate      = src.pclk_rate;
endfunction: from_struct
/*******************************************************************************************/