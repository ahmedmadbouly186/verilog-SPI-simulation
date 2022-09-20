
module Slave_TB();
reg reset;// 
reg [0:7]slaveDataToSend;
wire [0:7]slaveDataReceived;
reg CS;//
reg SDI;
wire SDO;
reg SCLK;
Slave l1(reset,slaveDataToSend,slaveDataReceived,SCLK,CS,SDI,SDO);

reg [7:0]TestDataToSend;
reg [7:0]TestDataReceived;
integer index_sent;
integer index_recived;
localparam TESTCASECOUNT = 4;
integer failures;
integer i=1;
localparam PERIOD = 20;
always #(PERIOD/2) SCLK = ~SCLK;

always@(TestDataToSend)
CS=1'b0;
always @(posedge SCLK)
begin
    if(index_sent<8)
        begin
        SDI=TestDataToSend[index_sent];
        index_sent=index_sent+1;
    end
end
always @(negedge SCLK)
begin
    if(index_recived<=8 & index_sent>0)
        begin
        TestDataReceived[index_recived]=SDO;
        index_recived=index_recived+1;
        if (index_recived==8)
        begin
        CS=1'b1;
        end
    end
end

wire [7:0] testcase_slaveData [1:TESTCASECOUNT];
wire [7:0] testcase_benchData  [1:TESTCASECOUNT];


assign testcase_slaveData[1] = 8'b01010011;
assign testcase_benchData[1] = 8'b10001001;

assign testcase_slaveData[2] = 8'b00100010;
assign testcase_benchData[2] = 8'b00000011;

assign testcase_slaveData[3] = 8'b00111100;
assign testcase_benchData[3] = 8'b10011000;

assign testcase_slaveData[4] = 8'b00100101;
assign testcase_benchData[4] = 8'b11000010;
 

initial begin
reset=1'b0;
CS=1'b1;
failures=0;
SCLK=0;
index_sent=0;
index_recived=0;
TestDataReceived=0;//just intialization (dosnt matter)
for(i = 1; i <= TESTCASECOUNT; i=i+1)
begin
    #PERIOD  CS=1'b0;
    index_sent=0;
    index_recived=0;
    slaveDataToSend=testcase_slaveData[i];
    TestDataToSend=testcase_benchData[i];
    #(20*PERIOD);
     CS=1'b1;
    if(TestDataReceived == slaveDataToSend) $display("Sending data From Slave to the Test_Bench: Success");
	else 
	begin
			$display("Sending data From Slave to Test_Bench: Failure (Expected: %b, Received: %b . The data input to the slave is :%b)", slaveDataToSend, TestDataReceived,slaveDataToSend);
				failures = failures + 1;
	end
			// Check that the slave correctly received the data that should have been sent by the master
    if(slaveDataReceived == TestDataToSend) $display("Receiving data From Test_bench to Slave : Success");
		else
		begin
			$display("Receiving data From Test_bench to Slave : Failure (Expected: %b, Received: %b . The data input to the test_bench is:%b)", TestDataToSend, slaveDataReceived,TestDataToSend);
				failures = failures + 1;
		end
end
if(failures) $display("FAILURE: %d out of %d testcases have failed", failures, 2*TESTCASECOUNT);
	else $display("SUCCESS: All %d testcases have been successful", 2*TESTCASECOUNT);
 $finish;
end
endmodule