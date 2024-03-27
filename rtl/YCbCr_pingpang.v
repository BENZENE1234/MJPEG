module YCbCr_pingpang
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire    signed  [7:0]   img_out         ,
    input   wire            [1:0]   state_Ycc       ,
    input   wire                    data_en         ,
    
    output  reg             [7:0]   data_out        ,
    output  reg                     rd_end          
);

parameter   IDLE        =   4'b0001     ;
parameter   WRAM1       =   4'b0010     ;
parameter   RRAM1_WRAM2 =   4'b0100     ;
parameter   WRAM1_RRAM2 =   4'b1000     ;

reg         [3:0]   state       ;

//读写使能信号
reg                 wr_ram1_en  ;
reg                 wr_ram2_en  ;
reg                 rd_ram1_en  ;
reg                 rd_ram2_en  ;

//写地址寄存器
reg         [8:0]   wr_addr     ;
reg         [7:0]   cnt_Y       ;
reg         [6:0]   cnt_Cb      ;
reg         [6:0]   cnt_Cr      ;

//读地址寄存器
reg         [2:0]   cnt_T       ;
reg         [1:0]   cnt_row     ;
reg         [3:0]   cnt_col     ;

reg         [7:0]   img_data_reg;

wire signed [7:0]   ram1_data   ;
wire signed [7:0]   ram2_data   ;

//数据寄存
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        img_data_reg<=8'd0;
    else
        img_data_reg<=img_out;
        
//写地址计算
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        wr_addr<=9'd0;
    else if(state==IDLE)
        wr_addr<=9'd0;
    else
        case(state_Ycc)
            2'd0    :   wr_addr<=cnt_Y;
            2'd1    :   wr_addr<=9'd256+cnt_Cr;
            2'd2    :   wr_addr<=9'd384+cnt_Cb;
            2'd3    :   wr_addr<=cnt_Y;
            default :   wr_addr<=9'd0;
        endcase
    
//写地址控制计数器
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            cnt_Y<=8'd0;
            cnt_Cr<=7'd0;
            cnt_Cb<=7'd0;
        end
    else if(state==IDLE)
        begin
            cnt_Y<=8'd0;       
            cnt_Cr<=7'd0;      
            cnt_Cb<=7'd0;      
        end                    
    else
        case(state_Ycc)
            2'd0    :   if(cnt_Cr==7'd127)
                            cnt_Cr<=7'd0;
                        else
                            cnt_Cr<=cnt_Cr+1'b1;
            2'd1    :   if(cnt_Cb==7'd127)
                            cnt_Cb<=7'd0;
                        else
                            cnt_Cb<=cnt_Cb+1'b1;
            2'd2    :   if(cnt_Y==8'd255)
                            cnt_Y<=8'd0;
                        else
                            cnt_Y<=cnt_Y+1'b1;
            2'd3    :   if(cnt_Y==8'd255)
                            cnt_Y<=8'd0;
                        else
                            cnt_Y<=cnt_Y+1'b1;
            default :   begin
                            cnt_Y<=8'd0;
                            cnt_Cr<=7'd0;
                            cnt_Cb<=7'd0;
                        end
        endcase
        
//读地址计数器
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt_T<=3'd0;
    else if(state==IDLE || cnt_T==3'd7)
        cnt_T<=3'd0;
    else
        cnt_T<=cnt_T+1'b1;
        
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt_col<=4'd0;
    else if(state==IDLE || (cnt_col==4'd15 && cnt_T==3'd7))
        cnt_col<=4'd0;
    else if(cnt_T==3'd7)
        cnt_col<=cnt_col+1'b1;
    else
        cnt_col<=cnt_col;
        
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt_row<=2'd0;
    else if(state==IDLE || (cnt_row==2'd3 && cnt_col==4'd15 && cnt_T==3'd7))
        cnt_row<=2'd0;
    else if(cnt_col==4'd15 && cnt_T==3'd7)
        cnt_row<=cnt_row+1'b1;
    else
        cnt_row<=cnt_row;

        
//状态机跳转
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        state<=IDLE;
    else
        case(state)
            IDLE       :   if(data_en==1'b1)
                               state<=WRAM1;
                           else
                               state<=state;
            WRAM1      :   if(wr_addr==8'd255&&(cnt_row==2'd3&&cnt_col==4'd15&&cnt_T==3'd7))
                               state<=RRAM1_WRAM2;
                           else
                               state<=state;
            RRAM1_WRAM2:   if(wr_addr==8'd255&&(cnt_row==2'd3&&cnt_col==4'd15&&cnt_T==3'd7))
                               state<=WRAM1_RRAM2;
                           else
                               state<=state;
            WRAM1_RRAM2:   if(wr_addr==8'd255&&(cnt_row==2'd3&&cnt_col==4'd15&&cnt_T==3'd7))
                               state<=RRAM1_WRAM2;
                           else
                               state<=state;
            default    :   state<=IDLE;
        endcase

//读写使能信号
always@(*)
    case(state)
        IDLE        :   begin
                            wr_ram1_en =1'b0;
                            wr_ram2_en =1'b0;
                            rd_ram1_en =1'b0;
                            rd_ram2_en =1'b0;
                        end
        WRAM1       :   begin
                            wr_ram1_en =1'b1;
                            wr_ram2_en =1'b0;
                            rd_ram1_en =1'b0;
                            rd_ram2_en =1'b0;
                        end
        RRAM1_WRAM2 :   begin
                            wr_ram1_en =1'b0;
                            wr_ram2_en =1'b1;
                            rd_ram1_en =1'b1;
                            rd_ram2_en =1'b0;
                        end
        WRAM1_RRAM2 :   begin
                            wr_ram1_en =1'b1;
                            wr_ram2_en =1'b0;
                            rd_ram1_en =1'b0;
                            rd_ram2_en =1'b1;
                        end
        default     :   begin
                            wr_ram1_en =1'b0;
                            wr_ram2_en =1'b0;
                            rd_ram1_en =1'b0;
                            rd_ram2_en =1'b0;
                        end
        endcase

always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        data_out<=8'd0;
    else if(state==RRAM1_WRAM2)
        data_out<=ram1_data;
    else if(state==WRAM1_RRAM2)
        data_out<=ram2_data;
    else
        data_out<=data_out;

//在读取八个数据开始时生成信号   
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        rd_end<=1'b0;
    else if(state==RRAM1_WRAM2 && cnt_T==7'd0)
        rd_end<=1'b1;
    else if(state==WRAM1_RRAM2 && cnt_T==7'd0)
        rd_end<=1'b1;
    else
        rd_end<=1'b0;
        
YCbCr_RAM_8x512_two	YCbCr_RAM_8x512_two_inst_1
(
	.clock ( sys_clk ),
	.data ( img_data_reg ),
	.rdaddress ( 9'd128*cnt_row+9'd16*cnt_T+cnt_col ),
	.rden ( rd_ram1_en ),
	.wraddress ( wr_addr ),
	.wren ( wr_ram1_en ),
	.q ( ram1_data )
);
        
YCbCr_RAM_8x512_two	YCbCr_RAM_8x512_two_inst_2
(
	.clock ( sys_clk ),
	.data ( img_data_reg ),
	.rdaddress ( 9'd128*cnt_row+9'd16*cnt_T+cnt_col ),
	.rden ( rd_ram2_en ),
	.wraddress ( wr_addr ),
	.wren ( wr_ram2_en ),
	.q ( ram2_data )
);

endmodule