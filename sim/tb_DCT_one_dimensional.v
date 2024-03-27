`timescale 1ns/1ns
module tb_DCT_one_dimensional();

reg             sys_clk         ;
reg             sys_rst_n       ;
reg             start           ;
reg     [95:0]  DCT_data_in     ;

wire    signed [11:0]  DCT_data_z0     ;
wire    signed [11:0]  DCT_data_z1     ;
wire    signed [11:0]  DCT_data_z2     ;
wire    signed [11:0]  DCT_data_z3     ;
wire    signed [11:0]  DCT_data_z4     ;
wire    signed [11:0]  DCT_data_z5     ;
wire    signed [11:0]  DCT_data_z6     ;
wire    signed [11:0]  DCT_data_z7     ;
wire                    data_en        ;

wire    signed [11:0]  DCT_data_z0_     ;
wire    signed [11:0]  DCT_data_z1_     ;
wire    signed [11:0]  DCT_data_z2_     ;
wire    signed [11:0]  DCT_data_z3_     ;
wire    signed [11:0]  DCT_data_z4_     ;
wire    signed [11:0]  DCT_data_z5_     ;
wire    signed [11:0]  DCT_data_z6_     ;
wire    signed [11:0]  DCT_data_z7_     ;

wire                    data_en_        ;

wire    [95:0]  data_out;
wire            rd_end  ;

reg     [2:0]   cnt             ;
initial
    begin
        sys_clk=1'b1;
        start=1'b0;
        DCT_data_in=64'd0;
        sys_rst_n<=1'b0;
        #20
        sys_rst_n<=1'b1;
        DCT_data_in={8'd38,8'd42,8'd47,8'd48,8'd49,8'd51,8'd51,8'd50};
    end
    
always #10 sys_clk=~sys_clk;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt<=3'd0;
    else if(cnt==3'd7)
        cnt<=3'd0;
    else
        cnt<=cnt+1'b1;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        start<=1'b1;
    else if(cnt==3'd6)
        start<=1'b1;
    else
        start<=1'b0;
        
DCT_one_dimensional     DCT_one_dimensional_inst_1
(
    .sys_clk         (sys_clk    ),
    .sys_rst_n       (sys_rst_n  ),
    .start           (start      ),
    .DCT_data_in     (DCT_data_in),

    .DCT_data_o_z0   (DCT_data_z0),
    .DCT_data_o_z1   (DCT_data_z1),
    .DCT_data_o_z2   (DCT_data_z2),
    .DCT_data_o_z3   (DCT_data_z3),
    .DCT_data_o_z4   (DCT_data_z4),
    .DCT_data_o_z5   (DCT_data_z5),
    .DCT_data_o_z6   (DCT_data_z6),
    .DCT_data_o_z7   (DCT_data_z7),
    .data_en         (data_en    )
);

DCT_pingpang_T      DCT_pingpang_T_inst
(
    .sys_clk         (sys_clk      ),
    .sys_rst_n       (sys_rst_n    ),
    .DCT_data_o_z0   (DCT_data_z0  ),
    .DCT_data_o_z1   (DCT_data_z1  ),
    .DCT_data_o_z2   (DCT_data_z2  ),
    .DCT_data_o_z3   (DCT_data_z3  ),
    .DCT_data_o_z4   (DCT_data_z4  ),
    .DCT_data_o_z5   (DCT_data_z5  ),
    .DCT_data_o_z6   (DCT_data_z6  ),
    .DCT_data_o_z7   (DCT_data_z7  ),
    .data_en         (data_en      ),

    .data_out        (data_out     ),
    .rd_end          (rd_end       )
);

DCT_one_dimensional     DCT_one_dimensional_inst_2
(
    .sys_clk         (sys_clk    ),
    .sys_rst_n       (sys_rst_n  ),
    .start           (rd_end     ),
    .DCT_data_in     (data_out   ),

    .DCT_data_o_z0   (DCT_data_z0_),
    .DCT_data_o_z1   (DCT_data_z1_),
    .DCT_data_o_z2   (DCT_data_z2_),
    .DCT_data_o_z3   (DCT_data_z3_),
    .DCT_data_o_z4   (DCT_data_z4_),
    .DCT_data_o_z5   (DCT_data_z5_),
    .DCT_data_o_z6   (DCT_data_z6_),
    .DCT_data_o_z7   (DCT_data_z7_),
    .data_en         (data_en_    )
);

endmodule