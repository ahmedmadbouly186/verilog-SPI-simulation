module Master_TB();
reg reset;
reg start;
reg [0:7]MasterDataToSend;
wire [0:7]MasterDataReceived;
reg [1:0] slaveSelect;
wire [0:2] CS;
reg MDI;
wire MDO;
wire SCLK;
reg clk;
Master UUT_M(
	clk, reset,
	start, slaveSelect, MasterDataToSend, MasterDataReceived,
	SCLK, CS, MDO, MDI);

reg [7:0]TestDataToSend;
reg [7:0]TestDataReceived;
integer index_sent;
integer index_recived;
localparam TESTCASECOUNT = 4;
integer failures;
integer i;
localparam PERIOD = 20;


always @(posedge clk)
begin
    if(index_sent<8)
        begin
        MDI=TestDataToSend[index_sent];
        index_sent=index_sent+1;
    end
end

always @(negedge clk)
begin
    if(index_recived<8 & index_sent>0)
        begin
        TestDataReceived[index_recived]=MDO;
        index_recived=index_recived+1;
    end
end

wire [7:0] testcase_MasterData [1:TESTCASECOUNT];
wire [7:0] testcase_benchData  [1:TESTCASECOUNT];


assign testcase_MasterData[1] = 8'b01010011;
assign testcase_benchData[1] = 8'b01111111;

assign testcase_MasterData[2] = 8'b00100010;
assign testcase_benchData[2] = 8'b10000011;

assign testcase_MasterData[3] = 8'b00111100;
assign testcase_benchData[3] = 8'b10011000;

assign testcase_MasterData[4] = 8'b00100101;
assign testcase_benchData[4] = 8'b11000010;

initial begin
TestDataToSend=0;
 start=0;
reset =1;
failures=0;
clk=0;
slaveSelect=0;
#PERIOD reset = 0;
TestDataReceived=0;
for(i = 1; i <= TESTCASECOUNT; i=i+1) begin
index_sent=0;
 index_recived=0;
MasterDataToSend=testcase_MasterData[i];
TestDataToSend=testcase_benchData[i];
start=1;
#PERIOD start=0;
#(20*PERIOD);
if(TestDataReceived == MasterDataToSend) $display("Sending data From Master to the Test_Bench: Success");
		else begin
			$display("Sending data From Master to Test_Bench: Failure (Expected: %b, Received: %b). The data input to the master is:%b", MasterDataToSend, TestDataReceived,MasterDataToSend);
				failures = failures + 1;
end
			// Check that the slave correctly received the data that should have been sent by the master
if(MasterDataReceived == TestDataToSend) $display("Receiving data From Test_bench to Master : Success");
		else begin
			$display("Receiving data From Test_bench to Master : Failure (Expected: %b, Received: %b). The data input to the test_bench is:%b", TestDataToSend, MasterDataReceived,TestDataToSend);
				failures = failures + 1;
end
 end
 if(failures) $display("FAILURE: %d out of %d testcases have failed", failures, 2*TESTCASECOUNT);
	else $display("SUCCESS: All %d testcases have been successful", 2*TESTCASECOUNT);
 
 $finish;
end
always #(PERIOD/2) clk = ~clk;
endmodule