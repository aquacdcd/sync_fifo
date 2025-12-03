`timescale 1ns/1ps

module top_module();
    reg clk;
    reg areset_n;
    reg [7:0]data_in;
    reg wr_en;
    reg rd_en;
    wire [7:0]data_out;
    wire full;
    wire empty;

sync_fifo my_fifo(
    .clk(clk),
    .areset_n(areset_n),
    .data_in(data_in),
    .data_out(data_out),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .full(full),
    .empty(empty));

initial begin
   clk =0;
   forever #5 clk=~clk;
end
initial begin
    areset_n=1;
    data_in=0;
    wr_en=0;
    rd_en=0;
    #10 areset_n=0;//复位
    #10 areset_n=1;//

    repeat(16)begin//循环16次，写满fifo
        @(negedge clk);
        wr_en=1;
        data_in=data_in+1;
    end
    //--溢出测试--
    @(negedge clk);
    wr_en=1;
    data_in=8'hff;//mem不变

    @(negedge clk);
    wr_en=0;
    rd_en=1;
    data_in=0;
    //--停止写，读测试--
    repeat(16)begin
    @(negedge clk);
    end
    //--读空测试--
    @(negedge clk);
    rd_en=1;//data_out不变

    #100
    $finish;
    end

    initial begin
        $monitor("Time=%t | wr=%b data_in=%d | rd=%b data_out=%d | full=%b empty=%b",
        $time,wr_en,data_in,rd_en,data_out,full,empty);
    end

    initial begin
    $fsdbDumpfile("fifo.fsdb");  // 指定生成的波形文件名，叫什么都行
    $fsdbDumpvars(0, top_module); // 0 表示抓取 top_module 下的所有层级信号
end

endmodule