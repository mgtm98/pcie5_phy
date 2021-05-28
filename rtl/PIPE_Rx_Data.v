module PIPE_Rx_Data #(parameter GEN1_PIPEWIDTH = 8, parameter GEN2_PIPEWIDTH = 16, parameter GEN3_PIPEWIDTH = 32, parameter GEN4_PIPEWIDTH = 8,
					 parameter GEN5_PIPEWIDTH = 8)(input wire reset, input wire clk, input wire [2:0]GEN, input wire PhyStatus, input wire RxValid,
												input wire RxStartBlock, input wire [2:0]RxStatus, input wire [1:0]RxSyncHeader, input wire RxElectricalIdle,
												input wire [31:0]RxData, input wire [3:0]RxDataK, output wire [1:0]PIPESyncHeader, output [5:0]PIPEWIDTH,
												output wire PIPEElectricalIdle, output wire PIPEDataValid, output wire [31:0]PIPEData, output wire [3:0]PIPEDataK);
	
	reg  dataValid, dataValid_next, pipeWidth;
	reg [1:0]syncHeader, syncHeader_next;
	reg [31:0] data, data_next;
	reg [3:0]dataK, dataK_next;
	always@(posedge clk or negedge reset)
	if(!reset)
	begin
		data <= 0;
		dataK <= 0;
		dataValid <= 0;
		syncHeader <= 0;
	end
	else 
	begin
		data <= data_next;
		dataK <= dataK_next;
		dataValid <= dataValid_next;
		syncHeader <= syncHeader_next;
	end

	always@*
		begin
		if(RxStatus == 0)
			dataValid_next = RxValid;
		else 
			dataValid_next = 0;

		if(RxStartBlock == 1)
			syncHeader_next = RxSyncHeader;
		else 
			syncHeader_next = 0;

		if(GEN == 1)
			begin
			data_next = RxData[GEN1_PIPEWIDTH-1:0];
			dataK_next = RxDataK[(GEN1_PIPEWIDTH/8)-1:0];
			pipeWidth = GEN1_PIPEWIDTH;
			end
		else if(GEN == 2)
			begin
			data_next = RxData[GEN2_PIPEWIDTH-1:0];
			dataK_next = RxDataK[(GEN2_PIPEWIDTH/8)-1:0];
			pipeWidth = GEN2_PIPEWIDTH;
			end
		else if(GEN == 3)
			begin
			data_next = RxData[GEN3_PIPEWIDTH-1:0];
			dataK_next = RxDataK[(GEN3_PIPEWIDTH/8)-1:0];
			pipeWidth = GEN3_PIPEWIDTH;
			end
		else if(GEN == 4)
			begin
			data_next = RxData[GEN4_PIPEWIDTH-1:0];
			dataK_next = RxDataK[(GEN4_PIPEWIDTH/8)-1:0];
			pipeWidth = GEN4_PIPEWIDTH;
			end
		else if(GEN == 5)
			begin
			data_next = RxData[GEN5_PIPEWIDTH-1:0];
			dataK_next = RxDataK[(GEN5_PIPEWIDTH/8)-1:0];
			pipeWidth = GEN5_PIPEWIDTH;
			end
		else 
			begin
			data_next = 0;
			dataK_next = 0;
			pipeWidth = 0;
			end
		end

	assign PIPEData = data;
	assign PIPEDataK = dataK;
	assign PIPEWIDTH = pipeWidth;
	assign PIPEDataValid = dataValid;
	assign PIPESyncHeader = syncHeader;
	assign PIPEElectricalIdle = RxElectricalIdle;

endmodule
