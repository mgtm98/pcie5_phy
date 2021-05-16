/******************************** Class Header ********************************************/
class pipe_seq_item extends uvm_sequence_item;

  // UVM Factory Registration Macro
  `uvm_object_utils(pipe_seq_item)

  static const longint unsigned TLP_CONSTRAINT_MIN_WIDTH = 20;
  static const longint unsigned TLP_CONSTRAINT_MAX_WIDTH = 20;

  // sequence item data variables
  rand pipe_operation_t pipe_operation; 
  rand tlp_t tlp;
  rand dllp_t dllp;
  rand pipe_width_t pipe_width;
  rand pclk_rate_t pclk_rate;
  rand gen_t gen;                                 // TODO: where is gen ysed in seq item
  rand ts_s ts_sent;
  rand ts_s tses_sent [`NUM_OF_LANES];
  
  constraint c1 {
    tlp.size() > pipe_seq_item::TLP_CONSTRAINT_MIN_WIDTH;
    tlp.size() < pipe_seq_item::TLP_CONSTRAINT_MAX_WIDTH;
  };

  extern function new(string name = "pipe_seq_item");
  extern function void do_copy(uvm_object rhs);
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function string convert2string();
  extern function void do_print(uvm_printer printer);
  extern function pipe_seq_item_s to_struct();
  extern function void from_struct(pipe_seq_item_s src);

endclass:pipe_seq_item
/*******************************************************************************************/

/********************************* Class Implementation ************************************/
function pipe_seq_item::new(string name = "pipe_seq_item");
  super.new(name);
endfunction

function void pipe_seq_item::do_copy(uvm_object rhs);
  pipe_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy:", "cast of rhs object to `pipe_seq_item` failed")
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
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  
  return ((super.do_compare(rhs, comparer)) && 
          (this.tlp == rhs_.tlp) &&
          (this.dllp == rhs_.dllp) &&
          (this.pipe_width == rhs_.pipe_width) &&
          (this.pclk_rate == rhs_.pclk_rate) &&
          (this.ts_sent == rhs_.ts_sent) &&
          (this.tses_sent == rhs_.tses_sent));
endfunction:do_compare

function string pipe_seq_item::convert2string();
  return $sformatf("PIPE Sequence Item:\n\toperation:%s, width:%s, rate:%s,\n\ttlp[size=%0d]\n\tdllp[size=%0d]:%p\n",
                this.pipe_operation.name(),
                this.pipe_width.name(),
                this.pclk_rate.name(),
                this.tlp.size(),
                $size(this.dllp),
                this.dllp);
endfunction: convert2string

function void pipe_seq_item::do_print(uvm_printer printer);
  printer.m_string = this.convert2string();
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

function void pipe_seq_item::from_struct(pipe_seq_item_s src);
  this.pipe_operation = src.pipe_operation;
  this.tlp            = src.tlp;
  this.dllp           = src.dllp;
  this.pipe_width     = src.pipe_width;
  this.pclk_rate      = src.pclk_rate;
endfunction: from_struct
/*******************************************************************************************/