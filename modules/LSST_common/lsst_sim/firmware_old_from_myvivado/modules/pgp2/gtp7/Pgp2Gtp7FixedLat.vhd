-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : Pgp2Gtp7Fixedlat.vhd
-- Author     : Benjamin Reese  <bareese@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-06-29
-- Last update: 2014-06-04
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Gtp7 Wrapper
--
-- Dependencies:  ^/pgp2_core/trunk/rtl/core/Pgp2RxWrapper.vhd
--                ^/pgp2_core/trunk/rtl/core/Pgp2TxWrapper.vhd
--                ^/StdLib/trunk/rtl/CRC32Rtl.vhd
--                ^/MgtLib/trunk/rtl/gtp7/Gtp7Core.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2013 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.Pgp2CoreTypesPkg.all;
use work.StdRtlPkg.all;
use work.VcPkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity Pgp2Gtp7Fixedlat is
   generic (
      TPD_G : time := 1 ns;

      ----------------------------------------------------------------------------------------------
      -- GT Settings
      ----------------------------------------------------------------------------------------------
      -- Sim Generics --
      SIM_GTRESET_SPEEDUP_G : string     := "FALSE";
      SIM_VERSION_G         : string     := "1.0";
      SIMULATION_G          : boolean    := false;
      STABLE_CLOCK_PERIOD_G : real       := 4.0E-9;                    --units of seconds
      -- TX/RX Settings - Defaults to 2.5 Gbps operation 
      RXOUT_DIV_G           : integer    := 2;
      TXOUT_DIV_G           : integer    := 2;
      RX_CLK25_DIV_G        : integer    := 5;                         -- Set by wizard
      TX_CLK25_DIV_G        : integer    := 5;                         -- Set by wizard
      PMA_RSV_G             : bit_vector := x"00000333";               -- Set by wizard
      RX_OS_CFG_G           : bit_vector := "0001111110000";           -- Set by wizard
      RXCDR_CFG_G           : bit_vector := x"0000107FE206001041010";  -- Set by wizard
      RXLPM_INCM_CFG_G      : bit        := '1';                       -- Set by wizard
      RXLPM_IPCM_CFG_G      : bit        := '0';                       -- Set by wizard      

      -- Configure PLL sources
      TX_PLL_G : string := "PLL0";
      RX_PLL_G : string := "PLL1";

      ----------------------------------------------------------------------------------------------
      -- PGP Settings
      ----------------------------------------------------------------------------------------------
      EnShortCells : integer              := 1;        -- Enable short non-EOF cells
      VcInterleave : integer              := 1;        -- Interleave Frames
      NUM_VC_EN_G  : integer range 1 to 4 := 4
      );
   port (
      -- GT Clocking
      stableClk        : in  sl;        -- GT needs a stable clock to "boot up"
      gtQPllOutRefClk  : in  slv(1 downto 0) := "00";  -- Signals from QPLLs
      gtQPllOutClk     : in  slv(1 downto 0) := "00";
      gtQPllLock       : in  slv(1 downto 0) := "00";
      gtQPllRefClkLost : in  slv(1 downto 0) := "00";
      gtQPllReset      : out slv(1 downto 0);
      gtRxRefClkBufg   : in  sl;        -- gtrefclk driving rx side, fed through clock buffer

      -- Gt Serial IO
      gtRxN : in  sl;                   -- GT Serial Receive Negative
      gtRxP : in  sl;                   -- GT Serial Receive Positive
      gtTxN : out sl;                   -- GT Serial Transmit Negative
      gtTxP : out sl;                   -- GT Serial Transmit Positive

      -- Tx Clocking
      pgpTxReset : in sl;
      pgpTxClk   : in sl;

      -- Rx clocking
      pgpRxReset      : in  sl;
      pgpRxRecClk     : out sl;         -- rxrecclk basically
      pgpRxRecClkRst  : out sl;         -- Reset for recovered clock
      pgpRxClk        : in  sl;         -- Run recClk through external MMCM and sent to this input
      pgpRxMmcmReset  : out sl;
      pgpRxMmcmLocked : in  sl := '1';

      -- Non VC Rx Signals
      pgpRxIn  : in  PgpRxInType;
      pgpRxOut : out PgpRxOutType;

      -- Non VC Tx Signals
      pgpTxIn  : in  PgpTxInType;
      pgpTxOut : out PgpTxOutType;

      -- Frame Transmit Interface - 1 Lane, Array of 4 VCs
      pgpVcTxQuadIn  : in  VcTxQuadInType;
      pgpVcTxQuadOut : out VcTxQuadOutType;

      -- Frame Receive Interface - 1 Lane, Array of 4 VCs
      pgpVcRxCommonOut : out VcRxCommonOutType;
      pgpVcRxQuadOut   : out VcRxQuadOutType;

      -- GT loopback control
      loopback : in slv(2 downto 0));   -- GT Serial Loopback Control

