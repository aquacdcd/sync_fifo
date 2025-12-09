class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(fifo_transaction) gen2drv_mbx;
    mailbox #(fifo_transaction) mon2scb_mbx;

    virtual fifo_if vif;

    function new(virtual fifo_if vif);
        this.vif=vif;
        gen2drv_mbx =new();
        drv=new(gen2drv_mbx,vif);
        gen=new(gen2drv_mbx);
        mon2scb_mbx=new();
        mon=new(vif,mon2scb_mbx);
        scb=new(mon2scb_mbx);
    endfunction

    task main();
    fork
        gen.main();
        
        drv.main();
        
        mon.main();
       
        scb.main();
        
    join_any
    wait(gen2drv_mbx.num()==0);
    #20
    scb.report();
    $finish;
    endtask
endclass