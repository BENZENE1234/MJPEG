module DA_z0
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire    signed  [11:0]  X0              ,
    input   wire    signed  [11:0]  X1              ,
    input   wire    signed  [11:0]  X2              ,
    input   wire    signed  [11:0]  X3              ,
    input   wire                    DA_start        ,
    
    output  reg     signed  [11:0]  DCT_data_o      

);

reg     [2:0]   cnt_addr        ;

wire    [3:0]   addr_1          ;
wire    [3:0]   addr_2          ;
wire    [3:0]   addr_3          ;
wire    [3:0]   addr_4          ;

reg             DA_out          ;
reg             DA_out_1        ;

wire    signed  [11:0]  Rom_dat_1       ;
wire    signed  [11:0]  Rom_dat_2       ;
wire    signed  [11:0]  Rom_dat_3       ;
wire    signed  [11:0]  Rom_dat_4       ;
wire    signed  [21:0]  Rom_dat_4_temp  ;

reg     signed  [21:0]  DCT_dat_1       ;
reg     signed  [21:0]  DCT_dat_2       ;
reg     signed  [21:0]  DCT_dat_3       ;
reg     signed  [21:0]  DCT_dat_4       ;

reg                     flag            ;
reg                     max_flag        ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        max_flag<=1'b0;
    else if(cnt_addr==3'd1)
        max_flag<=1'b1;
    else
        max_flag<=1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        flag<=1'b0;
    else if(cnt_addr==3'd3 || DA_start==1'b1 || DA_out==1'b1)
        flag<=1'b1;
    else
        flag<=1'b0;
//地址计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt_addr<=3'd0;
    else if(DA_start==1'b1 || cnt_addr==3'd3 || DA_out==1'b1)
        cnt_addr<=3'd0;
    else if(flag==1'b1)
        cnt_addr<=3'd0;
    else
        cnt_addr<=cnt_addr+1'b1;

//计算结束信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DA_out<=1'b0;
    else if(cnt_addr==3'd3)
        DA_out<=1'b1;
    else
        DA_out<=1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DA_out_1<=1'b0;
    else
        DA_out_1<=DA_out;
        
//读ROM
assign  addr_1=(cnt_addr==3'd0)? 4'd0 : {X0[4'd3-cnt_addr],X1[4'd3-cnt_addr],X2[4'd3-cnt_addr],X3[4'd3-cnt_addr]};
assign  addr_2=(cnt_addr==3'd0)? 4'd0 : {X0[4'd6-cnt_addr],X1[4'd6-cnt_addr],X2[4'd6-cnt_addr],X3[4'd6-cnt_addr]};
assign  addr_3=(cnt_addr==3'd0)? 4'd0 : {X0[4'd9-cnt_addr],X1[4'd9-cnt_addr],X2[4'd9-cnt_addr],X3[4'd9-cnt_addr]};
assign  addr_4=(cnt_addr==3'd0)? 4'd0 : {X0[4'd12-cnt_addr],X1[4'd12-cnt_addr],X2[4'd12-cnt_addr],X3[4'd12-cnt_addr]};

ROM_12x16_z0	ROM_12x16_z0_inst_1
(
    .address(addr_1) ,
    .clock  ( sys_clk )   ,
    .q      ( Rom_dat_1)
);
ROM_12x16_z0	ROM_12x16_z0_inst_2
(
    .address(addr_2) ,
    .clock  ( sys_clk )   ,
    .q      ( Rom_dat_2)
);
ROM_12x16_z0	ROM_12x16_z0_inst_3
(
    .address(addr_3) ,
    .clock  ( sys_clk )   ,
    .q      ( Rom_dat_3)
);

ROM_12x16_z0	ROM_12x16_z0_inst_4
(
    .address(addr_4) ,
    .clock  ( sys_clk )   ,
    .q      ( Rom_dat_4)
);

assign  Rom_dat_4_temp= (max_flag==1'b1) ? {{10{Rom_dat_4[11]}},Rom_dat_4}:Rom_dat_4_temp;
//循环移位相加
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            DCT_dat_1<=22'd0;
            DCT_dat_2<=22'd0;
            DCT_dat_3<=22'd0;
            DCT_dat_4<=22'd0;
        end
    else if(DA_out_1==1'b1 || (cnt_addr==4'd0&&DA_out==1'b0))
        begin
            DCT_dat_1<=22'd0;
            DCT_dat_2<=22'd0;
            DCT_dat_3<=22'd0;
            DCT_dat_4<=22'd0;
        end
    else
        begin
            DCT_dat_1<=(DCT_dat_1<<1)+{{10{Rom_dat_1[11]}},Rom_dat_1};
            DCT_dat_2<=(DCT_dat_2<<1)+{{10{Rom_dat_2[11]}},Rom_dat_2};
            DCT_dat_3<=(DCT_dat_3<<1)+{{10{Rom_dat_3[11]}},Rom_dat_3};
            DCT_dat_4<=(DCT_dat_4<<1)+{{10{Rom_dat_4[11]}},Rom_dat_4};
        end
        
//输出数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DCT_data_o<=12'd0;
    else if(DA_out_1==1'b1)
        DCT_data_o<=((DCT_dat_4<<9)+(DCT_dat_3<<6)+(DCT_dat_2<<3)+DCT_dat_1-(Rom_dat_4_temp<<12))>>>10;
    else
        DCT_data_o<=12'd0;
        
endmodule