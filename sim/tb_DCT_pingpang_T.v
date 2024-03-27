`timescale 1ns/1ns
module tb_DCT_pingpang_T();

reg                     sys_clk         ;
reg                     sys_rst_n       ;
reg     signed  [11:0]  DCT_data_o_z0   ;
reg     signed  [11:0]  DCT_data_o_z1   ;
reg     signed  [11:0]  DCT_data_o_z2   ;
reg     signed  [11:0]  DCT_data_o_z3   ;
reg     signed  [11:0]  DCT_data_o_z4   ;
reg     signed  [11:0]  DCT_data_o_z5   ;
reg     signed  [11:0]  DCT_data_o_z6   ;
reg     signed  [11:0]  DCT_data_o_z7   ;

wire            [95:0]  data_out        ;
wire                    rd_end          ;

initial
    begin
        sys_clk=1'b1;
        sys_rst_n=1'b0;
        #20
        sys_rst_n=1'b1;
        DCT_data_o_z0<=12'd0;
        DCT_data_o_z1<=12'd1;
        DCT_data_o_z2<=12'd2;
        DCT_data_o_z3<=12'd3;
        DCT_data_o_z4<=12'd4;
        DCT_data_o_z5<=12'd5;
        DCT_data_o_z6<=12'd6;
        DCT_data_o_z7<=12'd7;
        #160
        DCT_data_o_z0<=12'd8;
        DCT_data_o_z1<=12'd9;
        DCT_data_o_z2<=12'd10;
        DCT_data_o_z3<=12'd11;
        DCT_data_o_z4<=12'd12;
        DCT_data_o_z5<=12'd13;
        DCT_data_o_z6<=12'd14;
        DCT_data_o_z7<=12'd15;
        #160
        DCT_data_o_z0<=12'd16;
        DCT_data_o_z1<=12'd17;
        DCT_data_o_z2<=12'd18;
        DCT_data_o_z3<=12'd19;
        DCT_data_o_z4<=12'd20;
        DCT_data_o_z5<=12'd21;
        DCT_data_o_z6<=12'd22;
        DCT_data_o_z7<=12'd23;
        #160
        DCT_data_o_z0<=12'd24;
        DCT_data_o_z1<=12'd25;
        DCT_data_o_z2<=12'd26;
        DCT_data_o_z3<=12'd27;
        DCT_data_o_z4<=12'd28;
        DCT_data_o_z5<=12'd29;
        DCT_data_o_z6<=12'd30;
        DCT_data_o_z7<=12'd31;
        #160
        DCT_data_o_z0<=12'd32;
        DCT_data_o_z1<=12'd33;
        DCT_data_o_z2<=12'd34;
        DCT_data_o_z3<=12'd35;
        DCT_data_o_z4<=12'd36;
        DCT_data_o_z5<=12'd37;
        DCT_data_o_z6<=12'd38;
        DCT_data_o_z7<=12'd39;
        #160
        DCT_data_o_z0<=12'd40;
        DCT_data_o_z1<=12'd41;
        DCT_data_o_z2<=12'd42;
        DCT_data_o_z3<=12'd43;
        DCT_data_o_z4<=12'd44;
        DCT_data_o_z5<=12'd45;
        DCT_data_o_z6<=12'd46;
        DCT_data_o_z7<=12'd47;
        #160
        DCT_data_o_z0<=12'd48;
        DCT_data_o_z1<=12'd49;
        DCT_data_o_z2<=12'd50;
        DCT_data_o_z3<=12'd51;
        DCT_data_o_z4<=12'd52;
        DCT_data_o_z5<=12'd53;
        DCT_data_o_z6<=12'd54;
        DCT_data_o_z7<=12'd55;
        #160
        DCT_data_o_z0<=12'd56;
        DCT_data_o_z1<=12'd57;
        DCT_data_o_z2<=12'd58;
        DCT_data_o_z3<=12'd59;
        DCT_data_o_z4<=12'd60;
        DCT_data_o_z5<=12'd61;
        DCT_data_o_z6<=12'd62;
        DCT_data_o_z7<=12'd63;

    end

always #10 sys_clk=~sys_clk;

DCT_pingpang_T      DCT_pingpang_T_inst
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
    .data_en         (1'b1         ),

    .data_out        (data_out     ),
    .rd_end          (rd_end       )
);

endmodule