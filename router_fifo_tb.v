module router_fifo_tb();
reg clk,resetn,soft_reset,write_enb,read_enb,lfd_state;
reg [7:0] datain;
wire empty, full;
wire [7:0] dataout;
integer i;
integer k;

// step1: instantiate the RAM module and connect the ports.

router_fifo dut (clk,resetn,soft_reset,write_enb,read_enb,lfd_state,datain,full,empty,dataout);

// task for initiating the input.

task initialize ;
begin
clk=1'b0;
resetn=1'b0;
soft_reset=1'b0;
write_enb=1'b0;
read_enb=1'b0;
end
endtask


always #10 clk=~clk;


//task for reseting the dut.


task resetn_dut;
begin
@(negedge clk)
resetn=1'b0;
@(negedge clk)
resetn=1'b1;
end 
endtask


//task for soft_reset

task soft_reset_dut;
begin
@(negedge clk)
soft_reset=1'b1;
@(negedge clk)
soft_reset=1'b0;
end
endtask

//task for writing into the memory location.

task write_fifo;
reg[7:0]payload_data,parity,header;
reg[5:0]payload_length;
reg[2:0]addr;
begin
@(negedge clk)
payload_length=6'd14;
addr=2'b01;
header={payload_length,addr};
datain=header;
lfd_state=1'b1;
write_enb=1'b1;

for(k=0;k<payload_length;k=k+1)          // for the next 14 clock cycles
begin
@(negedge clk)
lfd_state=1'b0;
payload_data={$random}%256;
datain=payload_data;
end
@(negedge clk)
lfd_state=1'b0;
parity={$random}%256;
datain=parity;
end
endtask


//task for raeding from the memory.

task read_fifo;
begin
@(negedge clk)
write_enb=1'b0;
read_enb=1'b1;
end
endtask

//task for delay

task delay;
begin
#50;
end
endtask


//process to call all the task for writing and reading.

initial
begin
initialize;
delay;
resetn_dut;
soft_reset_dut;
write_fifo;
for(i=0;i<17;i=i+1)
read_fifo;
delay;
read_enb=1'b0;
end
endmodule

