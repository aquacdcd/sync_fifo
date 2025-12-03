module sync_fifo(
    input[7:0]data_in,
    input clk,
    input areset_n,
    input wr_en,
    input rd_en,
    output reg [7:0]data_out,
    output full,
    output empty
);
    reg[4:0]wp,rp;
    reg[7:0]mem[15:0];

    always@(posedge clk,negedge areset_n)begin
        if(areset_n==0)begin
            wp<=0;
            rp<=0;
            data_out<=0;
        end
        else begin
           if(wr_en&&!full)begin
            mem[wp[3:0]]<=data_in;
            wp<=wp+1;
           end 

           if(rd_en&&!empty)begin
            data_out<=mem[rp[3:0]];
            rp<=rp+1;
           end
        end
    end
    assign empty=(wp==rp);
    assign full=(wp[4]!=rp[4]&&(wp[3:0]==rp[3:0]));
endmodule