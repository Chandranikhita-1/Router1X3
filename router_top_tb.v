module router_top_tb();
reg  clk, resetn,packet_valid,read_enb_0, read_enb_1, read_enb_2;
reg [7:0] datain;
wire err, busy,vldout_0, vldout_1, vldout_2;
wire  [7:0]data_out_0, data_out_1, data_out_2;

router_top UUT(.datain(datain),.packet_valid(packet_valid), .clk(clk), .resetn(resetn),.read_enb_0(read_enb_0), .read_enb_1(read_enb_1), .read_enb_2(read_enb_2),.err(err), .busy(busy),
.data_out_0(data_out_0), .data_out_1(data_out_1), .data_out_2(data_out_2),.vldout_0(vldout_0), .vldout_1(vldout_1), .vldout_2(vldout_2));



// task initialize

task initialize;
begin
clk=1'b0;
resetn=1'b0;
end
endtask

always #10 clk=~clk;   //clock




//task resetn.

task rst_dut;
begin
@(negedge clk)
resetn=1'b0;
@(negedge clk)
resetn=1'b1;
end
endtask


// Sending the packet

task packet_14();
reg [7:0] payload_data,header,parity;
reg [5:0]payload_len;
reg [1:0] addr;
integer k;
begin
@(negedge clk)
wait(~busy)                       // header is sent
@(negedge clk)
payload_len=6'd14;
addr=2'b01;
header={payload_len,addr};
parity=8'b0;
datain=header;
packet_valid=1'b1;
parity=parity^header;


//payload data is being sent


@(negedge clk)
wait(~busy)
for (k=0;k<payload_len;k=k+1)
begin
@(negedge clk)
wait(~busy)
payload_data={$random}%256;
datain=payload_data;
parity=parity^datain;
end

//parity

@(negedge clk)
wait(~busy)
packet_valid=1'b0;
datain=parity;
end
endtask

// packet_16 
task packet_16();
reg [7:0] payload_data,header,parity;
reg [5:0]payload_len;
reg [1:0] addr;
integer k;
begin
@(negedge clk)
wait(~busy)
@(negedge clk)
payload_len=6'd16;
addr=2'b00;
header={payload_len,addr};             // header is sent

parity=8'b0;
datain=header;
packet_valid=1'b1;
parity=parity^header;

@(negedge clk)
wait(~busy)
for (k=0;k<payload_len;k=k+1)
begin
@(negedge clk)                       //payload data is being sent
wait(~busy)
payload_data={$random}%256;
datain=payload_data;
parity=parity^datain;
end

@(negedge clk)
wait(~busy)
packet_valid=1'b0;                 //parity
datain=parity;
end
endtask


//task calling

initial
begin
initialize;
rst_dut;
packet_16;
@(negedge clk)
read_enb_1=1'b1;              
wait(!vldout_1)             // until empty =1
@(negedge clk)
read_enb_1=1'b0;
#10;

packet_14;
@(negedge clk)
read_enb_0=1'b1;
wait(!vldout_0)            //until empty=1
@(negedge clk)
read_enb_0=1'b0;

packet_16;
@(negedge clk)
read_enb_2=1'b1;
wait(!vldout_2)             // until empty=1
@(negedge clk)
read_enb_2=1'b0;
end
endmodule





