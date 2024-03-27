`timescale 1ns/1ns
module tb_YCbCr_pingpang();

reg                     sys_clk         ;
reg                     sys_rst_n       ;
reg     signed  [7:0]   img_out         ;
reg             [1:0]   state_Ycc       ;
reg                     data_en         ;

wire    signed  [7:0]   data_out        ;
wire                    rd_end          ;

initial 
    begin
        sys_clk=1'b1;
        sys_rst_n=1'b0;
        #20
        sys_rst_n=1'b1;
        img_out=8'd0;
        state_Ycc=2'd0;
        data_en=1'b0;
    end
    
always #10 sys_clk=~sys_clk;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        img_out<=8'd0;
    else if(img_out==8'b1111_1111)
        img_out<=8'd0;
    else if(data_en==1'b1)
        img_out<=img_out+1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        state_Ycc<=2'd0;
    else if(state_Ycc==2'b11)
        state_Ycc<=2'd0;
    else if(data_en==1'b1)
        state_Ycc<=state_Ycc+1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        data_en<=1'b0;
    else 
        data_en<=1'b1;
YCbCr_pingpang      YCbCr_pingpang_inst
(
    .sys_clk         (sys_clk  ),
    .sys_rst_n       (sys_rst_n),
    .img_out         (img_out  ),
    .state_Ycc       (state_Ycc),
    .data_en         (data_en  ),

    .data_out        (data_out ),
    .rd_end          (rd_end   )
);


endmodule