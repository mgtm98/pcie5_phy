`include "settings.svh"

package common_pkg;

  // TLP and DLLP definitions
  typedef bit [7:0] dllp_t [0:5];
  typedef bit [7:0] tlp_t [];

  // Typedef of parameterized LPIF interfaces
  typedef lpif_if #(
    .lpif_bus_width(`LPIF_BUS_WIDTH)
  ) lpif_if_param;
  typedef lpif_driver_bfm #(
    .lpif_bus_width(`LPIF_BUS_WIDTH)
  ) lpif_driver_bfm_param;
  typedef lpif_monitor_bfm #(
    .lpif_bus_width(`LPIF_BUS_WIDTH)
  ) lpif_monitor_bfm_param;

  // Typedef of parameterized PIPE interfaces
  typedef pipe_if #(
    .pipe_num_of_lanes(`NUM_OF_LANES),
    .pipe_max_width(`PIPE_MAX_WIDTH)
  ) pipe_if_param;
  typedef pipe_driver_bfm #(
    .pipe_num_of_lanes(`NUM_OF_LANES),
    .pipe_max_width(`PIPE_MAX_WIDTH)
  ) pipe_driver_bfm_param;
  typedef pipe_monitor_bfm #(
    .pipe_num_of_lanes(`NUM_OF_LANES),
    .pipe_max_width(`PIPE_MAX_WIDTH)
  ) pipe_monitor_bfm_param;

endpackage: common_pkg
