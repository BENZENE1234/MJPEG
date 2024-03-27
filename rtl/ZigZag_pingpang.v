module ZigZag_pingpang
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire    signed  [11:0]  ZigZag_data     ,
    input   wire                    data_en         ,
    
    output  reg     signed  [11:0]  data_out        ,
    output  reg                     rd_en           ,
    output  reg             [1:0]   data_state     
);

parameter   IDLE        =   4'b0001     ;
parameter   WRAM1       =   4'b0010     ;
parameter   RRAM1_WRAM2 =   4'b0100     ;
parameter   WRAM1_RRAM2 =   4'b1000     ;

reg         [3:0]   state           ;
    
//读写使能信号    
reg                 wr_ram1_en      ;
reg                 wr_ram2_en      ;
reg                 rd_ram1_en      ;
reg                 rd_ram2_en      ;
    
//地址寄存器    
reg         [5:0]   addr            ;  

//读地址信号
reg         [5:0]   rd_addr_1       ;
wire        [5:0]   rd_addr         ;

reg         [11:0]  ZigZag_data_reg ;

wire signed [11:0]  ram1_data       ;
wire signed [11:0]  ram2_data       ;

reg         [8:0]   cnt             ;

//输出数据类型判断
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt<=9'd0;
    else if(rd_en==1'b0 || cnt==9'd511)
        cnt<=9'd0;
    else
        cnt<=cnt+1'b1;

always@(*)
    if(rd_en==1'b0)
        data_state=2'd0;
    else if(cnt==9'd0)
        data_state=2'd1;
    else if(cnt==9'd256)
        data_state=2'd2;
    else if(cnt==9'd384)
        data_state=2'd3;
    else
        data_state=data_state;

//数据寄存
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        ZigZag_data_reg<=12'd0;
    else
        ZigZag_data_reg<=ZigZag_data;
        
//写地址计算
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        addr<=6'd0;
    else if(state==IDLE || addr==6'd63)
        addr<=6'd0;
    else
        addr<=addr+1'b1;
    
//读地址信号
ZigZga_ROM_6x64	ZigZga_ROM_6x64_inst 
(
	.address ( addr+1'b1 ),
	.clock ( sys_clk ),
	.q ( rd_addr )
);
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        rd_addr_1<=6'd0;
    else
        rd_addr_1<=rd_addr;
        
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
            WRAM1      :   if(addr==6'd63)
                               state<=RRAM1_WRAM2;
                           else
                               state<=state;
            RRAM1_WRAM2:   if(addr==6'd63)
                               state<=WRAM1_RRAM2;
                           else
                               state<=state;
            WRAM1_RRAM2:   if(addr==6'd63)
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
        data_out<=12'd0;
    else if(state==RRAM1_WRAM2)
        data_out<=ram1_data;
    else if(state==WRAM1_RRAM2)
        data_out<=ram2_data;
    else
        data_out<=data_out;
        
always@(negedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        rd_en<=1'b0;
    else if(state==RRAM1_WRAM2)
        rd_en<=1'b1;
    else if(state==WRAM1_RRAM2)
        rd_en<=1'b1;
    else
        rd_en<=rd_en;
        
ZigZag_RAM_12x64_two	ZigZag_RAM_12x64_two_inst_1
(
	.clock ( sys_clk ),
	.data ( ZigZag_data_reg ),
	.rdaddress ( rd_addr_1 ),
	.rden ( rd_ram1_en ),
	.wraddress ( addr ),
	.wren ( wr_ram1_en ),
	.q ( ram1_data )
);
        
ZigZag_RAM_12x64_two	ZigZag_RAM_12x64_two_inst_2
(
	.clock ( sys_clk ),
	.data ( ZigZag_data_reg ),
	.rdaddress ( rd_addr_1 ),
	.rden ( rd_ram2_en ),
	.wraddress ( addr ),
	.wren ( wr_ram2_en ),
	.q ( ram2_data )
);

endmodule