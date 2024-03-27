module serial_to_paraller
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire    signed  [7:0]   img_out         ,
    input   wire                    rd_end          ,
    
    output  reg                     change_end      ,
    output  reg             [95:0]  Dct_data_in
);

reg     [2:0]   cnt     ;
reg     [7:0]   img_reg ;

//同步至上升沿
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        img_reg<=8'd0;
    else
        img_reg<=img_out;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        cnt<=3'd0;
    else if(rd_end==1'b1 || cnt==3'd7)
        cnt<=3'd0;
    else
        cnt<=cnt+1'b1;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        change_end<=1'b0;
    else if(rd_end==1'b0)
        change_end<=1'b0;
    else if(cnt==3'd7)
        change_end<=1'b1;
    else
        change_end<=change_end;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        Dct_data_in<=95'd0;
    else
        case(cnt)
            3'd0:   Dct_data_in[11:0 ]<={{4{img_reg[7]}},img_reg};
            3'd1:   Dct_data_in[23:12]<={{4{img_reg[7]}},img_reg};
            3'd2:   Dct_data_in[35:24]<={{4{img_reg[7]}},img_reg};
            3'd3:   Dct_data_in[47:36]<={{4{img_reg[7]}},img_reg};
            3'd4:   Dct_data_in[59:48]<={{4{img_reg[7]}},img_reg};
            3'd5:   Dct_data_in[71:60]<={{4{img_reg[7]}},img_reg};
            3'd6:   Dct_data_in[83:72]<={{4{img_reg[7]}},img_reg};
            3'd7:   Dct_data_in[95:84]<={{4{img_reg[7]}},img_reg};
            default:Dct_data_in<=Dct_data_in;
        endcase





endmodule