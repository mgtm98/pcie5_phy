module PCIe #(
	
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
(
//clk and reset 
input CLK,
input lpreset,
output phy_reset,
//PIPE interface width
output [1:0] width, ///////////////////which module
//TX_signals
output [MAXPIPEWIDTH*LANESNUMBER-1:0]TxData,
output [LANESNUMBER-1:0]TxDataValid,
output [LANESNUMBER-1:0]TxElecIdle,
output [LANESNUMBER-1:0]TxStartBlock,
output [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]TxDataK,
output [2*LANESNUMBER -1:0]TxSyncHeader,
output [LANESNUMBER-1:0]TxDetectRx_Loopback,
//RX_signals
input  	[MAXPIPEWIDTH*LANESNUMBER-1:0]RxData,
input   [LANESNUMBER-1:0]RxDataValid,
input	[(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]RxDataK,
input	[LANESNUMBER-1:0]RxStartBlock,
input	[2*LANESNUMBER -1:0]RxSyncHeader,
input	[3*LANESNUMBER -1:0]RxStatus,
input [15:0]RxElectricalIdle,
//commands and status signals
output [4*LANESNUMBER-1:0]PowerDown,
output  [3:0]Rate,
input [LANESNUMBER-1:0]PhyStatus,

//pclkcontrolsignal
output [4:0]PCLKRate,
output PclkChangeAck,
input  PclkChangeOk,
//eq_signals
input 	[18*LANESNUMBER -1:0]LocalTxPresetCoefficients,
output 	[18*LANESNUMBER -1:0]TxDeemph,
input 	[6*LANESNUMBER -1:0]LocalFS,
input 	[6*LANESNUMBER -1:0]LocalLF,
output 	[4*LANESNUMBER -1:0]LocalPresetIndex,
output 	[LANESNUMBER -1:0]GetLocalPresetCoeffcients,
input 	[LANESNUMBER -1:0]LocalTxCoefficientsValid,
output 	[6*LANESNUMBER -1:0]LF,
output 	[LANESNUMBER -1:0]RxEqEval,
output 	[LANESNUMBER -1:0]InvalidRequest,
input 	[6*LANESNUMBER -1:0]LinkEvaluationFeedbackDirectionChange,

output pl_trdy,
input  lp_irdy,
input  [512-1:0]lp_data,
input  [64-1:0]lp_valid,
output [512-1:0]pl_data,
output [64-1:0] pl_valid,
input  [3:0]lp_state_req,
output [3:0]pl_state_sts,
output [2:0]pl_speedmode,////////////////////////////////////////
input lp_force_detect,
////lPIF start & end of TLP DLLP
input [64-1:0]lp_dlpstart,
input [64-1:0]lp_dlpend,
input [64-1:0]lp_tlpstart,
input [64-1:0]lp_tlpend,
output [64-1:0]pl_dlpstart,
output [64-1:0]pl_dlpend,
output [64-1:0]pl_tlpstart,
output [64-1:0]pl_tlpend,
output [64-1:0]pl_tlpedb,
output linkUp,
//optional Message bus
output [7:0] M2P_MessageBus,
input  [7:0] P2M_MessageBus
);

wire WriteDetectLanesFlag;
wire [3:0] SetTXState;
wire TXFinishFlag;
wire [3:0]TXExitTo;
wire WriteLinkNumFlagTx,WriteLinkNumFlagRx;
wire [4:0] NumberDetectLanesfromtx;
wire [2:0]GEN; 
wire [4:0]numberOfDetectedLanes;
wire [3:0]RXsubstate;
wire [7:0]linkNumberRxInput,linkNumberTxInput,linkNumberRxOutput,linkNumberTxOutput;
wire [7:0] rateid,rateIdInTx;
wire upConfigureCapability,upConfigureCapabilityInTX;
wire RXfinish;
wire [3:0]RXexitTo;
///////////output linkUp,////////////
wire witeUpconfigureCapability;
wire writerateid;

mainLTSSM #(
.Width(MAXPIPEWIDTH),
.DEVICETYPE(DEVICETYPE), //0 for downstream 1 for upstream
.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),	
.GEN2_PIPEWIDTH (GEN2_PIPEWIDTH) ,	
.GEN3_PIPEWIDTH (GEN3_PIPEWIDTH),	
.GEN4_PIPEWIDTH (GEN4_PIPEWIDTH) ,	
.GEN5_PIPEWIDTH (GEN5_PIPEWIDTH)	
) mainltssm(
    .clk(CLK),
    .reset(lpreset),
    .lpifStateRequest(lp_state_req),
    .numberOfDetectedLanesIn(NumberDetectLanesfromtx),
    .rateIdIn(rateid),
    .upConfigureCapabilityIn(upConfigureCapability),
    .writeNumberOfDetectedLanes(WriteDetectLanesFlag),
    //.writeLinkNumber(WriteLinkNumFlag),
    .writeUpconfigureCapability(witeUpconfigureCapability),
    .writeRateId(writerateid),
    .finishTx(TXFinishFlag),
    .finishRx( RXfinish),
    .gotoTx(TXExitTo),
    .gotoRx(RXexitTo),
    .forceDetect(lp_force_detect),
    .linkUp(linkUp),
    .GEN(GEN),
    .numberOfDetectedLanesOut(numberOfDetectedLanes),
    //.linkNumberOut(linkNumber),
    .rateIdOut(rateIdInTx),
    .upConfigureCapabilityOut(upConfigureCapabilityInTX),//////not used in tx
    .lpifStateStatus(pl_state_sts),
    .substateTx(SetTXState),
    .substateRx(RXsubstate),
    .linkNumberInTx(linkNumberTxOutput),
    .linkNumberInRx(linkNumberRxOutput),
    .writeLinkNumberTx(WriteLinkNumFlagTx),
    .writeLinkNumberRx(WriteLinkNumFlagRx),
    .linkNumberOutTx(linkNumberTxInput),
    .linkNumberOutRx(linkNumberRxInput),
    .width(width)
);

 


