module Scrambler (input wire pclk, input wire reset_n, input wire turnOff, input wire [5:0]PIPEWIDTH, 
				  input wire [23:0]seedValue, input wire [31:0]dataout_1, input wire [3:0]d_k_out_1, input wire data_valid_out_1, 
				  output wire [31:0]scramblerDataOut, output wire [3:0]scramblerDataK, output wire scramblerDataValid);


	wire patternReset;
	wire [3:0]advance;
	wire [1:0]lfsrSel;
	wire [31:0]lfsrOut_8, lfsrOut_16, lfsrOut_32;
	reg [7:0] reg1, reg2, reg3, reg4;
	reg [31:0]data, lfsrOut;

	LFSR_8 lfsr_8(.scrambler_reset(patternReset), .reset_n(reset_n), .pclk(pclk), .data_out(lfsrOut_8[7:0]));
	LFSR_16 lfsr_16(.scrambler_reset(patternReset), .reset_n(reset_n), .pclk(pclk), .data_out(lfsrOut_16[15:0]));
	LFSR_32 lfsr_32(.scrambler_reset(patternReset), .reset_n(reset_n), .pclk(pclk), .data_out(lfsrOut_32));					

	Master master(.turnOff(turnOff), .PIPEWIDTH(PIPEWIDTH), .masterData(dataout_1), .patternReset(patternReset), 
					.LFSRSel(lfsrSel), .advance(advance));

	always@*
		if(lfsrSel == 0)
			lfsrOut = lfsrOut_8;
		else if(lfsrSel == 1)
			lfsrOut = lfsrOut_16;
		else 
			lfsrOut = lfsrOut_32;

	always@(*)
		if(!reset_n)
			begin
			reg1 <= 0;
			reg2 <= 0;
			reg3 <= 0;
			reg4 <= 0;
			end
		else 
			begin
			if(advance[0] == 1)
				reg1 <= lfsrOut[7:0];
			if(advance[1] == 1)
				reg2 <= lfsrOut[15:8];
			if(advance[2] == 1)
				reg3 <= lfsrOut[23:16];
			if(advance[3] == 1)
				reg4 <= lfsrOut[31:24];
			end

	always@*
		begin
			if(d_k_out_1[0] == 0)
				data[7:0] = reg1 ^ dataout_1[7:0];
			else 
				data[7:0] = dataout_1[7:0];
			if(d_k_out_1[1] == 0)
				data[15:8] = reg2 ^ dataout_1[15:8];
			else 
				data[15:8] = dataout_1[15:8];
			if(d_k_out_1[2] == 0)
				data[23:16] = reg3 ^ dataout_1[23:16];
			else 
				data[23:16] = dataout_1[23:16];
			if(d_k_out_1[3] == 0)
				data[31:24] = reg4 ^ dataout_1[31:24];
			else 
				data[31:24] = dataout_1[31:24];
		end
			

	assign scramblerDataOut =   (turnOff == 1)? dataout_1 : 
								(PIPEWIDTH ==8)? {24'b0, data[7:0]} :
								(PIPEWIDTH ==16)? {16'b0, data[15:0]} :
								(PIPEWIDTH ==32)? data : 32'b0 ;

	assign scramblerDataK = d_k_out_1;	
	assign scramblerDataValid = data_valid_out_1;

endmodule

