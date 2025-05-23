-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Gtp7QuadPll.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-06-29
-- Last update: 2014-03-30
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.StdRtlPkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity Gtp7QuadPll is
   generic (
      TPD_G                : time                 := 1 ns;
      SIM_RESET_SPEEDUP_G  : string               := "TRUE";
      SIM_VERSION_G        : string               := "1.0";
      PLL0_REFCLK_SEL_G    : bit_vector           := "001";
      PLL0_FBDIV_IN_G      : integer range 1 to 5 := 4;
      PLL0_FBDIV_45_IN_G   : integer range 4 to 5 := 5;
      PLL0_REFCLK_DIV_IN_G : integer range 1 to 2 := 1;
      PLL1_REFCLK_SEL_G    : bit_vector           := "001";
      PLL1_FBDIV_IN_G      : integer range 1 to 5 := 4;
      PLL1_FBDIV_45_IN_G   : integer range 4 to 5 := 5;
      PLL1_REFCLK_DIV_IN_G : integer range 1 to 2 := 1);
   port (
      qPllRefClk     : in  slv(1 downto 0);
      qPllOutClk     : out slv(1 downto 0);
      qPllOutRefClk  : out slv(1 downto 0);
      qPllLock       : out slv(1 downto 0);
      qPllLockDetClk : in  slv(1 downto 0);  -- Lock detect clock
      qPllRefClkLost : out slv(1 downto 0);
      qPllPowerDown  : in  slv(1 downto 0) := (others => '0');
      qPllReset      : in  slv(1 downto 0));

end entity Gtp7QuadPll;

architecture rtl of Gtp7QuadPll is
   signal gtRefClk0     : sl;
   signal gtRefClk1     : sl;
   signal gtEastRefClk0 : sl;
   signal gtEastRefClk1 : sl;
   signal gtWestRefClk0 : sl;
   signal gtWestRefClk1 : sl;
   signal gtGRefClk0    : sl;
   signal gtGRefClk1    : sl;
