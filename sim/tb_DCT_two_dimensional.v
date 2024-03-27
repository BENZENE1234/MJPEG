`timescale 1ns/1ns
module tb_DCT_two_dimensional();

reg             sys_clk         ;
reg             sys_rst_n       ;
reg             start           ;
reg     [95:0]  DCT_data_in     ;

wire    signed [11:0]  DCT_data_o_z0     ;
wire    signed [11:0]  DCT_data_o_z1     ;
wire    signed [11:0]  DCT_data_o_z2     ;
wire    signed [11:0]  DCT_data_o_z3     ;
wire    signed [11:0]  DCT_data_o_z4     ;
wire    signed [11:0]  DCT_data_o_z5     ;
wire    signed [11:0]  DCT_data_o_z6     ;
wire    signed [11:0]  DCT_data_o_z7     ;
wire                   data_en           ;

wire    signed [11:0]   DCT_data         ;
wire                    ZigZag_start     ;

reg     [2:0]   cnt             ;
initial
    begin
        sys_clk=1'b1;
        start=1'b0;
        DCT_data_in=96'd0;
        sys_rst_n<=1'b0;
        #20
        sys_rst_n<=1'b1;
        #160
        DCT_data_in={12'd38,12'd43,12'd44,12'd45,12'd43,12'd39,12'd34,12'd35};
        #160
        DCT_data_in={12'd42,12'd43,12'd41,12'd43,12'd45,12'd43,12'd36,12'd34};
        #160
        DCT_data_in={12'd47,12'd46,12'd42,12'd43,12'd45,12'd42,12'd36,12'd35};
        #160
        DCT_data_in={12'd48,12'd50,12'd47,12'd45,12'd41,12'd36,12'd34,12'd38};
        #160
        DCT_data_in={12'd49,12'd50,12'd49,12'd45,12'd40,12'd34,12'd34,12'd41};
        #160
        DCT_data_in={12'd51,12'd47,12'd42,12'd41,12'd42,12'd39,12'd37,12'd40};
        #160
        DCT_data_in={12'd51,12'd45,12'd37,12'd38,12'd43,12'd42,12'd38,12'd40};
        #160
        DCT_data_in={12'd50,12'd45,12'd37,12'd38,12'd42,12'd40,12'd37,12'd40};

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
        start<=1'b0;
    else if(cnt==3'd6)
        start<=1'b1;
    else
        start<=1'b0;
        
DCT_two_dimensional DCT_two_dimensional_inst
(
    .sys_clk         (sys_clk      ),
    .sys_rst_n       (sys_rst_n    ),
    .start           (start        ),
    .DCT_data_in     (DCT_data_in  ),

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

paraller_to_serial  paraller_to_serial_inst
(
    .sys_clk         (sys_clk      ),
    .sys_rst_n       (sys_rst_n    ),
    .DCT_data_o_z0   (DCT_data_o_z0),
    .DCT_data_o_z1   (DCT_data_o_z1),
    .DCT_data_o_z2   (DCT_data_o_z2),
    .DCT_data_o_z3   (DCT_data_o_z3),
    .DCT_data_o_z4   (DCT_data_o_z4),
    .DCT_data_o_z5   (DCT_data_o_z5),
    .DCT_data_o_z6   (DCT_data_o_z6),
    .DCT_data_o_z7   (DCT_data_o_z7),
    .data_en         (data_en      ),
                      
    .DCT_data        (DCT_data     ),
    .ZigZag_start    (ZigZag_start )
    
);

endmodule