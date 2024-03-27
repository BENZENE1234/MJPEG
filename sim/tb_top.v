`timescale 1ns/1ns
module tb_top();

reg                     sys_clk         ;
reg                     sys_rst_n       ;
reg             [15:0]  rgb_data        ;

wire            [7:0]   JFIF_data       ;
wire                    fifo_wr_req     ;

initial
    begin
        sys_clk=1'b1;
        rgb_data=16'd0;
        sys_rst_n<=1'b0;
        #20
        sys_rst_n<=1'b1;
        rgb_data=16'h1111;
        #160
        rgb_data=16'h2222;
        #160
        rgb_data=16'h3333;
        #160
        rgb_data=16'h4444;
        #160
        rgb_data=16'h4444;
    end
    
always #10 sys_clk=~sys_clk;

top     top_inst
(
    .sys_clk         (sys_clk    ),
    .sys_rst_n       (sys_rst_n  ),
    .rgb_data        (rgb_data   ),

    .JFIF_data       (JFIF_data),
    .fifo_wr_req     (fifo_wr_req)
);


endmodule