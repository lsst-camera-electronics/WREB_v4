# Load RUCKUS library
source $::env(RUCKUS_PROC_TCL)

# Load Source Code
loadSource -lib common -dir "$::DIR_PATH/rtl/"
loadConstraints        -path "$::DIR_PATH/rtl/WREB_v4_phys.xdc"
# Load specific timing constraints from tarket ruckus.tcl
# loadConstraints        -path "$::DIR_PATH/rtl/WREB_v4_time.xdc"
# loadConstraints        -path "$::DIR_PATH/rtl/WREB_v4_natural_time.xdc"
