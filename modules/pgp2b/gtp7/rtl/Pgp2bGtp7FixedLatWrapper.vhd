-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Pgp2bGtp7FixedLatWrapper.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-01-29
-- Last update: 2016-08-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: PGP Wrapper
-------------------------------------------------------------------------------
-- This file is part of 'SLAC PGP2B Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC PGP2B Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.Pgp2bPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity Pgp2bGtp7FixedLatWrapper is
   generic (
      -- Select Master or Slave
      MASTER_SEL_G         : boolean              := true;
      RX_CLK_SEL_G         : boolean              := true;
      -- PGP Settings
      VC_INTERLEAVE_G      : integer              := 0;     -- No interleave Frames
      PAYLOAD_CNT_TOP_G    : integer              := 7;     -- Top bit for payload counter
      NUM_VC_EN_G          : integer range 1 to 4 := 4;
      AXI_ERROR_RESP_G     : slv(1 downto 0)      := AXI_RESP_DECERR_C;
      TX_ENABLE_G          : boolean              := true;  -- Enable TX direction
      RX_ENABLE_G          : boolean              := true;  -- Enable RX direction
      -- Quad PLL Configurations
      QPLL_FBDIV_IN_G      : integer range 1 to 5 := 4;
      QPLL_FBDIV_45_IN_G   : integer range 4 to 5 := 5;
      QPLL_REFCLK_DIV_IN_G : integer range 1 to 2 := 1;
      -- MMCM Configurations
      MMCM_CLKIN_PERIOD_G  : real                 := 8.000;
      MMCM_CLKFBOUT_MULT_G : real                 := 8.000;
      MMCM_GTCLK_DIVIDE_G  : real                 := 8.000;
      MMCM_TXCLK_DIVIDE_G  : natural              := 8;
      -- MGT Configurations
      RXOUT_DIV_G          : integer              := 2;
      TXOUT_DIV_G          : integer              := 2;
      RX_CLK25_DIV_G       : integer              := 5;     -- Set by wizard
      TX_CLK25_DIV_G       : integer              := 5;     -- Set by wizard
      PMA_RSV_G            : bit_vector           := x"00000333";               -- Set by wizard
      RX_OS_CFG_G          : bit_vector           := "0001111110000";           -- Set by wizard
      RXCDR_CFG_G          : bit_vector           := x"0000107FE206001041010";  -- Set by wizard
      RXLPM_INCM_CFG_G     : bit                  := '1';   -- Set by wizard
      RXLPM_IPCM_CFG_G     : bit                  := '0';   -- Set by wizard
      TX_PLL_G             : string               := "PLL0";
      RX_PLL_G             : string               := "PLL1");
   port (
      -- Manual Reset
      extRst           : in  sl;
      -- Status and Clock Signals
      txPllLock        : out sl;
      rxPllLock        : out sl;
      txClk            : out sl;
      rxClk            : out sl;
      stableClk        : out sl;
      -- Non VC Rx Signals
      pgpRxIn          : in  Pgp2bRxInType;
      pgpRxOut         : out Pgp2bRxOutType;
      -- Non VC Tx Signals
      pgpTxIn          : in  Pgp2bTxInType;
      pgpTxOut         : out Pgp2bTxOutType;
      -- Frame Transmit Interface - 1 Lane, Array of 4 VCs
      pgpTxMasters     : in  AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      pgpTxSlaves      : out AxiStreamSlaveArray(3 downto 0);
      -- Frame Receive Interface - 1 Lane, Array of 4 VCs
      pgpRxMasters     : out AxiStreamMasterArray(3 downto 0);
      pgpRxMasterMuxed : out AxiStreamMasterType;
      pgpRxCtrl        : in  AxiStreamCtrlArray(3 downto 0);
      -- GT Pins
      gtClkP           : in  sl;
      gtClkN           : in  sl;
      gtTxP            : out sl;
      gtTxN            : out sl;
      gtRxP            : in  sl;
      gtRxN            : in  sl;
      -- Debug Interface 
      txPreCursor      : in  slv(4 downto 0)                  := (others => '0');
      txPostCursor     : in  slv(4 downto 0)                  := (others => '0');
      txDiffCtrl       : in  slv(3 downto 0)                  := "1000";
      -- AXI-Lite Interface 
      axilClk          : in  sl                               := '0';
      axilRst          : in  sl                               := '0';
      axilReadMaster   : in  AxiLiteReadMasterType            := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType           := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave   : out AxiLiteWriteSlaveType);      

end Pgp2bGtp7FixedLatWrapper;