end Pgp2Gtp7Fixedlat;


-- Define architecture
architecture rtl of Pgp2Gtp7Fixedlat is

   --------------------------------------------------------------------------------------------------
   -- Rx Signals
   --------------------------------------------------------------------------------------------------
   -- Rx Clocks

   -- Rx Resets
   signal gtRxResetDone  : sl;
   signal gtRxResetDoneL : sl;
--   signal gtRxUserReset  : sl;

   -- PgpRx Signals
   signal gtRxData      : slv(19 downto 0);              -- Feed to 8B10B decoder
   signal dataValid     : sl;                            -- no decode or disparity errors
   signal phyRxLanesIn  : PgpRxPhyLaneInArray(0 to 0);   -- Output from decoder
   signal phyRxLanesOut : PgpRxPhyLaneOutArray(0 to 0);  -- Polarity to GT
--   signal phyRxReady    : sl;                            -- To RxRst
--   signal phyRxInit     : sl;                            -- To RxRst
   signal crcRxIn       : PgpCrcInType;
   signal crcRxOut      : slv(31 downto 0);

   -- CRC Rx IO (PgpRxPhy CRC IO must be adapted to V5 GT CRCs)
   signal crcRxWidthGtp7 : slv(2 downto 0);
   signal crcRxRstGtp7   : sl;
   signal crcRxInGtp7    : slv(31 downto 0);
   signal crcRxOutGtp7   : slv(31 downto 0);

   --------------------------------------------------------------------------------------------------
   -- Tx Signals
   --------------------------------------------------------------------------------------------------
   signal gtTxOutClk : sl;
   signal gtTxUsrClk : sl;

   signal gtTxResetDone : sl;

   -- PgpTx Signals
   signal phyTxLanesOut : PgpTxPhyLaneOutArray(0 to 0);
--   signal phyTxReady    : sl;
   signal crcTxIn       : PgpCrcInType;
   signal crcTxOut      : slv(31 downto 0);

   -- CRC Tx IO (PgpTxPhy CRC IO must be adapted to K7 GT CRCs)
   signal crcTxWidthGtp7 : slv(2 downto 0);
   signal crcTxRstGtp7   : sl;
   signal crcTxInGtp7    : slv(31 downto 0);
   signal crcTxOutGtp7   : slv(31 downto 0);

