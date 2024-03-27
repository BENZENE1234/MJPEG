`timescale 1ns/1ns
module tb_huffman_encoder();

reg                     sys_clk         ;
reg                     sys_rst_n       ;
reg     signed  [11:0]  ZigZag_data     ;
reg                     start_encoder   ;
reg             [1:0]   data_state      ;

wire            [7:0]   JPEG_data_o     ;
wire                    JPEG_data_en    ;
wire                    frame_en        ;

initial begin
    sys_clk=1'b1;
    sys_rst_n<=1'b0;
    #20
    sys_rst_n<=1'b1;
    start_encoder<=1'b1;
    data_state<=2'd1;
    ZigZag_data<=5;
    #20
    ZigZag_data<=-3;
    #20
    ZigZag_data<=2;
    #20
    ZigZag_data<=1;
    #20
    ZigZag_data<=-1;
    #20
    ZigZag_data<=1;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20
    ZigZag_data<=0;
    #20    
    ZigZag_data<=-1;
    #20
    ZigZag_data<=1;
    #820
    ZigZag_data<=10;
    #20
    ZigZag_data<=10;
    #20
    ZigZag_data<=1;
    #20
    ZigZag_data<=1;
    #20
    ZigZag_data<=1;
    #20
    ZigZag_data<=1;
    #20
    ZigZag_data<=1;
        #20
    ZigZag_data<=0;
end

always #10 sys_clk=~sys_clk ;

huffman_encoder     huffman_encoder_inst
(
    .sys_clk         (sys_clk),
    .sys_rst_n       (sys_rst_n),
    .ZigZag_data     (ZigZag_data),
    .start_encoder   (start_encoder),
    .data_state      (data_state),

    .JPEG_data_o     (JPEG_data_o),
    .JPEG_data_en    (JPEG_data_en),
    .frame_en       (frame_en)
);



endmodule