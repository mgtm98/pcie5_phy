module RxLTSSM #(
parameter DEVICETYPE=0,
parameter Width = 32,
parameter GEN1_PIPEWIDTH = 8 ,	
parameter GEN2_PIPEWIDTH = 8 ,	
parameter GEN3_PIPEWIDTH = 8 ,	
parameter GEN4_PIPEWIDTH = 8 ,	
parameter GEN5_PIPEWIDTH = 8)
 (
input [2:0]Gen,
input clk,
input reset,
input [2047:0] orderedSets,
input [4:0]numberOfDetectedLanes,
input [3:0]substate,
input [7:0]linkNumber,
//input forceDetect,
input rxElectricalIdle,
input validOrderedSets,
output [7:0] rateId,
output [7:0] linkNumberOut,
output upConfigureCapability,
output finish,
output [3:0]exitTo,
//output linkUp,
output witeUpconfigureCapability,
output writerateid,
output writeLinkNumber,
output disableDescrambler,
output [3:0]lpifStatus
);

wire [15:0]resetOsCheckers;
wire [15:0]countUp,resetCounters;
wire [127:0]rateIds;
wire [127:0]linkNumbers;
wire [15:0]upConfigurebits;
wire [79:0]countersValues;
wire [4:0] checkValues;
wire [15:0]comparisonValues;
wire  enableTimer,startTimer,resetTimer,timeOut;
wire [2:0]setTimer;


genvar i;
generate
   for (i=0; i <= 15; i=i+1) 
   begin
     osChecker #(.DEVICETYPE(DEVICETYPE))osChecker( 
     clk,
     linkNumber,
     i[7:0],
     orderedSets[(i*128)+127:i*128],
     validOrderedSets,
     substate,
     resetOsCheckers[i],
     countUp[i],
     resetCounters[i],
     rateIds[(i*8)+7:i*8],
     linkNumbers[(i*8)+7:i*8],
     upConfigurebits[i]);

     counter counter(
     resetCounters[i],
     clk,
     countUp[i],
     countersValues[(i*5)+4:i*5]);

     comparator comparator(
     countersValues[(i*5)+4:i*5],
     checkValues,
     comparisonValues[i]);

     
   end
endgenerate


masterRxLTSSM masterRxLTSSM(
    clk,
    numberOfDetectedLanes,
    substate,
    comparisonValues,
    //forceDetect,
    rxElectricalIdle,
    timeOut,
    reset,
    finish,
    exitTo,
    resetOsCheckers,
    disableDescrambler,
    lpifStatus,
    setTimer,
    enableTimer,
    startTimer,
    resetTimer,
    checkValues);

//timer timer(clk,setTimer,enableTimer,resetTimer,timeOut);
Timer #(
Width,
GEN1_PIPEWIDTH,	
GEN2_PIPEWIDTH,	
GEN3_PIPEWIDTH,	
GEN4_PIPEWIDTH,	
GEN5_PIPEWIDTH
)
timer
(
Gen,
resetTimer,
clk,
enableTimer,
startTimer,
setTimer,
timeOut
);

assign writerateid= (finish &&(exitTo == 4'd4|| exitTo == 4'd9))? 1'b1 : 1'b0;
assign witeUpconfigureCapability=(finish &&(exitTo == 4'd4|| exitTo == 4'd9))? 1'b1 : 1'b0;
assign writeLinkNumber = (finish && (exitTo == 4'd5) && DEVICETYPE)? 1'b1:1'b0;
assign {rateId,upConfigureCapability,linkNumberOut} = {rateIds[7:0],upConfigurebits[0],linkNumbers[7:0]};
//assign linkUp = (substate == 4'd10)? 1'b1 : 1'b0;
endmodule