begin

   --------------------------------------------------------------------------------------------------
   -- Rx Data Path
   -- Hold Decoder and PgpRx in reset until GtRxResetDone.
   --------------------------------------------------------------------------------------------------
   gtRxResetDoneL <= not gtRxResetDone;
   Decoder8b10b_1 : entity work.Decoder8b10b
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '0',         --active low polarity
         NUM_BYTES_G    => 2)
      port map (
         clk      => pgpRxClk,
         rst      => gtRxResetDone,
         dataIn   => gtRxData,
         dataOut  => phyRxLanesIn(0).data,
         dataKOut => phyRxLanesIn(0).dataK,
         codeErr  => phyRxLanesIn(0).decErr,
         dispErr  => phyRxLanesIn(0).dispErr);

   dataValid <= not (uOr(phyRxLanesIn(0).decErr) or uOr(phyRxLanesIn(0).dispErr));


   -- PGP RX Block
   Pgp2RxWrapper_1 : entity work.Pgp2RxWrapper
      generic map (
         RxLaneCnt    => 1,
         EnShortCells => EnShortCells)
      port map (
         pgpRxClk         => pgpRxClk,
         pgpRxReset       => gtRxResetDoneL,  -- Hold in reset until gtp rx is up
         pgpRxIn          => pgpRxIn,
         pgpRxOut         => pgpRxOut,
         pgpVcRxCommonOut => pgpVcRxCommonOut,
         pgpVcRxQuadOut   => pgpVcRxQuadOut,
         phyRxLanesOut    => phyRxLanesOut,
         phyRxLanesIn     => phyRxLanesIn,
         phyRxReady       => gtRxResetDone,
         phyRxInit        => open,  --gtRxUserReset,        -- Ignore phyRxInit, rx will reset on its own
         crcRxIn          => crcRxIn,
         crcRxOut         => crcRxOut,
         debug            => open);

   -- RX CRC BLock
   -- Must adapt generic CRC type to GTP7 CRC block
   crcRxWidthGtp7            <= "001";
   crcRxRstGtp7              <= pgpRxReset or crcRxIn.init or not gtRxResetDone;
   crcRxInGtp7(31 downto 24) <= crcRxIn.crcIn(7 downto 0);
   crcRxInGtp7(23 downto 16) <= crcRxIn.crcIn(15 downto 8);
   crcRxInGtp7(15 downto 0)  <= (others => '0');
   crcRxOut                  <= not crcRxOutGtp7;  -- Invert Output CRC

   Rx_CRC : entity work.CRC32Rtl
      generic map(
         CRC_INIT => x"FFFFFFFF")
      port map(
         CRCOUT       => crcRxOutGtp7,
         CRCCLK       => pgpRxClk,
         CRCDATAVALID => crcRxIn.valid,
         CRCDATAWIDTH => crcRxWidthGtp7,
         CRCIN        => crcRxInGtp7,
         CRCRESET     => crcRxRstGtp7
         );

   pgpRxRecClkRst <= gtRxResetDoneL;

   --------------------------------------------------------------------------------------------------
   -- Tx Data Path
   --------------------------------------------------------------------------------------------------

   Pgp2TxWrapper_1 : entity work.Pgp2TxWrapper
      generic map (
         TxLaneCnt    => 1,
         VcInterleave => VcInterleave,
         NUM_VC_EN_G  => NUM_VC_EN_G)
      port map (
         pgpTxClk       => pgpTxClk,
         pgpTxReset     => pgpTxReset,
         pgpTxIn        => pgpTxIn,
         pgpTxOut       => pgpTxOut,
         pgpVcTxQuadIn  => pgpVcTxQuadIn,
         pgpVcTxQuadOut => pgpVcTxQuadOut,
         phyTxLanesOut  => phyTxLanesOut,
         phyTxReady     => gtTxResetDone,  --phyTxReady,  -- Use txResetDone
         crcTxIn        => crcTxIn,
         crcTxOut       => crcTxOut,
         debug          => open);

   -- Adapt CRC data width flag
   crcTxWidthGtp7            <= "001";
   crcTxRstGtp7              <= pgpTxReset or crcTxIn.init;
   -- Pass CRC data in on proper bits
   crcTxInGtp7(31 downto 24) <= crcTxIn.crcIn(7 downto 0);
   crcTxInGtp7(23 downto 16) <= crcTxIn.crcIn(15 downto 8);
   crcTxInGtp7(15 downto 0)  <= (others => '0');
   crcTxOut                  <= not crcTxOutGtp7;

   -- TX CRC BLock
   Tx_CRC : entity work.CRC32Rtl
      generic map(
         CRC_INIT => x"FFFFFFFF")
      port map(
         CRCOUT       => crcTxOutGtp7,
         CRCCLK       => pgpTxClk,
         CRCDATAVALID => crcTxIn.valid,
         CRCDATAWIDTH => crcTxWidthGtp7,
         CRCIN        => crcTxInGtp7,
         CRCRESET     => crcTxRstGtp7
         );

   -- Wrap txOutClk back to TxUsrClk to get sim to lock the alignment
