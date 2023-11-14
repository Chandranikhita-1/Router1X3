module router_fsm_tb();
reg clk,resetn,packet_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid;
reg [1:0]datain;
wire write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;

router_fsm dut (clk,resetn,packet_valid,datain,
fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

parameter Tp=20;

//clock genertation.

always begin
clk=1'b0;
#( Tp/2) clk=1'b1;
# (Tp/2) ;
end

// initilalize task

task initialize;
begin
{resetn,soft_reset_0,soft_reset_1,soft_reset_2}=0;
datain=0;
{packet_valid,low_packet_valid}=2'b00;
fifo_full=0;
parity_done=0;
{fifo_empty_0,fifo_empty_1,fifo_empty_2}=3'b111;

end
endtask

// resetn task

task rstn;
begin                 // ACTIVE LOW
@(negedge clk)
resetn=1'b0;
@(negedge clk)
resetn=1'b1;
end
endtask

// soft_reset_0 task

task soft_rst_0;                // ACTIVE HIGH
begin
soft_reset_0=1'b1;
#15 soft_reset_0=1'b0;
end
endtask 

// soft_reset_1 task

task soft_rst_1;    //ACTIVE HIGH
begin
soft_reset_1=1'b1;
#15 soft_reset_1=1'b0;
end
endtask 

// soft_reset_2 task



task soft_rst_2;   // ACTIVE HIGH
begin
soft_reset_2=1'b1;
#15 soft_reset_2=1'b0;
end
endtask 

task DA_LFD_LD_LP_CPE_DA;
begin
packet_valid=1'b1;                // TRANSITION FROM DA TO LFD   (DA becomes low and LFD becomes high)
datain=2'b00;                    // lfd to ld unconditional)
fifo_empty_0=1'b1;
#100;

packet_valid=0;         // ld to lp  (fifo_full and packet_valid is 0)   (LD becomes low as parity valid is 0)  ( lp to cpe is unconditional)  
fifo_full=0;             // cpe to de (fifo_full is 0)
end
endtask

task  DA_LFD_LD_FFS_LAF_LP_CPE_DA;
begin
packet_valid=1'b1;    // TRANSITION FROM DA TO LFD   (DA becomes low and LFD becomes high)
datain=2'b01;          // lfd to ld (is unconditinal)
fifo_empty_1=1'b1;

#100 fifo_full=1'b1;     // ld to ffs
#20 fifo_full=1'b0;      // ffs to laf

#20 parity_done=0;       // laf to lp   (lp to cpe is unconditional)
low_packet_valid=1'b1;
#40 packet_valid=1'b0;
fifo_full=0;             // cpe to da
end
endtask

task DA_LFD_LD_FFS_LAF_LD_LP_CPE_DA;
begin
packet_valid=1'b1;    // TRANSITION FROM DA TO LFD   (DA becomes low and LFD becomes high)
datain=2'b01;          // lfd to ld (is unconditinal)
fifo_empty_1=1'b1;
#100 fifo_full=1'b1;     // ld to ffs
#20 fifo_full=1'b0;      // ffs to laf

#20 parity_done=0;       // laf to ld  
low_packet_valid=1'b0;

#20 packet_valid=0; 
fifo_full=0;       // ld to lp    (lp to cpe unconditional)

#40 packet_valid=1'b0;   // cpe to da.
fifo_full=0;

end
endtask

task DA_LFD_LD_LP_CPE_FFS_LAF_DA;
begin
packet_valid=1'b1;    // TRANSITION FROM DA TO LFD   (DA becomes low and LFD becomes high)
datain=2'b01;          // lfd to ld (is unconditinal)
fifo_empty_1=1'b1;  

#20 fifo_full=0;
packet_valid=0;         // ld to lp    (lp to cpe unconditional)

#20 fifo_full=1;       // cpe to ffs

#20 fifo_full=0;       // ffs to laf

#40 parity_done=1;     // laf to da
end
endtask

initial
begin
initialize;
rstn;
DA_LFD_LD_LP_CPE_DA;
#200;
DA_LFD_LD_FFS_LAF_LP_CPE_DA;
#160;
DA_LFD_LD_FFS_LAF_LD_LP_CPE_DA;
#200;
DA_LFD_LD_LP_CPE_FFS_LAF_DA;
#100;
$finish;
end
endmodule




