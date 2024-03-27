module huffman_encoder
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire    signed  [11:0]  ZigZag_data     ,
    input   wire                    start_encoder   ,
    input   wire            [1:0]   data_state      ,

    output  reg             [7:0]   JPEG_data_o     ,
    output  reg                     JPEG_data_en    ,
    output  reg                     frame_en        ,
    output  reg                     frame_end_flag  ,
    output  reg                     frame_end_flag_1    
);

// parameter   FRAME_NUM = 20'd614399                  ;
parameter   FRAME_NUM = 20'd63                  ;

reg                 [5:0]       num_cnt             ;

//各种有效标志信号
reg                             DC_diff_en          ;
reg                             abs_en              ;
reg                             level_size_en       ;
reg                             run_start           ;
wire                            AC_run_start        ;

//直流所存寄存器
reg     signed      [11:0]      Y_before            ; 
reg     signed      [11:0]      Cr_before           ; 
reg     signed      [11:0]      Cb_before           ; 

//直流差分
reg     signed      [11:0]      DC_diff             ;

//交流分量寄存器
reg     signed      [11:0]      AC_reg              ;
reg     signed      [11:0]      AC_reg_1            ;

//绝对值
reg                 [11:0]      Abs                 ;

//反码表示
reg                 [11:0]      level               ;
reg                 [11:0]      level_reg           ;

//反码长度
reg                 [3:0]       size                ;
reg                 [3:0]       size_reg            ;

//游程编码的run
reg                 [3:0]       run                 ;

//YCbCr分量标识
reg                 [1:0]       data_state_1        ;
reg                 [1:0]       data_state_2        ;
reg                 [1:0]       data_state_3        ;
reg                 [1:0]       data_state_4        ;
reg                 [1:0]       data_state_5        ;

//查表得huffman编码值
reg                 [10:0]      address             ;
wire                [19:0]      rom_data            ;

//编码值的长度
reg                 [4:0]       code_length         ;
reg                 [31:0]      huff_code           ;

reg                 [5:0]       code_num            ;
reg                             code_start          ;
reg                             code_start_1        ;

//提前结束信号
wire                            EOB                 ;
reg                             EOB_1               ;
reg                             EOB_2               ;
reg                             block_end           ;
reg                             block_end_1         ;

//最后一个非0位置
wire                [5:0]       last_nonzero_num    ;
reg                 [5:0]       last_nonzero_num_1  ;
reg                 [5:0]       last_nonzero_num_2  ;

//FIFO
wire                [31:0]      huff_code_q         ;
wire                [4:0]       huff_code_length    ;
wire                [1:0]       data_state_fifo     ;

reg                             huff_code_rdreq     ;
reg                             huff_code_wrreq     ;
wire                            huff_code_empty     ;
wire                            huff_code_full      ;
wire                [5:0]       huff_code_usedw     ;

reg                             huff_codelen_rdreq  ;
reg                             huff_codelen_wrreq  ;
wire                            huff_codelen_empty  ;
wire                            huff_codelen_full   ;
wire                [5:0]       huff_codelen_usedw  ;


//输出比特流
reg                             flag                ;
reg                 [5:0]       fifo_out_cnt        ;
reg                 [99:0]      word_reg            ;
reg                 [7:0]       word_bit_num        ;

//判断是否达到一帧图像
reg                 [19:0]      frame_cnt           ;
reg                             frame_start         ;

// reg                             frame_end_flag      ;
// reg                             frame_end_flag_1    ;

//产生有效脉冲信号
//计算直流差分脉冲信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DC_diff_en<=1'b0;
    else if(start_encoder==1'b1 && num_cnt==6'd0)
        DC_diff_en<=start_encoder;
    else
        DC_diff_en<=1'b0;

//绝对值，反码，大小计算脉冲信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            abs_en<=1'b0;
            level_size_en<=1'b0;
        end
    else
        begin
            abs_en<=DC_diff_en;
            level_size_en<=abs_en;
        end

