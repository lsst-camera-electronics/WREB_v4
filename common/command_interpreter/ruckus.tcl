# Load RUCKUS library
source $::env(RUCKUS_PROC_TCL)

# Load Source Code
loadSource -lib common -path "$::DIR_PATH/rtl/WREB_v4_commands_package.vhd"
loadSource -lib common -path "$::DIR_PATH/rtl/WREB_v4_cmd_interpreter.vhd"

# Load Simulation
#loadSource -lib common -sim_only -dir "$::DIR_PATH/TB"
