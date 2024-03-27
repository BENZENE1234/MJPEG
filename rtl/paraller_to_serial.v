module paraller_to_serial
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
    
    output  reg     signed  [11:0]  DCT_data        ,
    output  reg                     ZigZag_start    
    
);

reg     [2:0]   cnt     ;

reg     [95:0]  DCT_temp;

reg     start_temp      ;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        begin
            start_temp<=1'b0;
            ZigZag_start<=1'b0;
        end
    else if(data_en==1'b1)
            start_temp<=1'b1;
    else if(start_temp==1'b1)
        ZigZag_start<=1'b1;
    else
        begin
            start_temp<=1'b0;
            ZigZag_start<=ZigZag_start;
        end
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DCT_temp<=96'd0;
    else if(data_en==1'b1)
        DCT_temp<={DCT_data_o_z0,DCT_data_o_z1,DCT_data_o_z2,DCT_data_o_z3,DCT_data_o_z4,       DCT_data_o_z5,DCT_data_o_z6,DCT_data_o_z7};
    else 
        DCT_temp<=DCT_temp;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt<=3'd0;
    else if(data_en==1'b1 || cnt==3'd7)
        cnt<=3'd0;
    else 
        cnt<=cnt+1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        DCT_data<=12'd0;
    else
        case(cnt)
            3'd0:   DCT_data<=DCT_temp[95:84];
            3'd1:   DCT_data<=DCT_temp[83:72];
            3'd2:   DCT_data<=DCT_temp[71:60];
            3'd3:   DCT_data<=DCT_temp[59:48];
            3'd4:   DCT_data<=DCT_temp[47:36];
            3'd5:   DCT_data<=DCT_temp[35:24];
            3'd6:   DCT_data<=DCT_temp[23:12];
            3'd7:   DCT_data<=DCT_temp[11:0 ];
            default:DCT_data<=DCT_data     ;
        endcase

endmodule