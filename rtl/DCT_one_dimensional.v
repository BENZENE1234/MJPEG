module DCT_one_dimensional
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire                    start           ,
    input   wire            [95:0]  DCT_data_in     ,
    
    output  wire    signed  [11:0]  DCT_data_o_z0   ,
    output  wire    signed  [11:0]  DCT_data_o_z1   ,
    output  wire    signed  [11:0]  DCT_data_o_z2   ,
    output  wire    signed  [11:0]  DCT_data_o_z3   ,
    output  wire    signed  [11:0]  DCT_data_o_z4   ,
    output  wire    signed  [11:0]  DCT_data_o_z5   ,
    output  wire    signed  [11:0]  DCT_data_o_z6   ,
    output  wire    signed  [11:0]  DCT_data_o_z7   ,
    output  wire                    data_en         
);

reg             [95:0]  DCT_data            ;

reg     signed  [11:0]  X0                  ;
reg     signed  [11:0]  X1                  ;
reg     signed  [11:0]  X2                  ;
reg     signed  [11:0]  X3                  ;
reg     signed  [11:0]  X4                  ;
reg     signed  [11:0]  X5                  ;
reg     signed  [11:0]  X6                  ;
reg     signed  [11:0]  X7                  ;

reg                     DA_start            ;

reg             [2:0]   start_cnt           ;

reg                     DCT_start           ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DCT_start<=1'b0;
    else if(start==1'b1)
        DCT_start<=1'b1;
    else
        DCT_start<=DCT_start;                        

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        start_cnt<=3'd0;
    else if(start_cnt==3'd7)
        start_cnt<=3'd0;
    else if(DA_start==1'b1)
        start_cnt<=3'd0;
    else if(DCT_start==1'b1)
        start_cnt<=start_cnt+1'b1;
    else
        start_cnt<=start_cnt;        

assign data_en=(DCT_data_o_z0 || DCT_data_o_z1 || DCT_data_o_z2 || DCT_data_o_z3 || DCT_data_o_z4 || DCT_data_o_z5 || DCT_data_o_z6 || DCT_data_o_z7 || (start_cnt==3'd7)) ? 1'b1 : 1'b0;
//输入数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DCT_data<=96'd0;
    else if(start==1'b1)
        DCT_data<=DCT_data_in;
    else
        DCT_data<=DCT_data;
        
//加减计算
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            X0<=12'd0;
            X1<=12'd0;
            X2<=12'd0;
            X3<=12'd0;
            X4<=12'd0;
            X5<=12'd0;
            X6<=12'd0;
            X7<=12'd0;
        end
    else
        begin
            X0<=DCT_data[11: 0]+DCT_data[95:84];
            X2<=DCT_data[23:12]+DCT_data[83:72];
            X4<=DCT_data[35:24]+DCT_data[71:60];
            X6<=DCT_data[47:36]+DCT_data[59:48];
            X1<=DCT_data[11: 0]-DCT_data[95:84];
            X3<=DCT_data[23:12]-DCT_data[83:72];
            X5<=DCT_data[35:24]-DCT_data[71:60];
            X7<=DCT_data[47:36]-DCT_data[59:48];
        end

//DA计算开始信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DA_start<=1'b0;
    else
        DA_start<=start;

DA_z0   DA_z0_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .X0              (X0        ),
    .X1              (X2        ),
    .X2              (X4        ),
    .X3              (X6        ),
    .DA_start        (DA_start  ),

    .DCT_data_o      (DCT_data_o_z0)
);

DA_z1   DA_z1_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .X0              (X1        ),
    .X1              (X3        ),
    .X2              (X5        ),
    .X3              (X7        ),
    .DA_start        (DA_start  ),

    .DCT_data_o      (DCT_data_o_z1)
);

DA_z2   DA_z2_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .X0              (X0        ),
    .X1              (X2        ),
    .X2              (X4        ),
    .X3              (X6        ),
    .DA_start        (DA_start  ),

    .DCT_data_o      (DCT_data_o_z2)
);

DA_z3   DA_z3_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .X0              (X1        ),
    .X1              (X3        ),
    .X2              (X5        ),
    .X3              (X7        ),
    .DA_start        (DA_start  ),

    .DCT_data_o      (DCT_data_o_z3)
);

DA_z4   DA_z4_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .X0              (X0        ),
    .X1              (X2        ),
    .X2              (X4        ),
    .X3              (X6        ),
    .DA_start        (DA_start  ),

    .DCT_data_o      (DCT_data_o_z4)
);

DA_z5   DA_z5_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .X0              (X1        ),
    .X1              (X3        ),
    .X2              (X5        ),
    .X3              (X7        ),
    .DA_start        (DA_start  ),

    .DCT_data_o      (DCT_data_o_z5)
);

DA_z6   DA_z6_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .X0              (X0        ),
    .X1              (X2        ),
    .X2              (X4        ),
    .X3              (X6        ),
    .DA_start        (DA_start  ),

    .DCT_data_o      (DCT_data_o_z6)
);

DA_z7   DA_z7_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .X0              (X1        ),
    .X1              (X3        ),
    .X2              (X5        ),
    .X3              (X7        ),
    .DA_start        (DA_start  ),

    .DCT_data_o      (DCT_data_o_z7)
);
endmodule