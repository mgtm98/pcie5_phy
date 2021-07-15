
module TX_LTSSM #
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
(
input Pclk,
input Reset, //active low
output reg [2:0]Gen ,
output reg [4:0] NumberDetectLanes,
output reg [LANESNUMBER-1:0] DetectLanes,
output reg WriteDetectLanesFlag,
// main LTSSM interface
input  [3:0] SetTXState,
output reg TXFinishFlag,
output reg [3:0] TXExitTo,
output reg[7:0] WriteLinkNum,
output reg WriteLinkNumFlag,
input [7:0] ReadLinkNum,
// LPIF TX control & data flow interface 
output reg HoldFIFOData,
input FIFOReady,
// OS generator interface 
output reg [2:0] OSType,
output reg[1:0] LaneNumber, 
output reg[7:0] LinkNumber,
output reg[2:0] Rate,
output reg Loopback,
//OS generator interface communication
output reg OSGeneratorStart,
input OSGeneratorBusy,
input OSGeneratorFinish,
//OS generator interface equalization 
output [1:0] EC,
output ResetEIEOSCount,
output [4* LANESNUMBER-1:0] TXPreset,
output [3* LANESNUMBER-1:0] RXPreset,
output [LANESNUMBER-1:0] UsePresetCoff,
output [6* LANESNUMBER-1:0] FS,
output [6* LANESNUMBER-1:0] LF,
output [6* LANESNUMBER-1:0] PreCursorCoff,
output [6* LANESNUMBER-1:0] CursorCoff,
output [6* LANESNUMBER-1:0] PostCursorCoff,
output [ LANESNUMBER-1:0] RejectCoff,
output SpeedChange,
output ReqEq,
//mux
output reg MuxSel,
//Lane Management control 
//PIPE TX Control
output reg [ LANESNUMBER-1:0]DetectReq,
output reg [ LANESNUMBER-1:0]ElecIdleReq,
input  [ LANESNUMBER-1:0]DetectStatus,
//scrambler
output [23:0]seedValue

);

// states encoding
 parameter  DetectQuiet = 4'b0000, DetectActive = 4'b0001, PollingActive = 4'b0010,
	    PollingConfigration = 4'b0011, ConfigrationLinkWidthStart = 4'b0100, ConfigrationLinkWidthAccept= 4'b0101,
            ConfigrationLaneNumWait = 4'b0110,  ConfigrationLaneNumActive = 4'b0111, ConfigrationComplete = 4'b1000,
            ConfigrationIdle = 4'b1001,L0=4'b1010 ,Idle=4'b1111;
//Device type 
parameter DownStream = 0 ,UpStream = 1;
//time 
parameter t12ms= 3'b001,t0ms = 3'b000;
//Generation
parameter Gen1 = 3'b001,Gen2 = 3'b010,Gen3 = 3'b011,Gen4 = 3'b100,Gen5 = 3'b101; // TODO edited
//internal Register 

reg [3:0]State;
wire [3:0]NextState;
reg [3:0] ExitToState;
reg ExitToFlag;
//internal Register 
reg [15:0]OSCount;
reg [2:0]CurrentGen;
//
reg WriteDetectLanesFlagReg;
//Timer interface
reg TimerEnable;
reg TimerStart;
reg [2:0]TimerIntervalCode;
wire TimeOut;
Timer #(.Width(32)) T(.Gen(Gen),.Reset(Reset),.Pclk(Pclk),.Enable(TimerEnable),.Start(TimerStart),.TimerIntervalCode(TimerIntervalCode),.TimeOut(TimeOut));

//assignment
assign NextState = SetTXState; 

