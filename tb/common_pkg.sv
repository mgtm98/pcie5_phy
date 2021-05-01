`include "settings.svh"
`include "uvm_macros.svh"
package common_pkg;

  // TLP and DLLP definitions
  typedef bit [7:0] dllp_t [0:5];
  typedef bit [7:0] tlp_t [];

  typedef enum{
	  GEN1,
	  GEN2,
	  GEN3,
	  GEN4,
	  GEN5
	} gen_t;

endpackage: common_pkg
