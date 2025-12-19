# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/surf
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lsst_sci
loadRuckusTcl $::env(PROJ_DIR)/../../submodules/lsst_reb
loadRuckusTcl $::env(PROJ_DIR)/../../common

# Load local Source Code and constraints
loadSource      -path "$::DIR_PATH/hdl/WREB_v4_6p4ns.vhd"
loadConstraints -path $::env(PROJ_DIR)/../../common/wreb_v4_base/rtl/WREB_v4_natural_time.xdc
