module OS_GENERATOR #
(parameter GEN1_PIPEWIDTH=16,
parameter no_of_lanes=4
)
(pclk, reset_n, os_type, lane_number, link_number, rate, loopback , detected_lanes, gen, start, finish, Os_Out, DataK, busy, DataValid);
parameter LANESNUMBER=no_of_lanes;
input [1:0] os_type;
input [1:0]lane_number;
input [7:0]link_number;
input [2:0] rate;
input loopback;
input [no_of_lanes-1:0]detected_lanes;
input [2:0] gen;
input start;
input pclk;
input reset_n;
output reg busy;
output reg finish;
output reg [511:0] Os_Out;
output reg [63:0]DataK;
output reg [63:0]DataValid;
reg [GEN1_PIPEWIDTH*no_of_lanes-1:0] os_out;
reg [((GEN1_PIPEWIDTH/8)*no_of_lanes)-1:0]datak;
reg [((GEN1_PIPEWIDTH/8)*no_of_lanes)-1:0]datavalid;
reg send;
reg [1:0] os_type_reg;
reg [1:0] lane_number_reg;
reg [no_of_lanes-1:0]detected_lanes_reg;
reg [2:0] gen_reg;
reg [3:0] symbol;
reg [4:0] count;
reg D;
reg K;
reg valid;
reg not_valid;
reg [31:0] skp;
reg [31:0] EIOS;
reg [127:0] TS1;
reg [127:0] TS2;
reg [5:0]PIPE; 
//integer i;
always@(posedge pclk) begin
 if ( reset_n == 1'b0)
   send = 1'b0;  // in order to know that there won't be an order set to send
   valid = 1'b1;//represents that data is valid
   not_valid = 1'b0;//represents that data isn't valid
 if (start) begin 
   os_type_reg = os_type; // storing the type of the order set
   lane_number_reg = lane_number; // storing the type of lanes 
   detected_lanes_reg = detected_lanes; //storing the detected lanes
   gen_reg = gen; // storing the PCIe generation 
   symbol = 4'b0000; // flag which detects which symbol to be sent 
   send = 1'b1; // in order to know that there will be an order to send
   //count = 5'b00000; // counter which countes the number of lanes detected
   D = 1'b0;//reperesents the order sets is D character
   K = 1'b1;//represents that the order set is K character
   // preparation of the order set based on the inputs coming from the Tx LTSSM
   skp = 32'h1C1C1CBC;
   EIOS = 32'h7C7C7CBC;
   TS1[7:0] = 8'hBC;
   PIPE=GEN1_PIPEWIDTH;
   count=no_of_lanes;
   if (link_number==8'b00000000)
    TS1[15:8] = 8'hF7;
	
   else 
    TS1[15:8] = link_number;
	
   TS1[31:24] = 8'b0000000;
   if ( rate == 3'b001) 
     TS1[39:32] = 8'b00000010;
	
   else if ( rate == 3'b010) 
     TS1[39:32] = 8'b00000100;
	 
   else if ( rate == 3'b011) 
     TS1[39:32] = 8'b00001000;
	 
   else if ( rate == 3'b100) 
     TS1[39:32] = 8'b00010000;
	 
   else  
     TS1[39:32] = 8'b00100000;
	 
   if(loopback)
     TS1[47:40] = 8'b00000100;
	 
   else
     TS1[47:40] = 8'b00000000;
	
   TS1[127:48] = 80'h4A4A4A4A4A4A4A4A4A4A;
   
   TS2[7:0] = 8'hBC;
   if (link_number==8'b00000000)
    TS2[15:8] = 8'hF7;
   else 
    TS2[15:8] = link_number;
	
   TS2[31:24] = 8'b0000000;
   if ( rate == 3'b001) 
     TS2[39:32] = 8'b00000010;
	
   else if ( rate == 3'b010) 
     TS2[39:32] = 8'b00000100;
	 
   else if ( rate == 3'b011) 
     TS2[39:32] = 8'b00001000;
	 
   else if ( rate == 3'b100) 
     TS2[39:32] = 8'b00010000;
	 
   else  
     TS2[39:32] = 8'b00100000;
	 
   if(loopback)
     TS2[47:40] = 8'b00000100;
	 
   else
     TS2[47:40] = 8'b00000000;
	
   TS2[127:48] = 80'h4545454545454545454A;
   
  // for (i=0;i<no_of_lanes;i=i+1)begin // counting the number of lanes
	  //count=count+1;
	//end
	
  end
  // *******************************************pipewidth=8************************************************************************
   if (PIPE==6'b001000)begin
	if(send)begin//if there are order sets available to be sent
	  busy = 1'b1;
	  finish=1'b0;
	  datavalid = {no_of_lanes{valid}};
	  // ******************************************************checking if TS1 order sets to be sent********************************************
	  if (os_type_reg==2'b00)begin
	    
		  if(symbol==4'b0000)begin // checking if symbol 0 is to be sent
		    os_out ={no_of_lanes{TS1[7:0]}};
			datak ={no_of_lanes{K}};
			end
			
		  else if(symbol==4'b0001) begin // checking if symbol 1 is to be sent
		    os_out ={no_of_lanes{TS1[15:8]}};
			
			if (TS1[15:8] == 8'hF7)
              datak ={no_of_lanes{K}};
			  
	        else 
			   datak ={no_of_lanes{D}};
		     
			end
				
		  else if(symbol==4'b0010)begin // checking if symbol 2 is to be sent
		     if(lane_number_reg==2'b00)begin 
			   if (count==5'b00001)begin
			     os_out = 8'hF7;
				 datak ={no_of_lanes{K}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = 32'hF7F7F7F7;
				 datak ={no_of_lanes{K}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = 64'hF7F7F7F7F7F7F7F7;
				 datak ={no_of_lanes{K}};
				 end
				 
			  else begin
			     os_out = 128'hF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7;
				 datak ={no_of_lanes{K}};
				 end
			 end
			 
			 else if(lane_number_reg==2'b01)begin // checking if lanes number are sequential
			   if (count==5'b00001)begin
			     os_out = 8'h00;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = 32'h03020100;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = 64'h0706050403020100;
				 datak ={no_of_lanes{D}};
				 end
				 
			 else begin
			     os_out = 128'h0F0E0D0C0B0A09080706050403020100;
				 datak = {no_of_lanes{D}};
				 end
			 end
			 
			 else begin // checking if lanes number are sequentially reversed
			   if (count==5'b00001)begin
			     os_out = 8'h01;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = 32'h01020304;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = 64'h0102030405060708;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else begin
			     os_out = 128'h0102030405060708090A0B0C0D0E0F10;
				 datak ={no_of_lanes{D}};
				 end
			 end
			end
			
	       else if(symbol==4'b0011) begin // checking if symbol 3 is to be sent
		    os_out ={no_of_lanes{TS1[31:24]}};
			datak ={no_of_lanes{D}};
			end
			
		else if(symbol==4'b0100) begin // checking if symbol 4 is to be sent
		    os_out ={no_of_lanes{TS1[39:32]}};
			datak ={no_of_lanes{D}};
			end
		
	    else if(symbol==4'b0101) begin // checking if symbol 5 is to be sent
		    os_out ={no_of_lanes{TS1[47:40]}};
			datak ={no_of_lanes{D}};
			end
			
		else if(symbol==4'b0110|symbol==4'b0111|symbol==4'b1000|symbol==4'b1001|symbol==4'b1010|symbol==4'b1011|symbol==4'b1100|symbol==4'b1101|symbol==4'b1110) begin // checking if symbol 6 or 7 or 8 or 9 or 10 or 11 or 12 or 13 or 14  is to be sent
		    os_out ={no_of_lanes{TS1[55:48]}};
			datak ={no_of_lanes{D}};
			end
			
		else  begin
		    os_out ={no_of_lanes{TS1[127:120]}};// checking if symbol 15 is to be sent
			datak ={no_of_lanes{D}};
			send =1'b0;
			finish =1'b1;
			busy =1'b0;
		    end
			 symbol=symbol+1; 
		  end 
		 
		  // ******************************************************checking if TS2 order sets to be sent********************************************
      else if (os_type_reg==2'b01)begin
		
		  if(symbol==4'b0000)begin // checking if symbol 0 is to be sent
		    os_out ={no_of_lanes{TS2[7:0]}};
			datak ={no_of_lanes{K}};
			end
			
		  else if(symbol==4'b0001) begin // checking if symbol 1 is to be sent
		    os_out ={no_of_lanes{TS2[15:8]}};
			
			if (TS2[15:8] == 8'hF7)
              datak ={no_of_lanes{K}};
			  
	        else 
			   datak ={no_of_lanes{D}};
			
			end
				
		  else if(symbol==4'b0010)begin // checking if symbol 2 is to be sent
		     if(lane_number_reg==2'b00)begin 
			   if (count==5'b00001)begin
			     os_out = 8'hF7;
				 datak ={no_of_lanes{K}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = 32'hF7F7F7F7;
				 datak ={no_of_lanes{K}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = 64'hF7F7F7F7F7F7F7F7;
				 datak ={no_of_lanes{K}};
				 end
				 
			  else begin
			     os_out = 128'hF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7;
				 datak ={no_of_lanes{K}};
				 end
			 end
			 
			 else if(lane_number_reg==2'b01)begin // checking if lanes number are sequential
			   if (count==5'b00001)begin
			     os_out = 8'h00;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = 32'h03020100;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = 64'h0706050403020100;
				 datak ={no_of_lanes{D}};
				 end
				 
			 else begin
			     os_out = 128'h0F0E0D0C0B0A09080706050403020100;
				 datak ={no_of_lanes{D}};
				 end
			 end
			 
			 else begin // checking if lanes number are sequentially reversed
			   if (count==5'b00001)begin
			     os_out = 8'h01;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = 32'h01020304;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = 64'h0102030405060708;
				 datak ={no_of_lanes{D}};
				 end
				 
			   else begin
			     os_out = 128'h0102030405060708090A0B0C0D0E0F10;
				 datak ={no_of_lanes{D}};
				 end
			 end
			end
			
	       else if(symbol==4'b0011) begin // checking if symbol 3 is to be sent
		    os_out ={no_of_lanes{TS2[31:24]}};
			datak ={no_of_lanes{D}};
			end
			
		else if(symbol==4'b0100) begin // checking if symbol 4 is to be sent
		    os_out ={no_of_lanes{TS2[39:32]}};
			datak ={no_of_lanes{D}};
			end
		
	    else if(symbol==4'b0101) begin // checking if symbol 5 is to be sent
		    os_out={no_of_lanes{TS2[47:40]}};
			datak ={no_of_lanes{D}};
			end
			
		else if(symbol==4'b0110) begin // checking if symbol 6 is to be sent
		    os_out ={no_of_lanes{TS2[55:48]}};
			datak ={no_of_lanes{D}};
			end
			
		else if(symbol==4'b0111|symbol==4'b1000|symbol==4'b1001|symbol==4'b1010|symbol==4'b1011|symbol==4'b1100|symbol==4'b1101|symbol==4'b1110) begin // checking if symbol  7 or 8 or 9 or 10 or 11 or 12 or 13 or 14  is to be sent
		    os_out ={no_of_lanes{TS2[63:56]}};
			datak ={no_of_lanes{D}};
			end
			
		else  begin // checking if symbol 15 is to be sent
		    os_out={no_of_lanes{TS2[127:120]}};
			datak={no_of_lanes{D}};
			send=1'b0;
			finish=1'b1;
			busy=1'b0;
		    end
			 symbol=symbol+1; 
		  end 
		   // ******************************************************checking if skip order sets to be sent********************************************
      else if (os_type_reg==2'b10)begin
		
		  if(symbol==4'b0000)begin // checking if symbol 0 is to be sent
		    os_out={no_of_lanes{skp[7:0]}};
			datak={no_of_lanes{K}};
			end
			
		  else if(symbol==4'b0001) begin // checking if symbol 1 is to be sent
		    os_out={no_of_lanes{skp[15:8]}};
			datak={no_of_lanes{K}};
			end
			
			else if(symbol==4'b0010) begin // checking if symbol 1 is to be sent
		    os_out={no_of_lanes{skp[23:16]}};
			datak={no_of_lanes{K}};
			end
			
			else if(symbol==4'b0011) begin // checking if symbol 1 is to be sent
		    os_out={no_of_lanes{skp[31:24]}};
			datak={no_of_lanes{K}};
			send =1'b0;
			finish=1'b1;
			busy=1'b0;
			end
			symbol=symbol+1; 
		  end 
		  // ******************************************************checking if EIOS order sets to be sent********************************************
      else begin
		
		  if(symbol==4'b0000)begin // checking if symbol 0 is to be sent
		    os_out={no_of_lanes{EIOS[7:0]}};
			datak={no_of_lanes{K}};
			end
			
		  else if(symbol==4'b0001) begin // checking if symbol 1 is to be sent
		    os_out={no_of_lanes{EIOS[15:8]}};
			datak={no_of_lanes{K}};
			end
			
			else if(symbol==4'b0010) begin // checking if symbol 1 is to be sent
		    os_out={no_of_lanes{EIOS[23:16]}};
			datak={no_of_lanes{K}};
			end
			
			else if(symbol==4'b0011) begin // checking if symbol 1 is to be sent
		    os_out={no_of_lanes{EIOS[31:24]}};
			datak={no_of_lanes{K}};
			send=1'b0;
			finish=1'b1;
			busy=1'b0;
			end
			symbol=symbol+1; 
		   end
		 end
		else begin  //if there are no order sets available to be sent
		  datavalid = {no_of_lanes{not_valid}};
		  os_out={no_of_lanes*GEN1_PIPEWIDTH{not_valid}};
		  datak= {no_of_lanes{not_valid}};
		  finish=1'b0;
		  busy= 1'b0;
		 end
		if (count==5'b00001)begin
		 Os_Out={504'b0,os_out};
		 DataK ={63'b0,datak};
		 DataValid={63'b0,datavalid};
		 end
		else if (count==5'b00100)begin
		 Os_Out={480'b0,os_out};
		 DataK ={60'b0,datak};
		 DataValid={60'b0,datavalid};
		 end
		else if (count==5'b01000)begin
		 Os_Out={448'b0,os_out};
		 DataK={56'b0,datak};
		 DataValid={56'b0,datavalid};
		 end
		 else begin
		 Os_Out={384'b0,os_out};
		 DataK={48'b0,datak};
		 DataValid={48'b0,datavalid};
		 end
		end
	// *******************************************pipewidth=16************************************************************************
	else if(PIPE==6'b010000)begin
	  if(send)begin
	   busy = 1'b1;
	   finish=1'b0;
	   datavalid = {{no_of_lanes{valid}},{no_of_lanes{valid}}};
       //*****************************************checking if TS1 order sets to be sent*******************************************
	     if (os_type_reg==2'b00)begin
		
		  if(symbol==4'b0000)begin // checking if symbols 0,1 are to be sent
		    os_out ={{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
			if (TS1[15:8] == 8'hF7)
              datak ={{no_of_lanes{K}},{no_of_lanes{K}}};  
	        else 
			  datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
			end
				
		  else if(symbol==4'b0010)begin // checking if symbols 2,3 are to be sent
		     if(lane_number_reg==2'b00)begin 
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{8'hF7}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{32'hF7F7F7F7}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{64'hF7F7F7F7F7F7F7F7}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
				 end
				 
			  else begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{128'hF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
				 end
			 end
			 
			 else if(lane_number_reg==2'b01)begin // checking if lanes number are sequential
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{8'h00}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{32'h03020100}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{64'h0706050403020100}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			 else begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{128'h0F0E0D0C0B0A09080706050403020100}};
				 datak = {{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
			 end
			 
			 else begin // checking if lanes number are sequentially reversed
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{8'h01}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{32'h01020304}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{64'h0102030405060708}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{128'h0102030405060708090A0B0C0D0E0F10}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
			 end
			end
			
			
		else if(symbol==4'b0100) begin // checking if symbols 4,5 are to be sent
		    os_out ={{no_of_lanes{TS1[47:40]}},{no_of_lanes{TS1[39:32]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
			end
		
			
		else if(symbol==4'b0110|symbol==4'b1000|symbol==4'b1010|symbol==4'b1100) begin // checking if symbols 6,7 or 8,9 or 10,11 or 12,13 are to be sent
		    os_out ={{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
			end
			
		else  begin
		    os_out ={{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}}};// checking if symbols 14,15 are to be sent
			datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
			send =1'b0;
			finish =1'b1;
			busy =1'b0;
		    end
			 symbol=symbol+2; 
		  end 
		  //*****************************************checking if TS2 order sets to be sent*******************************************
	     else if (os_type_reg==2'b01)begin
		
		  if(symbol==4'b0000)begin // checking if symbols 0,1 are to be sent
		    os_out ={{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
			if (TS1[15:8] == 8'hF7)
              datak ={{no_of_lanes{K}},{no_of_lanes{K}}};  
	        else 
			  datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
			end
				
		  else if(symbol==4'b0010)begin // checking if symbols 2,3 are to be sent
		     if(lane_number_reg==2'b00)begin 
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{8'hF7}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{32'hF7F7F7F7}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{64'hF7F7F7F7F7F7F7F7}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
				 end
				 
			  else begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{128'hF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{K}}};
				 end
			 end
			 
			 else if(lane_number_reg==2'b01)begin // checking if lanes number are sequential
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{8'h01}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{32'h04030201}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{64'h0807060504030201}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			 else begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{128'h100F0E0D0C0B0A090807060504030201}};
				 datak = {{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
			 end
			 
			 else begin // checking if lanes number are sequentially reversed
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{8'h01}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{32'h01020304}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{64'h0102030405060708}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
				 
			   else begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{128'h0102030405060708090A0B0C0D0E0F10}};
				 datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
				 end
			 end
			end
			
			
		else if(symbol==4'b0100) begin // checking if symbols 4,5 are to be sent
		    os_out ={{no_of_lanes{TS2[47:40]}},{no_of_lanes{TS2[39:32]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
			end
			
		else if(symbol==4'b0110) begin // checking if symbols 6,7 are to be sent
		    os_out ={{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[55:48]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
			end
			
		else if(symbol==4'b1000|symbol==4'b1010|symbol==4'b1100) begin // checking if symbols  8,9 or 10,11 or 12,13 are to be sent
		    os_out ={{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[63:56]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
			end
			
		else  begin
		    os_out ={{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[63:56]}}};//checking if symbols 14,15 are to be sent
			datak ={{no_of_lanes{D}},{no_of_lanes{D}}};
			send =1'b0;
			finish =1'b1;
			busy =1'b0;
		    end
			 symbol=symbol+2; 
		  end 
		  // ******************************************************checking if skip order sets to be sent********************************************
      else if (os_type_reg==2'b10)begin
		
		  if(symbol==4'b0000)begin // checking if symbols 0,1 are to be sent
		    os_out={{no_of_lanes{skp[15:8]}},{no_of_lanes{skp[7:0]}}};
			datak={{no_of_lanes{K}},{no_of_lanes{K}}};
			end
			
		 else begin // checking if symbols 2,3 are to be sent
		    os_out={{no_of_lanes{skp[31:24]}},{no_of_lanes{skp[23:16]}}};
			datak={{no_of_lanes{K}},{no_of_lanes{K}}};
			send =1'b0;
			finish=1'b1;
			busy=1'b0;
			end
			symbol=symbol+2; 
		  end 
		  // ******************************************************checking if EIOS order sets to be sent********************************************
      else begin
		
		  if(symbol==4'b0000)begin // checking if symbols 0,1 are to be sent
		    os_out={{no_of_lanes{EIOS[15:8]}},{no_of_lanes{EIOS[7:0]}}};
			datak={{no_of_lanes{K}},{no_of_lanes{K}}};
			end
			
		  else begin // checking if symbols 2,3 are to be sent
		    os_out={{no_of_lanes{EIOS[31:24]}},{no_of_lanes{EIOS[23:16]}}};
			datak={{no_of_lanes{K}},{no_of_lanes{K}}};
			send=1'b0;
			finish=1'b1;
			busy=1'b0;
			end
			symbol=symbol+2; 
		 end
		end
		 else begin  //if there are no order sets available to be sent
		  datavalid = {no_of_lanes{not_valid}};
		  os_out={no_of_lanes*GEN1_PIPEWIDTH{not_valid}};
		  datak= {no_of_lanes{not_valid}};
		  finish=1'b0;
		  busy= 1'b0;
		 end
		if (count==5'b00001)begin
		 Os_Out={496'b0,os_out};
		 DataK ={62'b0,datak};
		 DataValid={62'b0,datavalid};
		 end
		else if (count==5'b00100)begin
		 Os_Out={448'b0,os_out};
		 DataK ={56'b0,datak};
		 DataValid={56'b0,datavalid};
		 end
		else if (count==5'b01000)begin
		 Os_Out={384'b0,os_out};
		 DataK={48'b0,datak};
		 DataValid={48'b0,datavalid};
		 end
		 else begin
		 Os_Out={256'b0,os_out};
		 DataK={32'b0,datak};
		 DataValid={32'b0,datavalid};
		 end
	  end
	    // *******************************************pipewidth=32************************************************************************
	else if(PIPE==6'b100000) begin
	  if(send)begin
	   busy = 1'b1;
	   finish=1'b0;
	   datavalid = {{no_of_lanes{valid}},{no_of_lanes{valid}},{no_of_lanes{valid}},{no_of_lanes{valid}}};
       //*****************************************checking if TS1 order sets to be sent*******************************************
	   if (os_type_reg==2'b00)begin
		
		  if(symbol==4'b0000)begin // checking if symbols 1,2,3,4 are to be sent
		     if(lane_number_reg==2'b00 )begin
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{8'hF7},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{32'hF7F7F7F7},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{64'hF7F7F7F7F7F7F7F7},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			 
				 
			  else begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{128'hF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			  end
			 
			 else if(lane_number_reg==2'b01)begin // checking if lanes number are sequential
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{8'h00},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				 
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{32'h03020100},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				  if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{64'h0706050403020100},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				  if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			     end
				 
			 else begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{128'h0F0E0D0C0B0A09080706050403020100},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				  if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			 end
			 
			 else begin // checking if lanes number are sequentially reversed
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{8'h01},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{32'h01020304},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{64'h0102030405060708},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				 
			   else begin
			     os_out = {{no_of_lanes{TS1[31:24]}},{128'h0102030405060708090A0B0C0D0E0F10},{no_of_lanes{TS1[15:8]}},{no_of_lanes{TS1[7:0]}}};
				 if (TS1[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			 end
			end
			
			
		else if(symbol==4'b0100) begin // checking if symbols 4,5,6,7 are to be sent
		    os_out ={{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[47:40]}},{no_of_lanes{TS1[39:32]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}}};
			end
		
			
		else if(symbol==4'b1000) begin // checking if symbols 8,9,10,11  are to be sent
		    os_out ={{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}}};
			end
			
		else  begin // checking if symbols 12,13,14,15 are sent
		    os_out ={{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}},{no_of_lanes{TS1[55:48]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}}};
			send =1'b0;
			finish =1'b1;
			busy =1'b0;
		    end
			 symbol=symbol+4; 
		  end 
			//*****************************************checking if TS2 order sets to be sent*******************************************
	    else if (os_type_reg==2'b01)begin
		
		  if(symbol==4'b0000)begin // checking if symbols 1,2,3,4 are to be sent
		     if(lane_number_reg==2'b00 )begin
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{8'hF7},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			
				 
			   else if (count==00100)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{32'hF7F7F7F7},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				
				 
			   else if (count==01000)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{64'hF7F7F7F7F7F7F7F7},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			 
				 
			  else begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{128'hF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			  end
			 
			 else if(lane_number_reg==2'b01)begin // checking if lanes number are sequential
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{8'h01},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				 
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{32'h04030201},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				  if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{64'h0807060504030201},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				  if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			     end
				 
			 else begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{128'h100F0E0D0C0B0A090807060504030201},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				  if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			 end
			 
			 else begin // checking if lanes number are sequentially reversed
			   if (count==5'b00001)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{8'h01},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				 
			   else if (count==5'b00100)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{32'h01020304},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				 
			   else if (count==5'b01000)begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{64'h0102030405060708},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
				 
			   else begin
			     os_out = {{no_of_lanes{TS2[31:24]}},{128'h0102030405060708090A0B0C0D0E0F10},{no_of_lanes{TS2[15:8]}},{no_of_lanes{TS2[7:0]}}};
				 if (TS2[15:8] == 8'hF7)
                   datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}},{no_of_lanes{K}}};  
	             else 
			       datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{K}}};
			    end
			 end
			end	
			
		else if(symbol==4'b0100) begin // checking if symbols 4,5,6,7 are to be sent
		    os_out ={{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[55:48]}},{no_of_lanes{TS2[47:40]}},{no_of_lanes{TS2[39:32]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}}};
			end
		
			
		else if(symbol==4'b1000) begin // checking if symbols 8,9,10,11 are to be sent
		    os_out ={{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[63:56]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}}};
			end
			
		else  begin //checking if symbols 12,13,14,15 are to be sent
		    os_out ={{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[63:56]}},{no_of_lanes{TS2[63:56]}}};
			datak ={{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}},{no_of_lanes{D}}};
			send =1'b0;
			finish =1'b1;
			busy =1'b0;
		    end
			 symbol=symbol+4; 
			 
		  end 
		  // ******************************************************checking if skip order sets to be sent********************************************
      else if (os_type_reg==2'b10)begin  
		    os_out={{no_of_lanes{skp[31:24]}},{no_of_lanes{skp[23:16]}},{no_of_lanes{skp[15:8]}},{no_of_lanes{skp[7:0]}}};
			datak={{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};
			send =1'b0;
			finish=1'b1;
			busy=1'b0; 
		  end 
		  // ******************************************************checking if EIOS order sets to be sent********************************************
      else begin
		    os_out={{no_of_lanes{EIOS[31:24]}},{no_of_lanes{EIOS[23:16]}},{no_of_lanes{EIOS[15:8]}},{no_of_lanes{EIOS[7:0]}}};
			datak={{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}},{no_of_lanes{K}}};
			send=1'b0;
			finish=1'b1;
			busy=1'b0;
		 end
	 end
  else begin  //if there are no order sets available to be sent
		  datavalid = {no_of_lanes{not_valid}};
		  os_out={no_of_lanes*GEN1_PIPEWIDTH{not_valid}};
		  datak= {no_of_lanes{not_valid}};
		  finish=1'b0;
		  busy= 1'b0;
		 end
		if (count==5'b00001)begin
		 Os_Out={480'b0,os_out};
		 DataK ={60'b0,datak};
		 DataValid={60'b0,datavalid};
		 end
		else if (count==5'b00100)begin
		 Os_Out={384'b0,os_out};
		 DataK ={48'b0,datak};
		 DataValid={48'b0,datavalid};
		 end
		else if (count==5'b01000)begin
		 Os_Out={256'b0,os_out};
		 DataK={32'b0,datak};
		 DataValid={32'b0,datavalid};
		 end
		 else begin
		 Os_Out=os_out;
		 DataK=datak;
		 DataValid=datavalid;
		 end
	  end
 else begin  
		  Os_Out = 512'b0;
		  DataValid=64'b0;
		  DataK= 64'b0;
		  finish=1'b0;
		  busy= 1'b0;
		 end
	  end
	endmodule	  
