module router_reg_tb();
reg [7:0] datain;
reg  clk,resetn,packet_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
wire err,parity_done,low_packet_valid;
wire [7:0] dout;

reg [7:0]hold_header_byte,fifo_full_state_byte,internal_parity,packet_parity_byte;        // for internal registers

router_reg dut(clk,resetn,packet_valid,datain,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);
// instantiate the design(rtl)


// task for initiating the input.

task initialise;
begin
clk=1'b0;
resetn=1'b0;
packet_valid=1'b0;
fifo_full=0;
detect_add=0;
ld_state=0;
laf_state=0;
full_state=0;
lfd_state=0;
rst_int_reg=0;
end
endtask


// clock
always #10 clk=~clk;

//task for reseting 

task rstn;
begin
@(negedge clk)
resetn=1'b0;
@(negedge clk)
resetn=1'b1;
end 
endtask

initial
 begin
initialise;
rstn;
fifo_full=0;
full_state=0;

packet_valid=1; // it will be in hold header byte
datain=5;
detect_add=1;

detect_add=0;
lfd_state=1;     // dout=5 (   as header header byte  becomes as an output)

lfd_state=0;

datain=7;
ld_state=1;
datain=8;
datain=2;       // will observe 7,8,2,3 at dout
datain=3;

ld_state=0;      // datain will be stored in ffb.
fifo_full=1;
full_state=1;
datain=2;

// check whether the data is read from ffb:

fifo_full=0;
full_state=0;
laf_state=1;             // 2 should be available at dout.


laf_state=0;            // parity bye
packet_valid=0;
datain=3;              // stored in Packet parity register
rst_int_reg=1;

//(internal parity=xor of header and payload)
  // 5^7=Res ^8......)
  //internal_parity= parity_reg_previous^header_byte;
//parity_reg=parity_reg_previous^payload1

end
initial #180 $finish;
endmodule





