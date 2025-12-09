class scoreboard;

    int err_count=0;
    bit [7:0]scb_fifo[$];//定义一个队列作为参考模型
    mailbox #(fifo_transaction) mbx;

    function new(mailbox #(fifo_transaction) mbx);
        this.mbx=mbx;
    endfunction
    task main();
    fifo_transaction tr;
    bit [7:0] expected_data;

    forever begin
        mbx.get(tr);//阻塞任务,有包才执行，没包就等包，软件顺序执行，所以都卡在这等包
        //tr=new();
        if(tr.wr_en)begin //我的设计的fifo不会在full的时候写，不用加&!full吧？
            if(scb_fifo.size()==16)$fatal("[Scoreboard] Fatal: DUT write data but Ref Model is full!");
            else begin
            scb_fifo.push_back(tr.data);
            $display("[Scoreboard] Store Data:%h",tr.data);
            end
        end 
        if(tr.rd_en)begin
            if(scb_fifo.size()==0)begin
                $fatal("[Scoreboard] Fatal: DUT read data but Ref Model is empty!");
            end
            else begin
                expected_data=scb_fifo.pop_front();
                if(expected_data==tr.data)begin
                    $display("[Scoreboard] Check PASS: %h",tr.data);
                end
                else begin
                    $display("[Scoreboard] Check FAIL: Expected:%h,Got:%h",expected_data,tr.data);
                    err_count++;
                end
            end
        end
        end
    endtask

    function void report();
        $display("--------------------------------------");
        $display("       [SCOREBOARD REPORT]            ");
        $display("--------------------------------------");
        if (err_count == 0) begin
            $display("        ALL CHECKS PASSED! ✅        ");
        end else begin
            $display("        TEST FAILED! ❌              ");
            $display("        Total Errors: %0d            ", err_count);
        end
        $display("--------------------------------------");
    endfunction

endclass