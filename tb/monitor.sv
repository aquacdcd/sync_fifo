class monitor;

    virtual fifo_if vif;

    mailbox #(fifo_transaction) mbx;

    function new(virtual fifo_if vif,mailbox #(fifo_transaction) mbx);//this跟着的是class定义的，右值是括号里面的，也就是从外面得到的接口
        this.vif=vif;//这个接口为了能测到上升沿且使能时的data_in或data_out
        this.mbx=mbx;//这个mailbox是为了把检测到的数据发给scoreboard，比如这次写入的数据，在fifo里就是当上升沿时rp=wp-1且rp=1的时候看有没有相同，具体逻辑还不知道
    endfunction

    task main();
        bit vaild_read=0;
        fifo_transaction tr;//和前面generator driver很像，都是为了这个操作这个包裹写这句话

        forever begin
            @(vif.mon_cb)
                if(vif.mon_cb.wr_en&~vif.mon_cb.full)begin
                    tr=new();
                    tr.data=vif.mon_cb.data_in;
                    tr.wr_en=vif.mon_cb.wr_en;
                    tr.display("Monitor-write");
                    mbx.put(tr);
                end
                if(vaild_read)begin
                    tr=new();
                    tr.data=vif.mon_cb.data_out;
                    tr.rd_en=1;
                    tr.display("Monitor-read");
                    mbx.put(tr);
                end
                if(vif.mon_cb.rd_en&&~vif.mon_cb.empty)begin
                    vaild_read=1;
                end
                else begin
                    vaild_read=0;
                end
                
            end

    endtask
endclass