//run值计算信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        run_start<=1'b0;
    else if(abs_en==1'b1)
        run_start<=1'b1;
    else
        run_start<=run_start;

//交流run值计算信号
assign AC_run_start=~level_size_en;

//开始编码信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            code_start<=1'b0;
            code_start_1<=1'b0;
        end
    else
        begin
            code_start<=run_start;
            code_start_1<=code_start;
        end

//用于判断直流信号的输入
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        num_cnt<=6'd0;
    else if(start_encoder==1'b0 || num_cnt==6'd63)
        num_cnt<=6'd0;
    else
        num_cnt<=num_cnt+1'b1;

//直流锁存操作
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            Y_before<=12'd0;
            Cr_before<=12'd0;
            Cb_before<=12'd0;
        end
    else if(start_encoder==1'b1 && num_cnt==6'd0)
        case(data_state)
            2'd1:Y_before<=ZigZag_data;
            2'd2:Cr_before<=ZigZag_data;
            2'd3:Cb_before<=ZigZag_data;
            default:    begin
                            Y_before<=12'd0;
                            Cr_before<=12'd0;
                            Cb_before<=12'd0;  
                        end
        endcase
    else
        begin
            Y_before<=Y_before;
            Cr_before<=Cr_before;
            Cb_before<=Cb_before;
        end

//直流差分操作
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DC_diff<=12'd0;
    else if(start_encoder==1'b1 && num_cnt==6'd0)
        case(data_state)
            2'd1:DC_diff<=ZigZag_data-Y_before;
            2'd2:DC_diff<=ZigZag_data-Cr_before;
            2'd3:DC_diff<=ZigZag_data-Cb_before;
            default:    DC_diff<=12'd0;
        endcase
    else
        DC_diff<=DC_diff;

//交流寄存操作
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            AC_reg<=12'd0;
            AC_reg_1<=12'd0;
        end
    else if(start_encoder==1'b1 && num_cnt!=6'd0)
        begin
            AC_reg<=ZigZag_data;
            AC_reg_1<=AC_reg;
        end
    else
        begin
            AC_reg<=12'd0;
            AC_reg_1<=12'd0;
        end

//求绝对值操作
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        Abs<=12'd0;
    else if(DC_diff_en==1'b1)
        begin
            if(DC_diff[11]==1'b1)
                Abs<=~DC_diff+1'b1;
            else
                Abs<=DC_diff;
        end
    else if(DC_diff_en==1'b0)
        begin
            if(AC_reg[11]==1'b1)
                Abs<=~AC_reg+1'b1;
            else
                Abs<=AC_reg;
        end
    else
        Abs<=12'd0;

//求解level值操作
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        level<=12'd0;
    else if(abs_en==1'b1)
        begin
            if(DC_diff[11]==1'b1)
                level<=~Abs;
            else
                level<=Abs;
        end
    else if(abs_en==1'b0)
        begin
            if(AC_reg_1[11]==1'b1)
                level<=~Abs;
            else
                level<=Abs;
        end
    else
        level<=12'd0;

//求解size操作
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        size<=4'd0;
    else if(Abs==12'd0)
        size<=4'd0;
    else if(Abs==12'd1)
        size<=4'd1;
    else if(Abs>=12'd2 && Abs<=12'd3)
        size<=4'd2;
    else if(Abs>=12'd4 && Abs<=12'd7)
        size<=4'd3;
    else if(Abs>=12'd8 && Abs<=12'd15)
        size<=4'd4;
    else if(Abs>=12'd16 && Abs<=12'd31)
        size<=4'd5;
    else if(Abs>=12'd32 && Abs<=12'd63)
        size<=4'd6;
    else if(Abs>=12'd64 && Abs<=12'd127)
        size<=4'd7;
    else if(Abs>=12'd128 && Abs<=12'd255)
        size<=4'd8;
    else if(Abs>=12'd256 && Abs<=12'd511)
        size<=4'd9;
    else if(Abs>=12'd512 && Abs<=12'd1023)
        size<=4'd10;
    else if(Abs>=12'd1024 && Abs<=12'd2047)
        size<=4'd11;
    else
        size<=4'd0;

//求解run的值
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        run<=4'd0;
    else if(run_start==1'b0 || abs_en==1'b1)
        run<=4'd0;
    else if(AC_run_start==1'b0 && run_start==1'b1)
        run<=4'd0;
    else if(AC_run_start==1'b1 && run_start==1'b1 && level!=12'd0)
        run<=4'd0;
    else if(run==4'd15)
        run<=4'd0;
    else
        run<=run+1'b1;

//数据状态寄存
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            data_state_1<=2'd0;
            data_state_2<=2'd0;
            data_state_3<=2'd0;
            data_state_4<=2'd0;
            data_state_5<=2'd0;
        end
    else
        begin
            data_state_1<=data_state;
            data_state_2<=data_state_1;
            data_state_3<=data_state_2; 
            data_state_4<=data_state_3;
            data_state_5<=data_state_4;
        end

//生成地址
always@(run_start,AC_run_start,data_state_3,run,size)
    if(run_start==1'b0 || data_state_3==2'd0)
        address=11'd400;
    else if(run_start==1'b1 && AC_run_start==1'b0 && data_state_3==2'd1)
        address=11'h400+{3'd0,run,size};
    else if(run_start==1'b1 && AC_run_start==1'b1 && data_state_3==2'd1)
        address={3'd0,run,size};
    else if(run_start==1'b1 && AC_run_start==1'b0 && (data_state_3==2'd2 || data_state_3==2'd3))
        address=11'h40C+{3'd0,run,size};
    else if(run_start==1'b1 && AC_run_start==1'b1 && (data_state_3==2'd2 || data_state_3==2'd3))
        address=11'h200+{3'd0,run,size};
    else
        address=11'd400;

//查表得出霍夫曼编码值
Huffman_ROM_20x1048	Huffman_ROM_20x1048_inst
(
	.address ( address ),
	.clock ( sys_clk ),
	.q ( rom_data )
);

//size,level值打一拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        size_reg<=4'd0;
    else
        size_reg<=size;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        level_reg<=12'd0;
    else
        level_reg<=level;

//统计level值个数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        code_num<=6'd0;
    else if(code_start==1'b0 || code_num==6'd63)
        code_num<=6'd0;
    else
        code_num<=code_num+1'b1;

//生成EOB信号
assign EOB = (code_start==1'b1 && code_num==6'd63 && level_reg==12'd0) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            EOB_1<=1'b0;
            EOB_2<=1'b0;
        end
    else
        begin
            EOB_1<=EOB;
            EOB_2<=EOB_1;
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        block_end<=1'b0;
    else if(code_start==1'b1 && code_num==6'd63)  
        block_end<=1'b1;
    else
        block_end<=1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        block_end_1<=1'b0;
    else
        block_end_1<=block_end;

//计算最后一次出现非0的位置
assign last_nonzero_num = (level_reg==12'd0)? last_nonzero_num : code_num   ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        last_nonzero_num_1<=1'b0;
    else
        last_nonzero_num_1<=last_nonzero_num;

//用于消除冗余的ZRL
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        last_nonzero_num_2<=6'd0;
    else if(EOB_1==1'b1 || block_end==1'b1)
        last_nonzero_num_2<=last_nonzero_num_1;
    else
        last_nonzero_num_2<=last_nonzero_num_2;

//计算一个编码的长度
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        code_length<=5'd0;
    else if(EOB==1'b0 && (rom_data[15:0]==16'd10 || rom_data[15:0]==16'd0) && size_reg==4'd0)
        code_length<=5'd0;
    else if(EOB==1'b1)
        case(data_state_4)
            2'd1:   code_length<=5'd4;
            2'd2:   code_length<=5'd2;
            2'd3:   code_length<=5'd2;
            default:code_length<=5'd0;
        endcase
    else
        code_length<=size_reg+rom_data[19:16]+1'b1;

//生成编码值
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        huff_code<=32'd0;
    else if(EOB==1'b0 && (rom_data[15:0]==16'd10 || rom_data[15:0]==16'd0) && size_reg==4'd0)
        huff_code<=32'd0;
    else if(EOB==1'b1)
        case(data_state_4)
            2'd1:   huff_code<=32'b1010_0000_0000_0000_0000_0000_0000_0000;
            2'd2:   huff_code<=32'b0;
            2'd3:   huff_code<=32'b0;
            default:huff_code<=32'd0;
        endcase
    else
        huff_code<={rom_data,level_reg<<(12-size_reg)}<<(19-rom_data[19:16]);

//FIFO请求信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        huff_code_wrreq<=1'b0;
    else if(code_start==1'b1)
        huff_code_wrreq<=1'b1;
    else
        huff_code_wrreq<=1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        huff_code_rdreq<=1'b0;
    else if(huff_code_usedw==6'd62 && code_start==1'b1)
        huff_code_rdreq<=1'b1;
    else
        huff_code_rdreq<=huff_code_rdreq;       

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        huff_codelen_wrreq<=1'b0;
    else if(code_start==1'b1)
        huff_codelen_wrreq<=1'b1;
    else
        huff_codelen_wrreq<=1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        huff_codelen_rdreq<=1'b0;
    else if(huff_codelen_usedw==6'd62 && code_start==1'b1)
        huff_codelen_rdreq<=1'b1;
    else
        huff_codelen_rdreq<=huff_codelen_rdreq; 

Huffman_encoder_32x64_DCFIFO	Huffman_encoder_32x64_DCFIFO_inst 
(
	.clock ( sys_clk ),
	.data ( huff_code ),
	.rdreq ( huff_code_rdreq ),
	.wrreq ( huff_code_wrreq ),
	.empty ( huff_code_empty ),
	.full ( huff_code_full ),
	.q ( huff_code_q ),
	.usedw ( huff_code_usedw )
);

Huffman_codelen_5x64_DCFIFO	    Huffman_codelen_5x64_DCFIFO_inst 
(
	.clock ( sys_clk ),
	.data ( {data_state_5,code_length} ),
	.rdreq ( huff_codelen_rdreq ),
	.wrreq ( huff_codelen_wrreq ),
	.empty ( huff_codelen_empty ),
	.full ( huff_codelen_full ),
	.q ( {data_state_fifo,huff_code_length} ),
	.usedw ( huff_codelen_usedw )
);

//判断是否读到冗余的ZRL
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        fifo_out_cnt<=6'd0;
    else if(block_end==1'b1 || fifo_out_cnt==6'd63)
        fifo_out_cnt<=6'd0;
    else if(word_reg[(word_bit_num-1'b1)-:8]==8'hFF)    
        fifo_out_cnt<=fifo_out_cnt;
    else
        fifo_out_cnt<=fifo_out_cnt+1'b1;            

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        flag<=1'b0;
    else if(fifo_out_cnt==last_nonzero_num_2)  
        flag<=1'b1;
    else
        flag<=1'b0;

//保存未输出的比特流
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        word_reg<=100'd0;
    else if(fifo_out_cnt<=last_nonzero_num_2)
        word_reg<=(word_reg<<huff_code_length)+(huff_code_q>>(32-huff_code_length));
    else if(fifo_out_cnt>last_nonzero_num_2 && flag==1'b1)     
        case(data_state_fifo)
            2'd1:   word_reg<=(word_reg<<4)+4'b1010;
            2'd2:   word_reg<=word_reg<<2;
            2'd3:   word_reg<=word_reg<<2;
            default:word_reg<=word_reg;    
        endcase   
    else
        word_reg<=word_reg;

//保存未输出的比特流数据量
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        word_bit_num<=8'd0;    
    else if(frame_en==1'b0 && frame_end_flag==1'b1)
        word_bit_num<=8'd0+huff_code_length;  
    else if(fifo_out_cnt<=last_nonzero_num_2 && word_bit_num<8'd8)
        word_bit_num<=word_bit_num+huff_code_length;
    else if(fifo_out_cnt<=last_nonzero_num_2 && word_bit_num>=8'd8 && frame_en==1'b0)
        word_bit_num<=word_bit_num+huff_code_length;        
    else if(fifo_out_cnt>last_nonzero_num_2 && flag==1'b1)  
        if(word_bit_num>=8'd8 && frame_en==1'b1)              
            case(data_state_fifo)
                2'd1:   word_bit_num<=word_bit_num-4;
                2'd2:   word_bit_num<=word_bit_num-6;
                2'd3:   word_bit_num<=word_bit_num-6;
                default:word_bit_num<=word_bit_num;    
            endcase 
        else
            case(data_state_fifo)
                2'd1:   word_bit_num<=word_bit_num+4;
                2'd2:   word_bit_num<=word_bit_num+2;
                2'd3:   word_bit_num<=word_bit_num+2;
                default:word_bit_num<=word_bit_num;    
            endcase                 
    else if(word_bit_num>=8'd8 && JPEG_data_o!=8'hFF && frame_en==1'b1)
        word_bit_num<=word_bit_num-8'd8+huff_code_length;             
    else
        word_bit_num<=word_bit_num;    
                
//按字节输出比特流
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        JPEG_data_o<=8'd0;
    else if(word_bit_num>=8'd8 && JPEG_data_o!=8'hFF && frame_en==1'b1)
        JPEG_data_o<=word_reg[(word_bit_num-1'b1)-:8];
    else if(JPEG_data_o==8'hFF)
        JPEG_data_o<=8'h00;    
    else if(frame_en==1'b0 && frame_end_flag==1'b1)
        if(word_bit_num!=8'd0)
            JPEG_data_o<=word_reg[(word_bit_num-1'b1)-:8] | 8'hFF>>(word_bit_num);
        else
            JPEG_data_o<=8'd0;            
    else
        JPEG_data_o<=JPEG_data_o;

//输出字节流有效信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        JPEG_data_en<=1'b0;
    else if(huff_code_rdreq==1'b1 && word_bit_num>=8'd8 && frame_en==1'b1)
        JPEG_data_en<=1'b1;
    else if(frame_end_flag==1'b1 && JPEG_data_o!=8'd0 && word_bit_num!=8'd0)
        JPEG_data_en<=1'b1;      
    else if(JPEG_data_o==8'hFF)
        JPEG_data_en<=1'b1;                 
    else
        JPEG_data_en<=1'b0;        

//帧开始结束信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        frame_en<=1'b0;
    else if(frame_cnt==FRAME_NUM)        
        frame_en<=1'b0;
    else if(block_end==1'b1 && frame_cnt!=FRAME_NUM)
        frame_en<=1'b1;
    else if(frame_cnt==20'd3)
        frame_en<=1'b1;
    else
        frame_en<=frame_en;     

//帧计数                   
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        frame_cnt<=20'd0;
    else if(frame_cnt==FRAME_NUM)
        frame_cnt<=20'd0;
    else if(frame_start==1'b1)
        frame_cnt<=frame_cnt+1'b1;   
    else
        frame_cnt<=frame_cnt;  

//帧结束标志
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        frame_end_flag<=1'b0;
    else if(frame_cnt==FRAME_NUM)
        frame_end_flag<=1'b1;
    else
        frame_end_flag<=1'b0;                 

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        frame_end_flag_1<=1'b0;
    else
        frame_end_flag_1<=frame_end_flag;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        frame_start<=1'b0;
    else if(block_end==1'b1)
        frame_start<=1'b1;
    else
        frame_start<=frame_start;

endmodule

