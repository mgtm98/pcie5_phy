module TOP_MODULE #
(
parameter MAXPIPEWIDTH = 32,
parameter DEVICETYPE = 0, //0 for downstream 1 for upstream
parameter LANESNUMBER =16,
parameter GEN1_PIPEWIDTH = 8 ,	
parameter GEN2_PIPEWIDTH = 8 ,	
parameter GEN3_PIPEWIDTH = 8 ,	
parameter GEN4_PIPEWIDTH = 8 ,	
parameter GEN5_PIPEWIDTH = 8 ,	
parameter MAX_GEN = 1
)
(pclk,reset_n,NumberDetectLanes,pl_trdy,lp_irdy,lp_data,lp_valid,lp_dlpstart,lp_dlpend, lp_tlpstart,lp_tlpend,RxStatus,TxDetectRx_Loopback,PowerDown, PhyStatus,TxElecIdle,detected_lanes,WriteDetectLanesFlag,SetTXState,TXFinishFlag,TXExitTo,WriteLinkNum,WriteLinkNumFlag,ReadLinkNum, 
turnOff,TxData1,TxData2,TxData3,TxData4,TxData5,TxData6,TxData7,TxData8,TxData9,TxData10,TxData11,TxData12,TxData13,TxData14,TxData15,TxData16,TxDataValid1,TxDataValid2,TxDataValid3,TxDataValid4,TxDataValid5,TxDataValid6,TxDataValid7,TxDataValid8,TxDataValid9,TxDataValid10,TxDataValid11,TxDataValid12,
TxDataValid13,TxDataValid14,TxDataValid15,TxDataValid16,TxDataK1,TxDataK2,TxDataK3,
TxDataK4,TxDataK5,TxDataK6,TxDataK7,TxDataK8,TxDataK9,TxDataK10,TxDataK11,TxDataK12,TxDataK13,TxDataK14,TxDataK15,
TxDataK16,rateIdIn,upConfigureCapabilityIn,turnOffScrambler_flag,startSend16);

//lane number 
input [7:0] rateIdIn;
input upConfigureCapabilityIn;
input turnOff;
input startSend16;
output  [4:0] NumberDetectLanes;
//lpif control
wire hold;

//can not find it
output pl_trdy;
input  lp_irdy;
////// wr in tx control ??????

input  [512-1:0]lp_data;
input  [64-1:0]lp_valid;
input [64-1:0]lp_dlpstart;
input [64-1:0]lp_dlpend;
input [64-1:0]lp_tlpstart;
input [64-1:0]lp_tlpend;



//fifo 
wire [511:0] FIFO_dataIN;
wire [63:0] FIFO_datavalid;
wire [63:0] FIFO_datak;


//scrambler 
wire [23:0]seedValue;
//mux
wire sel;
//output data signals
output turnOffScrambler_flag;
output [31:0] TxData1,TxData2,TxData3,TxData4,TxData5,TxData6,TxData7,TxData8,TxData9,TxData10,TxData11,TxData12,TxData13,TxData14,TxData15,TxData16;
output  TxDataValid1,TxDataValid2,TxDataValid3,TxDataValid4,TxDataValid5,TxDataValid6,TxDataValid7,TxDataValid8,TxDataValid9,TxDataValid10,TxDataValid11,TxDataValid12,TxDataValid13,TxDataValid14,TxDataValid15,TxDataValid16;
output [3:0]  TxDataK1,TxDataK2,TxDataK3,TxDataK4,TxDataK5,TxDataK6,TxDataK7,TxDataK8,TxDataK9,TxDataK10,TxDataK11,TxDataK12,TxDataK13,TxDataK14,TxDataK15,TxDataK16;
//common
wire [2:0] gen;
input pclk;
input reset_n;
//os generator internal signals
wire [2:0] os_type;
wire [1:0]lane_number;
wire [7:0]link_number;
wire [2:0] rate;
wire loopback;
wire start;
wire finish;
wire busy;
///main ltssm
output [15:0]detected_lanes;
output  WriteDetectLanesFlag;
input  [3:0] SetTXState;
output  TXFinishFlag;
output  [3:0] TXExitTo;
output [7:0] WriteLinkNum;
output  WriteLinkNumFlag;
input [7:0] ReadLinkNum;
//scrambler  
wire [31:0]scramblerDataOut1,scramblerDataOut2, scramblerDataOut3,scramblerDataOut4, scramblerDataOut5,scramblerDataOut6,scramblerDataOut7,scramblerDataOut8,scramblerDataOut9,scramblerDataOut10, scramblerDataOut11, scramblerDataOut12,scramblerDataOut13, scramblerDataOut14,scramblerDataOut15,scramblerDataOut16;
wire [3:0] scramblerDataK1, scramblerDataK2, scramblerDataK3, scramblerDataK4, scramblerDataK5, scramblerDataK6, scramblerDataK7, scramblerDataK8, scramblerDataK9, scramblerDataK10, scramblerDataK11, scramblerDataK12, scramblerDataK13, scramblerDataK14, scramblerDataK15,scramblerDataK16;
wire  scramblerDataValid1,scramblerDataValid2,scramblerDataValid3,scramblerDataValid4,scramblerDataValid5,scramblerDataValid6,scramblerDataValid7,scramblerDataValid8,scramblerDataValid9,scramblerDataValid10,scramblerDataValid11,scramblerDataValid12,scramblerDataValid13,scramblerDataValid14,scramblerDataValid15,scramblerDataValid16;

