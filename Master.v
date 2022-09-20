module Master(
	input clk,input reset,
	input start,input [1:0]slaveSelect,input [7:0]masterDataToSend,output [7:0]masterDataReceived,
	output SCLK,output [0:2]CS,output MOSI,input MISO
);
reg [7:0]MasterDataToSend;
integer c = 100;
reg store;//store the value to send
assign SCLK = clk;
reg [2:0] csss; /////// to Store CS Value
reg enable=1'b0;

assign CS = csss;
assign MOSI = store;
assign masterDataReceived = MasterDataToSend;
/////////////////////////////////////
always@(masterDataToSend)
begin
if (start==1 & c>8)
begin
c=0;
if(slaveSelect == 2'b00)
    csss = 3'b011;
else if(slaveSelect == 2'b01)
    csss = 3'b101;
else if(slaveSelect == 2'b10)
    csss = 3'b110;
else
    csss = 3'b111;
end
end
//////////////////////////////////////
always@(posedge start)
begin
if (c>8)begin
c=0;
if(slaveSelect == 2'b00)
    csss = 3'b011;
else if(slaveSelect == 2'b01)
    csss = 3'b101;
else if(slaveSelect == 2'b10)
    csss = 3'b110;
else
    csss = 3'b111;
end
end
///////////////////////////////
always @(reset)
begin
if(reset == 1)
begin
    MasterDataToSend = 0;
end
end

always @(posedge clk)
begin
    if(c == 0)
        begin
         MasterDataToSend = masterDataToSend;
        end
    if(c < 8)
        begin
        store = MasterDataToSend[0];
        MasterDataToSend =  MasterDataToSend >> 1;
        c = c + 1;
    end
end

always@(negedge clk)
begin

if( c <= 8 )
begin
MasterDataToSend[7] = MISO;
if (c==8)c=c+1;
end
if (c>8)csss=3'b111;
end
endmodule


