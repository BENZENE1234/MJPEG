module rgb565_to_ycbcr422
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire    [15:0]          rgb_data        ,
    
    output  reg     signed  [7:0]   img_out         ,
    output  reg     [1:0]           state           ,
    output  reg                     start_en        
);

reg             start_1             ;
reg             start               ;

reg     [1:0]   cnt_state           ;

wire    [7:0]   R0_8b               ;
wire    [7:0]   G0_8b               ;
wire    [7:0]   B0_8b               ;

reg     signed  [15:0]  RGB_mul[8:0]        ;
reg     signed  [15:0]  YCrCb_16b[2:0]      ;
reg     signed  [15:0]  Cb_delay            ;

//RGB565 转 RGB888
assign R0_8b = {rgb_data[15:11],rgb_data[13:11]}; //R8
assign G0_8b = {rgb_data[10: 5],rgb_data[ 6: 5]}; //G8
assign B0_8b = {rgb_data[ 4: 0],rgb_data[ 2: 0]}; //B8

//乘法运算
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            RGB_mul[0]<=16'd0;
            RGB_mul[1]<=16'd0;
            RGB_mul[2]<=16'd0;
            RGB_mul[3]<=16'd0;
            RGB_mul[4]<=16'd0;
            RGB_mul[5]<=16'd0;
            RGB_mul[6]<=16'd0;
            RGB_mul[7]<=16'd0;
            RGB_mul[8]<=16'd0;
        end
    else
        begin
            RGB_mul[0]<=16'd77 * R0_8b;
            RGB_mul[1]<=16'd150* G0_8b;
            RGB_mul[2]<=16'd29 * B0_8b;
            RGB_mul[3]<=16'd43 * R0_8b;
            RGB_mul[4]<=16'd85 * G0_8b;
            RGB_mul[5]<=16'd128* B0_8b;
            RGB_mul[6]<=16'd128* R0_8b;
            RGB_mul[7]<=16'd107* G0_8b;
            RGB_mul[8]<=16'd21 * B0_8b;
        end
        
//加减运算
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            YCrCb_16b[0]<=16'd0;
            YCrCb_16b[1]<=16'd0;
            YCrCb_16b[2]<=16'd0;
        end
    else
        begin
            YCrCb_16b[0]<=RGB_mul[0]+RGB_mul[1]+RGB_mul[2]-16'd32768;//Y
            YCrCb_16b[1]<=RGB_mul[5]-RGB_mul[3]-RGB_mul[4];//CR
            YCrCb_16b[2]<=RGB_mul[6]-RGB_mul[7]-RGB_mul[8];//CB
        end

//Cb打一拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        Cb_delay<=16'd0;
    else
        Cb_delay<=YCrCb_16b[2];

//发送422采样数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        img_out<=8'd0;
    else if(cnt_state==2'd0 && start_1==1'b1)
        img_out<=YCrCb_16b[0][15:8];
    else if(cnt_state==2'd1 && start_1==1'b1)
        img_out<=YCrCb_16b[1][15:8];
    else if(cnt_state==2'd2 && start_1==1'b1)
        img_out<=Cb_delay[15:8];
    else if(cnt_state==2'd3 && start_1==1'b1)
        img_out<=YCrCb_16b[0][15:8];
    else
        img_out<=img_out;

//cnt_state开始计数打拍
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            start<=1'b0;
            start_1<=1'b0;
            start_en<=1'b0;
        end
    else
        begin
            start<=1'b1;
            start_1<=start;
            start_en<=start_1;
        end
        
//cnt_state
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt_state<=2'd0;
    else if(cnt_state==2'd3)
        cnt_state<=2'd0;
    else if(start_1==1'b1)
        cnt_state<=cnt_state+1'b1;
    else
        cnt_state<=cnt_state;

//输出state
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        state<=2'd0;
    else
        state<=cnt_state;
        
endmodule