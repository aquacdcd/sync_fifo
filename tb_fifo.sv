interface fifo_if(input logic clk, input logic rst_n);
    logic wr_en;
    logic rd_en;
    logic [7:0]data_in;
    logic [7:0]data_out;
    logic full;
    logic empty;
    
    modport TEST(
        output wr_en,rd_en,data_in,
        input full,empty,data_out,
        input clk,rst_n
    );
endinterface//定义了一个接口，然后写了一个TEST的安全卫士

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

//--另一端即将用test来驱动--
/*program automatic test(fifo_if intf);

    initial begin
        intf.wr_en=0;
        intf.rd_en=0;
        intf.data_in=0;//这里不知道给data_in初始为0，主要感觉没啥必要
        @(posedge intf.rst_n)
        intf.wr_en=1;
        intf.data_in=8'hfa;
        @(posedge intf.clk)
        intf.wr_en=1;
        intf.data_in=8'hff;
        @(posedge intf.clk)
        intf.wr_en=0;
        intf.rd_en=1;
        @(posedge intf.clk)
        intf.rd_en=1;
        #10
        $display("Test Done!")
        
    end

endprogram */

class fifo_transaction;
    rand bit[7:0]data;//命名成data会更好吗？
    rand bit wr_en;
    rand bit rd_en;

    constraint valid_ctrl{
        wr_en+rd_en<=1;
        wr_en dist{1:=80,0:=20};
        rd_en dist{1:=10,0:=90};
    }

    function void display(string name);
        $display("Time =%t [%s] wr=%b rd=%b data=%h",$time,name,wr_en,rd_en,data);
    endfunction

endclass

class generator;//实例化(声明句柄 然后new)->随机化（randomize()）->发送(mailbox)
    mailbox #(fifo_transaction) mbx;

    fifo_transaction tr;//声明句柄
    
    function new(mailbox #(fifo_transaction) mbx);
        this.mbx=mbx;
    endfunction

    task main();
        repeat(10) begin
            tr=new();//每次都为这个句柄new一个内存空间，上一个内存空间就没有句柄指向了，就被释放了
            //但后面还有mbx.put(tr);在这里每次生成的句柄
            if(!tr.randomize)$fatal("随机失败");
            tr.display("Generator");
            mbx.put(tr);
        end
    endtask
endclass

class driver;

    mailbox #(fifo_transaction) mbx;
    virtual fifo_if vif;

    function new(mailbox #(fifo_transaction) mbx,virtual fifo_if vif);
        this.mbx=mbx;
        this.vif=vif;
    endfunction

    task main();
        fifo_transaction tr;
        vif.wr_en=0;
        vif.rd_en=0;
        vif.data_in=0;
        @(posedge vif.rst_n);
        forever begin
            mbx.get(tr);
            tr.display("Driver");

            @(posedge vif.clk);
            vif.wr_en<=tr.wr_en;
            vif.rd_en<=tr.rd_en;
            vif.data_in<=tr.data;
            @(posedge vif.clk);
            vif.wr_en<=0;
            vif.rd_en<=0;
            
        end

    endtask
endclass

class environment;
    generator gen;
    driver drv;
    mailbox #(fifo_transaction) mbx;

    virtual fifo_if vif;

    function new(virtual fifo_if vif);
        this.vif=vif;
        mbx =new();
        drv=new(mbx,vif);
        gen=new(mbx);
    endfunction

    task main();
    fork
        begin
        gen.main();
        end
        begin
        drv.main();
        end
    join_any
    wait(mbx.num()==0);
    #20
    $finish;
    endtask
endclass

program automatic test(fifo_if intf);
    environment env;
    initial begin
        env=new(intf);
        env.main();
    end
endprogram

