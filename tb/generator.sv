class generator;//实例化(声明句柄 然后new)->随机化（randomize()）->发送(mailbox)
    mailbox #(fifo_transaction) mbx;

    fifo_transaction tr;//声明句柄
    
    function new(mailbox #(fifo_transaction) mbx);
        this.mbx=mbx;
    endfunction

    task main();
        repeat(100) begin
            tr=new();//每次都为这个句柄new一个内存空间，上一个内存空间就没有句柄指向了，就被释放了
            //但后面还有mbx.put(tr);在这里每次生成的句柄
            if(!tr.randomize)$fatal("随机失败");
            tr.display("Generator");
            mbx.put(tr);
        end
    endtask
endclass