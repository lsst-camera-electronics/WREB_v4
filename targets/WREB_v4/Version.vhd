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
library ieee;
use ieee.std_logic_1164.all;

package Version is
-------------------------------------------------------------------------------
-- Version History
-------------------------------------------------------------------------------
  -- 102c4000  Compiling WREB_v4 for DAQ v1

  constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"11394008";  -- MAKE_VERSION

  constant BUILD_STAMP_C : string := "WREB_v4: Vivado v2018.3 (x86_64) Built Wed Apr 26 09:17:39 PDT 2023 by jgt";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
-- 4000 first version
-- 4001 Sync commands 
-- 4002 silver cable gpio cottected to sequencer_out(16) and CCD security
-- 4003 solved a bug on ADC data handler that prevented the image transfer for
-- a specific clk sequence multiboot feature included
-- 4004 one wire interface rewritten, sync command and LAMs modules updated,
-- sequencer start add now is set from sync cmd, step now is also a sync cmd
-- 4005 look at me various fixes (masked at start and other errors). Now the
-- version shuld be identical to GREB 2007 and following 
-- 4006 Added STOP Synchronous command 0x30
--      Fixed bug that caused 160ns of 0 on output when entering default state
-- 4007 Added register START command that specifies MAIN
-- 4008 Added version number to bitfile
-------------------------------------------------------------------------------