RX #(.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),.GEN2_PIPEWIDTH(GEN2_PIPEWIDTH),.GEN3_PIPEWIDTH(GEN3_PIPEWIDTH),.GEN4_PIPEWIDTH(GEN4_PIPEWIDTH),.GEN5_PIPEWIDTH(GEN5_PIPEWIDTH))
rx
( .reset(lpreset), 
.clk(CLK), 
.GEN(GEN), 
.PhyStatus(PhyStatus), 
.RxValid(RxDataValid),
.RxStartBlock(RxStartBlock), 
.RxStatus(RxStatus),
.RxSyncHeader(RxSyncHeader), 
.RxElectricalIdle(RxElectricalIdle),
.RxData(RxData), 
.RxDataK(RxDataK),
.numberOfDetectedLanes(numberOfDetectedLanes),
.substate(RXsubstate),
.linkNumber(linkNumberRxInput),
//.lp_force_detect(lp_force_detect),
.pl_tlpstart(pl_tlpstart), 
.pl_dllpstart(pl_dlpstart), 
.pl_tlpend(pl_tlpend),
.pl_dllpend(pl_dlpend), 
.pl_tlpedb(pl_tlpedb), 
.pl_valid(pl_valid), 
.pl_data(pl_data),
.pl_speedmode(pl_speedmode), 
//.pl_state_sts(),
.rateid(rateid),
.upConfigureCapability(upConfigureCapability),
.finish( RXfinish),
.exitTo(RXexitTo),
//.linkUp(),/////////////////////////////////////////////output from RX
.witeUpconfigureCapability(witeUpconfigureCapability),
.writerateid(writerateid),
.linkNumberOut(linkNumberRxOutput),
.writeLinkNumber(WriteLinkNumFlagRx));