begin
   --------------------------------------------------------------------------------------------------
   -- QPLL clock select. Only ever use 1 clock to drive qpll. Never switch clocks.
   --------------------------------------------------------------------------------------------------
   gtRefClk0     <= qpllRefClk(0) when (PLL0_REFCLK_SEL_G = "001") else qpllRefClk(1) when (PLL1_REFCLK_SEL_G = "001") else '0';
   gtRefClk1     <= qpllRefClk(0) when (PLL0_REFCLK_SEL_G = "010") else qpllRefClk(1) when (PLL1_REFCLK_SEL_G = "010") else '0';
   gtEastRefClk0 <= qpllRefClk(0) when (PLL0_REFCLK_SEL_G = "011") else qpllRefClk(1) when (PLL1_REFCLK_SEL_G = "011") else '0';
   gtEastRefClk1 <= qpllRefClk(0) when (PLL0_REFCLK_SEL_G = "100") else qpllRefClk(1) when (PLL1_REFCLK_SEL_G = "100") else '0';
   gtWestRefClk0 <= qpllRefClk(0) when (PLL0_REFCLK_SEL_G = "101") else qpllRefClk(1) when (PLL1_REFCLK_SEL_G = "101") else '0';
   gtWestRefClk1 <= qpllRefClk(0) when (PLL0_REFCLK_SEL_G = "110") else qpllRefClk(1) when (PLL1_REFCLK_SEL_G = "110") else '0';
   gtGRefClk0    <= qpllRefClk(0) when (PLL0_REFCLK_SEL_G = "111") else '0';
   gtGRefClk1    <= qpllRefClk(1) when (PLL1_REFCLK_SEL_G = "111") else '0';

   gtpe2_common_0_i : GTPE2_COMMON
      generic map(
         -- Simulation attributes
         SIM_RESET_SPEEDUP  => SIM_RESET_SPEEDUP_G,
         SIM_PLL0REFCLK_SEL => PLL0_REFCLK_SEL_G,
         SIM_PLL1REFCLK_SEL => PLL1_REFCLK_SEL_G,
         SIM_VERSION        => SIM_VERSION_G,
         -- COMMON BLOCK Attributes
         BIAS_CFG           => (x"0000000000050001"),
         COMMON_CFG         => (x"00000000"),
         RSVD_ATTR0         => (x"0000"),
         RSVD_ATTR1         => (x"0000"),
         -- PLL0 Attributes
         PLL0_FBDIV         => PLL0_FBDIV_IN_G,
         PLL0_FBDIV_45      => PLL0_FBDIV_45_IN_G,
         PLL0_REFCLK_DIV    => PLL0_REFCLK_DIV_IN_G,
         PLL0_CFG           => (x"01F03DC"),
         PLL0_DMON_CFG      => ('0'),
         PLL0_INIT_CFG      => (x"00001E"),
         PLL0_LOCK_CFG      => (x"1E8"),
         -- PLL1 Attributes
         PLL1_FBDIV         => PLL1_FBDIV_IN_G,
         PLL1_FBDIV_45      => PLL1_FBDIV_45_IN_G,
         PLL1_REFCLK_DIV    => PLL1_REFCLK_DIV_IN_G,
         PLL1_CFG           => (x"01F03DC"),
         PLL1_DMON_CFG      => ('0'),
         PLL1_INIT_CFG      => (x"00001E"),
         PLL1_LOCK_CFG      => (x"1E8"),
         PLL_CLKOUT_CFG     => (x"00"))
      port map(
         -- Dynamic Reconfiguration Port (DRP)
         DRPADDR           => (others => '0'),
         DRPCLK            => '0',
         DRPDI             => (others => '0'),
         DRPDO             => open,
         DRPEN             => '0',
         DRPRDY            => open,
         DRPWE             => '0',
         -- Clocking Ports 
         GTREFCLK0         => gtRefClk0,      --address="001" for both PLLs
         GTREFCLK1         => gtRefClk1,      --address="010" for both PLLs   
         GTEASTREFCLK0     => gtEastRefClk0,  --address="011" for both PLLs   
         GTEASTREFCLK1     => gtEastRefClk1,  --address="100" for both PLLs   
         GTWESTREFCLK0     => gtWestRefClk0,  --address="101" for both PLLs  
         GTWESTREFCLK1     => gtWestRefClk1,  --address="110" for both PLLs       
         GTGREFCLK0        => gtGRefClk0,     --address="111" for PLL0  
         GTGREFCLK1        => gtGRefClk1,     --address="111" for PLL1
         -- PLL0 Ports 
         PLL0OUTCLK        => qPllOutClk(0),
         PLL0OUTREFCLK     => qPllOutRefClk(0),
         PLL0FBCLKLOST     => open,
         PLL0LOCK          => qPllLock(0),
         PLL0LOCKDETCLK    => qPllLockDetClk(0),
         PLL0LOCKEN        => '1',
         PLL0PD            => qPllPowerDown(0),
         PLL0REFCLKLOST    => qPllRefClkLost(0),
         PLL0REFCLKSEL     => to_stdlogicvector(PLL0_REFCLK_SEL_G),
         PLL0RESET         => qPllReset(0),
         -- PLL1 Ports 
         PLL1OUTCLK        => qPllOutClk(1),
         PLL1OUTREFCLK     => qPllOutRefClk(1),
         PLL1FBCLKLOST     => open,
         PLL1LOCK          => qPllLock(1),
         PLL1LOCKDETCLK    => qPllLockDetClk(1),
         PLL1LOCKEN        => '1',
         PLL1PD            => qPllPowerDown(1),
         PLL1REFCLKLOST    => qPllRefClkLost(1),
         PLL1REFCLKSEL     => to_stdlogicvector(PLL1_REFCLK_SEL_G),
         PLL1RESET         => qPllReset(1),
         -- MISC Ports 
         DMONITOROUT       => open,
         BGRCALOVRDENB     => '1',
         PLLRSVD1          => "0000000000000000",
         PLLRSVD2          => "00000",
         REFCLKOUTMONITOR0 => open,
         REFCLKOUTMONITOR1 => open,
         -- RX AFE Ports -----------------------
         PMARSVDOUT        => open,
         -- QPLL Ports 
         BGBYPASSB         => '1',
         BGMONITORENB      => '1',
         BGPDB             => '1',
         BGRCALOVRD        => "00000",
         PMARSVD           => "00000000",
         RCALENB           => '1');         
end architecture rtl;
