module osChecker #(parameter DEVICETYPE = 0)(
    input clk,
    input [7:0]linkNumber,
    input [7:0]laneNumber,
    input [127:0]orderedset,
    input valid,
    input [3:0]substate,
    input reset,
    output reg countup,
    output reg resetcounter,
    output [7:0] rateid,
    output [7:0] linkNumberOut,
    output upconfigure_capability);

    //LOCLA VARIABLES
    reg[4:0] currentState,nextState;
    reg[127:0] localorderedset;
    reg notEqual;
    reg [7:0] linkNumberReg;
    wire ts1CorrectStart,ts2CorrectStart;
    localparam [7:0]
    PAD = 8'hF7, 
    TS1 = 8'h4A,
    TS2 = 8'h45,
    COM = 	8'hBC, //BC
    gen3TS1 = 8'h1E,
    gen3TS2 = 8'h2D;

//input substates from main ltssm
    localparam [3:0]
        detectQuiet =  4'd0,
        detectActive = 4'd1,
        pollingActive= 4'd2,
        pollingConfiguration= 4'd3,
        configurationLinkWidthStart = 4'd4,
        configurationLinkWidthAccept = 4'd5,
        configurationLanenumWait = 4'd6,
        configurationLanenumAccept = 4'd7,
        configurationComplete = 4'd8,
        configurationIdle = 4'd9;


//internal states
    localparam [4:0]
        start = 5'd0,
        pollingActive1= 5'd1,
        pollingActive2= 5'd2,
        pollingConfiguration1= 5'd3,
        pollingConfiguration2= 5'd4,
        configLinkWidthStartDown1 = 5'd5,
        configLinkWidthStartDown2 = 5'd6,
        configLinkWidthStartUp1 = 5'd7,
        configLinkWidthStartUp2 = 5'd8,
        configLinkWidthAcceptUp1 = 5'd9,
        configLinkWidthAcceptUp2 = 5'd10,
        configLanenumWaitDown1 = 5'd11,
        configLanenumWaitDown2 = 5'd12,
        configLanenumWaitUp1 = 5'd13,
        configLanenumWaitUp2 = 5'd14,
        configLanenumAcceptDown1 = 5'd15,
        configLanenumAcceptDown2 = 5'd16,
        configLanenumAcceptUp1 = 5'd17,
        configLanenumAcceptUp2 = 5'd18,
        configCompleteDown1 = 5'd19,
        configCompleteDown2 = 5'd20,
        configCompleteUp1 = 5'd21,
        configCompleteUp2 = 5'd22,
        configIdle1 = 5'd23,
        configIdle2 = 5'd24;
//CURRENT STATE FF
always @(posedge clk or negedge reset)
begin
    notEqual <= 1'b0;
    if(!reset)
    begin
        currentState <= start;
    end
    else
    begin
        currentState <= nextState;
        if(valid)
        begin
            localorderedset<=orderedset;
            if((currentState == configCompleteDown2||currentState == configCompleteUp2)&&(localorderedset[42] != orderedset[42] || localorderedset[39:32] != orderedset[39:32]))
            notEqual <= 1'b1;
        end
    end    
end

