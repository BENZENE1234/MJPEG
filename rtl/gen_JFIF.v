module gen_JFIF
(
    input   wire                sys_clk         ,
    input   wire                sys_rst_n       ,
    input   wire        [7:0]   JPEG_data_o     ,
    input   wire                JPEG_data_en    ,
    input   wire                frame_en        ,
    input   wire                frame_end_flag  ,
    input   wire                frame_end_flag_1,
    input   wire                fifo_full       ,

    output  reg         [7:0]   JFIF_data       ,
    output  reg                 fifo_wr_req        
);

parameter   IDLE        = 4'b0001           ;
parameter   HEAD        = 4'b0010           ;
parameter   JPEG        = 4'b0100           ;
parameter   EOI         = 4'b1000           ;

parameter   CNT_ROM_MAX = 10'd606           ;
//四个状态
reg     [3:0]   state               ;
reg             state_flag          ;
//读JFIF头文件ROM地址计数器
reg     [9:0]   addr_cnt            ;
reg             rd_rom_end          ;
//rom数据寄存
wire    [7:0]   JFIF_head_rom       ;

reg             EOI_flag            ;
reg             EOI_flag_1          ;

//状态跳转
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        state<=IDLE;
    else 
        case(state)
            IDLE    :   state<=HEAD;
            HEAD    :   if(state_flag==1'b1)
                            state<=JPEG;
                        else
                            state<=HEAD;
            JPEG    :   if(state_flag==1'b1)
                            state<=EOI;
                        else
                            state<=JPEG;
            EOI     :   if(state_flag==1'b1)
                            state<=JPEG;
                        else
                            state<=EOI;
            default :   state<=IDLE;    
        endcase        

//状态跳转标志
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        state_flag<=1'b0;
    else
        case(state)
            IDLE    :   state_flag<=1'b0;
            HEAD    :   if(rd_rom_end==1'b1)
                            state_flag<=1'b1;
                        else
                            state_flag<=1'b0;
            JPEG    :   if(frame_en==1'b0 && frame_end_flag==1'b1)
                            state_flag<=1'b1;
                        else
                            state_flag<=1'b0;
            EOI     :   if(EOI_flag==1'b1)
                            state_flag<=1'b1;
                        else
                            state_flag<=1'b0;
            default :   state_flag<=1'b0;                                                                                                                                               
        endcase        

//读ROM计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        addr_cnt<=10'd0;
    else if(addr_cnt==CNT_ROM_MAX || state_flag==1'b1)
        addr_cnt<=10'd0;
    else if(rd_rom_end==1'b1)
        addr_cnt<=10'd0;
    else if(state==HEAD)
        addr_cnt<=addr_cnt+1'b1;     
    else
        addr_cnt<=addr_cnt;

//ROM读结束信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        rd_rom_end<=1'b0;
    else if(addr_cnt==CNT_ROM_MAX)
        rd_rom_end<=1'b1;
    else
        rd_rom_end<=1'b0;

//读ROM
JFIF_8x607_ROM_one	JFIF_8x607_ROM_one_inst (
	.address ( addr_cnt ),
	.clock ( sys_clk ),
	.q ( JFIF_head_rom )
	);

//EOI输出标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            EOI_flag<=1'b0;
            EOI_flag_1<=1'b0;
        end
    else
        begin
            EOI_flag<=frame_end_flag_1;
            EOI_flag_1<=EOI_flag;
        end

//输出数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        JFIF_data<=8'd0;
    else
        case(state) 
            HEAD    :   JFIF_data<=JFIF_head_rom;
            JPEG    :   if(JPEG_data_en==1'b1)
                            JFIF_data<=JPEG_data_o;
                        else
                            JFIF_data<=JFIF_data;
            EOI     :   if(EOI_flag_1==1'b1)
                            JFIF_data<=8'hD9;
                        else
                            JFIF_data<=8'hFF;
            default :   JFIF_data<=8'd0;
        endcase

//生成写FIFO请求信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        fifo_wr_req<=1'b0;
    else if(fifo_full==1'b0)
        case(state)
            IDLE    :   fifo_wr_req<=1'b0;
            HEAD    :   if(state_flag==1'd0 && rd_rom_end==1'b0)
                            fifo_wr_req<=1'b1;
                        else
                            fifo_wr_req<=1'b0;
            JPEG    :   if(JPEG_data_en==1'b1)
                            fifo_wr_req<=1'b1;
                        else
                            fifo_wr_req<=1'b0;
            EOI     :   fifo_wr_req<=1'b1;
            default :   fifo_wr_req<=1'b0;
        endcase

endmodule