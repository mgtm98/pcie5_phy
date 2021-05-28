module PIPE_Control(generation, pclk, reset_n, RxStatus, ElecIdle_req, Detect_req, PhyStatus, TxDetectRx_Loopback, PowerDown, Detect_status, TxElecIdle);


parameter number_of_lanes= 4;


input pclk, reset_n;
input [2:0] generation;
input [2:0] RxStatus; 
input ElecIdle_req, Detect_req, PhyStatus;

output reg TxDetectRx_Loopback;
output reg [3:0] PowerDown;
output reg Detect_status; 
output reg TxElecIdle;

reg flag;

always @(posedge pclk or negedge reset_n) begin
  if (~reset_n) begin
  	PowerDown=0;
  	Detect_status=0;
  	TxElecIdle=0;
  	TxDetectRx_Loopback=0;
  end
  
  if (ElecIdle_req==1) begin
  		TxElecIdle=1;
  end
  else begin
  		TxElecIdle=0;
  end
  	
  if (Detect_req==1) begin
  		TxDetectRx_Loopback =1;
  		PowerDown = 4'b0010;
  		flag=1;
  end

  if(flag==1) begin
  	if (PhyStatus==1 && RxStatus==3'b011) begin
  		TxDetectRx_Loopback =0;
  		Detect_status=1;
  		flag=0;
  	end
  	else begin
  		Detect_status=0;
  	end
  end

 end

 endmodule