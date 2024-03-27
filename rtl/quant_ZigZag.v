module quant_ZigZag
(
    input   wire                    sys_clk     ,
    input   wire                    sys_rst_n   ,
    input   wire    signed  [11:0]  DCT_data    ,
    input   wire                    ZigZag_start,
    
    output  wire    signed  [11:0]  ZigZag_data ,
    output  wire                    rd_en       ,
    output  wire            [1:0]   data_state  
);

reg             [5:0]   cnt_addr        ;
reg                     data_en_0       ;
reg                     data_en         ;
reg             [8:0]   quant_state_cnt ;
reg     signed  [27:0]  quant_data      ;
reg     signed  [11:0]  DCT_data_reg    ;

wire    signed  [15:0]  ROM_data_Y      ;
wire    signed  [15:0]  ROM_data_CbCr   ;
wire    signed  [15:0]  ROM_data        ;
        
//读ROM地址计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt_addr<=6'd0;
    else if(ZigZag_start==1'b0 || cnt_addr==6'd63)
        cnt_addr<=6'd0;
    else
        cnt_addr<=cnt_addr+1'b1;

//数据寄存一拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DCT_data_reg<=12'd0;
    else
        DCT_data_reg<=DCT_data;

//量化数据有效信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            data_en<=1'b0;
            data_en_0<=1'b0;
        end
    else
        begin
            data_en_0<=ZigZag_start;
            data_en<=data_en_0;
        end
        
//量化表格选择计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        quant_state_cnt<=9'd0;
    else if(ZigZag_start==1'b0 || quant_state_cnt==9'd511)
        quant_state_cnt<=9'd0;
    else
        quant_state_cnt<=quant_state_cnt+1'b1;
  
//选择量化数据
assign ROM_data = (quant_state_cnt<=255)? ROM_data_Y : ROM_data_CbCr    ;
        
//实例化ROM表
ZigZag_ROM_16x64_Y	ZigZag_ROM_16x64_Y_inst 
(
	.address ( cnt_addr ),
	.clock ( sys_clk ),
	.q ( ROM_data_Y )
);

ZigZag_ROM_16x64_CbCr	ZigZag_ROM_16x64_CbCr_inst 
(
	.address ( cnt_addr ),
	.clock ( sys_clk ),
	.q ( ROM_data_CbCr )
);

//计算量化数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        quant_data<=28'd0;
    else if(data_en_0==1'b1)
        quant_data<= (ROM_data*DCT_data_reg);
    else
        quant_data<=28'd0;

ZigZag_pingpang     ZigZag_pingpang_inst
(
    .sys_clk         (sys_clk    ),
    .sys_rst_n       (sys_rst_n  ),
    .ZigZag_data     (quant_data>>16 ),
    .data_en         (data_en    ),

    .data_out        (ZigZag_data),
    .rd_en           (rd_en      ),
    .data_state      (data_state )
);

endmodule