--   TX_USR_CLK_BUFG : BUFG
--      port map (
--         I => gtTxOutClk,
--         O => gtTxUsrClk);
   gtTxUsrClk <= pgpTxClk;

   --------------------------------------------------------------------------------------------------
   -- GTP 7 Core in Fixed Latency mode
   --------------------------------------------------------------------------------------------------
   Gtp7Core_1 : entity work.Gtp7Core
      generic map (
         TPD_G                 => TPD_G,
         SIM_GTRESET_SPEEDUP_G => SIM_GTRESET_SPEEDUP_G,
         SIM_VERSION_G         => SIM_VERSION_G,
         SIMULATION_G          => SIMULATION_G,
         STABLE_CLOCK_PERIOD_G => STABLE_CLOCK_PERIOD_G,
         RXOUT_DIV_G           => RXOUT_DIV_G,
         TXOUT_DIV_G           => TXOUT_DIV_G,
         RX_CLK25_DIV_G        => RX_CLK25_DIV_G,
         TX_CLK25_DIV_G        => TX_CLK25_DIV_G,
         PMA_RSV_G             => PMA_RSV_G,
         RX_OS_CFG_G           => RX_OS_CFG_G,
         RXCDR_CFG_G           => RXCDR_CFG_G,
         RXLPM_INCM_CFG_G      => RXLPM_INCM_CFG_G,
         RXLPM_IPCM_CFG_G      => RXLPM_IPCM_CFG_G,
         TX_PLL_G              => TX_PLL_G,
         RX_PLL_G              => RX_PLL_G,
         TX_EXT_DATA_WIDTH_G   => 16,
         TX_INT_DATA_WIDTH_G   => 20,
         TX_8B10B_EN_G         => true,
         RX_EXT_DATA_WIDTH_G   => 20,
         RX_INT_DATA_WIDTH_G   => 20,
         RX_8B10B_EN_G         => false,
         TX_BUF_EN_G           => false,
         TX_OUTCLK_SRC_G       => "PLLREFCLK",
         TX_DLY_BYPASS_G       => '0',
         TX_PHASE_ALIGN_G      => "MANUAL",
         RX_BUF_EN_G           => false,
         RX_OUTCLK_SRC_G       => "OUTCLKPMA",
         RX_USRCLK_SRC_G       => "RXOUTCLK",
         RX_DLY_BYPASS_G       => '1',
         RX_DDIEN_G            => '0',
         RX_ALIGN_MODE_G       => "FIXED_LAT",
--         ALIGN_COMMA_DOUBLE_G   => ALIGN_COMMA_DOUBLE_G,
--         ALIGN_COMMA_ENABLE_G   => ALIGN_COMMA_ENABLE_G,
--         ALIGN_COMMA_WORD_G     => ALIGN_COMMA_WORD_G,
--         ALIGN_MCOMMA_DET_G     => ALIGN_MCOMMA_DET_G,
--         ALIGN_MCOMMA_VALUE_G   => ALIGN_MCOMMA_VALUE_G,
--         ALIGN_MCOMMA_EN_G      => ALIGN_MCOMMA_EN_G,
--         ALIGN_PCOMMA_DET_G     => ALIGN_PCOMMA_DET_G,
--         ALIGN_PCOMMA_VALUE_G   => ALIGN_PCOMMA_VALUE_G,
--         ALIGN_PCOMMA_EN_G      => ALIGN_PCOMMA_EN_G,
--         SHOW_REALIGN_COMMA_G   => SHOW_REALIGN_COMMA_G,
         RXSLIDE_MODE_G        => "PMA",
         FIXED_ALIGN_COMMA_0_G => "----------0101111100",  -- Normal Comma
         FIXED_ALIGN_COMMA_1_G => "----------1010000011",  -- Inverted Comma
         FIXED_ALIGN_COMMA_2_G => "XXXXXXXXXXXXXXXXXXXX",  -- Unused
         FIXED_ALIGN_COMMA_3_G => "XXXXXXXXXXXXXXXXXXXX"   -- Unused
--         RX_DISPERR_SEQ_MATCH_G => RX_DISPERR_SEQ_MATCH_G,
--         DEC_MCOMMA_DETECT_G    => DEC_MCOMMA_DETECT_G,
--         DEC_PCOMMA_DETECT_G    => DEC_PCOMMA_DETECT_G,
--         DEC_VALID_COMMA_ONLY_G => DEC_VALID_COMMA_ONLY_G
         )
      port map (
         stableClkIn      => stableClk,
         qPllRefClkIn     => gtQPllOutRefClk,
         qPllClkIn        => gtQPllOutClk,
         qPllLockIn       => gtQPllLock,
         qPllRefClkLostIn => gtQPllRefClkLost,
         qPllResetOut     => gtQPllReset,
         gtRxRefClkBufg   => gtRxRefClkBufg,
         gtTxP            => gtTxP,
         gtTxN            => gtTxN,
         gtRxP            => gtRxP,
         gtRxN            => gtRxN,
         rxRefClkOut      => open,      -- Used for debugging only
         rxOutClkOut      => pgpRxRecClk,
         rxUsrClkIn       => pgpRxClk,
         rxUsrClk2In      => pgpRxClk,
         rxUserRdyOut     => open,      -- rx clock locked and stable, but alignment not yet done
         rxMmcmResetOut   => pgpRxMmcmReset,
         rxMmcmLockedIn   => pgpRxMmcmLocked,
         rxUserResetIn    => pgpRxReset,
         rxResetDoneOut   => gtRxResetDone,                -- Use for rxRecClkReset???
         rxDataValidIn    => dataValid,   -- From 8b10b
         rxSlideIn        => '0',       -- Slide is controlled internally
         rxDataOut        => gtRxData,
         rxCharIsKOut     => open,      -- Not using gt rx 8b10b
         rxDecErrOut      => open,      -- Not using gt rx 8b10b
         rxDispErrOut     => open,      -- Not using gt rx 8b10b
         rxPolarityIn     => phyRxLanesOut(0).polarity,
         rxBufStatusOut   => open,      -- Not using rx buff
         txRefClkOut      => open,      -- Used for debugging only
         txOutClkOut      => gtTxOutClk,  -- Maybe drive PGP TX with this and output it
         txOutClkPcsOut   => open,      -- For debugging only
         txUsrClkIn       => gtTxUsrClk,
         txUsrClk2In      => gtTxUsrClk,
         txUserRdyOut     => open,      -- Not sure what to do with this
         txMmcmResetOut   => open,      -- No Tx MMCM in Fixed Latency mode
         txMmcmLockedIn   => '1',
         txUserResetIn    => pgpTxReset,
         txResetDoneOut   => gtTxResetDone,
         txDataIn         => phyTxLanesOut(0).data,
         txCharIsKIn      => phyTxLanesOut(0).dataK,
         txBufStatusOut   => open,      -- Not using tx buff
         loopbackIn       => loopback);

end rtl;