//next state logic block
always @(*)
begin
    case(currentState)
        start:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if      (substate == pollingActive) nextState = pollingActive1;
            else if (substate == pollingConfiguration) nextState = pollingConfiguration1;
            else if (substate == configurationLinkWidthStart && DEVICETYPE == 1'b0)nextState = configLinkWidthStartDown1;
            else if (substate == configurationLinkWidthStart && DEVICETYPE == 1'b1)nextState = configLinkWidthStartUp1;
            else if (substate == configurationLinkWidthAccept && DEVICETYPE == 1'b1)nextState = configLinkWidthAcceptUp1;
            else if (substate == configurationLanenumWait && DEVICETYPE == 1'b0) nextState = configLanenumWaitDown1;
            else if (substate == configurationLanenumWait && DEVICETYPE == 1'b1) nextState = configLanenumWaitUp1;
            else if (substate == configurationLanenumAccept && DEVICETYPE == 1'b0) nextState = configLanenumAcceptDown1;
            else if (substate == configurationLanenumAccept && DEVICETYPE == 1'b1) nextState = configLanenumAcceptUp1;
            else if (substate == configurationComplete && DEVICETYPE == 1'b0) nextState = configCompleteDown1;
            else if (substate == configurationComplete && DEVICETYPE == 1'b1) nextState = configCompleteUp1;
            else if (substate == configurationIdle) nextState = configIdle1;
            else nextState = start;
        end
/******************************polling Active**************************************************/
        pollingActive1:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if((valid&&ts1CorrectStart&&orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)||
            (valid&&ts2CorrectStart&&orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)||
            (valid&&ts1CorrectStart&&orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[42] == 1'b1 && orderedset[87:80] == TS1)) 
            begin
            nextState = pollingActive2;
            resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = pollingActive1;
        end
        pollingActive2:
        begin
            resetcounter = 1'b1; countup = 1'b0; 
            if(valid)
            begin
            if((ts1CorrectStart&&orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)||
                (ts2CorrectStart&&orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)||
                (ts1CorrectStart&&orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[42] == 1'b1 && orderedset[87:80] == TS1)) 
                begin
                    countup = 1'b1; 
                    nextState = pollingActive2;
                end
            else nextState = pollingActive1; 
            end
            else nextState = pollingActive2;
            
        end
        /**********************************pollingConfiguration*****************************************************/
        pollingConfiguration1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid &&ts2CorrectStart&& orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)
            begin
                nextState = pollingConfiguration2;
                resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = pollingConfiguration1;
        end

        pollingConfiguration2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
            begin
                if(ts2CorrectStart&&orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)
                begin
                    countup = 1'b1; 
                    nextState = pollingConfiguration2;
                end
                else nextState = pollingConfiguration1;        
            end
            else nextState = pollingConfiguration2;
        end
        /**********************************configLinkWidthStart*************************************************/
        configLinkWidthStartDown1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid&&ts1CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==PAD && orderedset[87:80] == TS1)
            begin
                nextState =  configLinkWidthStartDown2;
                resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = configLinkWidthStartDown1;
        end

        configLinkWidthStartDown2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
                begin
                    if(ts1CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==PAD && orderedset[87:80] == TS1)
                    begin
                        countup = 1'b1;
                        nextState =  configLinkWidthStartDown2;
                    end
                    else nextState =  configLinkWidthStartDown1;
                end
            else nextState =  configLinkWidthStartDown2;
        end
        configLinkWidthStartUp1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid &&ts1CorrectStart&&orderedset[15:8]!=PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS1)
            begin
                nextState =  configLinkWidthStartUp2;
                linkNumberReg = orderedset[15:8];
                resetcounter = 1'b1; countup = 1'b1;
            end
                else nextState = configLinkWidthStartUp1;
        end

        configLinkWidthStartUp2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
                begin
                    if(ts1CorrectStart&&orderedset[15:8]==linkNumberReg && orderedset[23:16]==PAD && orderedset[87:80] == TS1)
                    begin
                        countup =1'b1;
                        nextState =  configLinkWidthStartUp2;
                    end
                    else nextState =  configLinkWidthStartUp1;
                end
            else nextState =  configLinkWidthStartUp2;
        end
        /********************************configLinkWidthAccept**************************************************/
            configLinkWidthAcceptUp1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid &&ts1CorrectStart&& orderedset[15:8]==linkNumber && orderedset[23:16]!=PAD  && orderedset[87:80] == TS1)
            begin
                nextState = configLinkWidthAcceptUp2;
                resetcounter = 1'b1; countup = 1'b1;
            end
                else nextState = configLinkWidthAcceptUp1;
        end

        configLinkWidthAcceptUp2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
                begin
                    if(ts1CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]!=PAD && orderedset[87:80] == TS1)
                    begin
                        countup = 1'b1;
                        nextState =  configLinkWidthAcceptUp2;
                    end
                    else nextState =  configLinkWidthAcceptUp1;
                end
            else nextState =  configLinkWidthAcceptUp2;
        end
        /******************************configLanenumWait***************************************************/
            configLanenumWaitDown1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid && ts1CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS1)
            begin
                nextState = configLanenumWaitDown2;
                resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = configLanenumWaitDown1;
        end

        configLanenumWaitDown2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
            begin
                if(ts1CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS1)
                begin
                    countup = 1'b1;
                    nextState =  configLanenumWaitDown2;
                end
                else nextState =  configLanenumWaitDown1;
            end
            else nextState =  configLanenumWaitDown2;
        end

        configLanenumWaitUp1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid && ts2CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
            begin
            nextState = configLanenumWaitUp2;
            resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = configLanenumWaitUp1;
        end

        configLanenumWaitUp2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
                begin
                    if(ts2CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
                    begin
                        countup = 1'b1;
                        nextState =  configLanenumWaitUp2;
                    end
                    else nextState =  configLanenumWaitUp1;
                end
            else nextState =  configLanenumWaitUp2;
        end
        /*********************************configLanenumAccept************************************************/
        configLanenumAcceptDown1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid && ts1CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS1)
            begin
                nextState = configLanenumAcceptDown2;
                resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = configLanenumAcceptDown1;
        end

        configLanenumAcceptDown2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
            begin
                if(ts1CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS1)
                begin
                    countup = 1'b1;
                    nextState =  configLanenumAcceptDown2;
                end
                else nextState =  configLanenumAcceptDown1;
            end
            else nextState =  configLanenumAcceptDown2;
        end

        configLanenumAcceptUp1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid &&ts2CorrectStart&& orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
            begin 
                nextState = configLanenumAcceptUp2;
                resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = configLanenumAcceptUp1;
        end

        configLanenumAcceptUp2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
            begin
                if(ts2CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
                begin
                    countup = 1'b1;
                    nextState =  configLanenumAcceptUp2;
                end
                else nextState =  configLanenumAcceptUp1;
            end
            else nextState =  configLanenumAcceptUp2;
        end
        /****************************************configComplete***************************************************/
        configCompleteDown1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid &&ts2CorrectStart&& orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
            begin
            nextState = configCompleteDown2;
            resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = configCompleteDown1;
        end

        configCompleteDown2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(notEqual)nextState = configCompleteDown1;
            else if(valid)
            begin
                if(ts2CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
                begin
                    countup = 1'b1;
                    nextState =  configCompleteDown2;
                end
                else nextState =  configCompleteDown1;
            end
            else nextState =  configCompleteDown2;
        end

        configCompleteUp1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid &&ts2CorrectStart&& orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
            begin
            nextState = configCompleteUp2;
            resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = configCompleteUp1;
        end
        configCompleteUp2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(notEqual)nextState = configCompleteUp1;
            else if(valid)
                begin
                    if(ts2CorrectStart&&orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
                    begin
                        countup = 1'b1;
                        nextState =  configCompleteUp2;
                    end
                    else nextState =  configCompleteUp1;
                end
            else nextState =  configCompleteUp2;
        end
        /***************************************configIdle***********************************************/
        configIdle1:
        begin
            resetcounter = 1'b0; countup = 1'b0;
            if(valid && (|orderedset==1'b0))
            begin
            nextState = configIdle2;
            resetcounter = 1'b1; countup = 1'b1;
            end
            else nextState = configIdle1;
        end

        configIdle2:
        begin
            resetcounter = 1'b1; countup = 1'b0;
            if(valid)
                begin
                    if((|orderedset==1'b0))
                    begin
                        countup = 1'b1;
                        nextState =  configIdle2;
                    end
                    else nextState =  configIdle1;
                end
            else nextState =  configIdle2;   
        end


        default:nextState = start;
endcase
end
    assign rateid = localorderedset[39:32];
    assign linkNumberOut = localorderedset[15:8];
    assign upconfigure_capability = localorderedset[42];
    assign ts1CorrectStart = (orderedset[7:0]==COM || orderedset[7:0]==gen3TS1)? 1'b1 : 1'b0;
    assign ts2CorrectStart = (orderedset[7:0]==COM || orderedset[7:0]==gen3TS2)? 1'b1 : 1'b0;
    //assign {link,lane,id}={orderedset[15:8],orderedset[23:16],orderedset[87:80]};
    
endmodule