wire[511:0] os_data;
wire [63:0] os_datak;
wire [63:0] os_datavalid;
wire[511:0] data_muxout;
wire [63:0] datak_muxout;
wire [63:0] datavalid_muxout;
wire  datavalid_lmcout1,datavalid_lmcout2,datavalid_lmcout3,datavalid_lmcout4,datavalid_lmcout5,datavalid_lmcout6,datavalid_lmcout7,datavalid_lmcout8,datavalid_lmcout9,datavalid_lmcout10,datavalid_lmcout11,datavalid_lmcout12,datavalid_lmcout13,datavalid_lmcout14,datavalid_lmcout15,datavalid_lmcout16;
wire [31:0] data_lmc1,data_lmc2,data_lmc3,data_lmc4,data_lmc5,data_lmc6,data_lmc7,data_lmc8,data_lmc9,data_lmc10,data_lmc11,data_lmc12,data_lmc13,data_lmc14,data_lmc15,data_lmc16;
wire [3:0]  datak_lmc1,datak_lmc2,datak_lmc3,datak_lmc4,datak_lmc5,datak_lmc6,datak_lmc7,datak_lmc8,datak_lmc9,datak_lmc10,datak_lmc11,datak_lmc12,datak_lmc13,datak_lmc14,datak_lmc15,datak_lmc16;
wire [5:0] pipewidth;

//pipe control
wire [ LANESNUMBER-1:0]DetectReq;
wire [ LANESNUMBER-1:0]ElecIdleReq;
wire  [ LANESNUMBER-1:0]DetectStatus;
input	[3*LANESNUMBER -1:0]RxStatus;
output [LANESNUMBER-1:0]TxDetectRx_Loopback;
input [ LANESNUMBER-1:0]PhyStatus;
output [4*LANESNUMBER-1:0]PowerDown;
output [LANESNUMBER-1:0]TxElecIdle;


TX_CONTROL 
#(.MAXPIPEWIDTH(MAXPIPEWIDTH),.LANESNUMBER(LANESNUMBER),.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),
.GEN2_PIPEWIDTH(GEN2_PIPEWIDTH),.GEN3_PIPEWIDTH(GEN3_PIPEWIDTH),.GEN4_PIPEWIDTH(GEN4_PIPEWIDTH),.GEN5_PIPEWIDTH(GEN5_PIPEWIDTH)) 
LPIF_CTRL
(.reset_n(reset_n),.data_in(lp_data),.wr(lp_irdy),.wr_valid(lp_valid),.pclk(pclk),.STP_IN(lp_tlpstart),.SDP_IN(lp_dlpstart)
,.END_IN(lp_tlpend|lp_dlpend),.Gen(gen),.DetectedLanes(detected_lanes),.Hold(hold),.DataOut(FIFO_dataIN),.ValidOut(FIFO_datavalid),.DKOut(FIFO_datak),.full(pl_trdy));
genvar i;
generate 
for(i=0;i<LANESNUMBER;i=i+1)
begin
PIPE_Control PIPE_CTL(.substate(SetTXState),.generation(gen), .pclk(pclk), .reset_n(reset_n), .RxStatus(RxStatus[3*i+:3]),
 .ElecIdle_req(ElecIdleReq[i]), .Detect_req(DetectReq[i]), .PhyStatus(PhyStatus[i]), .TxDetectRx_Loopback(TxDetectRx_Loopback[i]),
 .PowerDown(PowerDown[4*i+:4]), .Detect_status(DetectStatus[i]), .TxElecIdle(TxElecIdle[i]));
end

endgenerate

