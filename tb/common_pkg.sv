package common_pkg;

  // TLP and DLLP definitions
  typedef bit [7:0] dllp_t [0:5];
  typedef bit [7:0] tlp_t [];

  // TLP and DLLP definitions
  const longint unsigned TLP_MIN_SIZE = 12;
  const longint unsigned TLP_MAX_SIZE = 400;
  bit IS_ENV_UPSTREAM;

endpackage: common_pkg
