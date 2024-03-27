`timescale 1ns/1ns
module tb_rgb565_to_ycrcb422();

reg             sys_clk     ;
reg             sys_rst_n   ;
reg     [15:0]  rgb_data    ;

wire    [7:0]   img_out     ;
wire    [1:0]   state       ;

initial
    begin
        sys_clk=1'b1;
        rgb_data=16'h1234;
        sys_rst_n<=1'b0;
        #20
        sys_rst_n<=1'b1;
    end
    
always #10 sys_clk=~sys_clk;

rgb565_to_ycbcr422      rgb565_to_ycbcr422_inst
(
    .sys_clk         (sys_clk  ),
    .sys_rst_n       (sys_rst_n),
    .rgb_data        (rgb_data ),

    .img_out         (img_out  ),
    .state           (state    )
);






endmodule