TX_LTSSM #(.DEVICETYPE(DEVICETYPE),.MAXPIPEWIDTH(MAXPIPEWIDTH),.LANESNUMBER(LANESNUMBER),.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),
.GEN2_PIPEWIDTH(GEN2_PIPEWIDTH),.GEN3_PIPEWIDTH(GEN3_PIPEWIDTH),.GEN4_PIPEWIDTH(GEN4_PIPEWIDTH),.GEN5_PIPEWIDTH(GEN5_PIPEWIDTH)) txltssm (.Pclk(pclk),.Reset(reset_n),.Gen(gen),.TXFinishFlag(TXFinishFlag),.TXExitTo(TXExitTo),.DetectLanes(detected_lanes),.WriteDetectLanesFlag(WriteDetectLanesFlag),.SetTXState(SetTXState)
,.WriteLinkNum(WriteLinkNum),.WriteLinkNumFlag(WriteLinkNumFlag),.ReadLinkNum(ReadLinkNum),.HoldFIFOData(hold),.FIFOReady(),.OSType(os_type),.LaneNumber(lane_number),.LinkNumber( link_number),
.Rate(rate),.Loopback(loopback),.OSGeneratorStart(start),.OSGeneratorBusy(busy),.OSGeneratorFinish(finish),. EC(),.ResetEIEOSCount(),.TXPreset(),.RXPreset(),.UsePresetCoff(),
.FS(),.LF(),.PreCursorCoff(),.CursorCoff(),.PostCursorCoff(),.RejectCoff(),.SpeedChange(),.ReqEq(),.MuxSel(sel),.DetectReq(DetectReq),
.ElecIdleReq(ElecIdleReq),.DetectStatus(DetectStatus),
.seedValue(seedValue),.NumberDetectLanes(NumberDetectLanes),.turnOffScrambler_flag(turnOffScrambler_flag),.startSend16(startSend16)
);


OS_GENERATOR #(.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),.no_of_lanes(LANESNUMBER))
block1 (pclk, reset_n, os_type, lane_number, link_number, rate, loopback , detected_lanes, gen, start, finish, os_data, os_datak, busy, os_datavalid);
MUX block2 (sel,FIFO_datavalid, os_datavalid, FIFO_dataIN, os_data, FIFO_datak, os_datak,data_muxout,datak_muxout,datavalid_muxout);
LMC  #(.pipe_width_gen1(GEN1_PIPEWIDTH),
.pipe_width_gen2(GEN2_PIPEWIDTH),
.pipe_width_gen3(GEN3_PIPEWIDTH),
.pipe_width_gen4(GEN4_PIPEWIDTH),
.pipe_width_gen5(GEN5_PIPEWIDTH),
.number_of_lanes(LANESNUMBER)
)block3 ( reset_n, pclk, gen, datavalid_muxout, data_muxout, datak_muxout, pipewidth,datavalid_lmcout1,datavalid_lmcout2,datavalid_lmcout3,datavalid_lmcout4,datavalid_lmcout5,datavalid_lmcout6,datavalid_lmcout7,datavalid_lmcout8,datavalid_lmcout9,datavalid_lmcout10,datavalid_lmcout11,datavalid_lmcout12,datavalid_lmcout13,datavalid_lmcout14,datavalid_lmcout15,datavalid_lmcout16,datak_lmc1,datak_lmc2,datak_lmc3,datak_lmc4,datak_lmc5,datak_lmc6,datak_lmc7,datak_lmc8,datak_lmc9,datak_lmc10,datak_lmc11,datak_lmc12,datak_lmc13,datak_lmc14,datak_lmc15,datak_lmc16,data_lmc1,data_lmc2,data_lmc3,data_lmc4,data_lmc5,data_lmc6,data_lmc7,data_lmc8,data_lmc9,data_lmc10,data_lmc11,data_lmc12,data_lmc13,data_lmc14,data_lmc15,data_lmc16);
Scrambler lane1 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc1,datak_lmc1, datavalid_lmcout1,scramblerDataOut1,scramblerDataK1,scramblerDataValid1);
Scrambler lane2 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc2,datak_lmc2, datavalid_lmcout2,scramblerDataOut2,scramblerDataK2,scramblerDataValid2);
Scrambler lane3 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc3,datak_lmc3, datavalid_lmcout3,scramblerDataOut3,scramblerDataK3,scramblerDataValid3);
Scrambler lane4 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc4,datak_lmc4, datavalid_lmcout4,scramblerDataOut4,scramblerDataK4,scramblerDataValid4);
Scrambler lane5 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc5,datak_lmc5, datavalid_lmcout5,scramblerDataOut5,scramblerDataK5,scramblerDataValid5);
Scrambler lane6 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc6,datak_lmc6, datavalid_lmcout6,scramblerDataOut6,scramblerDataK6,scramblerDataValid6);
Scrambler lane7 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc7,datak_lmc7, datavalid_lmcout7,scramblerDataOut7,scramblerDataK7,scramblerDataValid7);
Scrambler lane8 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc8,datak_lmc8, datavalid_lmcout8,scramblerDataOut8,scramblerDataK8,scramblerDataValid8);
Scrambler lane9 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc9,datak_lmc9, datavalid_lmcout9,scramblerDataOut9,scramblerDataK9,scramblerDataValid9);
Scrambler lane10 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc10,datak_lmc10, datavalid_lmcout10,scramblerDataOut10,scramblerDataK10,scramblerDataValid10);
Scrambler lane11 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc11,datak_lmc11, datavalid_lmcout11,scramblerDataOut11,scramblerDataK11,scramblerDataValid11);
Scrambler lane12 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc12,datak_lmc12, datavalid_lmcout12,scramblerDataOut12,scramblerDataK12,scramblerDataValid12);
Scrambler lane13 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc13,datak_lmc13, datavalid_lmcout13,scramblerDataOut13,scramblerDataK13,scramblerDataValid13);
Scrambler lane14 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc14,datak_lmc14, datavalid_lmcout14,scramblerDataOut14,scramblerDataK14,scramblerDataValid14);
Scrambler lane15 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc15,datak_lmc15, datavalid_lmcout15,scramblerDataOut15,scramblerDataK15,scramblerDataValid15);
Scrambler lane16 (pclk,reset_n,turnOff,pipewidth,seedValue,data_lmc16,datak_lmc16, datavalid_lmcout16,scramblerDataOut16,scramblerDataK16,scramblerDataValid16);

