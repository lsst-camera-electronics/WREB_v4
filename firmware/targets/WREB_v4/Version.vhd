-------------------------------------------------------------------------------
-- Title         : Version File
-- Project       : 
-------------------------------------------------------------------------------
-- File          : 
-- Author        : 
-- Created       : 
-------------------------------------------------------------------------------
-- Description:
-- Version Constant Module.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by SLAC National Accelerator Laboratory. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is
-------------------------------------------------------------------------------
-- Version History
-------------------------------------------------------------------------------
  -- 102c4000  Compiling WREB_v4 for DAQ v1

  constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"11384003"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "WREB_v4: Vivado v2015.3 (x86_64) Built Thu Oct 24 13:59:10 PDT 2019 by srusso";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 4000 first version
-- 4001 Sync commands 
-- 4002 silver cable gpio cottected to sequencer_out(16) and CCD security
-- 4003 solved a bug on ADC data handler that prevented the image transfer for
-- a specific clk sequence multiboot feature included
-------------------------------------------------------------------------------
