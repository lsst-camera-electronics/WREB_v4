// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (lin64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Tue Nov  3 18:23:49 2015
// Host        : lpnws5166 running 64-bit Scientific Linux release 6.7 (Carbon)
// Command     : write_verilog -force -mode synth_stub
//               /home/srusso/Xilinx_prj/LSST_prj/DREB_prj/REB_v3_vivado_15_2/REB_v3_vivado_15_2/REB_v3_vivado_15_2.srcs/sources_1/ip/dual_port_ram_10_4/dual_port_ram_10_4_stub.v
// Design      : dual_port_ram_10_4
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tffg676-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0,Vivado 2015.2" *)
module dual_port_ram_10_4(a, d, dpra, clk, we, spo, dpo)
/* synthesis syn_black_box black_box_pad_pin="a[3:0],d[9:0],dpra[3:0],clk,we,spo[9:0],dpo[9:0]" */;
  input [3:0]a;
  input [9:0]d;
  input [3:0]dpra;
  input clk;
  input we;
  output [9:0]spo;
  output [9:0]dpo;
endmodule
