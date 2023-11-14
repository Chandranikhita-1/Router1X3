module router_sync_tb();
reg clk,resetn,detect_add,write_enb_reg;

reg  [1:0]datain;
reg read_enb_0,read_enb_1,read_enb_2;
reg empty_0,empty_1,empty_2,full_0,full_1,full_2;
wire [2:0]write_enb;
wire fifo_full;
wire soft_reset_0,soft_reset_1,soft_reset_2;
wire vld_out_0,vld_out_1,vld_out_2;

router_sync dut(clk,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,datain,
vld_out_0,vld_out_1,vld_out_2,write_enb,fifo_full, soft_reset_0,soft_reset_1,soft_reset_2);

parameter Tp=20;

//clock genertaion


always 
begin
clk=1'b0;
#(Tp/2) clk = 1'b1;
#(Tp/2);
end

// initialize task

task initialize;
begin
{resetn,write_enb_reg,detect_add,datain}=0;
{read_enb_0,read_enb_1,read_enb_2}=0;
{empty_0,empty_1,empty_2}=3'b111;
{full_0,full_1,full_2}=0;

end
endtask


//reset task


task restn;
begin
@(negedge clk)
resetn=1'b0;
@(negedge clk)
resetn=1'b1;
end
endtask

//data in task

task dataip(input [1:0]i);
begin                              // To drive our data. (00, 01,10)
@(negedge clk)
datain=i;
end
endtask


initial begin    // calling tasks.
initialize;
restn;
dataip(2);
detect_add=1'b1;       // after the two steps its stored in the temp as 10.

dataip(2);
write_enb_reg=1'b1;               // we observe write_enb=100
#Tp;
dataip(3);
#Tp dataip(1);
//full_0=1;
//full_2=1;
full_1=1;
#40 empty_0=0;              // vld_out_0=1
#640;      // for 30 clock cycles 30x20=600. 

read_enb_0=1'b1;
#40 $finish;
end
endmodule