///lanes number
always @ *
begin 
if(DetectLanes[15]) NumberDetectLanes=15+1;
else if (DetectLanes[14]) NumberDetectLanes=14+1;
else if (DetectLanes[13]) NumberDetectLanes=13+1;
else if (DetectLanes[12]) NumberDetectLanes=12+1;
else if (DetectLanes[11]) NumberDetectLanes=11+1;
else if (DetectLanes[10]) NumberDetectLanes=10+1;
else if (DetectLanes[9]) NumberDetectLanes=9+1;
else if (DetectLanes[8]) NumberDetectLanes=8+1;
else if (DetectLanes[7]) NumberDetectLanes=7+1;
else if (DetectLanes[6]) NumberDetectLanes=6+1;
else if (DetectLanes[5]) NumberDetectLanes=5+1;
else if (DetectLanes[4]) NumberDetectLanes=4+1;
else if (DetectLanes[3]) NumberDetectLanes=3+1;
else if (DetectLanes[2]) NumberDetectLanes=2+1;
else if (DetectLanes[1]) NumberDetectLanes=1+1;
else if (DetectLanes[0]) NumberDetectLanes=0+1;
else   NumberDetectLanes=0;
end 
//exit to logic combinational
always @ *
begin
//default value for outputs (synthesis)
ExitToState = 4'bxxxx;
ExitToFlag  = 0 ;

	case(State)
		DetectQuiet:begin
			if (TimeOut==1) begin
				ExitToState = DetectActive;
				ExitToFlag  = 1 ;
			end
		end	
		DetectActive:begin
			if (DetectStatus == {LANESNUMBER{1'b1}} )begin
				DetectLanes = DetectStatus;
				WriteDetectLanesFlagReg<=1;
				ExitToState = PollingActive;
				ExitToFlag  = 1 ;
			end	
			else if (TimeOut && DetectStatus == {LANESNUMBER{1'b0}} )begin
				ExitToState = DetectQuiet;
				ExitToFlag  = 1 ;
			end	
		end
		PollingActive:begin
		 if(OSCount >= 1024)begin
			ExitToState = PollingConfigration;
			ExitToFlag  = 1 ;
		 end
		end
		PollingConfigration:begin
		 if(OSCount >= 16)begin
			ExitToState = ConfigrationLinkWidthStart;
			ExitToFlag  = 1 ;
		 end
		end
		ConfigrationLinkWidthAccept:begin
		if(OSGeneratorFinish)begin
			ExitToState = ConfigrationLaneNumWait;
			ExitToFlag  = 1 ;
		end
		end
		ConfigrationComplete:begin
		if(OSCount >= 16)begin
			ExitToState = ConfigrationIdle;
			ExitToFlag  = 1 ;
		 end
		end
		ConfigrationIdle:begin
		if(OSCount >= 16)begin
			ExitToState = L0;
			ExitToFlag  = 1 ;
		 end
		end
		
	endcase
end


//TODO Remeber 
always @(posedge Pclk) begin
//Default values of outputs
Gen <= CurrentGen;
ElecIdleReq <= {LANESNUMBER{1'b0}};
DetectReq<= {LANESNUMBER{1'b0}};
OSGeneratorStart <=0;
WriteLinkNumFlag <=0;
	case(State)
		DetectQuiet:begin
			HoldFIFOData <= 1;
			ElecIdleReq <= {LANESNUMBER{1'b1}};
		end
		DetectActive:begin
			HoldFIFOData<=1;
			//DetectReq<= {LANESNUMBER{1'b1}};
			if (DetectStatus == {LANESNUMBER{1'b1}} || DetectLanes == {LANESNUMBER{1'b1}} )begin
				DetectReq<= {LANESNUMBER{1'b0}};
				end
			else begin
				DetectReq<= {LANESNUMBER{1'b1}};
				end
		end
		 PollingActive:begin
			HoldFIFOData<=1;
			MuxSel <=0; //TODO : check is it 1 or 0 for orderset
			if(!OSGeneratorBusy)begin //it is supposed that
			OSType<=2'b00;
		   LaneNumber<=2'b00;
			LinkNumber<=8'b0;
			Rate<=MAX_GEN;
			Loopback<=1;
			OSGeneratorStart<=1;
			end
		end
		PollingConfigration:begin
			HoldFIFOData<=1;
			MuxSel <=0; //TODO : check is it 1 or 0 for orderset
			if(!OSGeneratorBusy)begin //it is supposed that
			OSType<=2'b01; //TS2
		   LaneNumber<=2'b00;
			LinkNumber<=8'b0;
			Rate<=MAX_GEN;
			OSGeneratorStart<=1;
			end
		end
		ConfigrationLinkWidthStart:begin
			HoldFIFOData<=1;
			MuxSel <=0; //TODO : check is it 1 or 0 for orderset
			if(!OSGeneratorBusy)begin //it is supposed that
			OSType<=2'b00; //TS1
		   LaneNumber<=2'b00;
			Rate<=MAX_GEN;
			if(DEVICETYPE==DownStream)begin
				LinkNumber<=8'b01;
				WriteLinkNum <= 8'b01;
				WriteLinkNumFlag <= 1;
			end
			else begin
				LinkNumber<=8'b00; //pad
			end
			OSGeneratorStart<=1;
			end
		end
		
		ConfigrationLinkWidthAccept:begin
			HoldFIFOData<=1;
			MuxSel <=0; //TODO : check is it 1 or 0 for orderset
			if(!OSGeneratorBusy)begin //it is supposed that
			OSType<=2'b00; //TS1
		   LinkNumber<=ReadLinkNum;
			Rate<=MAX_GEN;
			if(DEVICETYPE==DownStream)begin
				LaneNumber<=2'b01; //num_seq
			end
			else begin
				LaneNumber<=8'b00; //pad
			end
			OSGeneratorStart<=1;
			end
		end
		ConfigrationLaneNumWait:begin
			HoldFIFOData<=1;
			MuxSel <=0; //TODO : check is it 1 or 0 for orderset
			if(!OSGeneratorBusy)begin //it is supposed that
			OSType<=2'b00; //TS1
		   LinkNumber<=ReadLinkNum;
			Rate<=MAX_GEN;
			LaneNumber<=2'b01; //num_seq
			OSGeneratorStart<=1;
			end
		end
		ConfigrationLaneNumActive:begin
			HoldFIFOData<=1;
			MuxSel <=0; //TODO : check is it 1 or 0 for orderset
			if(!OSGeneratorBusy)begin //it is supposed that
			OSType<=2'b00; //TS1
		   LinkNumber<=ReadLinkNum;
			Rate<=MAX_GEN;
			LaneNumber<=2'b01; //num_seq
			OSGeneratorStart<=1;
			end
		end
		
		ConfigrationComplete:begin
			HoldFIFOData<=1;
			MuxSel <=0; //TODO : check is it 1 or 0 for orderset
			if(!OSGeneratorBusy)begin //it is supposed that
			OSType<=2'b01; //TS2
		   LinkNumber<=ReadLinkNum;
			Rate<=MAX_GEN;
			LaneNumber<=2'b01; //num_seq
			OSGeneratorStart<=1;
			end
		end
		ConfigrationIdle:begin
			HoldFIFOData<=1;
			MuxSel <=0; //TODO : check is it 1 or 0 for orderset
			if(!OSGeneratorBusy)begin //it is supposed that
			OSType<=3'b100; //IDLE
			OSGeneratorStart<=1;
			end
		end
		L0:begin
			HoldFIFOData<=0;
			MuxSel <=1; //TODO : check is it 1 or 0 for orderset
		end
	endcase 
end


//on trasition to different state initialize orderset_count and any other variable need to be initialized
always @(posedge Pclk)
begin
TimerStart <= 0;
	case(State)
		DetectQuiet:begin
			if( NextState == DetectActive)begin
				TimerEnable <= 1;
				TimerStart  <= 1;
				TimerIntervalCode <= t12ms;
			end
			
			else if (NextState == PollingActive || NextState == PollingConfigration 
			|| NextState == ConfigrationComplete ||NextState == ConfigrationIdle)begin
				OSCount<=0;		
			end
			if(TimeOut)begin
				TimerEnable <= 0;
			end
		end		
		
		DetectActive:begin
			if(NextState == DetectQuiet)begin
				TimerEnable <= 1;
				TimerStart  <= 1;
				TimerIntervalCode <= t12ms;
			end
			else if (NextState == PollingActive || NextState == PollingConfigration 
			|| NextState == ConfigrationComplete ||NextState == ConfigrationIdle)begin
				OSCount<=0;		
			end			
		   if(TimeOut)begin
				TimerEnable <= 0;
			end
		end		

		PollingActive:begin
			if(OSGeneratorFinish)begin
				OSCount<=OSCount+1;		
			end
			if(NextState == DetectQuiet || NextState == DetectActive)begin
				TimerEnable <= 1;
				TimerStart  <= 1;
				TimerIntervalCode <= t12ms;
			end
			else if ( NextState == PollingConfigration || NextState == ConfigrationComplete 
			||NextState == ConfigrationIdle)begin
				OSCount<=0;		
			end			
		end		
		
		PollingConfigration :begin
			if(OSGeneratorFinish)begin
				OSCount<=OSCount+1;		
			end
			if(NextState == DetectQuiet || NextState == DetectActive)begin
				TimerEnable <= 1;
				TimerStart  <= 1;
				TimerIntervalCode <= t12ms;
			end
			else if (NextState == PollingActive  
			|| NextState == ConfigrationComplete ||NextState == ConfigrationIdle)begin
				OSCount<=0;		
			end			
		end		
	
		ConfigrationComplete:begin
			if(OSGeneratorFinish)begin
				OSCount<=OSCount+1;		
			end
			if(NextState == DetectQuiet || NextState == DetectActive)begin
				TimerEnable <= 1;
				TimerStart  <= 1;
				TimerIntervalCode <= t12ms;
			end
			else if (NextState == PollingActive || NextState == PollingConfigration)begin
				OSCount<=0;		
			end			
			else if(NextState == ConfigrationIdle) begin
					OSCount<=0;
				end

		end		

		ConfigrationIdle:begin
			if(OSGeneratorFinish)begin
				OSCount<=OSCount+1;		
			end
			if(NextState == DetectQuiet || NextState == DetectActive)begin
				TimerEnable <= 1;
				TimerStart  <= 1;
				TimerIntervalCode <= t12ms;
			end
			else if (NextState == PollingActive || NextState == PollingConfigration 
			|| NextState == ConfigrationComplete )begin
				OSCount<=0;		
			end			
		end		
		
		default:begin
			if(NextState == DetectQuiet || NextState == DetectActive)begin
				TimerEnable <= 1;
				TimerStart  <= 1;
				TimerIntervalCode <= t12ms;
			end
			else if (NextState == PollingActive || NextState == PollingConfigration 
			|| NextState == ConfigrationComplete ||NextState == ConfigrationIdle)begin
				OSCount<=0;		
			end			
		end		
	endcase
end
// outputs
always @ (posedge Pclk)
begin
	if(!Reset) begin
		State <= Idle;
		TXExitTo <= DetectQuiet;
		TXFinishFlag <= 0;
		CurrentGen=Gen1;
		WriteDetectLanesFlag<=0;
	end
	else begin
		State   <= NextState;
		TXExitTo<= ExitToState;
		TXFinishFlag <= ExitToFlag;
		WriteDetectLanesFlag<=WriteDetectLanesFlagReg;
	end
end

endmodule