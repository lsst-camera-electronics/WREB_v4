// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.2 (lin64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
// Date        : Wed Nov  4 17:32:35 2015
// Host        : lpnws5166 running 64-bit Scientific Linux release 6.7 (Carbon)
// Command     : write_verilog -force -mode funcsim
//               /home/srusso/Xilinx_prj/LSST_prj/DREB_prj/REB_v3_vivado_15_2/REB_v3_vivado_15_2/REB_v3_vivado_15_2.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0_funcsim.v
// Design      : xadc_wiz_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tffg676-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* core_generation_info = "xadc_wiz_0,xadc_wiz_v3_1,{component_name=xadc_wiz_0,enable_axi=false,enable_axi4stream=false,dclk_frequency=100,enable_busy=true,enable_convst=false,enable_convstclk=false,enable_dclk=true,enable_drp=true,enable_eoc=true,enable_eos=true,enable_vbram_alaram=true,enable_vccddro_alaram=false,enable_Vccint_Alaram=true,enable_Vccaux_alaram=trueenable_vccpaux_alaram=false,enable_vccpint_alaram=false,ot_alaram=true,user_temp_alaram=true,timing_mode=continuous,channel_averaging=None,sequencer_mode=on,startup_channel_selection=contineous_sequence}" *) 
(* NotValidForBitStream *)
module xadc_wiz_0
   (daddr_in,
    den_in,
    di_in,
    dwe_in,
    do_out,
    drdy_out,
    dclk_in,
    reset_in,
    busy_out,
    channel_out,
    eoc_out,
    eos_out,
    ot_out,
    vccaux_alarm_out,
    vccint_alarm_out,
    user_temp_alarm_out,
    vbram_alarm_out,
    alarm_out,
    vp_in,
    vn_in);
  input [6:0]daddr_in;
  input den_in;
  input [15:0]di_in;
  input dwe_in;
  output [15:0]do_out;
  output drdy_out;
  input dclk_in;
  input reset_in;
  output busy_out;
  output [4:0]channel_out;
  output eoc_out;
  output eos_out;
  output ot_out;
  output vccaux_alarm_out;
  output vccint_alarm_out;
  output user_temp_alarm_out;
  output vbram_alarm_out;
  output alarm_out;
  input vp_in;
  input vn_in;

  wire alarm_out;
  wire busy_out;
  wire [4:0]channel_out;
  wire [6:0]daddr_in;
  wire dclk_in;
  wire den_in;
  wire [15:0]di_in;
  wire [15:0]do_out;
  wire drdy_out;
  wire dwe_in;
  wire eoc_out;
  wire eos_out;
  wire ot_out;
  wire reset_in;
  wire user_temp_alarm_out;
  wire vbram_alarm_out;
  wire vccaux_alarm_out;
  wire vccint_alarm_out;
  wire vn_in;
  wire vp_in;
  wire NLW_U0_JTAGBUSY_UNCONNECTED;
  wire NLW_U0_JTAGLOCKED_UNCONNECTED;
  wire NLW_U0_JTAGMODIFIED_UNCONNECTED;
  wire [6:4]NLW_U0_ALM_UNCONNECTED;
  wire [4:0]NLW_U0_MUXADDR_UNCONNECTED;

  (* box_type = "PRIMITIVE" *) 
  XADC #(
    .INIT_40(16'h0000),
    .INIT_41(16'h2000),
    .INIT_42(16'h0400),
    .INIT_43(16'h0000),
    .INIT_44(16'h0000),
    .INIT_45(16'h0000),
    .INIT_46(16'h0000),
    .INIT_47(16'h0000),
    .INIT_48(16'h4700),
    .INIT_49(16'h0000),
    .INIT_4A(16'h0000),
    .INIT_4B(16'h0000),
    .INIT_4C(16'h0000),
    .INIT_4D(16'h0000),
    .INIT_4E(16'h0000),
    .INIT_4F(16'h0000),
    .INIT_50(16'hB5ED),
    .INIT_51(16'h57E4),
    .INIT_52(16'hA147),
    .INIT_53(16'hCA33),
    .INIT_54(16'hA93A),
    .INIT_55(16'h52C6),
    .INIT_56(16'h9555),
    .INIT_57(16'hAE4E),
    .INIT_58(16'h5999),
    .INIT_59(16'h0000),
    .INIT_5A(16'h0000),
    .INIT_5B(16'h0000),
    .INIT_5C(16'h5111),
    .INIT_5D(16'h0000),
    .INIT_5E(16'h0000),
    .INIT_5F(16'h0000),
    .IS_CONVSTCLK_INVERTED(1'b0),
    .IS_DCLK_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SIM_MONITOR_FILE("/home/srusso/Xilinx_prj/LSST_prj/DREB_prj/REB_v3_vivado_15_2/REB_v3_vivado_15_2/REB_v3_vivado_15_2.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0/simulation/functional/design.txt")) 
    U0
       (.ALM({alarm_out,NLW_U0_ALM_UNCONNECTED[6:4],vbram_alarm_out,vccaux_alarm_out,vccint_alarm_out,user_temp_alarm_out}),
        .BUSY(busy_out),
        .CHANNEL(channel_out),
        .CONVST(1'b0),
        .CONVSTCLK(1'b0),
        .DADDR(daddr_in),
        .DCLK(dclk_in),
        .DEN(den_in),
        .DI(di_in),
        .DO(do_out),
        .DRDY(drdy_out),
        .DWE(dwe_in),
        .EOC(eoc_out),
        .EOS(eos_out),
        .JTAGBUSY(NLW_U0_JTAGBUSY_UNCONNECTED),
        .JTAGLOCKED(NLW_U0_JTAGLOCKED_UNCONNECTED),
        .JTAGMODIFIED(NLW_U0_JTAGMODIFIED_UNCONNECTED),
        .MUXADDR(NLW_U0_MUXADDR_UNCONNECTED[4:0]),
        .OT(ot_out),
        .RESET(reset_in),
        .VAUXN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .VAUXP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .VN(vn_in),
        .VP(vp_in));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