architecture rtl of Pgp2bGtp7FixedLatWrapper is

   signal gtClk,
      gtClkDiv2,
      clkin1,
      stableClock,
      stableRst,
      locked,
      clkOut0,
      clkOut1,
      clkFbIn,
      clkFbOut,
      txClock,
      txRst,
      rxClock,
      rxRecClk : sl := '0';
   signal pllRefClk,
      qPllOutClk,
      qPllOutRefClk,
      qPllLock,
      pllLockDetClk,
      qPllRefClkLost,
      qPllReset,
      gtQPllReset : slv(1 downto 0);
   
   attribute KEEP_HIERARCHY : string;
   attribute KEEP_HIERARCHY of
      PwrUpRst_Inst,
      Quad_Pll_Inst,
      Pgp2bGtp7Fixedlat_Inst : label is "TRUE";
   
begin

   -- Set the status outputs
   txPllLock <= ite((TX_PLL_G = "PLL0"), qPllLock(0), qPllLock(1));
   rxPllLock <= ite((RX_PLL_G = "PLL0"), qPllLock(0), qPllLock(1));
   txClk     <= txClock;
   rxClk     <= rxClock;
   stableClk <= stableClock;

   -- GT Reference Clock
   IBUFDS_GTE2_Inst : IBUFDS_GTE2
      port map (
         I     => gtClkP,
         IB    => gtClkN,
         CEB   => '0',
         ODIV2 => gtClkDiv2,
         O     => open);

   BUFH_0 : BUFH
      port map (
         I => gtClkDiv2,
         O => stableClock);

   -- Power Up Reset      
   PwrUpRst_Inst : entity work.PwrUpRst
      port map (
         arst   => extRst,
         clk    => stableClock,
         rstOut => stableRst);

   clkin1 <= ite(MASTER_SEL_G, stableClock, rxClock);
   mmcm_adv_inst : MMCME2_ADV
      generic map(
         BANDWIDTH            => "LOW",
         CLKOUT4_CASCADE      => false,
         COMPENSATION         => "ZHOLD",
         STARTUP_WAIT         => false,
         DIVCLK_DIVIDE        => 1,
         CLKFBOUT_MULT_F      => MMCM_CLKFBOUT_MULT_G,
         CLKFBOUT_PHASE       => 0.000,
         CLKFBOUT_USE_FINE_PS => false,
         CLKOUT0_DIVIDE_F     => MMCM_GTCLK_DIVIDE_G,
         CLKOUT0_PHASE        => 0.000,
         CLKOUT0_DUTY_CYCLE   => 0.500,
         CLKOUT0_USE_FINE_PS  => false,
         CLKOUT1_DIVIDE       => MMCM_TXCLK_DIVIDE_G,
         CLKOUT1_PHASE        => 0.000,
         CLKOUT1_DUTY_CYCLE   => 0.500,
         CLKOUT1_USE_FINE_PS  => false,
         CLKIN1_PERIOD        => MMCM_CLKIN_PERIOD_G,
         REF_JITTER1          => 0.006)
      port map(
         -- Output clocks
         CLKFBOUT     => clkFbOut,
         CLKFBOUTB    => open,
         CLKOUT0      => clkOut0,
         CLKOUT0B     => open,
         CLKOUT1      => clkOut1,
         CLKOUT1B     => open,
         CLKOUT2      => open,
         CLKOUT2B     => open,
         CLKOUT3      => open,
         CLKOUT3B     => open,
         CLKOUT4      => open,
         CLKOUT5      => open,
         CLKOUT6      => open,
         -- Input clock control
         CLKFBIN      => clkFbIn,
         CLKIN1       => clkin1,
         CLKIN2       => '0',
         -- Tied to always select the primary input clock
         CLKINSEL     => '1',
         -- Ports for dynamic reconfiguration
         DADDR        => (others => '0'),
         DCLK         => '0',
         DEN          => '0',
         DI           => (others => '0'),
         DO           => open,
         DRDY         => open,
         DWE          => '0',
         -- Ports for dynamic phase shift
         PSCLK        => '0',
         PSEN         => '0',
         PSINCDEC     => '0',
         PSDONE       => open,
         -- Other control and status signals
         LOCKED       => locked,
         CLKINSTOPPED => open,
         CLKFBSTOPPED => open,
         PWRDWN       => '0',
         RST          => stableRst);         

   BUFH_1 : BUFH
      port map (
         I => clkFbOut,
         O => clkFbIn); 

   BUFG_2 : BUFG
      port map (
         I => clkOut0,
         O => gtClk); 

   BUFG_3 : BUFG
      port map (
         I => clkOut1,
         O => txClock);          

   txRst <= stableRst;

   -- PLL0 Port Mapping
   pllRefClk(0)     <= gtClk when((MASTER_SEL_G = true) or (TX_PLL_G = "PLL0")) else stableClock;
   pllLockDetClk(0) <= stableClock;
   qPllReset(0)     <= stableRst or gtQPllReset(0);

   -- PLL1 Port Mapping
   pllRefClk(1)     <= gtClk    when((MASTER_SEL_G = true) or (TX_PLL_G = "PLL1")) else stableClock;
   pllLockDetClk(1) <= stableClock;
   qPllReset(1)     <= stableRst or gtQPllReset(1);
   rxClock          <= rxRecClk when(RX_CLK_SEL_G = true)                          else txClock;

   Quad_Pll_Inst : entity work.Gtp7QuadPll
      generic map (
         PLL0_REFCLK_SEL_G    => "111",
         PLL0_FBDIV_IN_G      => QPLL_FBDIV_IN_G,
         PLL0_FBDIV_45_IN_G   => QPLL_FBDIV_45_IN_G,
         PLL0_REFCLK_DIV_IN_G => QPLL_REFCLK_DIV_IN_G,
         PLL1_REFCLK_SEL_G    => "111",
         PLL1_FBDIV_IN_G      => QPLL_FBDIV_IN_G,
         PLL1_FBDIV_45_IN_G   => QPLL_FBDIV_45_IN_G,
         PLL1_REFCLK_DIV_IN_G => QPLL_REFCLK_DIV_IN_G)         
      port map (
         qPllRefClk     => pllRefClk,
         qPllOutClk     => qPllOutClk,
         qPllOutRefClk  => qPllOutRefClk,
         qPllLock       => qPllLock,
         qPllLockDetClk => pllLockDetClk,
         qPllRefClkLost => qPllRefClkLost,
         qPllReset      => qPllReset);                

   Pgp2bGtp7Fixedlat_Inst : entity work.Pgp2bGtp7FixedLat
      generic map (
         VC_INTERLEAVE_G       => VC_INTERLEAVE_G,
         PAYLOAD_CNT_TOP_G     => PAYLOAD_CNT_TOP_G,
         NUM_VC_EN_G           => NUM_VC_EN_G,
         AXI_ERROR_RESP_G      => AXI_ERROR_RESP_G,
         TX_ENABLE_G           => TX_ENABLE_G,
         RX_ENABLE_G           => RX_ENABLE_G,
         STABLE_CLOCK_PERIOD_G => 4.0E-9,  --set for longest timeout 
         RXOUT_DIV_G           => RXOUT_DIV_G,
         TXOUT_DIV_G           => TXOUT_DIV_G,
         RX_CLK25_DIV_G        => RX_CLK25_DIV_G,
         TX_CLK25_DIV_G        => TX_CLK25_DIV_G,
         RX_OS_CFG_G           => RX_OS_CFG_G,
         RXCDR_CFG_G           => RXCDR_CFG_G,
         RXLPM_INCM_CFG_G      => RXLPM_INCM_CFG_G,
         RXLPM_IPCM_CFG_G      => RXLPM_IPCM_CFG_G,
         TX_PLL_G              => TX_PLL_G,
         RX_PLL_G              => RX_PLL_G)
      port map (
         -- GT Clocking
         stableClk        => stableClock,
         gtQPllOutRefClk  => qPllOutRefClk,
         gtQPllOutClk     => qPllOutClk,
         gtQPllLock       => qPllLock,
         gtQPllRefClkLost => qPllRefClkLost,
         gtQPllReset      => gtQPllReset,
         gtRxRefClkBufg   => stableClock,
         -- Gt Serial IO
         gtTxP            => gtTxP,
         gtTxN            => gtTxN,
         gtRxP            => gtRxP,
         gtRxN            => gtRxN,
         -- Tx Clocking
         pgpTxReset       => txRst,
         pgpTxClk         => txClock,
         -- Rx clocking
         pgpRxReset       => extRst,
         pgpRxRecClk      => rxRecClk,
         pgpRxClk         => rxClock,
         pgpRxMmcmReset   => open,
         pgpRxMmcmLocked  => locked,
         -- Non VC Rx Signals
         pgpRxIn          => pgpRxIn,
         pgpRxOut         => pgpRxOut,
         -- Non VC Tx Signals
         pgpTxIn          => pgpTxIn,
         pgpTxOut         => pgpTxOut,
         -- Frame Transmit Interface - 1 Lane, Array of 4 VCs
         pgpTxMasters     => pgpTxMasters,
         pgpTxSlaves      => pgpTxSlaves,
         -- Frame Receive Interface - 1 Lane, Array of 4 VCs
         pgpRxMasters     => pgpRxMasters,
         pgpRxMasterMuxed => pgpRxMasterMuxed,
         pgpRxCtrl        => pgpRxCtrl,
         -- Debug Interface 
         txPreCursor      => txPreCursor,
         txPostCursor     => txPostCursor,
         txDiffCtrl       => txDiffCtrl,
         -- AXI-Lite Interface 
         axilClk          => axilClk,
         axilRst          => axilRst,
         axilReadMaster   => axilReadMaster,
         axilReadSlave    => axilReadSlave,
         axilWriteMaster  => axilWriteMaster,
         axilWriteSlave   => axilWriteSlave);        
end rtl;
