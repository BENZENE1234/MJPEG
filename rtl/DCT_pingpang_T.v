module DCT_pingpang_T
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire    signed  [11:0]  DCT_data_o_z0   ,
    input   wire    signed  [11:0]  DCT_data_o_z1   ,
    input   wire    signed  [11:0]  DCT_data_o_z2   ,
    input   wire    signed  [11:0]  DCT_data_o_z3   ,
    input   wire    signed  [11:0]  DCT_data_o_z4   ,
    input   wire    signed  [11:0]  DCT_data_o_z5   ,
    input   wire    signed  [11:0]  DCT_data_o_z6   ,
    input   wire    signed  [11:0]  DCT_data_o_z7   ,
    input   wire                    data_en         ,
    
    output  reg             [95:0]  data_out        ,
    output  reg                     rd_end          
);

parameter   IDLE        =   4'b0001     ;
parameter   WRAM1       =   4'b0010     ;
parameter   RRAM1_WRAM2 =   4'b0100     ;
parameter   WRAM1_RRAM2 =   4'b1000     ;

reg         [3:0]   state       ;

reg                 wr_ram1_en  ;
reg                 wr_ram2_en  ;
reg                 rd_ram1_en  ;
reg                 rd_ram2_en  ;

reg         [2:0]   cnt_addr    ;
reg         [2:0]   cnt_T       ;

reg          [95:0]  DCT_data_reg_zx   ;

wire signed  [11:0]  ram1_data         ;
wire signed  [11:0]  ram2_data         ;

//数据寄存
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DCT_data_reg_zx<=96'd0;
    else if(data_en==1'b1)
        begin
            DCT_data_reg_zx[11:0 ]<=DCT_data_o_z0;
            DCT_data_reg_zx[23:12]<=DCT_data_o_z1;
            DCT_data_reg_zx[35:24]<=DCT_data_o_z2;
            DCT_data_reg_zx[47:36]<=DCT_data_o_z3;
            DCT_data_reg_zx[59:48]<=DCT_data_o_z4;
            DCT_data_reg_zx[71:60]<=DCT_data_o_z5;
            DCT_data_reg_zx[83:72]<=DCT_data_o_z6;
            DCT_data_reg_zx[95:84]<=DCT_data_o_z7;
        end
    else
        DCT_data_reg_zx<=DCT_data_reg_zx;
        
//读写地址计算计数器
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt_addr<=3'd0;
    else if(state==IDLE || cnt_addr==3'd7)
        cnt_addr<=3'd0;
    else
        cnt_addr<=cnt_addr+1'b1;

//周期计数器
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt_T<=3'd0;
    else if(state==IDLE || (cnt_T==3'd7&&cnt_addr==3'd7))
        cnt_T<=3'd0;
    else if(cnt_addr==3'd7)
        cnt_T<=cnt_T+1'b1;
    else
        cnt_T<=cnt_T;
        
//状态机跳转
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        state<=IDLE;
    else
        case(state)
            IDLE        :   if(data_en==1'b1)
                                state<=WRAM1;
                            else
                                state<=state;
            WRAM1       :   if(cnt_addr==3'd7 && cnt_T==3'd7)
                                state<=RRAM1_WRAM2;
                            else
                                state<=state;
            RRAM1_WRAM2 :   if(cnt_addr==3'd7 && cnt_T==3'd7)
                                state<=WRAM1_RRAM2;
                            else
                                state<=state;
            WRAM1_RRAM2 :   if(cnt_addr==3'd7 && cnt_T==3'd7)
                                state<=RRAM1_WRAM2;
                            else
                                state<=state;
            default     :   state<=IDLE;
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
        data_out<=96'd0;
    else if(state==RRAM1_WRAM2)
        data_out[7'd12*cnt_addr+:7'd12]<=ram1_data;
    else if(state==WRAM1_RRAM2)
        data_out[7'd12*cnt_addr+:7'd12]<=ram2_data;
    else
        data_out<=data_out;
        
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        rd_end<=1'b0;
    else if(state==RRAM1_WRAM2 && cnt_addr==3'd7)
        rd_end<=1'b1;
    else if(state==WRAM1_RRAM2 && cnt_addr==3'd7)
        rd_end<=1'b1;
    else
        rd_end<=1'b0;
        
DCT_RAM_12x64_tow	DCT_RAM_12x64_tow_inst_1
(
	.clock ( sys_clk ),
	.data ( DCT_data_reg_zx[7'd12*cnt_addr+:7'd12] ),
	.rdaddress ( cnt_addr + 7'd8*cnt_T),
	.rden ( rd_ram1_en ),
	.wraddress ( 7'd8*cnt_addr + cnt_T),
	.wren ( wr_ram1_en ),
	.q ( ram1_data )
);
        
DCT_RAM_12x64_tow	DCT_RAM_12x64_tow_inst_2
(
	.clock ( sys_clk ),
	.data ( DCT_data_reg_zx[7'd12*cnt_addr+:7'd12] ),
	.rdaddress ( cnt_addr + 7'd8*cnt_T),
	.rden ( rd_ram2_en ),
	.wraddress ( 7'd8*cnt_addr + cnt_T),
	.wren ( wr_ram2_en ),
	.q ( ram2_data )
);

endmodule