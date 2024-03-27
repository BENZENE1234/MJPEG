module DCT_two_dimensional
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

wire     signed [11:0]  DCT_data_z0     ;
wire     signed [11:0]  DCT_data_z1     ;
wire     signed [11:0]  DCT_data_z2     ;
wire     signed [11:0]  DCT_data_z3     ;
wire     signed [11:0]  DCT_data_z4     ;
wire     signed [11:0]  DCT_data_z5     ;
wire     signed [11:0]  DCT_data_z6     ;
wire     signed [11:0]  DCT_data_z7     ;
wire                    data_en_1       ;

wire           [95:0]   data_out        ;
wire                    rd_end          ;

reg            [95:0]   data_in         ;
reg                     start_1         ;

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
    .data_en         (data_en_1  )
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
    .data_en         (data_en_1    ),

    .data_out        (data_out     ),
    .rd_end          (rd_end       )
);

always@(posedge sys_clk or negedge sys_rst_n)   
    if(sys_rst_n==1'b0)
        data_in<=96'd0;
    else
        data_in<=data_out;

always@(posedge sys_clk or negedge sys_rst_n)   
    if(sys_rst_n==1'b0)
        start_1<=1'b0;
    else
        start_1<=rd_end;
        
DCT_one_dimensional     DCT_one_dimensional_inst_2
(
    .sys_clk         (sys_clk    ),
    .sys_rst_n       (sys_rst_n  ),
    .start           (start_1    ),
    .DCT_data_in     (data_in    ),

    .DCT_data_o_z0   (DCT_data_o_z0),
    .DCT_data_o_z1   (DCT_data_o_z1),
    .DCT_data_o_z2   (DCT_data_o_z2),
    .DCT_data_o_z3   (DCT_data_o_z3),
    .DCT_data_o_z4   (DCT_data_o_z4),
    .DCT_data_o_z5   (DCT_data_o_z5),
    .DCT_data_o_z6   (DCT_data_o_z6),
    .DCT_data_o_z7   (DCT_data_o_z7),
    .data_en         (data_en      )
);

endmodule