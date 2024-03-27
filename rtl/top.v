module top
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire            [15:0]  rgb_data        ,

    output  wire            [7:0]   JFIF_data       ,
    output  wire                    fifo_wr_req
);

//色域转换
wire            [7:0]   img_out         ;
wire            [1:0]   state           ;
wire                    start_en        ;
//分块
wire            [7:0]   data_out        ;
wire                    rd_end          ;
//串转并
wire                    change_end      ;
wire            [95:0]  Dct_data_in     ;
//二维DCT变换
wire    signed  [11:0]  DCT_data_o_z0   ;
wire    signed  [11:0]  DCT_data_o_z1   ;
wire    signed  [11:0]  DCT_data_o_z2   ;
wire    signed  [11:0]  DCT_data_o_z3   ;
wire    signed  [11:0]  DCT_data_o_z4   ;
wire    signed  [11:0]  DCT_data_o_z5   ;
wire    signed  [11:0]  DCT_data_o_z6   ;
wire    signed  [11:0]  DCT_data_o_z7   ;
wire                    data_en         ;
//并转串
wire    signed  [11:0]  DCT_data        ;
wire                    ZigZag_start    ;
//量化扫描
wire    signed  [11:0]  ZigZag_data     ;
wire                    rd_en           ;
wire            [1:0]   data_state      ;
//霍夫曼编码
wire            [7:0]   JPEG_data_o     ;
wire                    JPEG_data_en    ;
wire                    frame_en        ;
wire                    frame_end_flag  ;
wire                    frame_end_flag_1;

//色域转换
rgb565_to_ycbcr422      rgb565_to_ycbcr422_inst
(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .rgb_data           (rgb_data           ),

    .img_out            (img_out            ),
    .state              (state              ),
    .start_en           (start_en           )
);

//三通道分块
YCbCr_pingpang      YCbCr_pingpang_inst
(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .img_out            (img_out            ),
    .state_Ycc          (state              ),
    .data_en            (start_en           ),

    .data_out           (data_out           ),
    .rd_end             (rd_end             )
);

//串转并
serial_to_paraller      serial_to_paraller_inst
(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .img_out            (data_out           ),
    .rd_end             (rd_end             ),

    .change_end         (change_end         ),
    .Dct_data_in        (Dct_data_in        )
);

//二维DCT
DCT_two_dimensional     DCT_two_dimensional_inst
(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .start              (change_end         ),
    .DCT_data_in        (Dct_data_in        ),

    .DCT_data_o_z0      (DCT_data_o_z0      ),
    .DCT_data_o_z1      (DCT_data_o_z1      ),
    .DCT_data_o_z2      (DCT_data_o_z2      ),
    .DCT_data_o_z3      (DCT_data_o_z3      ),
    .DCT_data_o_z4      (DCT_data_o_z4      ),
    .DCT_data_o_z5      (DCT_data_o_z5      ),
    .DCT_data_o_z6      (DCT_data_o_z6      ),
    .DCT_data_o_z7      (DCT_data_o_z7      ),
    .data_en            (data_en            )
);  

//并转串
paraller_to_serial  paraller_to_serial_inst
(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .DCT_data_o_z0      (DCT_data_o_z0      ),
    .DCT_data_o_z1      (DCT_data_o_z1      ),
    .DCT_data_o_z2      (DCT_data_o_z2      ),
    .DCT_data_o_z3      (DCT_data_o_z3      ),
    .DCT_data_o_z4      (DCT_data_o_z4      ),
    .DCT_data_o_z5      (DCT_data_o_z5      ),
    .DCT_data_o_z6      (DCT_data_o_z6      ),
    .DCT_data_o_z7      (DCT_data_o_z7      ),
    .data_en            (data_en            ),

    .DCT_data           (DCT_data           ),
    .ZigZag_start       (ZigZag_start       )
    
);

//量化扫描
quant_ZigZag        quant_ZigZag_inst
(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .DCT_data           (DCT_data           ),
    .ZigZag_start       (ZigZag_start       ),

    .ZigZag_data        (ZigZag_data        ),
    .rd_en              (rd_en              ),
    .data_state         (data_state         )
);

//霍夫曼编码
huffman_encoder     huffman_encoder_inst
(
    .sys_clk            (sys_clk           ),
    .sys_rst_n          (sys_rst_n         ),
    .ZigZag_data        (ZigZag_data       ),
    .start_encoder      (rd_en             ),
    .data_state         (data_state        ),

    .JPEG_data_o        (JPEG_data_o       ),
    .JPEG_data_en       (JPEG_data_en      ),
    .frame_en           (frame_en          ),
    .frame_end_flag     (frame_end_flag    ),
    .frame_end_flag_1   (frame_end_flag_1  )  
);

//组装JFIF文件
gen_JFIF    gen_JFIF_inst
(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .JPEG_data_o        (JPEG_data_o        ),
    .JPEG_data_en       (JPEG_data_en       ),
    .frame_en           (frame_en           ),
    .frame_end_flag     (frame_end_flag     ),
    .frame_end_flag_1   (frame_end_flag_1   ),
    .fifo_full          (1'b0               ),

    .JFIF_data          (JFIF_data          ),
    .fifo_wr_req        (fifo_wr_req        )   
);
endmodule