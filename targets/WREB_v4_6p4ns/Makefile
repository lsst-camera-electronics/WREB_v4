# -------------------------------------------------------------------------------
# -- Revision History:
# -- 4000 first version
# -- 4001 Sync commands
# -- 4002 silver cable gpio cottected to sequencer_out(16) and CCD security
# -- 4003 solved a bug on ADC data handler that prevented the image transfer for
# -- a specific clk sequence multiboot feature included
# -- 4004 one wire interface rewritten, sync command and LAMs modules updated,
# -- sequencer start add now is set from sync cmd, step now is also a sync cmd
# -- 4005 look at me various fixes (masked at start and other errors). Now the
# -- version shuld be identical to GREB 2007 and following
# -- 4006 Added STOP Synchronous command 0x30
# --      Fixed bug that caused 160ns of 0 on output when entering default state
# -- 4007 Added register START command that specifies MAIN
# -- 4008 Added version number to bitfile
# -- 4009 Added readback of sensor bias thresholds
# -- 400A Version that fixes reset to not cause CCS to power down sensors or open bias switch.
# -- 400B Nominally same as version 400A, but refactored to use new build system and modern Vivado
# -- 400C Update to support 6.4ns and 10ns system clocks
# -- 400D Fixed bug in ASPIC SPI connection
# -------------------------------------------------------------------------------

# Define Firmware Version Number
export PRJ_VERSION = 0x113B400D

export GIT_BYPASS=0
export OVERRIDE_SUBMODULE_LOCKS=0

export GEN_BIT_IMAGE=0
export GEN_BIT_IMAGE_GZIP=1
export GEN_MCS_IMAGE=0
export GEN_MCS_IMAGE_GZIP=0
export GEN_MULTIBOOT_IMAGE=0
export GEN_MULTIBOOT_IMAGE_GZIP=1

# Define target output
target: prom

# Define target part
export PRJ_PART = XC7K160TFFG676-1

# Use top level makefile
include ../../submodules/ruckus/system_vivado.mk