TOP_MODULE #
(
.MAXPIPEWIDTH(MAXPIPEWIDTH),
.DEVICETYPE(DEVICETYPE), //0 for downstream 1 for upstream
.LANESNUMBER(LANESNUMBER),
.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH),	
.GEN2_PIPEWIDTH (GEN2_PIPEWIDTH) ,	
.GEN3_PIPEWIDTH (GEN3_PIPEWIDTH),	
.GEN4_PIPEWIDTH (GEN4_PIPEWIDTH) ,	
.GEN5_PIPEWIDTH (GEN5_PIPEWIDTH),	
.MAX_GEN(MAX_GEN))
TX
(.pclk(CLK),
.reset_n(lpreset),
.pl_trdy(pl_trdy),
.lp_irdy(lp_irdy),
.lp_data(lp_data),
.lp_valid(lp_valid),
.lp_dlpstart(lp_dlpstart),
.lp_dlpend(lp_dlpend),
.lp_tlpstart(lp_tlpstart),
.lp_tlpend(lp_tlpend),
.RxStatus(RxStatus),
.NumberDetectLanes(NumberDetectLanesfromtx),
.TxDetectRx_Loopback(TxDetectRx_Loopback),
.PowerDown(PowerDown),
.PhyStatus(PhyStatus),
.TxElecIdle(TxElecIdle),
.detected_lanes(),//////////////////////////////////////////////////////
.WriteDetectLanesFlag(WriteDetectLanesFlag),
.SetTXState(SetTXState),
.TXFinishFlag(TXFinishFlag),
.TXExitTo(TXExitTo), /////////////////////////
.WriteLinkNum(linkNumberTxOutput),//////////////////////////////
.WriteLinkNumFlag(WriteLinkNumFlagTx),
.ReadLinkNum(linkNumberTxInput),
.rateIdIn(rateIdInTx),
.upConfigureCapabilityIn(upConfigureCapabilityInTX),
.TxData16(TxData[31:0]),
.TxData15(TxData[63:32]),
.TxData14(TxData[95:64]),
.TxData13(TxData[127:96]),
.TxData12(TxData[159:128]),
.TxData11(TxData[191:160]),
.TxData10(TxData[223:192]),
.TxData9(TxData[255:224]),
.TxData8(TxData[287:256]),
.TxData7(TxData[319:288]),
.TxData6(TxData[351:320]),
.TxData5(TxData[383:352]),
.TxData4(TxData[415:384]),
.TxData3(TxData[447:416]),
.TxData2(TxData[479:448]),
.TxData1(TxData[511:480]),
.TxDataValid16(TxDataValid[0]),
.TxDataValid15(TxDataValid[1]),
.TxDataValid14(TxDataValid[2]),
.TxDataValid13(TxDataValid[3]),
.TxDataValid12(TxDataValid[4]),
.TxDataValid11(TxDataValid[5]),
.TxDataValid10(TxDataValid[6]),
.TxDataValid9(TxDataValid[7]),
.TxDataValid8(TxDataValid[8]),
.TxDataValid7(TxDataValid[9]),
.TxDataValid6(TxDataValid[10]),
.TxDataValid5(TxDataValid[11]),
.TxDataValid4(TxDataValid[12]),
.TxDataValid3(TxDataValid[13]),
.TxDataValid2(TxDataValid[14]),
.TxDataValid1(TxDataValid[15]),
.TxDataK16(TxDataK[3:0]),
.TxDataK15(TxDataK[7:4]),
.TxDataK14(TxDataK[11:8]),
.TxDataK13(TxDataK[15:12]),
.TxDataK12(TxDataK[19:16]),
.TxDataK11(TxDataK[23:20]),
.TxDataK10(TxDataK[27:24]),
.TxDataK9(TxDataK[31:28]),
.TxDataK8(TxDataK[35:32]),
.TxDataK7(TxDataK[39:36]),
.TxDataK6(TxDataK[43:40]),
.TxDataK5(TxDataK[47:44]),
.TxDataK4(TxDataK[51:48]),
.TxDataK3(TxDataK[55:52]),
.TxDataK2(TxDataK[59:56]),
.TxDataK1(TxDataK[63:60]));

assign phy_reset = lpreset;

endmodule




module pcieTB;
    parameter MAXPIPEWIDTH = 32;
	parameter DEVICETYPE = 0; //0 for downstream 1 for upstream
	parameter LANESNUMBER =16;
	parameter GEN1_PIPEWIDTH = 8 ;	
	parameter GEN2_PIPEWIDTH = 8 ;	
	parameter GEN3_PIPEWIDTH = 8 ;								
	parameter GEN4_PIPEWIDTH = 8 ;	
	parameter GEN5_PIPEWIDTH = 8 ;	
	parameter MAX_GEN = 1;
