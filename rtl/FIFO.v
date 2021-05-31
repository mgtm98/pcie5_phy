module FIFO(reset_n,data_in,wr,rd,wr_valid,pclk,STP_IN,SDP_IN,END_IN,empty,full,data_out,STP_OUT,SDP_OUT,END_OUT,rd_valid);
parameter W=128;
input reset_n;
input wr;
input rd;
input pclk;
input[63:0] wr_valid;
input[63:0] STP_IN;
input[63:0] SDP_IN;
input[63:0] END_IN;
input[511:0] data_in;
output reg full;
output reg empty;
output reg[63:0] rd_valid;
output reg[63:0] STP_OUT;
output reg[63:0] SDP_OUT;
output reg[63:0] END_OUT;
output reg[511:0] data_out;
reg [767:0] FIFO [0:W-1];
reg [6:0] writecounter;
reg [6:0] readcounter;
always @(posedge pclk) begin
 if (reset_n==1'b0) begin
   writecounter=7'b0;
   readcounter=7'b0;
   empty=1'b1;
   full=1'b0;
  end
  
 if(wr==1'b1 && rd==1'b0)begin
  FIFO[writecounter][511:0]=data_in;
  FIFO[writecounter][575:512]=STP_IN;
  FIFO[writecounter][639:576]=SDP_IN;
  FIFO[writecounter][703:640]=END_IN;
  FIFO[writecounter][767:704]=wr_valid;
  data_out=512'b0;
  STP_OUT=64'b0;
  SDP_OUT=64'b0;
  END_OUT=64'b0;
  rd_valid=64'b0;
  writecounter=writecounter+1;
  empty=1'b0;
  if (writecounter==readcounter)
     full=1'b1;
  else
     full=1'b0;
 end
  
 else if (rd==1'b1 && wr==1'b0) begin
    data_out=FIFO[readcounter][511:0];
	STP_OUT=FIFO[readcounter][575:512];
	SDP_OUT=FIFO[readcounter][639:576];
	END_OUT=FIFO[readcounter][703:640];
	rd_valid=FIFO[readcounter][767:704];
	readcounter=readcounter+1;
	 full=1'b0;
	if(readcounter==writecounter)
	 empty=1'b1;
	else
	 empty=1'b0;
	end
	
 else if (wr==1'b1 && rd==1'b1) begin
  FIFO[writecounter][511:0]=data_in;
  FIFO[writecounter][575:512]=STP_IN;
  FIFO[writecounter][639:576]=SDP_IN;
  FIFO[writecounter][703:640]=END_IN;
  FIFO[writecounter][767:704]=wr_valid;
  data_out=FIFO[readcounter][511:0];
  STP_OUT=FIFO[readcounter][575:512];
  SDP_OUT=FIFO[readcounter][639:576];
  END_OUT=FIFO[readcounter][703:640];
  rd_valid=FIFO[readcounter][767:704];
  writecounter=writecounter+1;
  readcounter=readcounter+1;
  full=1'b0;
  empty=1'b0;
 end
 
 else begin
  data_out=512'b0;
  STP_OUT=64'b0;
  SDP_OUT=64'b0;
  END_OUT=64'b0;
  rd_valid=64'b0;
 end 
 end
 endmodule
	
	   
 



