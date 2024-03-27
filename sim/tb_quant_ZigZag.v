`timescale 1ns/1ns
module tb_quant_ZigZag();

reg                    sys_clk         ;
reg                    sys_rst_n       ;
reg    signed  [11:0]  DCT_data        ;
reg                    ZigZag_start    ;

wire   signed  [11:0]  ZigZag_data     ;
wire                   rd_en           ;

initial
    begin
        sys_clk=1'b1;
        sys_rst_n=1'b0;
        ZigZag_start=1'b0;
        #20
        sys_rst_n=1'b1;
        #20
        ZigZag_start=1'b1;
    end

always #10 sys_clk=~sys_clk;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DCT_data<=12'd0;
    else if(ZigZag_start==1'b0 || DCT_data==12'd63)
        DCT_data<=12'd0;
    else
        DCT_data<=DCT_data+1'b1;

quant_ZigZag    quant_ZigZag_inst
(
    .sys_clk     (sys_clk     ),
    .sys_rst_n   (sys_rst_n   ),
    .DCT_data    (DCT_data<<6 ),
    .ZigZag_start(ZigZag_start),

    .ZigZag_data (ZigZag_data ),
    .rd_en       (rd_en       )
);


endmodule