-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.3 (lin64) Build 1368829 Mon Sep 28 20:06:39 MDT 2015
-- Date        : Wed Sep 21 14:25:04 2016
-- Host        : lsst-daq03 running 64-bit Red Hat Enterprise Linux Server release 6.8 (Santiago)
-- Command     : write_vhdl -force -mode synth_stub
--               /u1/srusso/Xilinx_prj/LSST_prj/DREB_prj/GREB_v1_daq_v1/firmware/modules/LSST_common/sequencer_v3/ipcore_vivado/ip/dual_port_ram_16_4/dual_port_ram_16_4_stub.vhdl
-- Design      : dual_port_ram_16_4
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k160tffg676-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dual_port_ram_16_4 is
  Port ( 
    a : in STD_LOGIC_VECTOR ( 3 downto 0 );
    d : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dpra : in STD_LOGIC_VECTOR ( 3 downto 0 );
    clk : in STD_LOGIC;
    we : in STD_LOGIC;
    spo : out STD_LOGIC_VECTOR ( 15 downto 0 );
    dpo : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );

end dual_port_ram_16_4;

architecture stub of dual_port_ram_16_4 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "a[3:0],d[15:0],dpra[3:0],clk,we,spo[15:0],dpo[15:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "dist_mem_gen_v8_0_9,Vivado 2015.3";
begin
end;