PIPE_Data Lane1(gen, pclk, reset_n, scramblerDataOut1, scramblerDataK1, scramblerDataValid1, TxData1, TxDataValid1, TxDataK1);
PIPE_Data Lane2(gen, pclk, reset_n, scramblerDataOut2, scramblerDataK2, scramblerDataValid2, TxData2, TxDataValid2, TxDataK2);
PIPE_Data Lane3(gen, pclk, reset_n, scramblerDataOut3, scramblerDataK3, scramblerDataValid3, TxData3, TxDataValid3, TxDataK3);
PIPE_Data Lane4(gen, pclk, reset_n, scramblerDataOut4, scramblerDataK4, scramblerDataValid4, TxData4, TxDataValid4, TxDataK4);
PIPE_Data Lane5(gen, pclk, reset_n, scramblerDataOut5, scramblerDataK5, scramblerDataValid5, TxData5, TxDataValid5, TxDataK5);
PIPE_Data Lane6(gen, pclk, reset_n, scramblerDataOut6, scramblerDataK6, scramblerDataValid6, TxData6, TxDataValid6, TxDataK6);
PIPE_Data Lane7(gen, pclk, reset_n, scramblerDataOut7, scramblerDataK7, scramblerDataValid7, TxData7, TxDataValid7, TxDataK7);
PIPE_Data Lane8(gen, pclk, reset_n, scramblerDataOut8, scramblerDataK8, scramblerDataValid8, TxData8, TxDataValid8, TxDataK8);
PIPE_Data Lane9(gen, pclk, reset_n, scramblerDataOut9, scramblerDataK9, scramblerDataValid9, TxData9, TxDataValid9, TxDataK9);
PIPE_Data Lane10(gen, pclk, reset_n, scramblerDataOut10, scramblerDataK10, scramblerDataValid10, TxData10, TxDataValid10, TxDataK10);
PIPE_Data Lane11(gen, pclk, reset_n, scramblerDataOut11, scramblerDataK11, scramblerDataValid11, TxData11, TxDataValid11, TxDataK11);
PIPE_Data Lane12(gen, pclk, reset_n, scramblerDataOut12, scramblerDataK12, scramblerDataValid12, TxData12, TxDataValid12, TxDataK12);
PIPE_Data Lane13(gen, pclk, reset_n, scramblerDataOut13, scramblerDataK13, scramblerDataValid13, TxData13, TxDataValid13, TxDataK13);
PIPE_Data Lane14(gen, pclk, reset_n, scramblerDataOut14, scramblerDataK14, scramblerDataValid14, TxData14, TxDataValid14, TxDataK14);
PIPE_Data Lane15(gen, pclk, reset_n, scramblerDataOut15, scramblerDataK15, scramblerDataValid15, TxData15, TxDataValid15, TxDataK15);
PIPE_Data Lane16(gen, pclk, reset_n, scramblerDataOut16, scramblerDataK16, scramblerDataValid16, TxData16, TxDataValid16, TxDataK16);


endmodule