reg CLK;
reg reset;
//output phy_reset,
//PIPE interface width
//output [1:0] width, ///////////////////which module
//TX_signals
wire [MAXPIPEWIDTH*LANESNUMBER-1:0]TxData;
wire [LANESNUMBER-1:0]TxDataValid;
wire [LANESNUMBER-1:0]TxElecIdle;
wire [LANESNUMBER-1:0]TxStartBlock;
wire [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]TxDataK;
wire [2*LANESNUMBER -1:0]TxSyncHeader;
wire [LANESNUMBER-1:0]TxDetectRx_Loopback;
//RX_signals
reg [MAXPIPEWIDTH*LANESNUMBER-1:0]RxData;
reg [LANESNUMBER-1:0]RxDataValid;////////////////////////////////////////
reg	[(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]RxDataK;
reg	[LANESNUMBER-1:0]RxStartBlock;
reg	[2*LANESNUMBER -1:0]RxSyncHeader;
reg	[LANESNUMBER-1:0]RxValid;
reg	[3*LANESNUMBER -1:0]RxStatus;
reg [15:0]RxElectricalIdle;
//commands and status signals
wire [4*LANESNUMBER-1:0]PowerDown;
wire  [3:0]Rate;
reg [LANESNUMBER-1:0]PhyStatus;

//pclkcontrolsignal
wire [4:0]PCLKRate;
wire PclkChangeAck;
reg  PclkChangeOk;
//eq_signals
reg 	[18*LANESNUMBER -1:0]LocalTxPresetCoefficients;
wire 	[18*LANESNUMBER -1:0]TxDeemph;
reg 	[6*LANESNUMBER -1:0]LocalFS;
reg 	[6*LANESNUMBER -1:0]LocalLF;
wire 	[4*LANESNUMBER -1:0]LocalPresetIndex;
wire 	[LANESNUMBER -1:0]GetLocalPresetCoeffcients;
reg 	[LANESNUMBER -1:0]LocalTxCoefficientsValid;
wire 	[6*LANESNUMBER -1:0]LF;
wire 	[LANESNUMBER -1:0]RxEqEval;
wire 	[LANESNUMBER -1:0]InvalidRequest;
reg 	[6*LANESNUMBER -1:0]LinkEvaluationFeedbackDirectionChange;
wire    pl_trdy;
reg     lp_irdy;
reg     [512-1:0]lp_data;
reg     [64-1:0]lp_valid;
wire [512-1:0]pl_data;
wire [64-1:0] pl_valid;
reg  [3:0]lp_state_req;
wire [3:0]pl_state_sts;
wire [2:0]pl_speedmode;////////////////////////////////////////
reg lp_force_detect;
////lPIF start & end of TLP DLLP
reg [64-1:0]lp_dlpstart;
reg [64-1:0]lp_dlpend;
reg  [64-1:0]lp_tlpstart;
reg  [64-1:0]lp_tlpend;
wire [64-1:0]pl_dlpstart;
wire [64-1:0]pl_dlpend;
wire [64-1:0]pl_tlpstart;
wire [64-1:0]pl_tlpend;
wire [64-1:0]pl_tlpedb;
wire linkUp;
//optional Message bus
wire [7:0] M2P_MessageBus;
reg  [7:0] P2M_MessageBus;

localparam[1:0]
        reset_   = 2'd0,
        active_  = 2'd1,
        retrain_ = 2'd2;

initial
begin
    CLK = 0;
    reset = 0;
    #8
    reset = 1;
    #10
    lp_state_req = reset_;
    #10
    wait(TxDetectRx_Loopback);
    PhyStatus={16{1'b1}};
    RxStatus={16{3'b011}};
    #100
    RxStatus=16'd0;


end
always #5 CLK = ~CLK;




PCIe #(
	
	.MAXPIPEWIDTH(32),
	.DEVICETYPE (0), //0 for downstream 1 for upstream
	. LANESNUMBER (16),
	. GEN1_PIPEWIDTH (8) ,	
	. GEN2_PIPEWIDTH (8) ,	
	. GEN3_PIPEWIDTH (8) ,								
	. GEN4_PIPEWIDTH (8) ,	
	. GEN5_PIPEWIDTH (8) ,	
	. MAX_GEN (1)
)
pcie
(
//clk and reset 
 CLK,
 reset,
 phy_reset,
//PIPE interface width
 width, ///////////////////which module
//TX_signals
 TxData,
 TxDataValid,
 TxElecIdle,
 TxStartBlock,
 TxDataK,
 TxSyncHeader,
 TxDetectRx_Loopback,
//RX_signals
 RxData,
 RxDataValid,////////////////////////////////////////
 RxDataK,
 RxStartBlock,
 RxSyncHeader,
 RxStatus,
 RxElectricalIdle,
//commands and status signals
 PowerDown,
 Rate,
 PhyStatus,

//pclkcontrolsignal
 PCLKRate,
 PclkChangeAck,
 PclkChangeOk,
//eq_signals
 LocalTxPresetCoefficients,
 TxDeemph,
 LocalFS,
 LocalLF,
 LocalPresetIndex,
 GetLocalPresetCoeffcients,
 LocalTxCoefficientsValid,
LF,
RxEqEval,
InvalidRequest,
LinkEvaluationFeedbackDirectionChange,

pl_trdy,
lp_irdy,
lp_data,
lp_valid,
pl_data,
pl_valid,
lp_state_req,
pl_state_sts,
pl_speedmode,////////////////////////////////////////
lp_force_detect,
////lPIF start & end of TLP DLLP
lp_dlpstart,
lp_dlpend,
lp_tlpstart,
lp_tlpend,
pl_dlpstart,
pl_dlpend,
pl_tlpstart,
pl_tlpend,
pl_tlpedb,
linkUp,
//optional Message bus
M2P_MessageBus,
P2M_MessageBus
);

assign {RxData,RxDataValid,RxDataK,RxValid} = {TxData,TxDataValid,TxDataK,TxDataValid}; 
endmodule
