module tb_top;
    logic clk;
    logic rst_n;

    initial begin
        clk=0;
        forever #5 clk=~clk;

    end

    initial begin
        rst_n=1;
        #10 rst_n=0;
        #10 rst_n=1;
    end

    fifo_if intf(clk,rst_n);//例化了一个叫做intf的fifo_if（接口）
    sync_fifo dut(
        .clk(clk),
        .areset_n(rst_n),
        .data_in(intf.data_in),
        .wr_en(intf.wr_en),
        .rd_en(intf.rd_en),
        .data_out(intf.data_out),
        .full(intf.full),
        .empty(intf.empty)
    );//把接口的线的一端连上dut

    test t1(intf);

    initial begin
    $fsdbDumpfile("fifo.fsdb");  // 指定生成的波形文件名，叫什么都行
    $fsdbDumpvars(0, tb_top); // 0 表示抓取 top_module 下的所有层级信号
end
endmodule